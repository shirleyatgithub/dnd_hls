#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "dnd_create_mlp_activation.hpp"
#include "mlp/myproject.h"

#define SPIKE_COUNT 100
// Events captured from the DVS.
const char * input_events_file_path = "/home/arios/Projects/dvs_denoising/dnd_hls_repo/src/tb/data/v2e-dvs-events.txt";
// Output file where the MLP activations will be stored.
const char * hw_activation_file_path = "/home/arios/Projects/dvs_denoising/dnd_hls_repo/src/tb/data/HW_activations.txt";
// File that contains the MLP activation generated by the software. This file will be used to validate the HW activation generated by this HW module
const char * soft_activation_file_path = "/home/arios/Projects/dvs_denoising/dnd_hls_repo/src/tb/data/SOFT_activations.txt";

int main() {

	printf("Starting the test to read the Temporal Image and create the activations for the MLP \n");
	char cwd[1024];
	getcwd(cwd, sizeof(cwd));
	printf("Current working dir: %s\n", cwd);

	printf("Create the Timestamp Image (TI)\n");
	timestamp_polarity_image_data_t timestamp_image[DVS_WIDTH * DVS_HEIGHT];
//	timestamp_polarity_image_data_t timestamp_image[DVS_WIDTH][DVS_HEIGHT/COMBINED_SPIKES]; // DIFFERENT MEMORY INTERFACE.

	printf("Open the input txt spikes file and create the output activation file.\n");
	FILE *spike_f = fopen(input_events_file_path, "rb");
	// Avoid comment lines
	char line[LINE_MAX];
	std::fgets(line, LINE_MAX, spike_f);
	while (line[0] == '#') {
		std::fgets(line, LINE_MAX, spike_f);
	}

	// Create the output file where HW activation will be written per line
	FILE *activation_f = fopen(hw_activation_file_path, "wb");
	// Write header information
	//fprintf(activation_f, "#Each row means the MLP activations: [age_p0, age_p1, ..., age_pn, pol_p0, pol_p1, ..., age_pn]\n");

	printf("Loop in the input events file and send the spikes (one-by-one) to the dnd_create_mlp_activation module.\n");
	caviar_data_t caviar_data;
	timestamp_t current_time;
	mlp_input_activation_t mlp_activations[MLP_INPUT_NEURONS];
	char *token;
	const char delimiter[2] = " ";
	unsigned short size_in;
	unsigned short size_out;
	result_t mlp_out[N_LAYER_6];
	for (int s_id = 0; s_id < SPIKE_COUNT; s_id++) {
		// Get timestamp
		token = strtok(line, delimiter);
		uint ts = (uint) (std::stof(token) * 1000);  // Convert to ms
		current_time = ts;
		// Get spike address+polarity
		token = std::strtok(NULL, delimiter);
		uint16_t x = std::stoi(token);
		token = std::strtok(NULL, delimiter);
		uint16_t y = std::stoi(token);
		token = std::strtok(NULL, delimiter);
		uint16_t pol = std::stoi(token);
		caviar_data = 0x00000000 | (y << CAVIAR_X_Y_BITS + 1);
		caviar_data = caviar_data | (x << 1);
		caviar_data += pol;
		printf("Spike #%u --> Ts: %u, X_col: %u, Y_row: %u, Pol: %u. Caviar spike: %u\n",
				s_id, current_time.to_uint(), x, y, pol, caviar_data.to_uint());

		dnd_create_mlp_activation(caviar_data, timestamp_image, current_time, mlp_activations);

		myproject(mlp_activations, mlp_out, size_in, size_out);

		printf("Processed\n");

		// Write the activation into the output file
		for (int idx = 0; idx < MLP_INPUT_NEURONS; idx++) {
			if(mlp_activations[idx].to_float() == 0.0 || mlp_activations[idx].to_float() == 1.0 || mlp_activations[idx].to_float() == -1.0){
				fprintf(activation_f, "%.1f ", mlp_activations[idx].to_float());
			}else{
				fprintf(activation_f, "%f ", mlp_activations[idx].to_float());
			}
		}
		fprintf(activation_f, "%d", mlp_out[0].to_int());
		fprintf(activation_f, "\n");

		// Get next spike
		if (std::fgets(line, LINE_MAX, spike_f) == NULL) {
			break;
		}
	}

	fclose(activation_f);
	fclose(spike_f);

	printf("Comparing the results getting from the HW module with the soft jAER output...\n");
	FILE *hw_activation_f = fopen(hw_activation_file_path, "rb");
	FILE *soft_activation_f = fopen(soft_activation_file_path, "rb");

	// Avoid comment lines
	char line_hw[LINE_MAX], line_soft[LINE_MAX];
	char *line_hw_ret, *line_soft_ret;
	std::fgets(line_hw, LINE_MAX, hw_activation_f);
	std::fgets(line_soft, LINE_MAX, soft_activation_f);
	while (line_hw[0] == '#') {
		std::fgets(line_hw, LINE_MAX, hw_activation_f);
	}
	while (line_soft[0] == '#') {
		std::fgets(line_soft, LINE_MAX, soft_activation_f);
	}
	line_hw_ret = line_hw;
	line_soft_ret = line_soft;

	char *token_hw, *token_soft;
	//const char delimiter_hw[2] = " ", delimiter_soft[2] = " ";
	float activation_hw, activation_soft;
	int error_count = 0;
	for (int s_id = 0; s_id < SPIKE_COUNT; s_id++) {
		for (int a_idx = 0; a_idx < MLP_INPUT_NEURONS; a_idx++) {
			// Get next activation value from both files
			token_hw = strtok_r(line_hw_ret, " ", &line_hw_ret);
			token_soft = strtok_r(line_soft_ret, " ", &line_soft_ret);
			activation_hw = std::stof(token_hw);
			activation_soft = std::stof(token_soft);
			if (activation_hw != activation_soft) {
				error_count++;
				printf("ERROR!! Spike #%d: Activations #%d don't match: HW %f - SOFT %f\n",
						s_id, a_idx, activation_hw, activation_soft);
			}
		}

		// Get next spike
		if (std::fgets(line_hw, LINE_MAX, hw_activation_f) == NULL
				|| std::fgets(line_soft, LINE_MAX, soft_activation_f) == NULL) {
			break;
		}
		line_hw_ret = line_hw;
		line_soft_ret = line_soft;
	}

	if (error_count == 0) {
		printf("Test passed successfully!!");
	} else {
		printf("Test doesn't pass. There are %d errors!", error_count);
	}
	return error_count;
}
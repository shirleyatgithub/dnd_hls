`timescale 1ns/1ps

module mlp #(
  parameter   N1 = 98,
              N2 = 10,
              W_X = 4,
              W_K = 4,
              W_Y = 16
)(
  input  logic clk,
  input  logic [N1/2-1:0][W_X-1:0] in_mag,
  input  logic [N1/2-1:0]          in_pol,
  output logic [W_Y -1:0]          out
);

  localparam  W_SUM_FC1     = W_X + W_K + $clog2(N1/2),
              W_SUM_FC1_POL = 1 + W_K + $clog2(N1/2),
              W_SUM_FC2     = W_X + W_K + $clog2(N2);

  // Weights initialized from luts generated by python
  logic [N1/2:0][N2-1:0][W_K-1:0] weights_n1_mag; 
  logic [N1/2:0][N2-1:0][W_K-1:0] weights_n1_pol;
  logic           [N2:0][W_K-1:0] weights_n2;
  logic       [2**W_X-1:0][W_Y-1:0] tanh;
  luts LUTS (.*);

  logic [N2-1:0][W_SUM_FC1_POL-1:0] fc1_out_pol;
  logic [N2-1:0][W_SUM_FC1-1:0] fc1_out_mag, fc1_out;

  matvec_mul #(.R(N2), .C(N1/2+1), .W_X(W_X), .W_K(W_K)
  ) FC1_MAG (  
    .clk(clk), .cen(1'b1), 
    .k(weights_n1_mag),
    .x({W_X'(1), in_mag}),
    .y(fc1_out_mag)
  );
  
  matvec_mul #(
    .R(N2), .C(N1/2+1), .W_X(1), .W_K(W_K)
  ) FC1_POL (  
    .clk(clk), 
    .cen(1'b1), 
    .k(weights_n1_pol),
    .x({1'b1, in_pol}),
    .y(fc1_out_pol)
  );

  logic [N2-1:0][W_X-1:0] fc2_in;

  genvar n2;
  for (n2=0; n2<N2; n2++) begin
    always_ff @(posedge clk)
      fc1_out[n2] <= $signed(fc1_out_pol[n2]) + $signed(fc1_out_mag[n2]);

    assign fc2_in[n2] = fc1_out[n2][N2-1:0];
  end

  logic [W_SUM_FC2-1:0] fc2_out;
  
  matvec_mul #(
    .R(1), .C(N2+1), .W_X(W_X), .W_K(W_K)
  ) FC2_MAG (  
    .clk(clk), 
    .cen(1'b1), 
    .k(weights_n2),
    .x({W_X'(1), fc2_in}),
    .y(fc2_out)
  );

  assign out = tanh[W_X'(fc2_out)];


endmodule


/*

reset_run synth_1
launch_runs synth_1 -jobs 10

open_run synth_1 -name synth_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 500 -input_pins -routable_nets -name timing_1
report_utilization -name utilization_1

*/
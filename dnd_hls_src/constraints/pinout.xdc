set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {caviar_data_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {wsaer_data_0[0]}]
set_property PACKAGE_PIN AF15 [get_ports wsaer_req_n_0]
set_property PACKAGE_PIN AG15 [get_ports wsaer_ack_n_0]
set_property PACKAGE_PIN T29 [get_ports {caviar_data_0[0]}]
set_property PACKAGE_PIN W29 [get_ports {caviar_data_0[1]}]
set_property PACKAGE_PIN U25 [get_ports {caviar_data_0[2]}]
set_property PACKAGE_PIN AB30 [get_ports {caviar_data_0[4]}]
set_property PACKAGE_PIN AC27 [get_ports {caviar_data_0[5]}]
set_property PACKAGE_PIN AG30 [get_ports {caviar_data_0[6]}]
set_property PACKAGE_PIN AC28 [get_ports {caviar_data_0[7]}]
set_property PACKAGE_PIN AD29 [get_ports {caviar_data_0[8]}]
set_property PACKAGE_PIN AF28 [get_ports {caviar_data_0[9]}]
set_property PACKAGE_PIN AF27 [get_ports {caviar_data_0[10]}]
set_property PACKAGE_PIN AE26 [get_ports {caviar_data_0[11]}]
set_property PACKAGE_PIN V28 [get_ports {caviar_data_0[3]}]
set_property PACKAGE_PIN V29 [get_ports {caviar_data_0[12]}]
set_property PACKAGE_PIN V26 [get_ports {caviar_data_0[13]}]
set_property PACKAGE_PIN W30 [get_ports {caviar_data_0[14]}]
set_property PACKAGE_PIN U29 [get_ports {caviar_data_0[15]}]
set_property PACKAGE_PIN P28 [get_ports {caviar_data_0[16]}]
set_property PACKAGE_PIN N26 [get_ports {caviar_data_0[17]}]
set_property PACKAGE_PIN N27 [get_ports {caviar_data_0[18]}]
set_property PACKAGE_PIN U30 [get_ports cavir_req_n_0]
set_property PACKAGE_PIN N29 [get_ports caviar_ack_n_0]

set_property IOSTANDARD LVCMOS33 [get_ports caviar_ack_n_0]
set_property IOSTANDARD LVCMOS33 [get_ports cavir_req_n_0]
set_property IOSTANDARD LVCMOS33 [get_ports wsaer_ack_n_0]
set_property IOSTANDARD LVCMOS33 [get_ports wsaer_req_n_0]

set_property IOSTANDARD LVDS [get_ports sys_diff_clock_clk_p]


set_property PACKAGE_PIN AF17 [get_ports {wsaer_data_0[0]}]
set_property PACKAGE_PIN AF18 [get_ports {wsaer_data_0[1]}]
set_property PACKAGE_PIN AJ18 [get_ports {wsaer_data_0[2]}]
set_property PACKAGE_PIN AH18 [get_ports {wsaer_data_0[3]}]
set_property PACKAGE_PIN AG16 [get_ports {wsaer_data_0[4]}]
set_property PACKAGE_PIN AG17 [get_ports {wsaer_data_0[5]}]
set_property PACKAGE_PIN AF12 [get_ports {wsaer_data_0[6]}]
set_property PACKAGE_PIN AE12 [get_ports {wsaer_data_0[7]}]
set_property PACKAGE_PIN AE15 [get_ports {wsaer_data_0[8]}]
set_property PACKAGE_PIN AE16 [get_ports {wsaer_data_0[9]}]
set_property PACKAGE_PIN AF13 [get_ports {wsaer_data_0[10]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/clk_wiz/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 19 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/okt_wsaer2caviar_0/caviar_data[0]} {design_1_i/okt_wsaer2caviar_0/caviar_data[1]} {design_1_i/okt_wsaer2caviar_0/caviar_data[2]} {design_1_i/okt_wsaer2caviar_0/caviar_data[3]} {design_1_i/okt_wsaer2caviar_0/caviar_data[4]} {design_1_i/okt_wsaer2caviar_0/caviar_data[5]} {design_1_i/okt_wsaer2caviar_0/caviar_data[6]} {design_1_i/okt_wsaer2caviar_0/caviar_data[7]} {design_1_i/okt_wsaer2caviar_0/caviar_data[8]} {design_1_i/okt_wsaer2caviar_0/caviar_data[9]} {design_1_i/okt_wsaer2caviar_0/caviar_data[10]} {design_1_i/okt_wsaer2caviar_0/caviar_data[11]} {design_1_i/okt_wsaer2caviar_0/caviar_data[12]} {design_1_i/okt_wsaer2caviar_0/caviar_data[13]} {design_1_i/okt_wsaer2caviar_0/caviar_data[14]} {design_1_i/okt_wsaer2caviar_0/caviar_data[15]} {design_1_i/okt_wsaer2caviar_0/caviar_data[16]} {design_1_i/okt_wsaer2caviar_0/caviar_data[17]} {design_1_i/okt_wsaer2caviar_0/caviar_data[18]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 5 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/okt_wsaer2caviar_0/row_delay[0]} {design_1_i/okt_wsaer2caviar_0/row_delay[1]} {design_1_i/okt_wsaer2caviar_0/row_delay[2]} {design_1_i/okt_wsaer2caviar_0/row_delay[3]} {design_1_i/okt_wsaer2caviar_0/row_delay[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 5 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/okt_wsaer2caviar_0/inst/cnt[0]} {design_1_i/okt_wsaer2caviar_0/inst/cnt[1]} {design_1_i/okt_wsaer2caviar_0/inst/cnt[2]} {design_1_i/okt_wsaer2caviar_0/inst/cnt[3]} {design_1_i/okt_wsaer2caviar_0/inst/cnt[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/okt_wsaer2caviar_0/inst/ns[0]} {design_1_i/okt_wsaer2caviar_0/inst/ns[1]} {design_1_i/okt_wsaer2caviar_0/inst/ns[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 11 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/okt_wsaer2caviar_0/wsaer_data[0]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[1]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[2]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[3]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[4]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[5]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[6]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[7]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[8]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[9]} {design_1_i/okt_wsaer2caviar_0/wsaer_data[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 3 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/okt_wsaer2caviar_0/inst/cs[0]} {design_1_i/okt_wsaer2caviar_0/inst/cs[1]} {design_1_i/okt_wsaer2caviar_0/inst/cs[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list design_1_i/okt_wsaer2caviar_0/caviar_ack_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list design_1_i/okt_wsaer2caviar_0/cavir_req_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list design_1_i/okt_wsaer2caviar_0/rst_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list design_1_i/okt_wsaer2caviar_0/wsaer_ack_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list design_1_i/okt_wsaer2caviar_0/wsaer_req_n]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out1]

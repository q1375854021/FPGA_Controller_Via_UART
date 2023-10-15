set_property SRC_FILE_INFO {cfile:d:/study/my_diy/STM32_Communicate_FPGA_CLI_Via_UART/FPGA/FPGA_Top/FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock.xdc rfile:../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports sys_clk]] 0.200

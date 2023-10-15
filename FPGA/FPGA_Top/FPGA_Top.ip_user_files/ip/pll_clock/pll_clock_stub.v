// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
// Date        : Sun Oct  1 23:42:05 2023
// Host        : DESKTOP-ACVK3GV running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/study/my_diy/STM32_Communicate_FPGA_CLI_Via_UART/FPGA/FPGA_Top/FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock_stub.v
// Design      : pll_clock
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module pll_clock(clk_100mhz, resetn, locked, sys_clk)
/* synthesis syn_black_box black_box_pad_pin="resetn,locked,sys_clk" */
/* synthesis syn_force_seq_prim="clk_100mhz" */;
  output clk_100mhz /* synthesis syn_isclock = 1 */;
  input resetn;
  output locked;
  input sys_clk;
endmodule

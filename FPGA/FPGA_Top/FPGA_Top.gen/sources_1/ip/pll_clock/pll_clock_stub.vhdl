-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
-- Date        : Sun Oct  1 23:42:05 2023
-- Host        : DESKTOP-ACVK3GV running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/study/my_diy/STM32_Communicate_FPGA_CLI_Via_UART/FPGA/FPGA_Top/FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock_stub.vhdl
-- Design      : pll_clock
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll_clock is
  Port ( 
    clk_100mhz : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC;
    sys_clk : in STD_LOGIC
  );

end pll_clock;

architecture stub of pll_clock is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_100mhz,resetn,locked,sys_clk";
begin
end;

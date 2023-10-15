transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {D:/study/my_diy/STM32_Communicate_FPGA_CLI_Via_UART/FPGA/FPGA_Top/FPGA_Top.cache/compile_simlib/activehdl}
vlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" -l xil_defaultlib \
"../../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock_clk_wiz.v" \
"../../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock.v" \


vlog -work xil_defaultlib \
"glbl.v"


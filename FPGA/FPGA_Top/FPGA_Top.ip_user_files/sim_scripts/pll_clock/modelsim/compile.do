vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" \
"../../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock_clk_wiz.v" \
"../../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock.v" \


vlog -work xil_defaultlib \
"glbl.v"


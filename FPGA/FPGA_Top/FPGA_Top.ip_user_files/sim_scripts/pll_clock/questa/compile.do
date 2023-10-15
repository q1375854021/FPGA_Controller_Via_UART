vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" \
"../../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock_clk_wiz.v" \
"../../../../FPGA_Top.gen/sources_1/ip/pll_clock/pll_clock.v" \


vlog -work xil_defaultlib \
"glbl.v"


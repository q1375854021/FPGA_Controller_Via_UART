transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+pll_clock  -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.pll_clock xil_defaultlib.glbl

do {pll_clock.udo}

run 1000ns

endsim

quit -force

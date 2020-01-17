onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib clk_wiz_1_idelay_refclk_opt

do {wave.do}

view wave
view structure
view signals

do {clk_wiz_1_idelay_refclk.udo}

run -all

quit -force

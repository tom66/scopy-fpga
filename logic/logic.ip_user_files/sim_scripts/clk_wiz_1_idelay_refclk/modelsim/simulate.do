onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xilinx_vip -L xil_defaultlib -L xpm -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.clk_wiz_1_idelay_refclk xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {clk_wiz_1_idelay_refclk.udo}

run -all

quit -force

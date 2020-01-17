onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+clk_wiz_1_idelay_refclk -L xilinx_vip -L xil_defaultlib -L xpm -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clk_wiz_1_idelay_refclk xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {clk_wiz_1_idelay_refclk.udo}

run -all

endsim

quit -force

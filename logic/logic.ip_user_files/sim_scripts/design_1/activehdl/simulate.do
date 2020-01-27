onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+design_1 -L xilinx_vip -L xpm -L lib_pkg_v1_0_2 -L fifo_generator_v13_2_5 -L lib_fifo_v1_0_14 -L lib_srl_fifo_v1_0_2 -L lib_cdc_v1_0_2 -L axi_datamover_v5_1_22 -L axi_sg_v4_1_13 -L axi_dma_v7_1_21 -L xil_defaultlib -L proc_sys_reset_v5_0_13 -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xlconcat_v2_1_3 -L axi_bram_ctrl_v4_1_2 -L blk_mem_gen_v8_4_4 -L generic_baseblocks_v2_1_0 -L axi_register_slice_v2_1_20 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L axi_protocol_converter_v2_1_20 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.design_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {design_1.udo}

run -all

endsim

quit -force

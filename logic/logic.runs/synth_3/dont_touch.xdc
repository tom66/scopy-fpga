# This file is automatically generated.
# It contains project source information necessary for synthesis and implementation.

# XDC: new/constraints.xdc

# Block Designs: bd/design_1/design_1.bd
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1 || ORIG_REF_NAME==design_1} -quiet] -quiet

# IP: bd/design_1/ip/design_1_axi_dma_0/design_1_axi_dma_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_axi_dma_0 || ORIG_REF_NAME==design_1_axi_dma_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_adc_test_streamer_0_0/design_1_adc_test_streamer_0_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_adc_test_streamer_0_0 || ORIG_REF_NAME==design_1_adc_test_streamer_0_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/fifo_generator_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==fifo_generator_0 || ORIG_REF_NAME==fifo_generator_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_rst_ps7_0_20M_1/design_1_rst_ps7_0_20M_1.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_rst_ps7_0_20M_1 || ORIG_REF_NAME==design_1_rst_ps7_0_20M_1} -quiet] -quiet

# IP: bd/design_1/ip/design_1_axi_mem_intercon_0/design_1_axi_mem_intercon_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_axi_mem_intercon_0 || ORIG_REF_NAME==design_1_axi_mem_intercon_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_axi_interconnect_0_0/design_1_axi_interconnect_0_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_axi_interconnect_0_0 || ORIG_REF_NAME==design_1_axi_interconnect_0_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_processing_system7_0_1/design_1_processing_system7_0_1.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_processing_system7_0_1 || ORIG_REF_NAME==design_1_processing_system7_0_1} -quiet] -quiet

# IP: bd/design_1/ip/design_1_xlconcat_1_0/design_1_xlconcat_1_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_xlconcat_1_0 || ORIG_REF_NAME==design_1_xlconcat_1_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_axi_bram_ctrl_0_0/design_1_axi_bram_ctrl_0_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_axi_bram_ctrl_0_0 || ORIG_REF_NAME==design_1_axi_bram_ctrl_0_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_blk_mem_gen_0_1/design_1_blk_mem_gen_0_1.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_blk_mem_gen_0_1 || ORIG_REF_NAME==design_1_blk_mem_gen_0_1} -quiet] -quiet

# IP: bd/design_1/ip/design_1_ila_0_0/design_1_ila_0_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_ila_0_0 || ORIG_REF_NAME==design_1_ila_0_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_axi_bram_ctrl_1_0/design_1_axi_bram_ctrl_1_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_axi_bram_ctrl_1_0 || ORIG_REF_NAME==design_1_axi_bram_ctrl_1_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_blk_mem_gen_1_1/design_1_blk_mem_gen_1_1.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_blk_mem_gen_1_1 || ORIG_REF_NAME==design_1_blk_mem_gen_1_1} -quiet] -quiet

# IP: bd/design_1/ip/design_1_xbar_5/design_1_xbar_5.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_xbar_5 || ORIG_REF_NAME==design_1_xbar_5} -quiet] -quiet

# IP: bd/design_1/ip/design_1_auto_pc_1/design_1_auto_pc_1.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_auto_pc_1 || ORIG_REF_NAME==design_1_auto_pc_1} -quiet] -quiet

# IP: bd/design_1/ip/design_1_auto_pc_0/design_1_auto_pc_0.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_auto_pc_0 || ORIG_REF_NAME==design_1_auto_pc_0} -quiet] -quiet

# IP: bd/design_1/ip/design_1_auto_pc_2/design_1_auto_pc_2.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==design_1_auto_pc_2 || ORIG_REF_NAME==design_1_auto_pc_2} -quiet] -quiet

# XDC: bd/design_1/ip/design_1_axi_dma_0/design_1_axi_dma_0.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_axi_dma_0 || ORIG_REF_NAME==design_1_axi_dma_0} -quiet] {/U0 } ]/U0 ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_axi_dma_0/design_1_axi_dma_0_clocks.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_axi_dma_0 || ORIG_REF_NAME==design_1_axi_dma_0} -quiet] {/U0 } ]/U0 ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/fifo_generator_0.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==fifo_generator_0 || ORIG_REF_NAME==fifo_generator_0} -quiet] {/U0 } ]/U0 ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/fifo_generator_0_clocks.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==fifo_generator_0 || ORIG_REF_NAME==fifo_generator_0} -quiet] {/U0 } ]/U0 ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_rst_ps7_0_20M_1/design_1_rst_ps7_0_20M_1_board.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_rst_ps7_0_20M_1 || ORIG_REF_NAME==design_1_rst_ps7_0_20M_1} -quiet] {/U0 } ]/U0 ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_rst_ps7_0_20M_1/design_1_rst_ps7_0_20M_1.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_rst_ps7_0_20M_1 || ORIG_REF_NAME==design_1_rst_ps7_0_20M_1} -quiet] {/U0 } ]/U0 ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_processing_system7_0_1/design_1_processing_system7_0_1.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_processing_system7_0_1 || ORIG_REF_NAME==design_1_processing_system7_0_1} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_axi_bram_ctrl_0_0/design_1_axi_bram_ctrl_0_0_ooc.xdc

# XDC: bd/design_1/ip/design_1_blk_mem_gen_0_1/design_1_blk_mem_gen_0_1_ooc.xdc

# XDC: bd/design_1/ip/design_1_ila_0_0/ila_v6_2/constraints/ila_impl.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_ila_0_0 || ORIG_REF_NAME==design_1_ila_0_0} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_ila_0_0/ila_v6_2/constraints/ila.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==design_1_ila_0_0 || ORIG_REF_NAME==design_1_ila_0_0} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: bd/design_1/ip/design_1_ila_0_0/design_1_ila_0_0_ooc.xdc

# XDC: bd/design_1/ip/design_1_axi_bram_ctrl_1_0/design_1_axi_bram_ctrl_1_0_ooc.xdc

# XDC: bd/design_1/ip/design_1_blk_mem_gen_1_1/design_1_blk_mem_gen_1_1_ooc.xdc

# XDC: bd/design_1/ip/design_1_xbar_5/design_1_xbar_5_ooc.xdc

# XDC: bd/design_1/ip/design_1_auto_pc_1/design_1_auto_pc_1_ooc.xdc

# XDC: bd/design_1/ip/design_1_auto_pc_0/design_1_auto_pc_0_ooc.xdc

# XDC: bd/design_1/ip/design_1_auto_pc_2/design_1_auto_pc_2_ooc.xdc

# XDC: bd/design_1/design_1_ooc.xdc

vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/lib_pkg_v1_0_2
vlib activehdl/fifo_generator_v13_2_5
vlib activehdl/lib_fifo_v1_0_14
vlib activehdl/lib_srl_fifo_v1_0_2
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/axi_datamover_v5_1_22
vlib activehdl/axi_sg_v4_1_13
vlib activehdl/axi_dma_v7_1_21
vlib activehdl/xil_defaultlib
vlib activehdl/proc_sys_reset_v5_0_13
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_6
vlib activehdl/processing_system7_vip_v1_0_8
vlib activehdl/xlconcat_v2_1_3
vlib activehdl/axi_bram_ctrl_v4_1_2
vlib activehdl/blk_mem_gen_v8_4_4
vlib activehdl/generic_baseblocks_v2_1_0
vlib activehdl/axi_register_slice_v2_1_20
vlib activehdl/axi_data_fifo_v2_1_19
vlib activehdl/axi_crossbar_v2_1_21
vlib activehdl/axi_protocol_converter_v2_1_20

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap lib_pkg_v1_0_2 activehdl/lib_pkg_v1_0_2
vmap fifo_generator_v13_2_5 activehdl/fifo_generator_v13_2_5
vmap lib_fifo_v1_0_14 activehdl/lib_fifo_v1_0_14
vmap lib_srl_fifo_v1_0_2 activehdl/lib_srl_fifo_v1_0_2
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap axi_datamover_v5_1_22 activehdl/axi_datamover_v5_1_22
vmap axi_sg_v4_1_13 activehdl/axi_sg_v4_1_13
vmap axi_dma_v7_1_21 activehdl/axi_dma_v7_1_21
vmap xil_defaultlib activehdl/xil_defaultlib
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_6 activehdl/axi_vip_v1_1_6
vmap processing_system7_vip_v1_0_8 activehdl/processing_system7_vip_v1_0_8
vmap xlconcat_v2_1_3 activehdl/xlconcat_v2_1_3
vmap axi_bram_ctrl_v4_1_2 activehdl/axi_bram_ctrl_v4_1_2
vmap blk_mem_gen_v8_4_4 activehdl/blk_mem_gen_v8_4_4
vmap generic_baseblocks_v2_1_0 activehdl/generic_baseblocks_v2_1_0
vmap axi_register_slice_v2_1_20 activehdl/axi_register_slice_v2_1_20
vmap axi_data_fifo_v2_1_19 activehdl/axi_data_fifo_v2_1_19
vmap axi_crossbar_v2_1_21 activehdl/axi_crossbar_v2_1_21
vmap axi_protocol_converter_v2_1_20 activehdl/axi_protocol_converter_v2_1_20

vlog -work xilinx_vip  -sv2k12 "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_14 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_22 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/1e40/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_13 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_21 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec2a/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_axi_dma_0/sim/design_1_axi_dma_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/sim/fifo_generator_0.v" \
"../../../bd/design_1/ipshared/94a6/hdl/adc_test_streamer_v2_0_M00_AXIS.v" \
"../../../bd/design_1/ipshared/94a6/hdl/adc_test_streamer_v2_0.v" \
"../../../bd/design_1/ip/design_1_adc_test_streamer_0_0/sim/design_1_adc_test_streamer_0_0.v" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_rst_ps7_0_20M_1/sim/design_1_rst_ps7_0_20M_1.vhd" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_6  -sv2k12 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_8  -sv2k12 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_1/sim/design_1_processing_system7_0_1.v" \

vlog -work xlconcat_v2_1_3  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xlconcat_1_0/sim/design_1_xlconcat_1_0.v" \

vcom -work axi_bram_ctrl_v4_1_2 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/a002/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_axi_bram_ctrl_0_0/sim/design_1_axi_bram_ctrl_0_0.vhd" \

vlog -work blk_mem_gen_v8_4_4  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_blk_mem_gen_0_1/sim/design_1_blk_mem_gen_0_1.v" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_20  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_data_fifo_v2_1_19  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_21  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xbar_2/sim/design_1_xbar_2.v" \
"../../../bd/design_1/ip/design_1_xbar_3/sim/design_1_xbar_3.v" \

vlog -work axi_protocol_converter_v2_1_20  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_auto_pc_1/sim/design_1_auto_pc_1.v" \
"../../../bd/design_1/ip/design_1_auto_pc_0/sim/design_1_auto_pc_0.v" \
"../../../bd/design_1/ip/design_1_auto_pc_2/sim/design_1_auto_pc_2.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"


vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/lib_pkg_v1_0_2
vlib questa_lib/msim/fifo_generator_v13_2_5
vlib questa_lib/msim/lib_fifo_v1_0_14
vlib questa_lib/msim/lib_srl_fifo_v1_0_2
vlib questa_lib/msim/lib_cdc_v1_0_2
vlib questa_lib/msim/axi_datamover_v5_1_22
vlib questa_lib/msim/axi_sg_v4_1_13
vlib questa_lib/msim/axi_dma_v7_1_21
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/proc_sys_reset_v5_0_13
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_6
vlib questa_lib/msim/processing_system7_vip_v1_0_8
vlib questa_lib/msim/xlconcat_v2_1_3
vlib questa_lib/msim/generic_baseblocks_v2_1_0
vlib questa_lib/msim/axi_register_slice_v2_1_20
vlib questa_lib/msim/axi_data_fifo_v2_1_19
vlib questa_lib/msim/axi_crossbar_v2_1_21
vlib questa_lib/msim/xlconstant_v1_1_6
vlib questa_lib/msim/axi_protocol_converter_v2_1_20

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap lib_pkg_v1_0_2 questa_lib/msim/lib_pkg_v1_0_2
vmap fifo_generator_v13_2_5 questa_lib/msim/fifo_generator_v13_2_5
vmap lib_fifo_v1_0_14 questa_lib/msim/lib_fifo_v1_0_14
vmap lib_srl_fifo_v1_0_2 questa_lib/msim/lib_srl_fifo_v1_0_2
vmap lib_cdc_v1_0_2 questa_lib/msim/lib_cdc_v1_0_2
vmap axi_datamover_v5_1_22 questa_lib/msim/axi_datamover_v5_1_22
vmap axi_sg_v4_1_13 questa_lib/msim/axi_sg_v4_1_13
vmap axi_dma_v7_1_21 questa_lib/msim/axi_dma_v7_1_21
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap proc_sys_reset_v5_0_13 questa_lib/msim/proc_sys_reset_v5_0_13
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_6 questa_lib/msim/axi_vip_v1_1_6
vmap processing_system7_vip_v1_0_8 questa_lib/msim/processing_system7_vip_v1_0_8
vmap xlconcat_v2_1_3 questa_lib/msim/xlconcat_v2_1_3
vmap generic_baseblocks_v2_1_0 questa_lib/msim/generic_baseblocks_v2_1_0
vmap axi_register_slice_v2_1_20 questa_lib/msim/axi_register_slice_v2_1_20
vmap axi_data_fifo_v2_1_19 questa_lib/msim/axi_data_fifo_v2_1_19
vmap axi_crossbar_v2_1_21 questa_lib/msim/axi_crossbar_v2_1_21
vmap xlconstant_v1_1_6 questa_lib/msim/xlconstant_v1_1_6
vmap axi_protocol_converter_v2_1_20 questa_lib/msim/axi_protocol_converter_v2_1_20

vlog -work xilinx_vip -64 -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_pkg_v1_0_2 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_5 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_14 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_22 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/1e40/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_13 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_21 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec2a/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_axi_dma_0/sim/design_1_axi_dma_0.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_adc_streamer/sim/fifo_generator_adc_streamer.v" \
"../../../bd/design_1/ipshared/22be/hdl/adc_test_streamer_v2_0_M00_AXIS.v" \
"../../../bd/design_1/ipshared/22be/hdl/adc_test_streamer_v2_0.v" \
"../../../bd/design_1/ip/design_1_adc_test_streamer_0_0/sim/design_1_adc_test_streamer_0_0.v" \

vcom -work proc_sys_reset_v5_0_13 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_rst_ps7_0_20M_1/sim/design_1_rst_ps7_0_20M_1.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_6 -64 -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_8 -64 -sv -L axi_vip_v1_1_6 -L processing_system7_vip_v1_0_8 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_1/sim/design_1_processing_system7_0_1.v" \

vlog -work xlconcat_v2_1_3 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xlconcat_1_0/sim/design_1_xlconcat_1_0.v" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_mmcm_pll_drp.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_conv_funs_pkg.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_proc_common_pkg.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_ipif_pkg.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_family_support.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_family.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_soft_reset.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/proc_common_v3_00_a/hdl/src/vhdl/design_1_clk_wiz_0_0_pselect_f.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/axi_lite_ipif_v1_01_a/hdl/src/vhdl/design_1_clk_wiz_0_0_address_decoder.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/axi_lite_ipif_v1_01_a/hdl/src/vhdl/design_1_clk_wiz_0_0_slave_attachment.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/axi_lite_ipif_v1_01_a/hdl/src/vhdl/design_1_clk_wiz_0_0_axi_lite_ipif.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_clk_wiz_drp.vhd" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_axi_clk_config.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.v" \

vlog -work generic_baseblocks_v2_1_0 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_20 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_data_fifo_v2_1_19 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_21 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xbar_6/sim/design_1_xbar_6.v" \
"../../../bd/design_1/ip/design_1_csi_gearbox_dma_0_0/src/fifo_generator_csi_gearbox/sim/fifo_generator_csi_gearbox.v" \
"../../../bd/design_1/ipshared/aca9/src/ecc24_fast.v" \
"../../../bd/design_1/ipshared/aca9/src/mipi_csi.v" \
"../../../bd/design_1/ipshared/aca9/src/mipi_csi_controller.v" \
"../../../bd/design_1/ipshared/aca9/hdl/csi_gearbox_dma_v1_0.v" \
"../../../bd/design_1/ip/design_1_csi_gearbox_dma_0_0/sim/design_1_csi_gearbox_dma_0_0.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_axi_dma_1/sim/design_1_axi_dma_1.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ipshared/1c32/hdl/FabCfg_NextGen_v1_0_S00_AXI.v" \
"../../../bd/design_1/ipshared/1c32/hdl/FabCfg_NextGen_v1_0.v" \
"../../../bd/design_1/ip/design_1_FabCfg_NextGen_0_0/sim/design_1_FabCfg_NextGen_0_0.v" \

vlog -work xlconstant_v1_1_6 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/34f7/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xlconstant_0_0/sim/design_1_xlconstant_0_0.v" \
"../../../bd/design_1/ip/design_1_xlconstant_1_0/sim/design_1_xlconstant_1_0.v" \
"../../../bd/design_1/ip/design_1_system_ila_0_0/bd_0/sim/bd_f60c.v" \
"../../../bd/design_1/ip/design_1_system_ila_0_0/bd_0/ip/ip_0/sim/bd_f60c_ila_lib_0.v" \
"../../../bd/design_1/ip/design_1_system_ila_0_0/sim/design_1_system_ila_0_0.v" \
"../../../bd/design_1/ipshared/0605/hdl/simple_reset_controller_v1_0.v" \
"../../../bd/design_1/ip/design_1_simple_reset_control_0_0/sim/design_1_simple_reset_control_0_0.v" \
"../../../bd/design_1/ipshared/4bda/src/adc_bitslip.v" \
"../../../bd/design_1/ipshared/4bda/src/adc_iserdese2_mod.v" \
"../../../bd/design_1/ipshared/4bda/src/adc_receiver.v" \
"../../../bd/design_1/ipshared/4bda/hdl/adc_receiver_core_v1_0.v" \
"../../../bd/design_1/ip/design_1_adc_receiver_core_0_0/sim/design_1_adc_receiver_core_0_0.v" \
"../../../bd/design_1/ip/design_1_xlconstant_0_1/sim/design_1_xlconstant_0_1.v" \
"../../../bd/design_1/ip/design_1_clk_wiz_1_0/design_1_clk_wiz_1_0_clk_wiz.v" \
"../../../bd/design_1/ip/design_1_clk_wiz_1_0/design_1_clk_wiz_1_0.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work axi_protocol_converter_v2_1_20 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/4fba" "+incdir+../../../bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/aca9/src" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/1b7e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/122e/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b205/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/8f82/hdl/verilog" "+incdir+G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_auto_pc_0/sim/design_1_auto_pc_0.v" \
"../../../bd/design_1/ip/design_1_auto_pc_1/sim/design_1_auto_pc_1.v" \
"../../../bd/design_1/ip/design_1_auto_pc_2/sim/design_1_auto_pc_2.v" \

vlog -work xil_defaultlib \
"glbl.v"


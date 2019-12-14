vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_4
vlib questa_lib/msim/processing_system7_vip_v1_0_6
vlib questa_lib/msim/blk_mem_gen_v8_3_6
vlib questa_lib/msim/axi_bram_ctrl_v4_1_0
vlib questa_lib/msim/blk_mem_gen_v8_4_2
vlib questa_lib/msim/xlconstant_v1_1_5
vlib questa_lib/msim/lib_cdc_v1_0_2
vlib questa_lib/msim/proc_sys_reset_v5_0_13
vlib questa_lib/msim/smartconnect_v1_0

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_4 questa_lib/msim/axi_vip_v1_1_4
vmap processing_system7_vip_v1_0_6 questa_lib/msim/processing_system7_vip_v1_0_6
vmap blk_mem_gen_v8_3_6 questa_lib/msim/blk_mem_gen_v8_3_6
vmap axi_bram_ctrl_v4_1_0 questa_lib/msim/axi_bram_ctrl_v4_1_0
vmap blk_mem_gen_v8_4_2 questa_lib/msim/blk_mem_gen_v8_4_2
vmap xlconstant_v1_1_5 questa_lib/msim/xlconstant_v1_1_5
vmap lib_cdc_v1_0_2 questa_lib/msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 questa_lib/msim/proc_sys_reset_v5_0_13
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0

vlog -work xilinx_vip -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_if.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/clk_vip_if.sv" \
"G:/Xilinx/Vivado/2018.3/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"G:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_4 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/98af/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_6 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_0/sim/design_1_processing_system7_0_0.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work blk_mem_gen_v8_3_6 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/2751/simulation/blk_mem_gen_v8_3.v" \

vcom -work axi_bram_ctrl_v4_1_0 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/27fe/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_axi_bram_ctrl_0_0/sim/design_1_axi_bram_ctrl_0_0.vhd" \

vlog -work blk_mem_gen_v8_4_2 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/37c2/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_bram_ctrl_0_bram_0/sim/design_1_axi_bram_ctrl_0_bram_0.v" \

vlog -work xlconstant_v1_1_5 -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/4649/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_0/sim/bd_afc3_one_0.v" \

vcom -work lib_cdc_v1_0_2 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -64 -93 \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_1/sim/bd_afc3_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/f85e/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_2/sim/bd_afc3_s00mmu_0.sv" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/ca72/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_3/sim/bd_afc3_s00tr_0.sv" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/9ade/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_4/sim/bd_afc3_s00sic_0.sv" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/b89e/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_5/sim/bd_afc3_s00a2s_0.sv" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_6/sim/bd_afc3_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_7/sim/bd_afc3_srn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_8/sim/bd_afc3_sawn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_9/sim/bd_afc3_swn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_10/sim/bd_afc3_sbn_0.sv" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/7005/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_11/sim/bd_afc3_m00s2a_0.sv" \

vlog -work smartconnect_v1_0 -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../logic.srcs/sources_1/bd/design_1/ipshared/b387/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_12/sim/bd_afc3_m00e_0.sv" \

vlog -work xil_defaultlib -64 "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+G:/Xilinx/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/sim/bd_afc3.v" \
"../../../bd/design_1/ip/design_1_axi_smc_0/sim/design_1_axi_smc_0.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_rst_ps7_0_50M_0/sim/design_1_rst_ps7_0_50M_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"


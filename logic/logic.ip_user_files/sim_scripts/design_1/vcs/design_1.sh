#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : design_1.sh
# Simulator   : Synopsys Verilog Compiler Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Sat Feb 15 12:54:30 +0000 2020
# SW Build 2708876 on Wed Nov  6 21:40:23 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved. 
#
# usage: design_1.sh [-help]
# usage: design_1.sh [-lib_map_path]
# usage: design_1.sh [-noclean_files]
# usage: design_1.sh [-reset_run]
#
# Prerequisite:- To compile and run simulation, you must compile the Xilinx simulation libraries using the
# 'compile_simlib' TCL command. For more information about this command, run 'compile_simlib -help' in the
# Vivado Tcl Shell. Once the libraries have been compiled successfully, specify the -lib_map_path switch
# that points to these libraries and rerun export_simulation. For more information about this switch please
# type 'export_simulation -help' in the Tcl shell.
#
# You can also point to the simulation libraries by either replacing the <SPECIFY_COMPILED_LIB_PATH> in this
# script with the compiled library directory path or specify this path with the '-lib_map_path' switch when
# executing this script. Please type 'design_1.sh -help' for more information.
#
# Additional references - 'Xilinx Vivado Design Suite User Guide:Logic simulation (UG900)'
#
#*********************************************************************************************************

# Directory path for design sources and include directories (if any) wrt this path
ref_dir="."

# Override directory with 'export_sim_ref_dir' env path value if set in the shell
if [[ (! -z "$export_sim_ref_dir") && ($export_sim_ref_dir != "") ]]; then
  ref_dir="$export_sim_ref_dir"
fi

# Command line options
vlogan_opts="-full64"
vhdlan_opts="-full64"
vcs_elab_opts="-full64 -debug_pp -t ps -licqueue -l elaborate.log"
vcs_sim_opts="-ucli -licqueue -l simulate.log"

# Design libraries
design_libs=(xilinx_vip xpm lib_pkg_v1_0_2 fifo_generator_v13_2_5 lib_fifo_v1_0_14 lib_srl_fifo_v1_0_2 lib_cdc_v1_0_2 axi_datamover_v5_1_22 axi_sg_v4_1_13 axi_dma_v7_1_21 xil_defaultlib proc_sys_reset_v5_0_13 axi_infrastructure_v1_1_0 axi_vip_v1_1_6 processing_system7_vip_v1_0_8 xlconcat_v2_1_3 axi_bram_ctrl_v4_1_2 blk_mem_gen_v8_4_4 generic_baseblocks_v2_1_0 axi_register_slice_v2_1_20 axi_data_fifo_v2_1_19 axi_crossbar_v2_1_21 axi_protocol_converter_v2_1_20)

# Simulation root library directory
sim_lib_dir="vcs_lib"

# Script info
echo -e "design_1.sh - Script generated by export_simulation (Vivado v2019.2 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $1
  setup $1 $2
  compile
  elaborate
  simulate
}

# RUN_STEP: <compile>
compile()
{
  # Compile design files
  vlogan -work xilinx_vip $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
    "G:/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work xpm $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
    "G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
    "G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
  2>&1 | tee -a vlogan.log

  vhdlan -work xpm $vhdlan_opts \
    "G:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_pkg_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work fifo_generator_v13_2_5 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work fifo_generator_v13_2_5 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work fifo_generator_v13_2_5 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work lib_fifo_v1_0_14 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_srl_fifo_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work lib_cdc_v1_0_2 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work axi_datamover_v5_1_22 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/1e40/hdl/axi_datamover_v5_1_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work axi_sg_v4_1_13 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work axi_dma_v7_1_21 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec2a/hdl/axi_dma_v7_1_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/design_1/ip/design_1_axi_dma_0/sim/design_1_axi_dma_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/sim/fifo_generator_0.v" \
    "$ref_dir/../../../bd/design_1/ipshared/33f1/hdl/adc_test_streamer_v2_0_M00_AXIS.v" \
    "$ref_dir/../../../bd/design_1/ipshared/33f1/hdl/adc_test_streamer_v2_0.v" \
    "$ref_dir/../../../bd/design_1/ip/design_1_adc_test_streamer_0_0/sim/design_1_adc_test_streamer_0_0.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work proc_sys_reset_v5_0_13 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/design_1/ip/design_1_rst_ps7_0_20M_1/sim/design_1_rst_ps7_0_20M_1.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work axi_infrastructure_v1_1_0 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_vip_v1_1_6 $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work processing_system7_vip_v1_0_8 $vlogan_opts -sverilog +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/design_1/ip/design_1_processing_system7_0_1/sim/design_1_processing_system7_0_1.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xlconcat_v2_1_3 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/design_1/ip/design_1_xlconcat_1_0/sim/design_1_xlconcat_1_0.v" \
  2>&1 | tee -a vlogan.log

  vhdlan -work axi_bram_ctrl_v4_1_2 $vhdlan_opts \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/a002/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \
  2>&1 | tee -a vhdlan.log

  vhdlan -work xil_defaultlib $vhdlan_opts \
    "$ref_dir/../../../bd/design_1/ip/design_1_axi_bram_ctrl_0_0/sim/design_1_axi_bram_ctrl_0_0.vhd" \
  2>&1 | tee -a vhdlan.log

  vlogan -work blk_mem_gen_v8_4_4 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/design_1/ip/design_1_blk_mem_gen_0_1/sim/design_1_blk_mem_gen_0_1.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work generic_baseblocks_v2_1_0 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_register_slice_v2_1_20 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_data_fifo_v2_1_19 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_crossbar_v2_1_21 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/design_1/ip/design_1_xbar_2/sim/design_1_xbar_2.v" \
    "$ref_dir/../../../bd/design_1/ip/design_1_xbar_3/sim/design_1_xbar_3.v" \
    "$ref_dir/../../../bd/design_1/sim/design_1.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work axi_protocol_converter_v2_1_20 $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
  2>&1 | tee -a vlogan.log

  vlogan -work xil_defaultlib $vlogan_opts +v2k +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ipshared/2d50/hdl" +incdir+"$ref_dir/../../../../logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1" +incdir+"G:/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
    "$ref_dir/../../../bd/design_1/ip/design_1_auto_pc_1/sim/design_1_auto_pc_1.v" \
    "$ref_dir/../../../bd/design_1/ip/design_1_auto_pc_0/sim/design_1_auto_pc_0.v" \
    "$ref_dir/../../../bd/design_1/ip/design_1_auto_pc_2/sim/design_1_auto_pc_2.v" \
  2>&1 | tee -a vlogan.log


  vlogan -work xil_defaultlib $vlogan_opts +v2k \
    glbl.v \
  2>&1 | tee -a vlogan.log

}

# RUN_STEP: <elaborate>
elaborate()
{
  vcs $vcs_elab_opts xil_defaultlib.design_1 xil_defaultlib.glbl -o design_1_simv
}

# RUN_STEP: <simulate>
simulate()
{
  ./design_1_simv $vcs_sim_opts -do simulate.do
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./design_1.sh -help\" for more information)\n"
        exit 1
      fi
      create_lib_mappings $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
      create_lib_mappings $2
  esac

  create_lib_dir

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Define design library mappings
create_lib_mappings()
{
  file="synopsys_sim.setup"
  if [[ -e $file ]]; then
    if [[ ($1 == "") ]]; then
      return
    else
      rm -rf $file
    fi
  fi

  touch $file

  lib_map_path=""
  if [[ ($1 != "") ]]; then
    lib_map_path="$1"
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    mapping="$lib:$sim_lib_dir/$lib"
    echo $mapping >> $file
  done

  if [[ ($lib_map_path != "") ]]; then
    incl_ref="OTHERS=$lib_map_path/synopsys_sim.setup"
    echo $incl_ref >> $file
  fi
}

# Create design library directory paths
create_lib_dir()
{
  if [[ -e $sim_lib_dir ]]; then
    rm -rf $sim_lib_dir
  fi

  for (( i=0; i<${#design_libs[*]}; i++ )); do
    lib="${design_libs[i]}"
    lib_dir="$sim_lib_dir/$lib"
    if [[ ! -e $lib_dir ]]; then
      mkdir -p $lib_dir
    fi
  done
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(ucli.key design_1_simv vlogan.log vhdlan.log compile.log elaborate.log simulate.log .vlogansetup.env .vlogansetup.args .vcs_lib_lock scirocco_command.log 64 AN.DB csrc design_1_simv.daidir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done

  create_lib_dir
}

# Check command line arguments
check_args()
{
  if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$2' (type \"./design_1.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: design_1.sh [-help]\n\
Usage: design_1.sh [-lib_map_path]\n\
Usage: design_1.sh [-reset_run]\n\
Usage: design_1.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2

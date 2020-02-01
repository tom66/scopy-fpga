# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param chipscope.maxJobs 1
create_project -in_memory -part xc7z014sclg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.cache/wt [current_project]
set_property parent.project_path C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths {
  c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/ip_repo/adc_test_streamer_2.0
  c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/ip_repo/adc_streamer_1.0
} [current_project]
update_ip_catalog
set_property ip_output_repo c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.ip_user_files/sine_rom.coe
read_verilog -library xil_defaultlib {
  C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/new/adc_iserdese2_mod.v
  C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/new/adc_receiver.v
  C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/new/cfg_bram_controller.v
  C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/new/main.v
}
add_files C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/design_1.bd
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_axi_dma_0/design_1_axi_dma_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_axi_dma_0/design_1_axi_dma_0_clocks.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/fifo_generator_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_adc_test_streamer_0_0/src/fifo_generator_0_1/fifo_generator_0_clocks.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_rst_ps7_0_20M_1/design_1_rst_ps7_0_20M_1_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_rst_ps7_0_20M_1/design_1_rst_ps7_0_20M_1.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_1/design_1_processing_system7_0_1.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_axi_bram_ctrl_0_0/design_1_axi_bram_ctrl_0_0_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_blk_mem_gen_0_1/design_1_blk_mem_gen_0_1_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_xbar_2/design_1_xbar_2_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_xbar_3/design_1_xbar_3_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_auto_pc_1/design_1_auto_pc_1_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_auto_pc_0/design_1_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_auto_pc_2/design_1_auto_pc_2_ooc.xdc]
set_property used_in_implementation false [get_files -all C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/design_1_ooc.xdc]

read_ip -quiet C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/clk_wiz_1_idelay_refclk/clk_wiz_1_idelay_refclk.xci
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/clk_wiz_1_idelay_refclk/clk_wiz_1_idelay_refclk_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/clk_wiz_1_idelay_refclk/clk_wiz_1_idelay_refclk.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/clk_wiz_1_idelay_refclk/clk_wiz_1_idelay_refclk_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/constrs_2/new/constraints.xdc
set_property used_in_implementation false [get_files C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/constrs_2/new/constraints.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1

read_checkpoint -auto_incremental -incremental C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/utils_1/imports/synth_3/main.dcp
close [open __synthesis_is_running__ w]

synth_design -top main -part xc7z014sclg400-1 -flatten_hierarchy none -directive RuntimeOptimized -fsm_extraction off


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef -incremental_synth main.dcp
create_report "synth_3_synth_report_utilization_0" "report_utilization -file main_utilization_synth.rpt -pb main_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]


################################################################
# This is a generated script based on design: bd_f60c
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bd_f60c_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z014sclg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bd_f60c

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design -bdsource SBD $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set clk [ create_bd_port -dir I -type clk clk ]
  set probe0 [ create_bd_port -dir I -from 5 -to 0 probe0 ]
  set probe1 [ create_bd_port -dir I -from 0 -to 0 probe1 ]
  set probe2 [ create_bd_port -dir I -from 0 -to 0 probe2 ]
  set probe3 [ create_bd_port -dir I -from 31 -to 0 probe3 ]
  set probe4 [ create_bd_port -dir I -from 31 -to 0 probe4 ]
  set probe5 [ create_bd_port -dir I -from 10 -to 0 probe5 ]
  set probe6 [ create_bd_port -dir I -from 15 -to 0 probe6 ]
  set probe7 [ create_bd_port -dir I -from 15 -to 0 probe7 ]
  set probe8 [ create_bd_port -dir I -from 0 -to 0 probe8 ]
  set probe9 [ create_bd_port -dir I -from 0 -to 0 probe9 ]
  set probe10 [ create_bd_port -dir I -from 0 -to 0 probe10 ]
  set probe11 [ create_bd_port -dir I -from 0 -to 0 probe11 ]
  set probe12 [ create_bd_port -dir I -from 31 -to 0 probe12 ]
  set probe13 [ create_bd_port -dir I -from 0 -to 0 probe13 ]
  set probe14 [ create_bd_port -dir I -from 63 -to 0 probe14 ]
  set probe15 [ create_bd_port -dir I -from 0 -to 0 probe15 ]
  set probe16 [ create_bd_port -dir I -from 0 -to 0 probe16 ]
  set probe17 [ create_bd_port -dir I -from 0 -to 0 probe17 ]
  set probe18 [ create_bd_port -dir I -from 63 -to 0 probe18 ]
  set probe19 [ create_bd_port -dir I -from 0 -to 0 probe19 ]
  set probe20 [ create_bd_port -dir I -from 0 -to 0 probe20 ]
  set probe21 [ create_bd_port -dir I -from 0 -to 0 probe21 ]
  set probe22 [ create_bd_port -dir I -from 0 -to 0 probe22 ]
  set probe23 [ create_bd_port -dir I -from 0 -to 0 probe23 ]
  set probe24 [ create_bd_port -dir I -from 0 -to 0 probe24 ]
  set probe25 [ create_bd_port -dir I -from 0 -to 0 probe25 ]
  set probe26 [ create_bd_port -dir I -from 0 -to 0 probe26 ]
  set probe27 [ create_bd_port -dir I -from 0 -to 0 probe27 ]
  set probe28 [ create_bd_port -dir I -from 0 -to 0 probe28 ]
  set probe29 [ create_bd_port -dir I -from 0 -to 0 probe29 ]
  set probe30 [ create_bd_port -dir I -from 2 -to 0 probe30 ]
  set probe31 [ create_bd_port -dir I -from 0 -to 0 probe31 ]

  # Create instance: ila_lib, and set properties
  set ila_lib [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_lib ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU {TRUE} \
   CONFIG.ALL_PROBE_SAME_MU_CNT {1} \
   CONFIG.C_ADV_TRIGGER {FALSE} \
   CONFIG.C_DATA_DEPTH {8192} \
   CONFIG.C_EN_STRG_QUAL {0} \
   CONFIG.C_EN_TIME_TAG {0} \
   CONFIG.C_ILA_CLK_FREQ {177777771} \
   CONFIG.C_INPUT_PIPE_STAGES {0} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {32} \
   CONFIG.C_PROBE0_MU_CNT {1} \
   CONFIG.C_PROBE0_TYPE {0} \
   CONFIG.C_PROBE0_WIDTH {6} \
   CONFIG.C_PROBE10_MU_CNT {1} \
   CONFIG.C_PROBE10_TYPE {0} \
   CONFIG.C_PROBE10_WIDTH {1} \
   CONFIG.C_PROBE11_MU_CNT {1} \
   CONFIG.C_PROBE11_TYPE {0} \
   CONFIG.C_PROBE11_WIDTH {1} \
   CONFIG.C_PROBE12_MU_CNT {1} \
   CONFIG.C_PROBE12_TYPE {0} \
   CONFIG.C_PROBE12_WIDTH {32} \
   CONFIG.C_PROBE13_MU_CNT {1} \
   CONFIG.C_PROBE13_TYPE {0} \
   CONFIG.C_PROBE13_WIDTH {1} \
   CONFIG.C_PROBE14_MU_CNT {1} \
   CONFIG.C_PROBE14_TYPE {0} \
   CONFIG.C_PROBE14_WIDTH {64} \
   CONFIG.C_PROBE15_MU_CNT {1} \
   CONFIG.C_PROBE15_TYPE {0} \
   CONFIG.C_PROBE15_WIDTH {1} \
   CONFIG.C_PROBE16_MU_CNT {1} \
   CONFIG.C_PROBE16_TYPE {0} \
   CONFIG.C_PROBE16_WIDTH {1} \
   CONFIG.C_PROBE17_MU_CNT {1} \
   CONFIG.C_PROBE17_TYPE {0} \
   CONFIG.C_PROBE17_WIDTH {1} \
   CONFIG.C_PROBE18_MU_CNT {1} \
   CONFIG.C_PROBE18_TYPE {0} \
   CONFIG.C_PROBE18_WIDTH {64} \
   CONFIG.C_PROBE19_MU_CNT {1} \
   CONFIG.C_PROBE19_TYPE {0} \
   CONFIG.C_PROBE19_WIDTH {1} \
   CONFIG.C_PROBE1_MU_CNT {1} \
   CONFIG.C_PROBE1_TYPE {0} \
   CONFIG.C_PROBE1_WIDTH {1} \
   CONFIG.C_PROBE20_MU_CNT {1} \
   CONFIG.C_PROBE20_TYPE {0} \
   CONFIG.C_PROBE20_WIDTH {1} \
   CONFIG.C_PROBE21_MU_CNT {1} \
   CONFIG.C_PROBE21_TYPE {0} \
   CONFIG.C_PROBE21_WIDTH {1} \
   CONFIG.C_PROBE22_MU_CNT {1} \
   CONFIG.C_PROBE22_TYPE {0} \
   CONFIG.C_PROBE22_WIDTH {1} \
   CONFIG.C_PROBE23_MU_CNT {1} \
   CONFIG.C_PROBE23_TYPE {0} \
   CONFIG.C_PROBE23_WIDTH {1} \
   CONFIG.C_PROBE24_MU_CNT {1} \
   CONFIG.C_PROBE24_TYPE {0} \
   CONFIG.C_PROBE24_WIDTH {1} \
   CONFIG.C_PROBE25_MU_CNT {1} \
   CONFIG.C_PROBE25_TYPE {0} \
   CONFIG.C_PROBE25_WIDTH {1} \
   CONFIG.C_PROBE26_MU_CNT {1} \
   CONFIG.C_PROBE26_TYPE {0} \
   CONFIG.C_PROBE26_WIDTH {1} \
   CONFIG.C_PROBE27_MU_CNT {1} \
   CONFIG.C_PROBE27_TYPE {0} \
   CONFIG.C_PROBE27_WIDTH {1} \
   CONFIG.C_PROBE28_MU_CNT {1} \
   CONFIG.C_PROBE28_TYPE {0} \
   CONFIG.C_PROBE28_WIDTH {1} \
   CONFIG.C_PROBE29_MU_CNT {1} \
   CONFIG.C_PROBE29_TYPE {0} \
   CONFIG.C_PROBE29_WIDTH {1} \
   CONFIG.C_PROBE2_MU_CNT {1} \
   CONFIG.C_PROBE2_TYPE {0} \
   CONFIG.C_PROBE2_WIDTH {1} \
   CONFIG.C_PROBE30_MU_CNT {1} \
   CONFIG.C_PROBE30_TYPE {0} \
   CONFIG.C_PROBE30_WIDTH {3} \
   CONFIG.C_PROBE31_MU_CNT {1} \
   CONFIG.C_PROBE31_TYPE {0} \
   CONFIG.C_PROBE31_WIDTH {1} \
   CONFIG.C_PROBE3_MU_CNT {1} \
   CONFIG.C_PROBE3_TYPE {0} \
   CONFIG.C_PROBE3_WIDTH {32} \
   CONFIG.C_PROBE4_MU_CNT {1} \
   CONFIG.C_PROBE4_TYPE {0} \
   CONFIG.C_PROBE4_WIDTH {32} \
   CONFIG.C_PROBE5_MU_CNT {1} \
   CONFIG.C_PROBE5_TYPE {0} \
   CONFIG.C_PROBE5_WIDTH {11} \
   CONFIG.C_PROBE6_MU_CNT {1} \
   CONFIG.C_PROBE6_TYPE {0} \
   CONFIG.C_PROBE6_WIDTH {16} \
   CONFIG.C_PROBE7_MU_CNT {1} \
   CONFIG.C_PROBE7_TYPE {0} \
   CONFIG.C_PROBE7_WIDTH {16} \
   CONFIG.C_PROBE8_MU_CNT {1} \
   CONFIG.C_PROBE8_TYPE {0} \
   CONFIG.C_PROBE8_WIDTH {1} \
   CONFIG.C_PROBE9_MU_CNT {1} \
   CONFIG.C_PROBE9_TYPE {0} \
   CONFIG.C_PROBE9_WIDTH {1} \
   CONFIG.C_TIME_TAG_WIDTH {32} \
   CONFIG.C_TRIGIN_EN {false} \
   CONFIG.C_TRIGOUT_EN {false} \
   CONFIG.C_XLNX_HW_PROBE_INFO {DEFAULT} \
 ] $ila_lib

  # Create port connections
  connect_bd_net -net clk_1 [get_bd_ports clk] [get_bd_pins ila_lib/clk]
  connect_bd_net -net probe0_1 [get_bd_ports probe0] [get_bd_pins ila_lib/probe0]
  connect_bd_net -net probe10_1 [get_bd_ports probe10] [get_bd_pins ila_lib/probe10]
  connect_bd_net -net probe11_1 [get_bd_ports probe11] [get_bd_pins ila_lib/probe11]
  connect_bd_net -net probe12_1 [get_bd_ports probe12] [get_bd_pins ila_lib/probe12]
  connect_bd_net -net probe13_1 [get_bd_ports probe13] [get_bd_pins ila_lib/probe13]
  connect_bd_net -net probe14_1 [get_bd_ports probe14] [get_bd_pins ila_lib/probe14]
  connect_bd_net -net probe15_1 [get_bd_ports probe15] [get_bd_pins ila_lib/probe15]
  connect_bd_net -net probe16_1 [get_bd_ports probe16] [get_bd_pins ila_lib/probe16]
  connect_bd_net -net probe17_1 [get_bd_ports probe17] [get_bd_pins ila_lib/probe17]
  connect_bd_net -net probe18_1 [get_bd_ports probe18] [get_bd_pins ila_lib/probe18]
  connect_bd_net -net probe19_1 [get_bd_ports probe19] [get_bd_pins ila_lib/probe19]
  connect_bd_net -net probe1_1 [get_bd_ports probe1] [get_bd_pins ila_lib/probe1]
  connect_bd_net -net probe20_1 [get_bd_ports probe20] [get_bd_pins ila_lib/probe20]
  connect_bd_net -net probe21_1 [get_bd_ports probe21] [get_bd_pins ila_lib/probe21]
  connect_bd_net -net probe22_1 [get_bd_ports probe22] [get_bd_pins ila_lib/probe22]
  connect_bd_net -net probe23_1 [get_bd_ports probe23] [get_bd_pins ila_lib/probe23]
  connect_bd_net -net probe24_1 [get_bd_ports probe24] [get_bd_pins ila_lib/probe24]
  connect_bd_net -net probe25_1 [get_bd_ports probe25] [get_bd_pins ila_lib/probe25]
  connect_bd_net -net probe26_1 [get_bd_ports probe26] [get_bd_pins ila_lib/probe26]
  connect_bd_net -net probe27_1 [get_bd_ports probe27] [get_bd_pins ila_lib/probe27]
  connect_bd_net -net probe28_1 [get_bd_ports probe28] [get_bd_pins ila_lib/probe28]
  connect_bd_net -net probe29_1 [get_bd_ports probe29] [get_bd_pins ila_lib/probe29]
  connect_bd_net -net probe2_1 [get_bd_ports probe2] [get_bd_pins ila_lib/probe2]
  connect_bd_net -net probe30_1 [get_bd_ports probe30] [get_bd_pins ila_lib/probe30]
  connect_bd_net -net probe31_1 [get_bd_ports probe31] [get_bd_pins ila_lib/probe31]
  connect_bd_net -net probe3_1 [get_bd_ports probe3] [get_bd_pins ila_lib/probe3]
  connect_bd_net -net probe4_1 [get_bd_ports probe4] [get_bd_pins ila_lib/probe4]
  connect_bd_net -net probe5_1 [get_bd_ports probe5] [get_bd_pins ila_lib/probe5]
  connect_bd_net -net probe6_1 [get_bd_ports probe6] [get_bd_pins ila_lib/probe6]
  connect_bd_net -net probe7_1 [get_bd_ports probe7] [get_bd_pins ila_lib/probe7]
  connect_bd_net -net probe8_1 [get_bd_ports probe8] [get_bd_pins ila_lib/probe8]
  connect_bd_net -net probe9_1 [get_bd_ports probe9] [get_bd_pins ila_lib/probe9]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""



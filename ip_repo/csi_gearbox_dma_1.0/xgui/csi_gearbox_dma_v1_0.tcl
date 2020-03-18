# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXIS_TDATA_WIDTH" -parent ${Page_0} -widget comboBox

  ipgui::add_param $IPINST -name "C_PN_SWAP_D0"
  ipgui::add_param $IPINST -name "C_PN_SWAP_D1"
  ipgui::add_param $IPINST -name "C_PN_SWAP_CLK"

}

proc update_PARAM_VALUE.C_PN_SWAP_CLK { PARAM_VALUE.C_PN_SWAP_CLK } {
	# Procedure called to update C_PN_SWAP_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PN_SWAP_CLK { PARAM_VALUE.C_PN_SWAP_CLK } {
	# Procedure called to validate C_PN_SWAP_CLK
	return true
}

proc update_PARAM_VALUE.C_PN_SWAP_D0 { PARAM_VALUE.C_PN_SWAP_D0 } {
	# Procedure called to update C_PN_SWAP_D0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PN_SWAP_D0 { PARAM_VALUE.C_PN_SWAP_D0 } {
	# Procedure called to validate C_PN_SWAP_D0
	return true
}

proc update_PARAM_VALUE.C_PN_SWAP_D1 { PARAM_VALUE.C_PN_SWAP_D1 } {
	# Procedure called to update C_PN_SWAP_D1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_PN_SWAP_D1 { PARAM_VALUE.C_PN_SWAP_D1 } {
	# Procedure called to validate C_PN_SWAP_D1
	return true
}

proc update_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S00_AXIS_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_PN_SWAP_D0 { MODELPARAM_VALUE.C_PN_SWAP_D0 PARAM_VALUE.C_PN_SWAP_D0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PN_SWAP_D0}] ${MODELPARAM_VALUE.C_PN_SWAP_D0}
}

proc update_MODELPARAM_VALUE.C_PN_SWAP_D1 { MODELPARAM_VALUE.C_PN_SWAP_D1 PARAM_VALUE.C_PN_SWAP_D1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PN_SWAP_D1}] ${MODELPARAM_VALUE.C_PN_SWAP_D1}
}

proc update_MODELPARAM_VALUE.C_PN_SWAP_CLK { MODELPARAM_VALUE.C_PN_SWAP_CLK PARAM_VALUE.C_PN_SWAP_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_PN_SWAP_CLK}] ${MODELPARAM_VALUE.C_PN_SWAP_CLK}
}


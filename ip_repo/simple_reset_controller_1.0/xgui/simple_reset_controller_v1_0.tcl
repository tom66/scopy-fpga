# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.G_RST_PULSE_WIDTH { PARAM_VALUE.G_RST_PULSE_WIDTH } {
	# Procedure called to update G_RST_PULSE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.G_RST_PULSE_WIDTH { PARAM_VALUE.G_RST_PULSE_WIDTH } {
	# Procedure called to validate G_RST_PULSE_WIDTH
	return true
}

proc update_PARAM_VALUE.G_RST_START { PARAM_VALUE.G_RST_START } {
	# Procedure called to update G_RST_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.G_RST_START { PARAM_VALUE.G_RST_START } {
	# Procedure called to validate G_RST_START
	return true
}


proc update_MODELPARAM_VALUE.G_RST_START { MODELPARAM_VALUE.G_RST_START PARAM_VALUE.G_RST_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.G_RST_START}] ${MODELPARAM_VALUE.G_RST_START}
}

proc update_MODELPARAM_VALUE.G_RST_PULSE_WIDTH { MODELPARAM_VALUE.G_RST_PULSE_WIDTH PARAM_VALUE.G_RST_PULSE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.G_RST_PULSE_WIDTH}] ${MODELPARAM_VALUE.G_RST_PULSE_WIDTH}
}


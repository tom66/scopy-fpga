# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "LED_BYTE_CHANNEL"

}

proc update_PARAM_VALUE.LED_BYTE_CHANNEL { PARAM_VALUE.LED_BYTE_CHANNEL } {
	# Procedure called to update LED_BYTE_CHANNEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LED_BYTE_CHANNEL { PARAM_VALUE.LED_BYTE_CHANNEL } {
	# Procedure called to validate LED_BYTE_CHANNEL
	return true
}


proc update_MODELPARAM_VALUE.LED_BYTE_CHANNEL { MODELPARAM_VALUE.LED_BYTE_CHANNEL PARAM_VALUE.LED_BYTE_CHANNEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LED_BYTE_CHANNEL}] ${MODELPARAM_VALUE.LED_BYTE_CHANNEL}
}


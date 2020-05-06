## SPI Interface to MCU ##
set_property IOSTANDARD LVCMOS18 [get_ports fpga_irq1]
set_property PACKAGE_PIN M15 [get_ports fpga_irq1]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_irq2]
set_property PACKAGE_PIN J16 [get_ports fpga_irq2]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_irq3]
set_property PACKAGE_PIN J15 [get_ports fpga_irq3]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_spi_miso]
set_property PACKAGE_PIN M14 [get_ports fpga_spi_miso]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_spi_mosi]
set_property PACKAGE_PIN L15 [get_ports fpga_spi_mosi]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_spi_sclk]
set_property PACKAGE_PIN L14 [get_ports fpga_spi_sclk]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_spi_csn]
set_property PACKAGE_PIN N16 [get_ports fpga_spi_csn]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_heartbeat]
set_property PACKAGE_PIN K19 [get_ports fpga_heartbeat]

## Generic IO ##

# Diagnostic LEDs
set_property IOSTANDARD LVCMOS25 [get_ports led_PL0]
set_property PACKAGE_PIN T19 [get_ports led_PL0]
set_property IOSTANDARD LVCMOS25 [get_ports led_PL1]
set_property PACKAGE_PIN R19 [get_ports led_PL1]

## Camera Interface ##

# Current configuration uses CAM1 (AUX port on MVP board) for camera, but only two lanes are implemented
# This is in line with the standard Raspberry Pi configuration.

# HS signalling for CSI
# CSI_RAW_D0_AUX_P/CSI_RAW_D0_AUX_N (HS data) - p/n data inverted in Verilog
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d0_p]
set_property PACKAGE_PIN B19 [get_ports csi_d0_p]

# CSI_RAW_D1_AUX_P/CSI_RAW_D1_AUX_N (HS data) - p/n data inverted in Verilog
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d1_n]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d1_p]
set_property PACKAGE_PIN C20 [get_ports csi_d1_p]
set_property PACKAGE_PIN B20 [get_ports csi_d1_n]

# CSI_RAW_CLK_AUX_N/CSI_RAW_CLK_AUX_P (HS data) - p/n data inverted in Verilog
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_clk_n]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_clk_p]
set_property PACKAGE_PIN G19 [get_ports csi_clk_p]
set_property PACKAGE_PIN G20 [get_ports csi_clk_n]

# LP signalling for CSI
# CSI_LPD0_AUX_P, CSI_LPD0_AUX_N
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd0_n]
set_property PACKAGE_PIN G17 [get_ports csi_lpd0_n]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd0_p]
set_property PACKAGE_PIN G18 [get_ports csi_lpd0_p]

# CSI_LPD1_AUX_P, CSI_LPD1_AUX_N
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd1_n]
set_property PACKAGE_PIN F19 [get_ports csi_lpd1_n]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd1_p]
set_property PACKAGE_PIN F20 [get_ports csi_lpd1_p]

# CSI_LPCLK_AUX_P, CSI_LPCLK_AUX_N
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpclk_n]
set_property PACKAGE_PIN E17 [get_ports csi_lpclk_n]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpclk_p]
set_property PACKAGE_PIN D18 [get_ports csi_lpclk_p]

## ADC Interface ##

# ADC_L4A_N, ADC_L4A_P:  This pair inverted (at parallel end)
set_property IOSTANDARD LVDS_25 [get_ports adc_l4a_p]
set_property DIFF_TERM TRUE [get_ports adc_l4a_p]
set_property PACKAGE_PIN Y16 [get_ports adc_l4a_p]
set_property PACKAGE_PIN Y17 [get_ports adc_l4a_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l4a_n]
set_property DIFF_TERM TRUE [get_ports adc_l4a_n]

# ADC_L4B_N, ADC_L4B_P:  This pair not inverted
set_property IOSTANDARD LVDS_25 [get_ports adc_l4b_p]
set_property DIFF_TERM TRUE [get_ports adc_l4b_p]
set_property PACKAGE_PIN W14 [get_ports adc_l4b_p]
set_property PACKAGE_PIN Y14 [get_ports adc_l4b_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l4b_n]
set_property DIFF_TERM TRUE [get_ports adc_l4b_n]

# ADC_L3B_N, ADC_L3B_P:  This pair inverted (at parallel end)
set_property IOSTANDARD LVDS_25 [get_ports adc_l3b_p]
set_property DIFF_TERM TRUE [get_ports adc_l3b_p]
set_property PACKAGE_PIN V15 [get_ports adc_l3b_p]
set_property PACKAGE_PIN W15 [get_ports adc_l3b_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l3b_n]
set_property DIFF_TERM TRUE [get_ports adc_l3b_n]

# ADC_L3A_N, ADC_L3A_P:  This pair inverted (at parallel end)
set_property IOSTANDARD LVDS_25 [get_ports adc_l3a_p]
set_property DIFF_TERM TRUE [get_ports adc_l3a_p]
set_property PACKAGE_PIN V16 [get_ports adc_l3a_p]
set_property PACKAGE_PIN W16 [get_ports adc_l3a_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l3a_n]
set_property DIFF_TERM TRUE [get_ports adc_l3a_n]

# ADC_L2B_N, ADC_L2B_P:  This pair inverted (at parallel end)
set_property IOSTANDARD LVDS_25 [get_ports adc_l2b_p]
set_property DIFF_TERM TRUE [get_ports adc_l2b_p]
set_property PACKAGE_PIN Y18 [get_ports adc_l2b_p]
set_property PACKAGE_PIN Y19 [get_ports adc_l2b_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l2b_n]
set_property DIFF_TERM TRUE [get_ports adc_l2b_n]

# ADC_L2A_N, ADC_L2A_P:  This pair inverted (at parallel end)
set_property IOSTANDARD LVDS_25 [get_ports adc_l2a_p]
set_property DIFF_TERM TRUE [get_ports adc_l2a_p]
set_property PACKAGE_PIN U14 [get_ports adc_l2a_p]
set_property PACKAGE_PIN U15 [get_ports adc_l2a_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l2a_n]
set_property DIFF_TERM TRUE [get_ports adc_l2a_n]

# ADC_L1B_N, ADC_L1B_P:  This pair not inverted
set_property IOSTANDARD LVDS_25 [get_ports adc_l1b_p]
set_property DIFF_TERM TRUE [get_ports adc_l1b_p]
set_property PACKAGE_PIN V17 [get_ports adc_l1b_p]
set_property PACKAGE_PIN V18 [get_ports adc_l1b_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l1b_n]
set_property DIFF_TERM TRUE [get_ports adc_l1b_n]

# ADC_L1A_N, ADC_L1A_P:  This pair not inverted
set_property IOSTANDARD LVDS_25 [get_ports adc_l1a_p]
set_property DIFF_TERM TRUE [get_ports adc_l1a_p]
set_property PACKAGE_PIN W18 [get_ports adc_l1a_p]
set_property PACKAGE_PIN W19 [get_ports adc_l1a_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_l1a_n]
set_property DIFF_TERM TRUE [get_ports adc_l1a_n]

# ADC_LCLK_N, ADC_LCLK_P:  This pair not inverted - MRCC clock
set_property IOSTANDARD LVDS_25 [get_ports adc_lclk_p]
set_property DIFF_TERM TRUE [get_ports adc_lclk_p]
set_property PACKAGE_PIN U18 [get_ports adc_lclk_p]
set_property PACKAGE_PIN U19 [get_ports adc_lclk_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_lclk_n]
set_property DIFF_TERM TRUE [get_ports adc_lclk_n]

# ADC_FCLK_N, ADC_FCLK_P:  This pair not inverted - MRCC clock (used as framing data)
set_property IOSTANDARD LVDS_25 [get_ports adc_fclk_p]
set_property DIFF_TERM TRUE [get_ports adc_fclk_p]
set_property PACKAGE_PIN N18 [get_ports adc_fclk_p]
set_property PACKAGE_PIN P19 [get_ports adc_fclk_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_fclk_n]
set_property DIFF_TERM TRUE [get_ports adc_fclk_n]

# Timing constraints for ADC bus into FPGA
create_clock -period 1.000 -name adc_lvds_clk -waveform {0.000 0.500} [get_ports adc_lclk_p]
create_clock -period 8.000 -name adc_frame_clk -waveform {0.000 4.000} [get_ports adc_fclk_p]

# Untimed registers:  the time for register data to settle configuration in the ADC/trigger
# core is not guaranteed so relax these.

# Old timing constraints
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_fclk_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_fclk_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l1a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l1a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l1a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l1a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l1b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l1b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l1b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l1b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l2a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l2a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l2a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l2a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l2b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l2b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l2b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l2b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l3a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l3a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l3a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l3a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l3b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l3b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l3b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l3b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l4a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l4a_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l4a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l4a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 10.100 [get_ports adc_l4b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min 9.900 [get_ports adc_l4b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min -0.100 [get_ports adc_l4a_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 0.100 [get_ports adc_l4b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min -0.100 [get_ports adc_l4b_p]
#set_input_delay -clock [get_clocks adc_lvds_clk] -max 0.100 [get_ports adc_l4b_n]
#set_input_delay -clock [get_clocks adc_lvds_clk] -min -0.100 [get_ports adc_l4b_n]



set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg38_reg[25]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/adc_trigger_core_4567a/adc_trigger_core_inner_1a1b/comp_ev_counter_reg[0]/D}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg39_reg[23]/C}] -to [get_pins nolabel_line119/adc_trigger_0/inst/adc_trigger_core_4567a/adc_trigger_core_inner_2a2b/comp_ch_b_reg/D]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg39_reg[20]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/adc_trigger_core_4567a/adc_trigger_core_inner_2a2b/comp_ev_counter_reg[0]/D}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg39_reg[20]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/adc_trigger_core_4567a/adc_trigger_core_inner_2a2b/comp_ev_counter_reg[1]/D}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg39_reg[20]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/adc_trigger_core_4567a/adc_trigger_core_inner_2a2b/comp_state_next_reg[0]/D}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg39_reg[20]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/adc_trigger_core_4567a/adc_trigger_core_inner_2a2b/comp_state_next_reg[1]/D}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg44_reg[28]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/FSM_sequential_trig_state_reg[1]/CE}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg44_reg[28]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/FSM_sequential_trig_state_reg[2]/CE}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg44_reg[28]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/trig_state_reg[0]/CE}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg44_reg[28]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/trig_state_reg[0]/CE}]
set_false_path -from [get_pins {nolabel_line119/FabCfg_NextGen_0/inst/FabCfg_NextGen_v1_0_S00_AXI_inst/slv_reg44_reg[28]/C}] -to [get_pins {nolabel_line119/adc_trigger_0/inst/trig_state_reg[1]/CE}]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_master]

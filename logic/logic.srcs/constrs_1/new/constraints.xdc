set_property PACKAGE_PIN T19 [get_ports led_PL0]
set_property IOSTANDARD LVCMOS25 [get_ports led_PL0]
set_property PACKAGE_PIN R19 [get_ports led_PL1]
set_property IOSTANDARD LVCMOS25 [get_ports led_PL1]

# Current configuration uses CAM1 (AUX port on MVP board) for camera, but only two lanes are implemented
# This is in line with the standard Raspberry Pi configuration.

# HS signalling for CSI
# CSI_RAW_D0_AUX_P/CSI_RAW_D0_AUX_N (HS data) - p/n data inverted in Verilog
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d0_p]
set_property PACKAGE_PIN B19 [get_ports csi_d0_p]
set_property PACKAGE_PIN A20 [get_ports csi_d0_n]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d0_n]

# CSI_RAW_D1_AUX_P/CSI_RAW_D1_AUX_N (HS data) - p/n data inverted in Verilog
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d1_p]
set_property PACKAGE_PIN C20 [get_ports csi_d1_p]
set_property PACKAGE_PIN B20 [get_ports csi_d1_n]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_d1_n]

# CSI_RAW_CLK_AUX_N/CSI_RAW_CLK_AUX_P (HS data) - p/n data inverted in Verilog
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_clk_p]
set_property PACKAGE_PIN G19 [get_ports csi_clk_p]
set_property PACKAGE_PIN G20 [get_ports csi_clk_n]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports csi_clk_n]

# LP signalling for CSI
# CSI_LPD0_AUX_P, CSI_LPD0_AUX_N 
set_property PACKAGE_PIN G18 [get_ports csi_lpd0_p]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd0_p]
set_property PACKAGE_PIN G17 [get_ports csi_lpd0_n]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd0_n]

# CSI_LPD1_AUX_P, CSI_LPD1_AUX_N 
set_property PACKAGE_PIN F20 [get_ports csi_lpd1_p]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd1_p]
set_property PACKAGE_PIN F19 [get_ports csi_lpd1_n]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpd1_n]

# CSI_LPCLK_AUX_P, CSI_LPCLK_AUX_N 
set_property PACKAGE_PIN D18 [get_ports csi_lpclk_p]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpclk_p]
set_property PACKAGE_PIN E17 [get_ports csi_lpclk_n]
set_property IOSTANDARD LVCMOS18 [get_ports csi_lpclk_n]

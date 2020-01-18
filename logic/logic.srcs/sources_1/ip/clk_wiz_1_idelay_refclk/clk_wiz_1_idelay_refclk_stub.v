// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Jan 17 15:45:58 2020
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/clk_wiz_1_idelay_refclk/clk_wiz_1_idelay_refclk_stub.v
// Design      : clk_wiz_1_idelay_refclk
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_1_idelay_refclk(clk_out1, reset, power_down, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,reset,power_down,locked,clk_in1" */;
  output clk_out1;
  input reset;
  input power_down;
  output locked;
  input clk_in1;
endmodule
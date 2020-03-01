// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Sun Feb 23 15:49:11 2020
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_out1_0, clk_out1_90, clk_out1_180, 
  clk_out1_270, power_down, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1_0,clk_out1_90,clk_out1_180,clk_out1_270,power_down,locked,clk_in1" */;
  output clk_out1_0;
  output clk_out1_90;
  output clk_out1_180;
  output clk_out1_270;
  input power_down;
  output locked;
  input clk_in1;
endmodule

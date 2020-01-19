// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sat Jan 18 23:04:27 2020
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_system_ila_0_1/design_1_system_ila_0_1_stub.v
// Design      : design_1_system_ila_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "bd_36cd,Vivado 2018.3" *)
module design_1_system_ila_0_1(clk, SLOT_0_AXIS_tdata, SLOT_0_AXIS_tstrb, 
  SLOT_0_AXIS_tlast, SLOT_0_AXIS_tvalid, SLOT_0_AXIS_tready, resetn)
/* synthesis syn_black_box black_box_pad_pin="clk,SLOT_0_AXIS_tdata[63:0],SLOT_0_AXIS_tstrb[7:0],SLOT_0_AXIS_tlast,SLOT_0_AXIS_tvalid,SLOT_0_AXIS_tready,resetn" */;
  input clk;
  input [63:0]SLOT_0_AXIS_tdata;
  input [7:0]SLOT_0_AXIS_tstrb;
  input SLOT_0_AXIS_tlast;
  input SLOT_0_AXIS_tvalid;
  input SLOT_0_AXIS_tready;
  input resetn;
endmodule

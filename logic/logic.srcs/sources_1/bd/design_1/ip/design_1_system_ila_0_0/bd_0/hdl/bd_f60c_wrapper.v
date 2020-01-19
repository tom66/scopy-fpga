//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_f60c_wrapper.bd
//Design : bd_f60c_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_f60c_wrapper
   (SLOT_0_AXIS_tdata,
    SLOT_0_AXIS_tlast,
    SLOT_0_AXIS_tready,
    SLOT_0_AXIS_tstrb,
    SLOT_0_AXIS_tvalid,
    SLOT_1_AXI_araddr,
    SLOT_1_AXI_arid,
    SLOT_1_AXI_arlen,
    SLOT_1_AXI_arprot,
    SLOT_1_AXI_arready,
    SLOT_1_AXI_arsize,
    SLOT_1_AXI_arvalid,
    SLOT_1_AXI_awaddr,
    SLOT_1_AXI_awid,
    SLOT_1_AXI_awlen,
    SLOT_1_AXI_awprot,
    SLOT_1_AXI_awready,
    SLOT_1_AXI_awsize,
    SLOT_1_AXI_awvalid,
    SLOT_1_AXI_bid,
    SLOT_1_AXI_bready,
    SLOT_1_AXI_bresp,
    SLOT_1_AXI_bvalid,
    SLOT_1_AXI_rdata,
    SLOT_1_AXI_rid,
    SLOT_1_AXI_rlast,
    SLOT_1_AXI_rready,
    SLOT_1_AXI_rresp,
    SLOT_1_AXI_rvalid,
    SLOT_1_AXI_wdata,
    SLOT_1_AXI_wid,
    SLOT_1_AXI_wlast,
    SLOT_1_AXI_wready,
    SLOT_1_AXI_wstrb,
    SLOT_1_AXI_wvalid,
    clk,
    resetn);
  input [63:0]SLOT_0_AXIS_tdata;
  input SLOT_0_AXIS_tlast;
  input SLOT_0_AXIS_tready;
  input [7:0]SLOT_0_AXIS_tstrb;
  input SLOT_0_AXIS_tvalid;
  input [31:0]SLOT_1_AXI_araddr;
  input [0:0]SLOT_1_AXI_arid;
  input [3:0]SLOT_1_AXI_arlen;
  input [2:0]SLOT_1_AXI_arprot;
  input SLOT_1_AXI_arready;
  input [2:0]SLOT_1_AXI_arsize;
  input SLOT_1_AXI_arvalid;
  input [31:0]SLOT_1_AXI_awaddr;
  input [0:0]SLOT_1_AXI_awid;
  input [3:0]SLOT_1_AXI_awlen;
  input [2:0]SLOT_1_AXI_awprot;
  input SLOT_1_AXI_awready;
  input [2:0]SLOT_1_AXI_awsize;
  input SLOT_1_AXI_awvalid;
  input [0:0]SLOT_1_AXI_bid;
  input SLOT_1_AXI_bready;
  input [1:0]SLOT_1_AXI_bresp;
  input SLOT_1_AXI_bvalid;
  input [63:0]SLOT_1_AXI_rdata;
  input [0:0]SLOT_1_AXI_rid;
  input SLOT_1_AXI_rlast;
  input SLOT_1_AXI_rready;
  input [1:0]SLOT_1_AXI_rresp;
  input SLOT_1_AXI_rvalid;
  input [63:0]SLOT_1_AXI_wdata;
  input [0:0]SLOT_1_AXI_wid;
  input SLOT_1_AXI_wlast;
  input SLOT_1_AXI_wready;
  input [7:0]SLOT_1_AXI_wstrb;
  input SLOT_1_AXI_wvalid;
  input clk;
  input resetn;

  wire [63:0]SLOT_0_AXIS_tdata;
  wire SLOT_0_AXIS_tlast;
  wire SLOT_0_AXIS_tready;
  wire [7:0]SLOT_0_AXIS_tstrb;
  wire SLOT_0_AXIS_tvalid;
  wire [31:0]SLOT_1_AXI_araddr;
  wire [0:0]SLOT_1_AXI_arid;
  wire [3:0]SLOT_1_AXI_arlen;
  wire [2:0]SLOT_1_AXI_arprot;
  wire SLOT_1_AXI_arready;
  wire [2:0]SLOT_1_AXI_arsize;
  wire SLOT_1_AXI_arvalid;
  wire [31:0]SLOT_1_AXI_awaddr;
  wire [0:0]SLOT_1_AXI_awid;
  wire [3:0]SLOT_1_AXI_awlen;
  wire [2:0]SLOT_1_AXI_awprot;
  wire SLOT_1_AXI_awready;
  wire [2:0]SLOT_1_AXI_awsize;
  wire SLOT_1_AXI_awvalid;
  wire [0:0]SLOT_1_AXI_bid;
  wire SLOT_1_AXI_bready;
  wire [1:0]SLOT_1_AXI_bresp;
  wire SLOT_1_AXI_bvalid;
  wire [63:0]SLOT_1_AXI_rdata;
  wire [0:0]SLOT_1_AXI_rid;
  wire SLOT_1_AXI_rlast;
  wire SLOT_1_AXI_rready;
  wire [1:0]SLOT_1_AXI_rresp;
  wire SLOT_1_AXI_rvalid;
  wire [63:0]SLOT_1_AXI_wdata;
  wire [0:0]SLOT_1_AXI_wid;
  wire SLOT_1_AXI_wlast;
  wire SLOT_1_AXI_wready;
  wire [7:0]SLOT_1_AXI_wstrb;
  wire SLOT_1_AXI_wvalid;
  wire clk;
  wire resetn;

  bd_f60c bd_f60c_i
       (.SLOT_0_AXIS_tdata(SLOT_0_AXIS_tdata),
        .SLOT_0_AXIS_tlast(SLOT_0_AXIS_tlast),
        .SLOT_0_AXIS_tready(SLOT_0_AXIS_tready),
        .SLOT_0_AXIS_tstrb(SLOT_0_AXIS_tstrb),
        .SLOT_0_AXIS_tvalid(SLOT_0_AXIS_tvalid),
        .SLOT_1_AXI_araddr(SLOT_1_AXI_araddr),
        .SLOT_1_AXI_arid(SLOT_1_AXI_arid),
        .SLOT_1_AXI_arlen(SLOT_1_AXI_arlen),
        .SLOT_1_AXI_arprot(SLOT_1_AXI_arprot),
        .SLOT_1_AXI_arready(SLOT_1_AXI_arready),
        .SLOT_1_AXI_arsize(SLOT_1_AXI_arsize),
        .SLOT_1_AXI_arvalid(SLOT_1_AXI_arvalid),
        .SLOT_1_AXI_awaddr(SLOT_1_AXI_awaddr),
        .SLOT_1_AXI_awid(SLOT_1_AXI_awid),
        .SLOT_1_AXI_awlen(SLOT_1_AXI_awlen),
        .SLOT_1_AXI_awprot(SLOT_1_AXI_awprot),
        .SLOT_1_AXI_awready(SLOT_1_AXI_awready),
        .SLOT_1_AXI_awsize(SLOT_1_AXI_awsize),
        .SLOT_1_AXI_awvalid(SLOT_1_AXI_awvalid),
        .SLOT_1_AXI_bid(SLOT_1_AXI_bid),
        .SLOT_1_AXI_bready(SLOT_1_AXI_bready),
        .SLOT_1_AXI_bresp(SLOT_1_AXI_bresp),
        .SLOT_1_AXI_bvalid(SLOT_1_AXI_bvalid),
        .SLOT_1_AXI_rdata(SLOT_1_AXI_rdata),
        .SLOT_1_AXI_rid(SLOT_1_AXI_rid),
        .SLOT_1_AXI_rlast(SLOT_1_AXI_rlast),
        .SLOT_1_AXI_rready(SLOT_1_AXI_rready),
        .SLOT_1_AXI_rresp(SLOT_1_AXI_rresp),
        .SLOT_1_AXI_rvalid(SLOT_1_AXI_rvalid),
        .SLOT_1_AXI_wdata(SLOT_1_AXI_wdata),
        .SLOT_1_AXI_wid(SLOT_1_AXI_wid),
        .SLOT_1_AXI_wlast(SLOT_1_AXI_wlast),
        .SLOT_1_AXI_wready(SLOT_1_AXI_wready),
        .SLOT_1_AXI_wstrb(SLOT_1_AXI_wstrb),
        .SLOT_1_AXI_wvalid(SLOT_1_AXI_wvalid),
        .clk(clk),
        .resetn(resetn));
endmodule

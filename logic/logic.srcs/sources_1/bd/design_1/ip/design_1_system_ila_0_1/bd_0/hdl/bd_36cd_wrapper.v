//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_36cd_wrapper.bd
//Design : bd_36cd_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_36cd_wrapper
   (SLOT_0_AXI_araddr,
    SLOT_0_AXI_arburst,
    SLOT_0_AXI_arcache,
    SLOT_0_AXI_arid,
    SLOT_0_AXI_arlen,
    SLOT_0_AXI_arlock,
    SLOT_0_AXI_arprot,
    SLOT_0_AXI_arqos,
    SLOT_0_AXI_arready,
    SLOT_0_AXI_arsize,
    SLOT_0_AXI_arvalid,
    SLOT_0_AXI_awaddr,
    SLOT_0_AXI_awburst,
    SLOT_0_AXI_awcache,
    SLOT_0_AXI_awid,
    SLOT_0_AXI_awlen,
    SLOT_0_AXI_awlock,
    SLOT_0_AXI_awprot,
    SLOT_0_AXI_awqos,
    SLOT_0_AXI_awready,
    SLOT_0_AXI_awsize,
    SLOT_0_AXI_awvalid,
    SLOT_0_AXI_bid,
    SLOT_0_AXI_bready,
    SLOT_0_AXI_bresp,
    SLOT_0_AXI_bvalid,
    SLOT_0_AXI_rdata,
    SLOT_0_AXI_rid,
    SLOT_0_AXI_rlast,
    SLOT_0_AXI_rready,
    SLOT_0_AXI_rresp,
    SLOT_0_AXI_rvalid,
    SLOT_0_AXI_wdata,
    SLOT_0_AXI_wid,
    SLOT_0_AXI_wlast,
    SLOT_0_AXI_wready,
    SLOT_0_AXI_wstrb,
    SLOT_0_AXI_wvalid,
    clk,
    probe0,
    probe1,
    probe2,
    probe3,
    probe4,
    probe5,
    resetn);
  input [31:0]SLOT_0_AXI_araddr;
  input [1:0]SLOT_0_AXI_arburst;
  input [3:0]SLOT_0_AXI_arcache;
  input [11:0]SLOT_0_AXI_arid;
  input [3:0]SLOT_0_AXI_arlen;
  input [1:0]SLOT_0_AXI_arlock;
  input [2:0]SLOT_0_AXI_arprot;
  input [3:0]SLOT_0_AXI_arqos;
  input SLOT_0_AXI_arready;
  input [2:0]SLOT_0_AXI_arsize;
  input SLOT_0_AXI_arvalid;
  input [31:0]SLOT_0_AXI_awaddr;
  input [1:0]SLOT_0_AXI_awburst;
  input [3:0]SLOT_0_AXI_awcache;
  input [11:0]SLOT_0_AXI_awid;
  input [3:0]SLOT_0_AXI_awlen;
  input [1:0]SLOT_0_AXI_awlock;
  input [2:0]SLOT_0_AXI_awprot;
  input [3:0]SLOT_0_AXI_awqos;
  input SLOT_0_AXI_awready;
  input [2:0]SLOT_0_AXI_awsize;
  input SLOT_0_AXI_awvalid;
  input [11:0]SLOT_0_AXI_bid;
  input SLOT_0_AXI_bready;
  input [1:0]SLOT_0_AXI_bresp;
  input SLOT_0_AXI_bvalid;
  input [31:0]SLOT_0_AXI_rdata;
  input [11:0]SLOT_0_AXI_rid;
  input SLOT_0_AXI_rlast;
  input SLOT_0_AXI_rready;
  input [1:0]SLOT_0_AXI_rresp;
  input SLOT_0_AXI_rvalid;
  input [31:0]SLOT_0_AXI_wdata;
  input [11:0]SLOT_0_AXI_wid;
  input SLOT_0_AXI_wlast;
  input SLOT_0_AXI_wready;
  input [3:0]SLOT_0_AXI_wstrb;
  input SLOT_0_AXI_wvalid;
  input clk;
  input [1:0]probe0;
  input [2:0]probe1;
  input [31:0]probe2;
  input [31:0]probe3;
  input [31:0]probe4;
  input [0:0]probe5;
  input resetn;

  wire [31:0]SLOT_0_AXI_araddr;
  wire [1:0]SLOT_0_AXI_arburst;
  wire [3:0]SLOT_0_AXI_arcache;
  wire [11:0]SLOT_0_AXI_arid;
  wire [3:0]SLOT_0_AXI_arlen;
  wire [1:0]SLOT_0_AXI_arlock;
  wire [2:0]SLOT_0_AXI_arprot;
  wire [3:0]SLOT_0_AXI_arqos;
  wire SLOT_0_AXI_arready;
  wire [2:0]SLOT_0_AXI_arsize;
  wire SLOT_0_AXI_arvalid;
  wire [31:0]SLOT_0_AXI_awaddr;
  wire [1:0]SLOT_0_AXI_awburst;
  wire [3:0]SLOT_0_AXI_awcache;
  wire [11:0]SLOT_0_AXI_awid;
  wire [3:0]SLOT_0_AXI_awlen;
  wire [1:0]SLOT_0_AXI_awlock;
  wire [2:0]SLOT_0_AXI_awprot;
  wire [3:0]SLOT_0_AXI_awqos;
  wire SLOT_0_AXI_awready;
  wire [2:0]SLOT_0_AXI_awsize;
  wire SLOT_0_AXI_awvalid;
  wire [11:0]SLOT_0_AXI_bid;
  wire SLOT_0_AXI_bready;
  wire [1:0]SLOT_0_AXI_bresp;
  wire SLOT_0_AXI_bvalid;
  wire [31:0]SLOT_0_AXI_rdata;
  wire [11:0]SLOT_0_AXI_rid;
  wire SLOT_0_AXI_rlast;
  wire SLOT_0_AXI_rready;
  wire [1:0]SLOT_0_AXI_rresp;
  wire SLOT_0_AXI_rvalid;
  wire [31:0]SLOT_0_AXI_wdata;
  wire [11:0]SLOT_0_AXI_wid;
  wire SLOT_0_AXI_wlast;
  wire SLOT_0_AXI_wready;
  wire [3:0]SLOT_0_AXI_wstrb;
  wire SLOT_0_AXI_wvalid;
  wire clk;
  wire [1:0]probe0;
  wire [2:0]probe1;
  wire [31:0]probe2;
  wire [31:0]probe3;
  wire [31:0]probe4;
  wire [0:0]probe5;
  wire resetn;

  bd_36cd bd_36cd_i
       (.SLOT_0_AXI_araddr(SLOT_0_AXI_araddr),
        .SLOT_0_AXI_arburst(SLOT_0_AXI_arburst),
        .SLOT_0_AXI_arcache(SLOT_0_AXI_arcache),
        .SLOT_0_AXI_arid(SLOT_0_AXI_arid),
        .SLOT_0_AXI_arlen(SLOT_0_AXI_arlen),
        .SLOT_0_AXI_arlock(SLOT_0_AXI_arlock),
        .SLOT_0_AXI_arprot(SLOT_0_AXI_arprot),
        .SLOT_0_AXI_arqos(SLOT_0_AXI_arqos),
        .SLOT_0_AXI_arready(SLOT_0_AXI_arready),
        .SLOT_0_AXI_arsize(SLOT_0_AXI_arsize),
        .SLOT_0_AXI_arvalid(SLOT_0_AXI_arvalid),
        .SLOT_0_AXI_awaddr(SLOT_0_AXI_awaddr),
        .SLOT_0_AXI_awburst(SLOT_0_AXI_awburst),
        .SLOT_0_AXI_awcache(SLOT_0_AXI_awcache),
        .SLOT_0_AXI_awid(SLOT_0_AXI_awid),
        .SLOT_0_AXI_awlen(SLOT_0_AXI_awlen),
        .SLOT_0_AXI_awlock(SLOT_0_AXI_awlock),
        .SLOT_0_AXI_awprot(SLOT_0_AXI_awprot),
        .SLOT_0_AXI_awqos(SLOT_0_AXI_awqos),
        .SLOT_0_AXI_awready(SLOT_0_AXI_awready),
        .SLOT_0_AXI_awsize(SLOT_0_AXI_awsize),
        .SLOT_0_AXI_awvalid(SLOT_0_AXI_awvalid),
        .SLOT_0_AXI_bid(SLOT_0_AXI_bid),
        .SLOT_0_AXI_bready(SLOT_0_AXI_bready),
        .SLOT_0_AXI_bresp(SLOT_0_AXI_bresp),
        .SLOT_0_AXI_bvalid(SLOT_0_AXI_bvalid),
        .SLOT_0_AXI_rdata(SLOT_0_AXI_rdata),
        .SLOT_0_AXI_rid(SLOT_0_AXI_rid),
        .SLOT_0_AXI_rlast(SLOT_0_AXI_rlast),
        .SLOT_0_AXI_rready(SLOT_0_AXI_rready),
        .SLOT_0_AXI_rresp(SLOT_0_AXI_rresp),
        .SLOT_0_AXI_rvalid(SLOT_0_AXI_rvalid),
        .SLOT_0_AXI_wdata(SLOT_0_AXI_wdata),
        .SLOT_0_AXI_wid(SLOT_0_AXI_wid),
        .SLOT_0_AXI_wlast(SLOT_0_AXI_wlast),
        .SLOT_0_AXI_wready(SLOT_0_AXI_wready),
        .SLOT_0_AXI_wstrb(SLOT_0_AXI_wstrb),
        .SLOT_0_AXI_wvalid(SLOT_0_AXI_wvalid),
        .clk(clk),
        .probe0(probe0),
        .probe1(probe1),
        .probe2(probe2),
        .probe3(probe3),
        .probe4(probe4),
        .probe5(probe5),
        .resetn(resetn));
endmodule

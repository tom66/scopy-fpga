// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

//------------------------------------------------------------------------------------
// Filename:    design_1_zynq_ps_0_stub.sv
// Description: This HDL file is intended to be used with following simulators only:
//
//   Vivado Simulator (XSim)
//   Cadence Xcelium Simulator
//   Aldec Riviera-PRO Simulator
//
//------------------------------------------------------------------------------------
`ifdef XILINX_SIMULATOR

`ifndef XILINX_SIMULATOR_BITASBOOL
`define XILINX_SIMULATOR_BITASBOOL
typedef bit bit_as_bool;
`endif

(* SC_MODULE_EXPORT *)
module design_1_zynq_ps_0 (
  input bit [63 : 0] GPIO_I,
  output bit [63 : 0] GPIO_O,
  output bit [63 : 0] GPIO_T,
  input bit_as_bool SPI0_SCLK_I,
  output bit_as_bool SPI0_SCLK_O,
  output bit_as_bool SPI0_SCLK_T,
  input bit_as_bool SPI0_MOSI_I,
  output bit_as_bool SPI0_MOSI_O,
  output bit_as_bool SPI0_MOSI_T,
  input bit_as_bool SPI0_MISO_I,
  output bit_as_bool SPI0_MISO_O,
  output bit_as_bool SPI0_MISO_T,
  input bit_as_bool SPI0_SS_I,
  output bit_as_bool SPI0_SS_O,
  output bit_as_bool SPI0_SS1_O,
  output bit_as_bool SPI0_SS2_O,
  output bit_as_bool SPI0_SS_T,
  output bit_as_bool TTC0_WAVE0_OUT,
  output bit_as_bool TTC0_WAVE1_OUT,
  output bit_as_bool TTC0_WAVE2_OUT,
  output bit_as_bool M_AXI_GP0_ARVALID,
  output bit_as_bool M_AXI_GP0_AWVALID,
  output bit_as_bool M_AXI_GP0_BREADY,
  output bit_as_bool M_AXI_GP0_RREADY,
  output bit_as_bool M_AXI_GP0_WLAST,
  output bit_as_bool M_AXI_GP0_WVALID,
  output bit [11 : 0] M_AXI_GP0_ARID,
  output bit [11 : 0] M_AXI_GP0_AWID,
  output bit [11 : 0] M_AXI_GP0_WID,
  output bit [1 : 0] M_AXI_GP0_ARBURST,
  output bit [1 : 0] M_AXI_GP0_ARLOCK,
  output bit [2 : 0] M_AXI_GP0_ARSIZE,
  output bit [1 : 0] M_AXI_GP0_AWBURST,
  output bit [1 : 0] M_AXI_GP0_AWLOCK,
  output bit [2 : 0] M_AXI_GP0_AWSIZE,
  output bit [2 : 0] M_AXI_GP0_ARPROT,
  output bit [2 : 0] M_AXI_GP0_AWPROT,
  output bit [31 : 0] M_AXI_GP0_ARADDR,
  output bit [31 : 0] M_AXI_GP0_AWADDR,
  output bit [31 : 0] M_AXI_GP0_WDATA,
  output bit [3 : 0] M_AXI_GP0_ARCACHE,
  output bit [3 : 0] M_AXI_GP0_ARLEN,
  output bit [3 : 0] M_AXI_GP0_ARQOS,
  output bit [3 : 0] M_AXI_GP0_AWCACHE,
  output bit [3 : 0] M_AXI_GP0_AWLEN,
  output bit [3 : 0] M_AXI_GP0_AWQOS,
  output bit [3 : 0] M_AXI_GP0_WSTRB,
  input bit_as_bool M_AXI_GP0_ACLK,
  input bit_as_bool M_AXI_GP0_ARREADY,
  input bit_as_bool M_AXI_GP0_AWREADY,
  input bit_as_bool M_AXI_GP0_BVALID,
  input bit_as_bool M_AXI_GP0_RLAST,
  input bit_as_bool M_AXI_GP0_RVALID,
  input bit_as_bool M_AXI_GP0_WREADY,
  input bit [11 : 0] M_AXI_GP0_BID,
  input bit [11 : 0] M_AXI_GP0_RID,
  input bit [1 : 0] M_AXI_GP0_BRESP,
  input bit [1 : 0] M_AXI_GP0_RRESP,
  input bit [31 : 0] M_AXI_GP0_RDATA,
  output bit_as_bool M_AXI_GP1_ARVALID,
  output bit_as_bool M_AXI_GP1_AWVALID,
  output bit_as_bool M_AXI_GP1_BREADY,
  output bit_as_bool M_AXI_GP1_RREADY,
  output bit_as_bool M_AXI_GP1_WLAST,
  output bit_as_bool M_AXI_GP1_WVALID,
  output bit [11 : 0] M_AXI_GP1_ARID,
  output bit [11 : 0] M_AXI_GP1_AWID,
  output bit [11 : 0] M_AXI_GP1_WID,
  output bit [1 : 0] M_AXI_GP1_ARBURST,
  output bit [1 : 0] M_AXI_GP1_ARLOCK,
  output bit [2 : 0] M_AXI_GP1_ARSIZE,
  output bit [1 : 0] M_AXI_GP1_AWBURST,
  output bit [1 : 0] M_AXI_GP1_AWLOCK,
  output bit [2 : 0] M_AXI_GP1_AWSIZE,
  output bit [2 : 0] M_AXI_GP1_ARPROT,
  output bit [2 : 0] M_AXI_GP1_AWPROT,
  output bit [31 : 0] M_AXI_GP1_ARADDR,
  output bit [31 : 0] M_AXI_GP1_AWADDR,
  output bit [31 : 0] M_AXI_GP1_WDATA,
  output bit [3 : 0] M_AXI_GP1_ARCACHE,
  output bit [3 : 0] M_AXI_GP1_ARLEN,
  output bit [3 : 0] M_AXI_GP1_ARQOS,
  output bit [3 : 0] M_AXI_GP1_AWCACHE,
  output bit [3 : 0] M_AXI_GP1_AWLEN,
  output bit [3 : 0] M_AXI_GP1_AWQOS,
  output bit [3 : 0] M_AXI_GP1_WSTRB,
  input bit_as_bool M_AXI_GP1_ACLK,
  input bit_as_bool M_AXI_GP1_ARREADY,
  input bit_as_bool M_AXI_GP1_AWREADY,
  input bit_as_bool M_AXI_GP1_BVALID,
  input bit_as_bool M_AXI_GP1_RLAST,
  input bit_as_bool M_AXI_GP1_RVALID,
  input bit_as_bool M_AXI_GP1_WREADY,
  input bit [11 : 0] M_AXI_GP1_BID,
  input bit [11 : 0] M_AXI_GP1_RID,
  input bit [1 : 0] M_AXI_GP1_BRESP,
  input bit [1 : 0] M_AXI_GP1_RRESP,
  input bit [31 : 0] M_AXI_GP1_RDATA,
  output bit_as_bool S_AXI_HP0_ARREADY,
  output bit_as_bool S_AXI_HP0_AWREADY,
  output bit_as_bool S_AXI_HP0_BVALID,
  output bit_as_bool S_AXI_HP0_RLAST,
  output bit_as_bool S_AXI_HP0_RVALID,
  output bit_as_bool S_AXI_HP0_WREADY,
  output bit [1 : 0] S_AXI_HP0_BRESP,
  output bit [1 : 0] S_AXI_HP0_RRESP,
  output bit [5 : 0] S_AXI_HP0_BID,
  output bit [5 : 0] S_AXI_HP0_RID,
  output bit [63 : 0] S_AXI_HP0_RDATA,
  output bit [7 : 0] S_AXI_HP0_RCOUNT,
  output bit [7 : 0] S_AXI_HP0_WCOUNT,
  output bit [2 : 0] S_AXI_HP0_RACOUNT,
  output bit [5 : 0] S_AXI_HP0_WACOUNT,
  input bit_as_bool S_AXI_HP0_ACLK,
  input bit_as_bool S_AXI_HP0_ARVALID,
  input bit_as_bool S_AXI_HP0_AWVALID,
  input bit_as_bool S_AXI_HP0_BREADY,
  input bit_as_bool S_AXI_HP0_RDISSUECAP1_EN,
  input bit_as_bool S_AXI_HP0_RREADY,
  input bit_as_bool S_AXI_HP0_WLAST,
  input bit_as_bool S_AXI_HP0_WRISSUECAP1_EN,
  input bit_as_bool S_AXI_HP0_WVALID,
  input bit [1 : 0] S_AXI_HP0_ARBURST,
  input bit [1 : 0] S_AXI_HP0_ARLOCK,
  input bit [2 : 0] S_AXI_HP0_ARSIZE,
  input bit [1 : 0] S_AXI_HP0_AWBURST,
  input bit [1 : 0] S_AXI_HP0_AWLOCK,
  input bit [2 : 0] S_AXI_HP0_AWSIZE,
  input bit [2 : 0] S_AXI_HP0_ARPROT,
  input bit [2 : 0] S_AXI_HP0_AWPROT,
  input bit [31 : 0] S_AXI_HP0_ARADDR,
  input bit [31 : 0] S_AXI_HP0_AWADDR,
  input bit [3 : 0] S_AXI_HP0_ARCACHE,
  input bit [3 : 0] S_AXI_HP0_ARLEN,
  input bit [3 : 0] S_AXI_HP0_ARQOS,
  input bit [3 : 0] S_AXI_HP0_AWCACHE,
  input bit [3 : 0] S_AXI_HP0_AWLEN,
  input bit [3 : 0] S_AXI_HP0_AWQOS,
  input bit [5 : 0] S_AXI_HP0_ARID,
  input bit [5 : 0] S_AXI_HP0_AWID,
  input bit [5 : 0] S_AXI_HP0_WID,
  input bit [63 : 0] S_AXI_HP0_WDATA,
  input bit [7 : 0] S_AXI_HP0_WSTRB,
  output bit_as_bool S_AXI_HP1_ARREADY,
  output bit_as_bool S_AXI_HP1_AWREADY,
  output bit_as_bool S_AXI_HP1_BVALID,
  output bit_as_bool S_AXI_HP1_RLAST,
  output bit_as_bool S_AXI_HP1_RVALID,
  output bit_as_bool S_AXI_HP1_WREADY,
  output bit [1 : 0] S_AXI_HP1_BRESP,
  output bit [1 : 0] S_AXI_HP1_RRESP,
  output bit [5 : 0] S_AXI_HP1_BID,
  output bit [5 : 0] S_AXI_HP1_RID,
  output bit [63 : 0] S_AXI_HP1_RDATA,
  output bit [7 : 0] S_AXI_HP1_RCOUNT,
  output bit [7 : 0] S_AXI_HP1_WCOUNT,
  output bit [2 : 0] S_AXI_HP1_RACOUNT,
  output bit [5 : 0] S_AXI_HP1_WACOUNT,
  input bit_as_bool S_AXI_HP1_ACLK,
  input bit_as_bool S_AXI_HP1_ARVALID,
  input bit_as_bool S_AXI_HP1_AWVALID,
  input bit_as_bool S_AXI_HP1_BREADY,
  input bit_as_bool S_AXI_HP1_RDISSUECAP1_EN,
  input bit_as_bool S_AXI_HP1_RREADY,
  input bit_as_bool S_AXI_HP1_WLAST,
  input bit_as_bool S_AXI_HP1_WRISSUECAP1_EN,
  input bit_as_bool S_AXI_HP1_WVALID,
  input bit [1 : 0] S_AXI_HP1_ARBURST,
  input bit [1 : 0] S_AXI_HP1_ARLOCK,
  input bit [2 : 0] S_AXI_HP1_ARSIZE,
  input bit [1 : 0] S_AXI_HP1_AWBURST,
  input bit [1 : 0] S_AXI_HP1_AWLOCK,
  input bit [2 : 0] S_AXI_HP1_AWSIZE,
  input bit [2 : 0] S_AXI_HP1_ARPROT,
  input bit [2 : 0] S_AXI_HP1_AWPROT,
  input bit [31 : 0] S_AXI_HP1_ARADDR,
  input bit [31 : 0] S_AXI_HP1_AWADDR,
  input bit [3 : 0] S_AXI_HP1_ARCACHE,
  input bit [3 : 0] S_AXI_HP1_ARLEN,
  input bit [3 : 0] S_AXI_HP1_ARQOS,
  input bit [3 : 0] S_AXI_HP1_AWCACHE,
  input bit [3 : 0] S_AXI_HP1_AWLEN,
  input bit [3 : 0] S_AXI_HP1_AWQOS,
  input bit [5 : 0] S_AXI_HP1_ARID,
  input bit [5 : 0] S_AXI_HP1_AWID,
  input bit [5 : 0] S_AXI_HP1_WID,
  input bit [63 : 0] S_AXI_HP1_WDATA,
  input bit [7 : 0] S_AXI_HP1_WSTRB,
  input bit [1 : 0] IRQ_F2P,
  output bit_as_bool FCLK_CLK0,
  output bit_as_bool FCLK_RESET0_N,
  output bit [53 : 0] MIO,
  output bit_as_bool DDR_CAS_n,
  output bit_as_bool DDR_CKE,
  output bit_as_bool DDR_Clk_n,
  output bit_as_bool DDR_Clk,
  output bit_as_bool DDR_CS_n,
  output bit_as_bool DDR_DRSTB,
  output bit_as_bool DDR_ODT,
  output bit_as_bool DDR_RAS_n,
  output bit_as_bool DDR_WEB,
  output bit [2 : 0] DDR_BankAddr,
  output bit [14 : 0] DDR_Addr,
  output bit_as_bool DDR_VRN,
  output bit_as_bool DDR_VRP,
  output bit [3 : 0] DDR_DM,
  output bit [31 : 0] DDR_DQ,
  output bit [3 : 0] DDR_DQS_n,
  output bit [3 : 0] DDR_DQS,
  output bit_as_bool PS_SRSTB,
  output bit_as_bool PS_CLK,
  output bit_as_bool PS_PORB
);
endmodule
`endif

`ifdef XCELIUM
(* XMSC_MODULE_EXPORT *)
module design_1_zynq_ps_0 (GPIO_I,GPIO_O,GPIO_T,SPI0_SCLK_I,SPI0_SCLK_O,SPI0_SCLK_T,SPI0_MOSI_I,SPI0_MOSI_O,SPI0_MOSI_T,SPI0_MISO_I,SPI0_MISO_O,SPI0_MISO_T,SPI0_SS_I,SPI0_SS_O,SPI0_SS1_O,SPI0_SS2_O,SPI0_SS_T,TTC0_WAVE0_OUT,TTC0_WAVE1_OUT,TTC0_WAVE2_OUT,M_AXI_GP0_ARVALID,M_AXI_GP0_AWVALID,M_AXI_GP0_BREADY,M_AXI_GP0_RREADY,M_AXI_GP0_WLAST,M_AXI_GP0_WVALID,M_AXI_GP0_ARID,M_AXI_GP0_AWID,M_AXI_GP0_WID,M_AXI_GP0_ARBURST,M_AXI_GP0_ARLOCK,M_AXI_GP0_ARSIZE,M_AXI_GP0_AWBURST,M_AXI_GP0_AWLOCK,M_AXI_GP0_AWSIZE,M_AXI_GP0_ARPROT,M_AXI_GP0_AWPROT,M_AXI_GP0_ARADDR,M_AXI_GP0_AWADDR,M_AXI_GP0_WDATA,M_AXI_GP0_ARCACHE,M_AXI_GP0_ARLEN,M_AXI_GP0_ARQOS,M_AXI_GP0_AWCACHE,M_AXI_GP0_AWLEN,M_AXI_GP0_AWQOS,M_AXI_GP0_WSTRB,M_AXI_GP0_ACLK,M_AXI_GP0_ARREADY,M_AXI_GP0_AWREADY,M_AXI_GP0_BVALID,M_AXI_GP0_RLAST,M_AXI_GP0_RVALID,M_AXI_GP0_WREADY,M_AXI_GP0_BID,M_AXI_GP0_RID,M_AXI_GP0_BRESP,M_AXI_GP0_RRESP,M_AXI_GP0_RDATA,M_AXI_GP1_ARVALID,M_AXI_GP1_AWVALID,M_AXI_GP1_BREADY,M_AXI_GP1_RREADY,M_AXI_GP1_WLAST,M_AXI_GP1_WVALID,M_AXI_GP1_ARID,M_AXI_GP1_AWID,M_AXI_GP1_WID,M_AXI_GP1_ARBURST,M_AXI_GP1_ARLOCK,M_AXI_GP1_ARSIZE,M_AXI_GP1_AWBURST,M_AXI_GP1_AWLOCK,M_AXI_GP1_AWSIZE,M_AXI_GP1_ARPROT,M_AXI_GP1_AWPROT,M_AXI_GP1_ARADDR,M_AXI_GP1_AWADDR,M_AXI_GP1_WDATA,M_AXI_GP1_ARCACHE,M_AXI_GP1_ARLEN,M_AXI_GP1_ARQOS,M_AXI_GP1_AWCACHE,M_AXI_GP1_AWLEN,M_AXI_GP1_AWQOS,M_AXI_GP1_WSTRB,M_AXI_GP1_ACLK,M_AXI_GP1_ARREADY,M_AXI_GP1_AWREADY,M_AXI_GP1_BVALID,M_AXI_GP1_RLAST,M_AXI_GP1_RVALID,M_AXI_GP1_WREADY,M_AXI_GP1_BID,M_AXI_GP1_RID,M_AXI_GP1_BRESP,M_AXI_GP1_RRESP,M_AXI_GP1_RDATA,S_AXI_HP0_ARREADY,S_AXI_HP0_AWREADY,S_AXI_HP0_BVALID,S_AXI_HP0_RLAST,S_AXI_HP0_RVALID,S_AXI_HP0_WREADY,S_AXI_HP0_BRESP,S_AXI_HP0_RRESP,S_AXI_HP0_BID,S_AXI_HP0_RID,S_AXI_HP0_RDATA,S_AXI_HP0_RCOUNT,S_AXI_HP0_WCOUNT,S_AXI_HP0_RACOUNT,S_AXI_HP0_WACOUNT,S_AXI_HP0_ACLK,S_AXI_HP0_ARVALID,S_AXI_HP0_AWVALID,S_AXI_HP0_BREADY,S_AXI_HP0_RDISSUECAP1_EN,S_AXI_HP0_RREADY,S_AXI_HP0_WLAST,S_AXI_HP0_WRISSUECAP1_EN,S_AXI_HP0_WVALID,S_AXI_HP0_ARBURST,S_AXI_HP0_ARLOCK,S_AXI_HP0_ARSIZE,S_AXI_HP0_AWBURST,S_AXI_HP0_AWLOCK,S_AXI_HP0_AWSIZE,S_AXI_HP0_ARPROT,S_AXI_HP0_AWPROT,S_AXI_HP0_ARADDR,S_AXI_HP0_AWADDR,S_AXI_HP0_ARCACHE,S_AXI_HP0_ARLEN,S_AXI_HP0_ARQOS,S_AXI_HP0_AWCACHE,S_AXI_HP0_AWLEN,S_AXI_HP0_AWQOS,S_AXI_HP0_ARID,S_AXI_HP0_AWID,S_AXI_HP0_WID,S_AXI_HP0_WDATA,S_AXI_HP0_WSTRB,S_AXI_HP1_ARREADY,S_AXI_HP1_AWREADY,S_AXI_HP1_BVALID,S_AXI_HP1_RLAST,S_AXI_HP1_RVALID,S_AXI_HP1_WREADY,S_AXI_HP1_BRESP,S_AXI_HP1_RRESP,S_AXI_HP1_BID,S_AXI_HP1_RID,S_AXI_HP1_RDATA,S_AXI_HP1_RCOUNT,S_AXI_HP1_WCOUNT,S_AXI_HP1_RACOUNT,S_AXI_HP1_WACOUNT,S_AXI_HP1_ACLK,S_AXI_HP1_ARVALID,S_AXI_HP1_AWVALID,S_AXI_HP1_BREADY,S_AXI_HP1_RDISSUECAP1_EN,S_AXI_HP1_RREADY,S_AXI_HP1_WLAST,S_AXI_HP1_WRISSUECAP1_EN,S_AXI_HP1_WVALID,S_AXI_HP1_ARBURST,S_AXI_HP1_ARLOCK,S_AXI_HP1_ARSIZE,S_AXI_HP1_AWBURST,S_AXI_HP1_AWLOCK,S_AXI_HP1_AWSIZE,S_AXI_HP1_ARPROT,S_AXI_HP1_AWPROT,S_AXI_HP1_ARADDR,S_AXI_HP1_AWADDR,S_AXI_HP1_ARCACHE,S_AXI_HP1_ARLEN,S_AXI_HP1_ARQOS,S_AXI_HP1_AWCACHE,S_AXI_HP1_AWLEN,S_AXI_HP1_AWQOS,S_AXI_HP1_ARID,S_AXI_HP1_AWID,S_AXI_HP1_WID,S_AXI_HP1_WDATA,S_AXI_HP1_WSTRB,IRQ_F2P,FCLK_CLK0,FCLK_RESET0_N,MIO,DDR_CAS_n,DDR_CKE,DDR_Clk_n,DDR_Clk,DDR_CS_n,DDR_DRSTB,DDR_ODT,DDR_RAS_n,DDR_WEB,DDR_BankAddr,DDR_Addr,DDR_VRN,DDR_VRP,DDR_DM,DDR_DQ,DDR_DQS_n,DDR_DQS,PS_SRSTB,PS_CLK,PS_PORB)
(* integer foreign = "SystemC";
*);
  input bit [63 : 0] GPIO_I;
  output wire [63 : 0] GPIO_O;
  output wire [63 : 0] GPIO_T;
  input bit SPI0_SCLK_I;
  output wire SPI0_SCLK_O;
  output wire SPI0_SCLK_T;
  input bit SPI0_MOSI_I;
  output wire SPI0_MOSI_O;
  output wire SPI0_MOSI_T;
  input bit SPI0_MISO_I;
  output wire SPI0_MISO_O;
  output wire SPI0_MISO_T;
  input bit SPI0_SS_I;
  output wire SPI0_SS_O;
  output wire SPI0_SS1_O;
  output wire SPI0_SS2_O;
  output wire SPI0_SS_T;
  output wire TTC0_WAVE0_OUT;
  output wire TTC0_WAVE1_OUT;
  output wire TTC0_WAVE2_OUT;
  output wire M_AXI_GP0_ARVALID;
  output wire M_AXI_GP0_AWVALID;
  output wire M_AXI_GP0_BREADY;
  output wire M_AXI_GP0_RREADY;
  output wire M_AXI_GP0_WLAST;
  output wire M_AXI_GP0_WVALID;
  output wire [11 : 0] M_AXI_GP0_ARID;
  output wire [11 : 0] M_AXI_GP0_AWID;
  output wire [11 : 0] M_AXI_GP0_WID;
  output wire [1 : 0] M_AXI_GP0_ARBURST;
  output wire [1 : 0] M_AXI_GP0_ARLOCK;
  output wire [2 : 0] M_AXI_GP0_ARSIZE;
  output wire [1 : 0] M_AXI_GP0_AWBURST;
  output wire [1 : 0] M_AXI_GP0_AWLOCK;
  output wire [2 : 0] M_AXI_GP0_AWSIZE;
  output wire [2 : 0] M_AXI_GP0_ARPROT;
  output wire [2 : 0] M_AXI_GP0_AWPROT;
  output wire [31 : 0] M_AXI_GP0_ARADDR;
  output wire [31 : 0] M_AXI_GP0_AWADDR;
  output wire [31 : 0] M_AXI_GP0_WDATA;
  output wire [3 : 0] M_AXI_GP0_ARCACHE;
  output wire [3 : 0] M_AXI_GP0_ARLEN;
  output wire [3 : 0] M_AXI_GP0_ARQOS;
  output wire [3 : 0] M_AXI_GP0_AWCACHE;
  output wire [3 : 0] M_AXI_GP0_AWLEN;
  output wire [3 : 0] M_AXI_GP0_AWQOS;
  output wire [3 : 0] M_AXI_GP0_WSTRB;
  input bit M_AXI_GP0_ACLK;
  input bit M_AXI_GP0_ARREADY;
  input bit M_AXI_GP0_AWREADY;
  input bit M_AXI_GP0_BVALID;
  input bit M_AXI_GP0_RLAST;
  input bit M_AXI_GP0_RVALID;
  input bit M_AXI_GP0_WREADY;
  input bit [11 : 0] M_AXI_GP0_BID;
  input bit [11 : 0] M_AXI_GP0_RID;
  input bit [1 : 0] M_AXI_GP0_BRESP;
  input bit [1 : 0] M_AXI_GP0_RRESP;
  input bit [31 : 0] M_AXI_GP0_RDATA;
  output wire M_AXI_GP1_ARVALID;
  output wire M_AXI_GP1_AWVALID;
  output wire M_AXI_GP1_BREADY;
  output wire M_AXI_GP1_RREADY;
  output wire M_AXI_GP1_WLAST;
  output wire M_AXI_GP1_WVALID;
  output wire [11 : 0] M_AXI_GP1_ARID;
  output wire [11 : 0] M_AXI_GP1_AWID;
  output wire [11 : 0] M_AXI_GP1_WID;
  output wire [1 : 0] M_AXI_GP1_ARBURST;
  output wire [1 : 0] M_AXI_GP1_ARLOCK;
  output wire [2 : 0] M_AXI_GP1_ARSIZE;
  output wire [1 : 0] M_AXI_GP1_AWBURST;
  output wire [1 : 0] M_AXI_GP1_AWLOCK;
  output wire [2 : 0] M_AXI_GP1_AWSIZE;
  output wire [2 : 0] M_AXI_GP1_ARPROT;
  output wire [2 : 0] M_AXI_GP1_AWPROT;
  output wire [31 : 0] M_AXI_GP1_ARADDR;
  output wire [31 : 0] M_AXI_GP1_AWADDR;
  output wire [31 : 0] M_AXI_GP1_WDATA;
  output wire [3 : 0] M_AXI_GP1_ARCACHE;
  output wire [3 : 0] M_AXI_GP1_ARLEN;
  output wire [3 : 0] M_AXI_GP1_ARQOS;
  output wire [3 : 0] M_AXI_GP1_AWCACHE;
  output wire [3 : 0] M_AXI_GP1_AWLEN;
  output wire [3 : 0] M_AXI_GP1_AWQOS;
  output wire [3 : 0] M_AXI_GP1_WSTRB;
  input bit M_AXI_GP1_ACLK;
  input bit M_AXI_GP1_ARREADY;
  input bit M_AXI_GP1_AWREADY;
  input bit M_AXI_GP1_BVALID;
  input bit M_AXI_GP1_RLAST;
  input bit M_AXI_GP1_RVALID;
  input bit M_AXI_GP1_WREADY;
  input bit [11 : 0] M_AXI_GP1_BID;
  input bit [11 : 0] M_AXI_GP1_RID;
  input bit [1 : 0] M_AXI_GP1_BRESP;
  input bit [1 : 0] M_AXI_GP1_RRESP;
  input bit [31 : 0] M_AXI_GP1_RDATA;
  output wire S_AXI_HP0_ARREADY;
  output wire S_AXI_HP0_AWREADY;
  output wire S_AXI_HP0_BVALID;
  output wire S_AXI_HP0_RLAST;
  output wire S_AXI_HP0_RVALID;
  output wire S_AXI_HP0_WREADY;
  output wire [1 : 0] S_AXI_HP0_BRESP;
  output wire [1 : 0] S_AXI_HP0_RRESP;
  output wire [5 : 0] S_AXI_HP0_BID;
  output wire [5 : 0] S_AXI_HP0_RID;
  output wire [63 : 0] S_AXI_HP0_RDATA;
  output wire [7 : 0] S_AXI_HP0_RCOUNT;
  output wire [7 : 0] S_AXI_HP0_WCOUNT;
  output wire [2 : 0] S_AXI_HP0_RACOUNT;
  output wire [5 : 0] S_AXI_HP0_WACOUNT;
  input bit S_AXI_HP0_ACLK;
  input bit S_AXI_HP0_ARVALID;
  input bit S_AXI_HP0_AWVALID;
  input bit S_AXI_HP0_BREADY;
  input bit S_AXI_HP0_RDISSUECAP1_EN;
  input bit S_AXI_HP0_RREADY;
  input bit S_AXI_HP0_WLAST;
  input bit S_AXI_HP0_WRISSUECAP1_EN;
  input bit S_AXI_HP0_WVALID;
  input bit [1 : 0] S_AXI_HP0_ARBURST;
  input bit [1 : 0] S_AXI_HP0_ARLOCK;
  input bit [2 : 0] S_AXI_HP0_ARSIZE;
  input bit [1 : 0] S_AXI_HP0_AWBURST;
  input bit [1 : 0] S_AXI_HP0_AWLOCK;
  input bit [2 : 0] S_AXI_HP0_AWSIZE;
  input bit [2 : 0] S_AXI_HP0_ARPROT;
  input bit [2 : 0] S_AXI_HP0_AWPROT;
  input bit [31 : 0] S_AXI_HP0_ARADDR;
  input bit [31 : 0] S_AXI_HP0_AWADDR;
  input bit [3 : 0] S_AXI_HP0_ARCACHE;
  input bit [3 : 0] S_AXI_HP0_ARLEN;
  input bit [3 : 0] S_AXI_HP0_ARQOS;
  input bit [3 : 0] S_AXI_HP0_AWCACHE;
  input bit [3 : 0] S_AXI_HP0_AWLEN;
  input bit [3 : 0] S_AXI_HP0_AWQOS;
  input bit [5 : 0] S_AXI_HP0_ARID;
  input bit [5 : 0] S_AXI_HP0_AWID;
  input bit [5 : 0] S_AXI_HP0_WID;
  input bit [63 : 0] S_AXI_HP0_WDATA;
  input bit [7 : 0] S_AXI_HP0_WSTRB;
  output wire S_AXI_HP1_ARREADY;
  output wire S_AXI_HP1_AWREADY;
  output wire S_AXI_HP1_BVALID;
  output wire S_AXI_HP1_RLAST;
  output wire S_AXI_HP1_RVALID;
  output wire S_AXI_HP1_WREADY;
  output wire [1 : 0] S_AXI_HP1_BRESP;
  output wire [1 : 0] S_AXI_HP1_RRESP;
  output wire [5 : 0] S_AXI_HP1_BID;
  output wire [5 : 0] S_AXI_HP1_RID;
  output wire [63 : 0] S_AXI_HP1_RDATA;
  output wire [7 : 0] S_AXI_HP1_RCOUNT;
  output wire [7 : 0] S_AXI_HP1_WCOUNT;
  output wire [2 : 0] S_AXI_HP1_RACOUNT;
  output wire [5 : 0] S_AXI_HP1_WACOUNT;
  input bit S_AXI_HP1_ACLK;
  input bit S_AXI_HP1_ARVALID;
  input bit S_AXI_HP1_AWVALID;
  input bit S_AXI_HP1_BREADY;
  input bit S_AXI_HP1_RDISSUECAP1_EN;
  input bit S_AXI_HP1_RREADY;
  input bit S_AXI_HP1_WLAST;
  input bit S_AXI_HP1_WRISSUECAP1_EN;
  input bit S_AXI_HP1_WVALID;
  input bit [1 : 0] S_AXI_HP1_ARBURST;
  input bit [1 : 0] S_AXI_HP1_ARLOCK;
  input bit [2 : 0] S_AXI_HP1_ARSIZE;
  input bit [1 : 0] S_AXI_HP1_AWBURST;
  input bit [1 : 0] S_AXI_HP1_AWLOCK;
  input bit [2 : 0] S_AXI_HP1_AWSIZE;
  input bit [2 : 0] S_AXI_HP1_ARPROT;
  input bit [2 : 0] S_AXI_HP1_AWPROT;
  input bit [31 : 0] S_AXI_HP1_ARADDR;
  input bit [31 : 0] S_AXI_HP1_AWADDR;
  input bit [3 : 0] S_AXI_HP1_ARCACHE;
  input bit [3 : 0] S_AXI_HP1_ARLEN;
  input bit [3 : 0] S_AXI_HP1_ARQOS;
  input bit [3 : 0] S_AXI_HP1_AWCACHE;
  input bit [3 : 0] S_AXI_HP1_AWLEN;
  input bit [3 : 0] S_AXI_HP1_AWQOS;
  input bit [5 : 0] S_AXI_HP1_ARID;
  input bit [5 : 0] S_AXI_HP1_AWID;
  input bit [5 : 0] S_AXI_HP1_WID;
  input bit [63 : 0] S_AXI_HP1_WDATA;
  input bit [7 : 0] S_AXI_HP1_WSTRB;
  input bit [1 : 0] IRQ_F2P;
  output wire FCLK_CLK0;
  output wire FCLK_RESET0_N;
  inout wire [53 : 0] MIO;
  inout wire DDR_CAS_n;
  inout wire DDR_CKE;
  inout wire DDR_Clk_n;
  inout wire DDR_Clk;
  inout wire DDR_CS_n;
  inout wire DDR_DRSTB;
  inout wire DDR_ODT;
  inout wire DDR_RAS_n;
  inout wire DDR_WEB;
  inout wire [2 : 0] DDR_BankAddr;
  inout wire [14 : 0] DDR_Addr;
  inout wire DDR_VRN;
  inout wire DDR_VRP;
  inout wire [3 : 0] DDR_DM;
  inout wire [31 : 0] DDR_DQ;
  inout wire [3 : 0] DDR_DQS_n;
  inout wire [3 : 0] DDR_DQS;
  inout wire PS_SRSTB;
  inout wire PS_CLK;
  inout wire PS_PORB;
endmodule
`endif

`ifdef RIVIERA
(* SC_MODULE_EXPORT *)
module design_1_zynq_ps_0 (GPIO_I,GPIO_O,GPIO_T,SPI0_SCLK_I,SPI0_SCLK_O,SPI0_SCLK_T,SPI0_MOSI_I,SPI0_MOSI_O,SPI0_MOSI_T,SPI0_MISO_I,SPI0_MISO_O,SPI0_MISO_T,SPI0_SS_I,SPI0_SS_O,SPI0_SS1_O,SPI0_SS2_O,SPI0_SS_T,TTC0_WAVE0_OUT,TTC0_WAVE1_OUT,TTC0_WAVE2_OUT,M_AXI_GP0_ARVALID,M_AXI_GP0_AWVALID,M_AXI_GP0_BREADY,M_AXI_GP0_RREADY,M_AXI_GP0_WLAST,M_AXI_GP0_WVALID,M_AXI_GP0_ARID,M_AXI_GP0_AWID,M_AXI_GP0_WID,M_AXI_GP0_ARBURST,M_AXI_GP0_ARLOCK,M_AXI_GP0_ARSIZE,M_AXI_GP0_AWBURST,M_AXI_GP0_AWLOCK,M_AXI_GP0_AWSIZE,M_AXI_GP0_ARPROT,M_AXI_GP0_AWPROT,M_AXI_GP0_ARADDR,M_AXI_GP0_AWADDR,M_AXI_GP0_WDATA,M_AXI_GP0_ARCACHE,M_AXI_GP0_ARLEN,M_AXI_GP0_ARQOS,M_AXI_GP0_AWCACHE,M_AXI_GP0_AWLEN,M_AXI_GP0_AWQOS,M_AXI_GP0_WSTRB,M_AXI_GP0_ACLK,M_AXI_GP0_ARREADY,M_AXI_GP0_AWREADY,M_AXI_GP0_BVALID,M_AXI_GP0_RLAST,M_AXI_GP0_RVALID,M_AXI_GP0_WREADY,M_AXI_GP0_BID,M_AXI_GP0_RID,M_AXI_GP0_BRESP,M_AXI_GP0_RRESP,M_AXI_GP0_RDATA,M_AXI_GP1_ARVALID,M_AXI_GP1_AWVALID,M_AXI_GP1_BREADY,M_AXI_GP1_RREADY,M_AXI_GP1_WLAST,M_AXI_GP1_WVALID,M_AXI_GP1_ARID,M_AXI_GP1_AWID,M_AXI_GP1_WID,M_AXI_GP1_ARBURST,M_AXI_GP1_ARLOCK,M_AXI_GP1_ARSIZE,M_AXI_GP1_AWBURST,M_AXI_GP1_AWLOCK,M_AXI_GP1_AWSIZE,M_AXI_GP1_ARPROT,M_AXI_GP1_AWPROT,M_AXI_GP1_ARADDR,M_AXI_GP1_AWADDR,M_AXI_GP1_WDATA,M_AXI_GP1_ARCACHE,M_AXI_GP1_ARLEN,M_AXI_GP1_ARQOS,M_AXI_GP1_AWCACHE,M_AXI_GP1_AWLEN,M_AXI_GP1_AWQOS,M_AXI_GP1_WSTRB,M_AXI_GP1_ACLK,M_AXI_GP1_ARREADY,M_AXI_GP1_AWREADY,M_AXI_GP1_BVALID,M_AXI_GP1_RLAST,M_AXI_GP1_RVALID,M_AXI_GP1_WREADY,M_AXI_GP1_BID,M_AXI_GP1_RID,M_AXI_GP1_BRESP,M_AXI_GP1_RRESP,M_AXI_GP1_RDATA,S_AXI_HP0_ARREADY,S_AXI_HP0_AWREADY,S_AXI_HP0_BVALID,S_AXI_HP0_RLAST,S_AXI_HP0_RVALID,S_AXI_HP0_WREADY,S_AXI_HP0_BRESP,S_AXI_HP0_RRESP,S_AXI_HP0_BID,S_AXI_HP0_RID,S_AXI_HP0_RDATA,S_AXI_HP0_RCOUNT,S_AXI_HP0_WCOUNT,S_AXI_HP0_RACOUNT,S_AXI_HP0_WACOUNT,S_AXI_HP0_ACLK,S_AXI_HP0_ARVALID,S_AXI_HP0_AWVALID,S_AXI_HP0_BREADY,S_AXI_HP0_RDISSUECAP1_EN,S_AXI_HP0_RREADY,S_AXI_HP0_WLAST,S_AXI_HP0_WRISSUECAP1_EN,S_AXI_HP0_WVALID,S_AXI_HP0_ARBURST,S_AXI_HP0_ARLOCK,S_AXI_HP0_ARSIZE,S_AXI_HP0_AWBURST,S_AXI_HP0_AWLOCK,S_AXI_HP0_AWSIZE,S_AXI_HP0_ARPROT,S_AXI_HP0_AWPROT,S_AXI_HP0_ARADDR,S_AXI_HP0_AWADDR,S_AXI_HP0_ARCACHE,S_AXI_HP0_ARLEN,S_AXI_HP0_ARQOS,S_AXI_HP0_AWCACHE,S_AXI_HP0_AWLEN,S_AXI_HP0_AWQOS,S_AXI_HP0_ARID,S_AXI_HP0_AWID,S_AXI_HP0_WID,S_AXI_HP0_WDATA,S_AXI_HP0_WSTRB,S_AXI_HP1_ARREADY,S_AXI_HP1_AWREADY,S_AXI_HP1_BVALID,S_AXI_HP1_RLAST,S_AXI_HP1_RVALID,S_AXI_HP1_WREADY,S_AXI_HP1_BRESP,S_AXI_HP1_RRESP,S_AXI_HP1_BID,S_AXI_HP1_RID,S_AXI_HP1_RDATA,S_AXI_HP1_RCOUNT,S_AXI_HP1_WCOUNT,S_AXI_HP1_RACOUNT,S_AXI_HP1_WACOUNT,S_AXI_HP1_ACLK,S_AXI_HP1_ARVALID,S_AXI_HP1_AWVALID,S_AXI_HP1_BREADY,S_AXI_HP1_RDISSUECAP1_EN,S_AXI_HP1_RREADY,S_AXI_HP1_WLAST,S_AXI_HP1_WRISSUECAP1_EN,S_AXI_HP1_WVALID,S_AXI_HP1_ARBURST,S_AXI_HP1_ARLOCK,S_AXI_HP1_ARSIZE,S_AXI_HP1_AWBURST,S_AXI_HP1_AWLOCK,S_AXI_HP1_AWSIZE,S_AXI_HP1_ARPROT,S_AXI_HP1_AWPROT,S_AXI_HP1_ARADDR,S_AXI_HP1_AWADDR,S_AXI_HP1_ARCACHE,S_AXI_HP1_ARLEN,S_AXI_HP1_ARQOS,S_AXI_HP1_AWCACHE,S_AXI_HP1_AWLEN,S_AXI_HP1_AWQOS,S_AXI_HP1_ARID,S_AXI_HP1_AWID,S_AXI_HP1_WID,S_AXI_HP1_WDATA,S_AXI_HP1_WSTRB,IRQ_F2P,FCLK_CLK0,FCLK_RESET0_N,MIO,DDR_CAS_n,DDR_CKE,DDR_Clk_n,DDR_Clk,DDR_CS_n,DDR_DRSTB,DDR_ODT,DDR_RAS_n,DDR_WEB,DDR_BankAddr,DDR_Addr,DDR_VRN,DDR_VRP,DDR_DM,DDR_DQ,DDR_DQS_n,DDR_DQS,PS_SRSTB,PS_CLK,PS_PORB)
  input bit [63 : 0] GPIO_I;
  output wire [63 : 0] GPIO_O;
  output wire [63 : 0] GPIO_T;
  input bit SPI0_SCLK_I;
  output wire SPI0_SCLK_O;
  output wire SPI0_SCLK_T;
  input bit SPI0_MOSI_I;
  output wire SPI0_MOSI_O;
  output wire SPI0_MOSI_T;
  input bit SPI0_MISO_I;
  output wire SPI0_MISO_O;
  output wire SPI0_MISO_T;
  input bit SPI0_SS_I;
  output wire SPI0_SS_O;
  output wire SPI0_SS1_O;
  output wire SPI0_SS2_O;
  output wire SPI0_SS_T;
  output wire TTC0_WAVE0_OUT;
  output wire TTC0_WAVE1_OUT;
  output wire TTC0_WAVE2_OUT;
  output wire M_AXI_GP0_ARVALID;
  output wire M_AXI_GP0_AWVALID;
  output wire M_AXI_GP0_BREADY;
  output wire M_AXI_GP0_RREADY;
  output wire M_AXI_GP0_WLAST;
  output wire M_AXI_GP0_WVALID;
  output wire [11 : 0] M_AXI_GP0_ARID;
  output wire [11 : 0] M_AXI_GP0_AWID;
  output wire [11 : 0] M_AXI_GP0_WID;
  output wire [1 : 0] M_AXI_GP0_ARBURST;
  output wire [1 : 0] M_AXI_GP0_ARLOCK;
  output wire [2 : 0] M_AXI_GP0_ARSIZE;
  output wire [1 : 0] M_AXI_GP0_AWBURST;
  output wire [1 : 0] M_AXI_GP0_AWLOCK;
  output wire [2 : 0] M_AXI_GP0_AWSIZE;
  output wire [2 : 0] M_AXI_GP0_ARPROT;
  output wire [2 : 0] M_AXI_GP0_AWPROT;
  output wire [31 : 0] M_AXI_GP0_ARADDR;
  output wire [31 : 0] M_AXI_GP0_AWADDR;
  output wire [31 : 0] M_AXI_GP0_WDATA;
  output wire [3 : 0] M_AXI_GP0_ARCACHE;
  output wire [3 : 0] M_AXI_GP0_ARLEN;
  output wire [3 : 0] M_AXI_GP0_ARQOS;
  output wire [3 : 0] M_AXI_GP0_AWCACHE;
  output wire [3 : 0] M_AXI_GP0_AWLEN;
  output wire [3 : 0] M_AXI_GP0_AWQOS;
  output wire [3 : 0] M_AXI_GP0_WSTRB;
  input bit M_AXI_GP0_ACLK;
  input bit M_AXI_GP0_ARREADY;
  input bit M_AXI_GP0_AWREADY;
  input bit M_AXI_GP0_BVALID;
  input bit M_AXI_GP0_RLAST;
  input bit M_AXI_GP0_RVALID;
  input bit M_AXI_GP0_WREADY;
  input bit [11 : 0] M_AXI_GP0_BID;
  input bit [11 : 0] M_AXI_GP0_RID;
  input bit [1 : 0] M_AXI_GP0_BRESP;
  input bit [1 : 0] M_AXI_GP0_RRESP;
  input bit [31 : 0] M_AXI_GP0_RDATA;
  output wire M_AXI_GP1_ARVALID;
  output wire M_AXI_GP1_AWVALID;
  output wire M_AXI_GP1_BREADY;
  output wire M_AXI_GP1_RREADY;
  output wire M_AXI_GP1_WLAST;
  output wire M_AXI_GP1_WVALID;
  output wire [11 : 0] M_AXI_GP1_ARID;
  output wire [11 : 0] M_AXI_GP1_AWID;
  output wire [11 : 0] M_AXI_GP1_WID;
  output wire [1 : 0] M_AXI_GP1_ARBURST;
  output wire [1 : 0] M_AXI_GP1_ARLOCK;
  output wire [2 : 0] M_AXI_GP1_ARSIZE;
  output wire [1 : 0] M_AXI_GP1_AWBURST;
  output wire [1 : 0] M_AXI_GP1_AWLOCK;
  output wire [2 : 0] M_AXI_GP1_AWSIZE;
  output wire [2 : 0] M_AXI_GP1_ARPROT;
  output wire [2 : 0] M_AXI_GP1_AWPROT;
  output wire [31 : 0] M_AXI_GP1_ARADDR;
  output wire [31 : 0] M_AXI_GP1_AWADDR;
  output wire [31 : 0] M_AXI_GP1_WDATA;
  output wire [3 : 0] M_AXI_GP1_ARCACHE;
  output wire [3 : 0] M_AXI_GP1_ARLEN;
  output wire [3 : 0] M_AXI_GP1_ARQOS;
  output wire [3 : 0] M_AXI_GP1_AWCACHE;
  output wire [3 : 0] M_AXI_GP1_AWLEN;
  output wire [3 : 0] M_AXI_GP1_AWQOS;
  output wire [3 : 0] M_AXI_GP1_WSTRB;
  input bit M_AXI_GP1_ACLK;
  input bit M_AXI_GP1_ARREADY;
  input bit M_AXI_GP1_AWREADY;
  input bit M_AXI_GP1_BVALID;
  input bit M_AXI_GP1_RLAST;
  input bit M_AXI_GP1_RVALID;
  input bit M_AXI_GP1_WREADY;
  input bit [11 : 0] M_AXI_GP1_BID;
  input bit [11 : 0] M_AXI_GP1_RID;
  input bit [1 : 0] M_AXI_GP1_BRESP;
  input bit [1 : 0] M_AXI_GP1_RRESP;
  input bit [31 : 0] M_AXI_GP1_RDATA;
  output wire S_AXI_HP0_ARREADY;
  output wire S_AXI_HP0_AWREADY;
  output wire S_AXI_HP0_BVALID;
  output wire S_AXI_HP0_RLAST;
  output wire S_AXI_HP0_RVALID;
  output wire S_AXI_HP0_WREADY;
  output wire [1 : 0] S_AXI_HP0_BRESP;
  output wire [1 : 0] S_AXI_HP0_RRESP;
  output wire [5 : 0] S_AXI_HP0_BID;
  output wire [5 : 0] S_AXI_HP0_RID;
  output wire [63 : 0] S_AXI_HP0_RDATA;
  output wire [7 : 0] S_AXI_HP0_RCOUNT;
  output wire [7 : 0] S_AXI_HP0_WCOUNT;
  output wire [2 : 0] S_AXI_HP0_RACOUNT;
  output wire [5 : 0] S_AXI_HP0_WACOUNT;
  input bit S_AXI_HP0_ACLK;
  input bit S_AXI_HP0_ARVALID;
  input bit S_AXI_HP0_AWVALID;
  input bit S_AXI_HP0_BREADY;
  input bit S_AXI_HP0_RDISSUECAP1_EN;
  input bit S_AXI_HP0_RREADY;
  input bit S_AXI_HP0_WLAST;
  input bit S_AXI_HP0_WRISSUECAP1_EN;
  input bit S_AXI_HP0_WVALID;
  input bit [1 : 0] S_AXI_HP0_ARBURST;
  input bit [1 : 0] S_AXI_HP0_ARLOCK;
  input bit [2 : 0] S_AXI_HP0_ARSIZE;
  input bit [1 : 0] S_AXI_HP0_AWBURST;
  input bit [1 : 0] S_AXI_HP0_AWLOCK;
  input bit [2 : 0] S_AXI_HP0_AWSIZE;
  input bit [2 : 0] S_AXI_HP0_ARPROT;
  input bit [2 : 0] S_AXI_HP0_AWPROT;
  input bit [31 : 0] S_AXI_HP0_ARADDR;
  input bit [31 : 0] S_AXI_HP0_AWADDR;
  input bit [3 : 0] S_AXI_HP0_ARCACHE;
  input bit [3 : 0] S_AXI_HP0_ARLEN;
  input bit [3 : 0] S_AXI_HP0_ARQOS;
  input bit [3 : 0] S_AXI_HP0_AWCACHE;
  input bit [3 : 0] S_AXI_HP0_AWLEN;
  input bit [3 : 0] S_AXI_HP0_AWQOS;
  input bit [5 : 0] S_AXI_HP0_ARID;
  input bit [5 : 0] S_AXI_HP0_AWID;
  input bit [5 : 0] S_AXI_HP0_WID;
  input bit [63 : 0] S_AXI_HP0_WDATA;
  input bit [7 : 0] S_AXI_HP0_WSTRB;
  output wire S_AXI_HP1_ARREADY;
  output wire S_AXI_HP1_AWREADY;
  output wire S_AXI_HP1_BVALID;
  output wire S_AXI_HP1_RLAST;
  output wire S_AXI_HP1_RVALID;
  output wire S_AXI_HP1_WREADY;
  output wire [1 : 0] S_AXI_HP1_BRESP;
  output wire [1 : 0] S_AXI_HP1_RRESP;
  output wire [5 : 0] S_AXI_HP1_BID;
  output wire [5 : 0] S_AXI_HP1_RID;
  output wire [63 : 0] S_AXI_HP1_RDATA;
  output wire [7 : 0] S_AXI_HP1_RCOUNT;
  output wire [7 : 0] S_AXI_HP1_WCOUNT;
  output wire [2 : 0] S_AXI_HP1_RACOUNT;
  output wire [5 : 0] S_AXI_HP1_WACOUNT;
  input bit S_AXI_HP1_ACLK;
  input bit S_AXI_HP1_ARVALID;
  input bit S_AXI_HP1_AWVALID;
  input bit S_AXI_HP1_BREADY;
  input bit S_AXI_HP1_RDISSUECAP1_EN;
  input bit S_AXI_HP1_RREADY;
  input bit S_AXI_HP1_WLAST;
  input bit S_AXI_HP1_WRISSUECAP1_EN;
  input bit S_AXI_HP1_WVALID;
  input bit [1 : 0] S_AXI_HP1_ARBURST;
  input bit [1 : 0] S_AXI_HP1_ARLOCK;
  input bit [2 : 0] S_AXI_HP1_ARSIZE;
  input bit [1 : 0] S_AXI_HP1_AWBURST;
  input bit [1 : 0] S_AXI_HP1_AWLOCK;
  input bit [2 : 0] S_AXI_HP1_AWSIZE;
  input bit [2 : 0] S_AXI_HP1_ARPROT;
  input bit [2 : 0] S_AXI_HP1_AWPROT;
  input bit [31 : 0] S_AXI_HP1_ARADDR;
  input bit [31 : 0] S_AXI_HP1_AWADDR;
  input bit [3 : 0] S_AXI_HP1_ARCACHE;
  input bit [3 : 0] S_AXI_HP1_ARLEN;
  input bit [3 : 0] S_AXI_HP1_ARQOS;
  input bit [3 : 0] S_AXI_HP1_AWCACHE;
  input bit [3 : 0] S_AXI_HP1_AWLEN;
  input bit [3 : 0] S_AXI_HP1_AWQOS;
  input bit [5 : 0] S_AXI_HP1_ARID;
  input bit [5 : 0] S_AXI_HP1_AWID;
  input bit [5 : 0] S_AXI_HP1_WID;
  input bit [63 : 0] S_AXI_HP1_WDATA;
  input bit [7 : 0] S_AXI_HP1_WSTRB;
  input bit [1 : 0] IRQ_F2P;
  output wire FCLK_CLK0;
  output wire FCLK_RESET0_N;
  inout wire [53 : 0] MIO;
  inout wire DDR_CAS_n;
  inout wire DDR_CKE;
  inout wire DDR_Clk_n;
  inout wire DDR_Clk;
  inout wire DDR_CS_n;
  inout wire DDR_DRSTB;
  inout wire DDR_ODT;
  inout wire DDR_RAS_n;
  inout wire DDR_WEB;
  inout wire [2 : 0] DDR_BankAddr;
  inout wire [14 : 0] DDR_Addr;
  inout wire DDR_VRN;
  inout wire DDR_VRP;
  inout wire [3 : 0] DDR_DM;
  inout wire [31 : 0] DDR_DQ;
  inout wire [3 : 0] DDR_DQS_n;
  inout wire [3 : 0] DDR_DQS;
  inout wire PS_SRSTB;
  inout wire PS_CLK;
  inout wire PS_PORB;
endmodule
`endif

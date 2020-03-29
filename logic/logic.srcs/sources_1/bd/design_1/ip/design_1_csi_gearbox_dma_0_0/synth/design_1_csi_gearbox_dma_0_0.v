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


// IP VLNV: xilinx.com:user:csi_gearbox_dma:1.0
// IP Revision: 26

(* X_CORE_INFO = "csi_gearbox_dma_v1_0,Vivado 2019.2" *)
(* CHECK_LICENSE_TYPE = "design_1_csi_gearbox_dma_0_0,csi_gearbox_dma_v1_0,{}" *)
(* CORE_GENERATION_INFO = "design_1_csi_gearbox_dma_0_0,csi_gearbox_dma_v1_0,{x_ipProduct=Vivado 2019.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=csi_gearbox_dma,x_ipVersion=1.0,x_ipCoreRevision=26,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_S00_AXIS_TDATA_WIDTH=64,C_PN_SWAP_D0=true,C_PN_SWAP_D1=true,C_PN_SWAP_CLK=true}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_csi_gearbox_dma_0_0 (
  csi_clk_p,
  csi_clk_n,
  csi_d0_p,
  csi_d0_n,
  csi_d1_p,
  csi_d1_n,
  csi_lpd0_p,
  csi_lpd0_n,
  csi_lpd1_p,
  csi_lpd1_n,
  csi_lpclk_p,
  csi_lpclk_n,
  mod_clk_I,
  mod_clk_Q,
  csi_sleep,
  csi_start_lines,
  csi_start_frame,
  csi_end_frame,
  csi_stop,
  csi_done,
  R_csi_line_count,
  R_csi_line_byte_count,
  R_csi_data_type,
  R_csi_wct_frame,
  R_csi_control_flags,
  csi_ctrl_state_dbg,
  csi_mipi_busy_dbg,
  csi_mipi_done_dbg,
  csi_mipi_init_short_dbg,
  csi_mipi_init_long_dbg,
  csi_mipi_init_idle_dbg,
  csi_debug_tx_size,
  csi_debug_mipi_state,
  csi_debug_state_timer,
  csi_debug_state_timer2,
  csi_debug_state_timer_rst,
  csi_debug_data_mux_out,
  csi_debug_fifo_read_valid,
  csi_debug_fifo_space_available,
  csi_debug_mipi_read_req,
  dbg_fifo_data_ct,
  dbg_ref_clk,
  g_rst,
  s00_axis_aclk,
  s00_axis_aresetn,
  s00_axis_tready,
  s00_axis_tdata,
  s00_axis_tstrb,
  s00_axis_tlast,
  s00_axis_tvalid
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME csi_clk_p, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_csi_gearbox_dma_0_0_csi_clk_p, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 csi_clk_p CLK" *)
output wire csi_clk_p;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME csi_clk_n, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_csi_gearbox_dma_0_0_csi_clk_n, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 csi_clk_n CLK" *)
output wire csi_clk_n;
output wire csi_d0_p;
output wire csi_d0_n;
output wire csi_d1_p;
output wire csi_d1_n;
output wire csi_lpd0_p;
output wire csi_lpd0_n;
output wire csi_lpd1_p;
output wire csi_lpd1_n;
output wire csi_lpclk_p;
output wire csi_lpclk_n;
input wire mod_clk_I;
input wire mod_clk_Q;
input wire csi_sleep;
input wire csi_start_lines;
input wire csi_start_frame;
input wire csi_end_frame;
input wire csi_stop;
output wire csi_done;
input wire [15 : 0] R_csi_line_count;
input wire [20 : 0] R_csi_line_byte_count;
input wire [7 : 0] R_csi_data_type;
input wire [15 : 0] R_csi_wct_frame;
input wire [15 : 0] R_csi_control_flags;
output wire [5 : 0] csi_ctrl_state_dbg;
output wire csi_mipi_busy_dbg;
output wire csi_mipi_done_dbg;
output wire csi_mipi_init_short_dbg;
output wire csi_mipi_init_long_dbg;
output wire csi_mipi_init_idle_dbg;
output wire [15 : 0] csi_debug_tx_size;
output wire [5 : 0] csi_debug_mipi_state;
output wire [15 : 0] csi_debug_state_timer;
output wire [15 : 0] csi_debug_state_timer2;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME csi_debug_state_timer_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 csi_debug_state_timer_rst RST" *)
output wire csi_debug_state_timer_rst;
output wire [15 : 0] csi_debug_data_mux_out;
output wire csi_debug_fifo_read_valid;
output wire csi_debug_fifo_space_available;
output wire csi_debug_mipi_read_req;
output wire [11 : 0] dbg_fifo_data_ct;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dbg_ref_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_csi_gearbox_dma_0_0_dbg_ref_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 dbg_ref_clk CLK" *)
output wire dbg_ref_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME g_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 g_rst RST" *)
input wire g_rst;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS_CLK, ASSOCIATED_BUSIF S00_AXIS, ASSOCIATED_RESET s00_axis_aresetn, FREQ_HZ 177777771, PHASE 0.000, CLK_DOMAIN design_1_zynq_ps_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S00_AXIS_CLK CLK" *)
input wire s00_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S00_AXIS_RST RST" *)
input wire s00_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TREADY" *)
output wire s00_axis_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TDATA" *)
input wire [63 : 0] s00_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TSTRB" *)
input wire [7 : 0] s00_axis_tstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TLAST" *)
input wire s00_axis_tlast;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 177777771, PHASE 0.000, CLK_DOMAIN design_1_zynq_ps_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TVALID" *)
input wire s00_axis_tvalid;

  csi_gearbox_dma_v1_0 #(
    .C_S00_AXIS_TDATA_WIDTH(64),  // AXI4Stream sink: Data Width
    .C_PN_SWAP_D0(1'B1),
    .C_PN_SWAP_D1(1'B1),
    .C_PN_SWAP_CLK(1'B1)
  ) inst (
    .csi_clk_p(csi_clk_p),
    .csi_clk_n(csi_clk_n),
    .csi_d0_p(csi_d0_p),
    .csi_d0_n(csi_d0_n),
    .csi_d1_p(csi_d1_p),
    .csi_d1_n(csi_d1_n),
    .csi_lpd0_p(csi_lpd0_p),
    .csi_lpd0_n(csi_lpd0_n),
    .csi_lpd1_p(csi_lpd1_p),
    .csi_lpd1_n(csi_lpd1_n),
    .csi_lpclk_p(csi_lpclk_p),
    .csi_lpclk_n(csi_lpclk_n),
    .mod_clk_I(mod_clk_I),
    .mod_clk_Q(mod_clk_Q),
    .csi_sleep(csi_sleep),
    .csi_start_lines(csi_start_lines),
    .csi_start_frame(csi_start_frame),
    .csi_end_frame(csi_end_frame),
    .csi_stop(csi_stop),
    .csi_done(csi_done),
    .R_csi_line_count(R_csi_line_count),
    .R_csi_line_byte_count(R_csi_line_byte_count),
    .R_csi_data_type(R_csi_data_type),
    .R_csi_wct_frame(R_csi_wct_frame),
    .R_csi_control_flags(R_csi_control_flags),
    .csi_ctrl_state_dbg(csi_ctrl_state_dbg),
    .csi_mipi_busy_dbg(csi_mipi_busy_dbg),
    .csi_mipi_done_dbg(csi_mipi_done_dbg),
    .csi_mipi_init_short_dbg(csi_mipi_init_short_dbg),
    .csi_mipi_init_long_dbg(csi_mipi_init_long_dbg),
    .csi_mipi_init_idle_dbg(csi_mipi_init_idle_dbg),
    .csi_debug_tx_size(csi_debug_tx_size),
    .csi_debug_mipi_state(csi_debug_mipi_state),
    .csi_debug_state_timer(csi_debug_state_timer),
    .csi_debug_state_timer2(csi_debug_state_timer2),
    .csi_debug_state_timer_rst(csi_debug_state_timer_rst),
    .csi_debug_data_mux_out(csi_debug_data_mux_out),
    .csi_debug_fifo_read_valid(csi_debug_fifo_read_valid),
    .csi_debug_fifo_space_available(csi_debug_fifo_space_available),
    .csi_debug_mipi_read_req(csi_debug_mipi_read_req),
    .dbg_fifo_data_ct(dbg_fifo_data_ct),
    .dbg_ref_clk(dbg_ref_clk),
    .g_rst(g_rst),
    .s00_axis_aclk(s00_axis_aclk),
    .s00_axis_aresetn(s00_axis_aresetn),
    .s00_axis_tready(s00_axis_tready),
    .s00_axis_tdata(s00_axis_tdata),
    .s00_axis_tstrb(s00_axis_tstrb),
    .s00_axis_tlast(s00_axis_tlast),
    .s00_axis_tvalid(s00_axis_tvalid)
  );
endmodule

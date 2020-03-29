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


// IP VLNV: xilinx.com:user:adc_streamer:2.0
// IP Revision: 121

(* X_CORE_INFO = "adc_streamer,Vivado 2019.2" *)
(* CHECK_LICENSE_TYPE = "design_1_adc_axi_streamer_0,adc_streamer,{}" *)
(* CORE_GENERATION_INFO = "design_1_adc_axi_streamer_0,adc_streamer,{x_ipProduct=Vivado 2019.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=adc_streamer,x_ipVersion=2.0,x_ipCoreRevision=121,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_M00_AXIS_TDATA_WIDTH=64,C_M00_AXIS_START_COUNT=32}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_adc_axi_streamer_0 (
  adc_bus,
  adc_data_clk,
  dbg_adcstream_state,
  dbg_axi_rdy,
  dbg_acq_axi_running,
  dbg_acq_axi_upcounter,
  dbg_acq_axi_downcounter,
  dbg_acq_trigger_out_ctr,
  dbg_rd_data_count,
  dbg_wr_data_count,
  dbg_acq_run,
  dbg_acq_axi_run,
  dbg_acq_trig_mask,
  dbg_acq_trig_rst,
  dbg_acq_depth_mux,
  dbg_acq_fifo_reset,
  dbg_acq_abort,
  dbg_acq_eof,
  dbg_acq_data_valid,
  dbg_trig_post_fifo,
  dbg_acq_have_trig,
  dbg_acq_tvalid_mask,
  dbg_fifo_wr_en,
  dbg_fifo_rd_en,
  dbg_fifo_wr_rst_busy,
  dbg_fifo_rd_rst_busy,
  dbg_fifo_rst_holdoff,
  dbg_acq_holdoff_regd,
  dbg_adc_fifo_gated_clk,
  dbg_acq_suspend,
  dbg_acq_post_trigger,
  acq_ctrl_a,
  acq_status_a,
  acq_status_b,
  acq_status_c,
  acq_train_a,
  acq_train_b,
  acq_depth_a,
  acq_depth_b,
  acq_reset_irq_gen,
  pll_lock_idelaye2_clkref,
  train_delay_loaded,
  train_bitslip_locked,
  train_idelaye2_ready,
  delay_load,
  delay_l1a,
  delay_l1b,
  delay_l2a,
  delay_l2b,
  delay_l3a,
  delay_l3b,
  delay_l4a,
  delay_l4b,
  trigger_in,
  trigger_sub_word,
  trigger_pos,
  trigger_out,
  acq_armed_waiting_trig,
  acq_holdoff,
  acq_done_post,
  acq_done,
  acq_have_trig,
  m00_axis_aclk,
  m00_axis_aresetn,
  m00_axis_tvalid,
  m00_axis_tdata,
  m00_axis_tstrb,
  m00_axis_tlast,
  m00_axis_tready
);

input wire [63 : 0] adc_bus;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_data_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_adc_receiver_core_0_0_adc_data_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc_data_clk CLK" *)
input wire adc_data_clk;
output wire [5 : 0] dbg_adcstream_state;
output wire dbg_axi_rdy;
output wire dbg_acq_axi_running;
output wire [31 : 0] dbg_acq_axi_upcounter;
output wire [31 : 0] dbg_acq_axi_downcounter;
output wire [10 : 0] dbg_acq_trigger_out_ctr;
output wire [15 : 0] dbg_rd_data_count;
output wire [15 : 0] dbg_wr_data_count;
output wire dbg_acq_run;
output wire dbg_acq_axi_run;
output wire dbg_acq_trig_mask;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dbg_acq_trig_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 dbg_acq_trig_rst RST" *)
output wire dbg_acq_trig_rst;
output wire dbg_acq_depth_mux;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dbg_acq_fifo_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 dbg_acq_fifo_reset RST" *)
output wire dbg_acq_fifo_reset;
output wire dbg_acq_abort;
output wire dbg_acq_eof;
output wire dbg_acq_data_valid;
output wire dbg_trig_post_fifo;
output wire dbg_acq_have_trig;
output wire dbg_acq_tvalid_mask;
output wire dbg_fifo_wr_en;
output wire dbg_fifo_rd_en;
output wire dbg_fifo_wr_rst_busy;
output wire dbg_fifo_rd_rst_busy;
output wire dbg_fifo_rst_holdoff;
output wire dbg_acq_holdoff_regd;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dbg_adc_fifo_gated_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_adc_axi_streamer_0_dbg_adc_fifo_gated_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 dbg_adc_fifo_gated_clk CLK" *)
output wire dbg_adc_fifo_gated_clk;
output wire dbg_acq_suspend;
output wire dbg_acq_post_trigger;
input wire [31 : 0] acq_ctrl_a;
output wire [31 : 0] acq_status_a;
output wire [31 : 0] acq_status_b;
output wire [31 : 0] acq_status_c;
input wire [31 : 0] acq_train_a;
input wire [31 : 0] acq_train_b;
input wire [28 : 0] acq_depth_a;
input wire [28 : 0] acq_depth_b;
output wire acq_reset_irq_gen;
input wire pll_lock_idelaye2_clkref;
input wire train_delay_loaded;
input wire train_bitslip_locked;
input wire train_idelaye2_ready;
output wire delay_load;
output wire [5 : 0] delay_l1a;
output wire [5 : 0] delay_l1b;
output wire [5 : 0] delay_l2a;
output wire [5 : 0] delay_l2b;
output wire [5 : 0] delay_l3a;
output wire [5 : 0] delay_l3b;
output wire [5 : 0] delay_l4a;
output wire [5 : 0] delay_l4b;
input wire trigger_in;
input wire [2 : 0] trigger_sub_word;
output wire [31 : 0] trigger_pos;
output wire trigger_out;
output wire acq_armed_waiting_trig;
input wire acq_holdoff;
output wire acq_done_post;
output wire acq_done;
output wire acq_have_trig;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_CLK, ASSOCIATED_BUSIF M00_AXIS, ASSOCIATED_RESET m00_axis_aresetn, FREQ_HZ 177777771, PHASE 0.000, CLK_DOMAIN design_1_zynq_ps_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK" *)
input wire m00_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST" *)
input wire m00_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TVALID" *)
output wire m00_axis_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TDATA" *)
output wire [63 : 0] m00_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TSTRB" *)
output wire [7 : 0] m00_axis_tstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TLAST" *)
output wire m00_axis_tlast;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 177777771, PHASE 0.000, CLK_DOMAIN design_1_zynq_ps_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TREADY" *)
input wire m00_axis_tready;

  adc_streamer #(
    .C_M00_AXIS_TDATA_WIDTH(64),  // Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    .C_M00_AXIS_START_COUNT(32)  // Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
  ) inst (
    .adc_bus(adc_bus),
    .adc_data_clk(adc_data_clk),
    .dbg_adcstream_state(dbg_adcstream_state),
    .dbg_axi_rdy(dbg_axi_rdy),
    .dbg_acq_axi_running(dbg_acq_axi_running),
    .dbg_acq_axi_upcounter(dbg_acq_axi_upcounter),
    .dbg_acq_axi_downcounter(dbg_acq_axi_downcounter),
    .dbg_acq_trigger_out_ctr(dbg_acq_trigger_out_ctr),
    .dbg_rd_data_count(dbg_rd_data_count),
    .dbg_wr_data_count(dbg_wr_data_count),
    .dbg_acq_run(dbg_acq_run),
    .dbg_acq_axi_run(dbg_acq_axi_run),
    .dbg_acq_trig_mask(dbg_acq_trig_mask),
    .dbg_acq_trig_rst(dbg_acq_trig_rst),
    .dbg_acq_depth_mux(dbg_acq_depth_mux),
    .dbg_acq_fifo_reset(dbg_acq_fifo_reset),
    .dbg_acq_abort(dbg_acq_abort),
    .dbg_acq_eof(dbg_acq_eof),
    .dbg_acq_data_valid(dbg_acq_data_valid),
    .dbg_trig_post_fifo(dbg_trig_post_fifo),
    .dbg_acq_have_trig(dbg_acq_have_trig),
    .dbg_acq_tvalid_mask(dbg_acq_tvalid_mask),
    .dbg_fifo_wr_en(dbg_fifo_wr_en),
    .dbg_fifo_rd_en(dbg_fifo_rd_en),
    .dbg_fifo_wr_rst_busy(dbg_fifo_wr_rst_busy),
    .dbg_fifo_rd_rst_busy(dbg_fifo_rd_rst_busy),
    .dbg_fifo_rst_holdoff(dbg_fifo_rst_holdoff),
    .dbg_acq_holdoff_regd(dbg_acq_holdoff_regd),
    .dbg_adc_fifo_gated_clk(dbg_adc_fifo_gated_clk),
    .dbg_acq_suspend(dbg_acq_suspend),
    .dbg_acq_post_trigger(dbg_acq_post_trigger),
    .acq_ctrl_a(acq_ctrl_a),
    .acq_status_a(acq_status_a),
    .acq_status_b(acq_status_b),
    .acq_status_c(acq_status_c),
    .acq_train_a(acq_train_a),
    .acq_train_b(acq_train_b),
    .acq_depth_a(acq_depth_a),
    .acq_depth_b(acq_depth_b),
    .acq_reset_irq_gen(acq_reset_irq_gen),
    .pll_lock_idelaye2_clkref(pll_lock_idelaye2_clkref),
    .train_delay_loaded(train_delay_loaded),
    .train_bitslip_locked(train_bitslip_locked),
    .train_idelaye2_ready(train_idelaye2_ready),
    .delay_load(delay_load),
    .delay_l1a(delay_l1a),
    .delay_l1b(delay_l1b),
    .delay_l2a(delay_l2a),
    .delay_l2b(delay_l2b),
    .delay_l3a(delay_l3a),
    .delay_l3b(delay_l3b),
    .delay_l4a(delay_l4a),
    .delay_l4b(delay_l4b),
    .trigger_in(trigger_in),
    .trigger_sub_word(trigger_sub_word),
    .trigger_pos(trigger_pos),
    .trigger_out(trigger_out),
    .acq_armed_waiting_trig(acq_armed_waiting_trig),
    .acq_holdoff(acq_holdoff),
    .acq_done_post(acq_done_post),
    .acq_done(acq_done),
    .acq_have_trig(acq_have_trig),
    .m00_axis_aclk(m00_axis_aclk),
    .m00_axis_aresetn(m00_axis_aresetn),
    .m00_axis_tvalid(m00_axis_tvalid),
    .m00_axis_tdata(m00_axis_tdata),
    .m00_axis_tstrb(m00_axis_tstrb),
    .m00_axis_tlast(m00_axis_tlast),
    .m00_axis_tready(m00_axis_tready)
  );
endmodule

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


// IP VLNV: xilinx.com:user:adc_trigger:1.0
// IP Revision: 89

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_adc_trigger_0_0 (
  adc_bus,
  adc_data_clk,
  trig_level_0,
  trig_level_1,
  trig_level_2,
  trig_level_3,
  trig_level_4,
  trig_level_5,
  trig_level_6,
  trig_level_7,
  trig_config_a,
  trig_config_b,
  trig_state_a,
  trig_holdoff,
  trig_auto_timers,
  trig_delay_reg0,
  trig_delay_reg1,
  trig_holdoff_debug,
  trig_input_external,
  trig_input_ac,
  acq_armed_waiting_trig,
  acq_holdoff,
  acq_done,
  acq_done_post,
  acq_have_trig,
  dbg_trig_sig_a,
  dbg_trig_sig_b,
  dbg_comp_state_1_0123a,
  dbg_comp_state_2_0123a,
  dbg_comp_state_1_0123b,
  dbg_comp_state_2_0123b,
  dbg_comp_state_1_4567a,
  dbg_comp_state_2_4567a,
  dbg_comp_state_1_4567b,
  dbg_comp_state_2_4567b,
  dbg_ev_counter_1_0123a,
  dbg_ev_counter_2_0123a,
  dbg_ev_counter_1_0123b,
  dbg_ev_counter_2_0123b,
  dbg_ev_counter_1_4567a,
  dbg_ev_counter_2_4567a,
  dbg_ev_counter_1_4567b,
  dbg_ev_counter_2_4567b,
  dbg_cmp_1a_hi_a,
  dbg_cmp_1b_hi_a,
  dbg_cmp_2a_hi_a,
  dbg_cmp_2b_hi_a,
  dbg_cmp_3a_hi_a,
  dbg_cmp_3b_hi_a,
  dbg_cmp_4a_hi_a,
  dbg_cmp_4b_hi_a,
  dbg_cmp_1a_lo_a,
  dbg_cmp_1b_lo_a,
  dbg_cmp_2a_lo_a,
  dbg_cmp_2b_lo_a,
  dbg_cmp_3a_lo_a,
  dbg_cmp_3b_lo_a,
  dbg_cmp_4a_lo_a,
  dbg_cmp_4b_lo_a,
  dbg_trig_src_1a_group_a,
  dbg_trig_src_1b_group_a,
  dbg_trig_src_2a_group_a,
  dbg_trig_src_2b_group_a,
  dbg_trig_src_3a_group_a,
  dbg_trig_src_3b_group_a,
  dbg_trig_src_4a_group_a,
  dbg_trig_src_4b_group_a,
  dbg_trig_src_1a_group_b,
  dbg_trig_src_1b_group_b,
  dbg_trig_src_2a_group_b,
  dbg_trig_src_2b_group_b,
  dbg_trig_src_3a_group_b,
  dbg_trig_src_3b_group_b,
  dbg_trig_src_4a_group_b,
  dbg_trig_src_4b_group_b,
  dbg_trig_edge_out,
  dbg_edge_trig_logic,
  dbg_trig_sum_word,
  dbg_edge_trig_ch_code_valid,
  dbg_edge_decode_rst,
  dbg_trig_src_4a4b_dly2,
  dbg_trig_ch_code_state,
  dbg_resv,
  trig_out,
  trig_sub_word
);

input wire [63 : 0] adc_bus;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_data_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_adc_receiver_core_0_0_adc_data_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc_data_clk CLK" *)
input wire adc_data_clk;
input wire [31 : 0] trig_level_0;
input wire [31 : 0] trig_level_1;
input wire [31 : 0] trig_level_2;
input wire [31 : 0] trig_level_3;
input wire [31 : 0] trig_level_4;
input wire [31 : 0] trig_level_5;
input wire [31 : 0] trig_level_6;
input wire [31 : 0] trig_level_7;
input wire [31 : 0] trig_config_a;
input wire [31 : 0] trig_config_b;
output wire [31 : 0] trig_state_a;
input wire [31 : 0] trig_holdoff;
input wire [31 : 0] trig_auto_timers;
input wire [31 : 0] trig_delay_reg0;
input wire [31 : 0] trig_delay_reg1;
output wire [31 : 0] trig_holdoff_debug;
input wire trig_input_external;
input wire trig_input_ac;
input wire acq_armed_waiting_trig;
output wire acq_holdoff;
input wire acq_done;
input wire acq_done_post;
input wire acq_have_trig;
output wire [3 : 0] dbg_trig_sig_a;
output wire [3 : 0] dbg_trig_sig_b;
output wire [1 : 0] dbg_comp_state_1_0123a;
output wire [1 : 0] dbg_comp_state_2_0123a;
output wire [1 : 0] dbg_comp_state_1_0123b;
output wire [1 : 0] dbg_comp_state_2_0123b;
output wire [1 : 0] dbg_comp_state_1_4567a;
output wire [1 : 0] dbg_comp_state_2_4567a;
output wire [1 : 0] dbg_comp_state_1_4567b;
output wire [1 : 0] dbg_comp_state_2_4567b;
output wire [1 : 0] dbg_ev_counter_1_0123a;
output wire [1 : 0] dbg_ev_counter_2_0123a;
output wire [1 : 0] dbg_ev_counter_1_0123b;
output wire [1 : 0] dbg_ev_counter_2_0123b;
output wire [1 : 0] dbg_ev_counter_1_4567a;
output wire [1 : 0] dbg_ev_counter_2_4567a;
output wire [1 : 0] dbg_ev_counter_1_4567b;
output wire [1 : 0] dbg_ev_counter_2_4567b;
output wire dbg_cmp_1a_hi_a;
output wire dbg_cmp_1b_hi_a;
output wire dbg_cmp_2a_hi_a;
output wire dbg_cmp_2b_hi_a;
output wire dbg_cmp_3a_hi_a;
output wire dbg_cmp_3b_hi_a;
output wire dbg_cmp_4a_hi_a;
output wire dbg_cmp_4b_hi_a;
output wire dbg_cmp_1a_lo_a;
output wire dbg_cmp_1b_lo_a;
output wire dbg_cmp_2a_lo_a;
output wire dbg_cmp_2b_lo_a;
output wire dbg_cmp_3a_lo_a;
output wire dbg_cmp_3b_lo_a;
output wire dbg_cmp_4a_lo_a;
output wire dbg_cmp_4b_lo_a;
output wire dbg_trig_src_1a_group_a;
output wire dbg_trig_src_1b_group_a;
output wire dbg_trig_src_2a_group_a;
output wire dbg_trig_src_2b_group_a;
output wire dbg_trig_src_3a_group_a;
output wire dbg_trig_src_3b_group_a;
output wire dbg_trig_src_4a_group_a;
output wire dbg_trig_src_4b_group_a;
output wire dbg_trig_src_1a_group_b;
output wire dbg_trig_src_1b_group_b;
output wire dbg_trig_src_2a_group_b;
output wire dbg_trig_src_2b_group_b;
output wire dbg_trig_src_3a_group_b;
output wire dbg_trig_src_3b_group_b;
output wire dbg_trig_src_4a_group_b;
output wire dbg_trig_src_4b_group_b;
output wire dbg_trig_edge_out;
output wire dbg_edge_trig_logic;
output wire [2 : 0] dbg_trig_sum_word;
output wire dbg_edge_trig_ch_code_valid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dbg_edge_decode_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 dbg_edge_decode_rst RST" *)
output wire dbg_edge_decode_rst;
output wire [1 : 0] dbg_trig_src_4a4b_dly2;
output wire [2 : 0] dbg_trig_ch_code_state;
output wire dbg_resv;
output wire trig_out;
output wire [2 : 0] trig_sub_word;

  adc_trigger_v1_0 #(
    .TRIG_TYPE_NEVER(0),
    .TRIG_TYPE_ALWAYS(1),
    .TRIG_TYPE_EDGE(2),
    .TRIG_EDGE_NONE('B00),
    .TRIG_EDGE_RISING('B01),
    .TRIG_EDGE_FALLING('B10),
    .TRIG_EDGE_EITHER('B11),
    .ADC_1A(0),
    .ADC_1B(1),
    .ADC_2A(2),
    .ADC_2B(3),
    .ADC_3A(4),
    .ADC_3B(5),
    .ADC_4A(6),
    .ADC_4B(7),
    .TRCHAN_1A(0),
    .TRCHAN_2A(1),
    .TRCHAN_3A(2),
    .TRCHAN_4A(3),
    .TRCHAN_1B(4),
    .TRCHAN_2B(5),
    .TRCHAN_3B(6),
    .TRCHAN_4B(7),
    .TRIG_MODE_NORMAL('B0),
    .TRIG_MODE_AUTO('B1),
    .TRIG_STATE_WAIT_FOR_ARM(1),
    .TRIG_STATE_ARMED_WAITING(2),
    .TRIG_STATE_TRIGD_HOLDOFF_LOAD(3),
    .TRIG_STATE_TRIGD_HOLDOFF(4),
    .TRIG_STATE_TRIGD_AUTO_INITIAL(5),
    .TRIG_STATE_TRIGD_AUTO_REPEAT(6),
    .TRIG_STATE_TRIGD_FORCE_AUTO(7),
    .TRIG_STATE_TRIGD_HOLDOFF_ACK(5)
  ) inst (
    .adc_bus(adc_bus),
    .adc_data_clk(adc_data_clk),
    .trig_level_0(trig_level_0),
    .trig_level_1(trig_level_1),
    .trig_level_2(trig_level_2),
    .trig_level_3(trig_level_3),
    .trig_level_4(trig_level_4),
    .trig_level_5(trig_level_5),
    .trig_level_6(trig_level_6),
    .trig_level_7(trig_level_7),
    .trig_config_a(trig_config_a),
    .trig_config_b(trig_config_b),
    .trig_state_a(trig_state_a),
    .trig_holdoff(trig_holdoff),
    .trig_auto_timers(trig_auto_timers),
    .trig_delay_reg0(trig_delay_reg0),
    .trig_delay_reg1(trig_delay_reg1),
    .trig_holdoff_debug(trig_holdoff_debug),
    .trig_input_external(trig_input_external),
    .trig_input_ac(trig_input_ac),
    .acq_armed_waiting_trig(acq_armed_waiting_trig),
    .acq_holdoff(acq_holdoff),
    .acq_done(acq_done),
    .acq_done_post(acq_done_post),
    .acq_have_trig(acq_have_trig),
    .dbg_trig_sig_a(dbg_trig_sig_a),
    .dbg_trig_sig_b(dbg_trig_sig_b),
    .dbg_comp_state_1_0123a(dbg_comp_state_1_0123a),
    .dbg_comp_state_2_0123a(dbg_comp_state_2_0123a),
    .dbg_comp_state_1_0123b(dbg_comp_state_1_0123b),
    .dbg_comp_state_2_0123b(dbg_comp_state_2_0123b),
    .dbg_comp_state_1_4567a(dbg_comp_state_1_4567a),
    .dbg_comp_state_2_4567a(dbg_comp_state_2_4567a),
    .dbg_comp_state_1_4567b(dbg_comp_state_1_4567b),
    .dbg_comp_state_2_4567b(dbg_comp_state_2_4567b),
    .dbg_ev_counter_1_0123a(dbg_ev_counter_1_0123a),
    .dbg_ev_counter_2_0123a(dbg_ev_counter_2_0123a),
    .dbg_ev_counter_1_0123b(dbg_ev_counter_1_0123b),
    .dbg_ev_counter_2_0123b(dbg_ev_counter_2_0123b),
    .dbg_ev_counter_1_4567a(dbg_ev_counter_1_4567a),
    .dbg_ev_counter_2_4567a(dbg_ev_counter_2_4567a),
    .dbg_ev_counter_1_4567b(dbg_ev_counter_1_4567b),
    .dbg_ev_counter_2_4567b(dbg_ev_counter_2_4567b),
    .dbg_cmp_1a_hi_a(dbg_cmp_1a_hi_a),
    .dbg_cmp_1b_hi_a(dbg_cmp_1b_hi_a),
    .dbg_cmp_2a_hi_a(dbg_cmp_2a_hi_a),
    .dbg_cmp_2b_hi_a(dbg_cmp_2b_hi_a),
    .dbg_cmp_3a_hi_a(dbg_cmp_3a_hi_a),
    .dbg_cmp_3b_hi_a(dbg_cmp_3b_hi_a),
    .dbg_cmp_4a_hi_a(dbg_cmp_4a_hi_a),
    .dbg_cmp_4b_hi_a(dbg_cmp_4b_hi_a),
    .dbg_cmp_1a_lo_a(dbg_cmp_1a_lo_a),
    .dbg_cmp_1b_lo_a(dbg_cmp_1b_lo_a),
    .dbg_cmp_2a_lo_a(dbg_cmp_2a_lo_a),
    .dbg_cmp_2b_lo_a(dbg_cmp_2b_lo_a),
    .dbg_cmp_3a_lo_a(dbg_cmp_3a_lo_a),
    .dbg_cmp_3b_lo_a(dbg_cmp_3b_lo_a),
    .dbg_cmp_4a_lo_a(dbg_cmp_4a_lo_a),
    .dbg_cmp_4b_lo_a(dbg_cmp_4b_lo_a),
    .dbg_trig_src_1a_group_a(dbg_trig_src_1a_group_a),
    .dbg_trig_src_1b_group_a(dbg_trig_src_1b_group_a),
    .dbg_trig_src_2a_group_a(dbg_trig_src_2a_group_a),
    .dbg_trig_src_2b_group_a(dbg_trig_src_2b_group_a),
    .dbg_trig_src_3a_group_a(dbg_trig_src_3a_group_a),
    .dbg_trig_src_3b_group_a(dbg_trig_src_3b_group_a),
    .dbg_trig_src_4a_group_a(dbg_trig_src_4a_group_a),
    .dbg_trig_src_4b_group_a(dbg_trig_src_4b_group_a),
    .dbg_trig_src_1a_group_b(dbg_trig_src_1a_group_b),
    .dbg_trig_src_1b_group_b(dbg_trig_src_1b_group_b),
    .dbg_trig_src_2a_group_b(dbg_trig_src_2a_group_b),
    .dbg_trig_src_2b_group_b(dbg_trig_src_2b_group_b),
    .dbg_trig_src_3a_group_b(dbg_trig_src_3a_group_b),
    .dbg_trig_src_3b_group_b(dbg_trig_src_3b_group_b),
    .dbg_trig_src_4a_group_b(dbg_trig_src_4a_group_b),
    .dbg_trig_src_4b_group_b(dbg_trig_src_4b_group_b),
    .dbg_trig_edge_out(dbg_trig_edge_out),
    .dbg_edge_trig_logic(dbg_edge_trig_logic),
    .dbg_trig_sum_word(dbg_trig_sum_word),
    .dbg_edge_trig_ch_code_valid(dbg_edge_trig_ch_code_valid),
    .dbg_edge_decode_rst(dbg_edge_decode_rst),
    .dbg_trig_src_4a4b_dly2(dbg_trig_src_4a4b_dly2),
    .dbg_trig_ch_code_state(dbg_trig_ch_code_state),
    .dbg_resv(dbg_resv),
    .trig_out(trig_out),
    .trig_sub_word(trig_sub_word)
  );
endmodule

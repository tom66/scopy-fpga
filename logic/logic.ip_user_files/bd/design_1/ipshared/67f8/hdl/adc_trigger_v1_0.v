
`timescale 1 ns / 1 ps

module adc_trigger_v1_0 
(
    input [63:0] adc_bus,
    input adc_data_clk,
    
    input [31:0] trig_level_0,
    input [31:0] trig_level_1,
    input [31:0] trig_level_2,
    input [31:0] trig_level_3,
    input [31:0] trig_level_4,
    input [31:0] trig_level_5,
    input [31:0] trig_level_6,
    input [31:0] trig_level_7,
    input [31:0] trig_config_a,
    input [31:0] trig_config_b,
    output [31:0] trig_state_a,
    input [31:0] trig_holdoff,
    input [31:0] trig_auto_timers,
    input [31:0] trig_delay_reg0,
    input [31:0] trig_delay_reg1,
    output [31:0] trig_holdoff_debug,
    
    input trig_input_external,
    input trig_input_ac,
    
    // Acquisition signals
    input acq_armed_waiting_trig,   // Signal from acquisition engine indicating that an acquisition is running waiting for a trigger
    output reg acq_holdoff,         // Output to acquisition engine to pause operations during holdoff, including gating FIFO clock to save power
    input acq_done,                 // Signal from acquisition engine indicating that the acquisition is done with or without post-trigger
    input acq_done_post,            // Signal from acquisition engine indicating that the acquisition is done with a post-trigger period
    input acq_have_trig,            // Signal from acquisition engine indicating that a trigger was captured in the last acquisition
    
    output wire [3:0] dbg_trig_sig_a,
    output wire [3:0] dbg_trig_sig_b,
        
    output wire [1:0] dbg_comp_state_1_0123a,
    output wire [1:0] dbg_comp_state_2_0123a,
    output wire [1:0] dbg_comp_state_1_0123b,
    output wire [1:0] dbg_comp_state_2_0123b,
    output wire [1:0] dbg_comp_state_1_4567a,
    output wire [1:0] dbg_comp_state_2_4567a,
    output wire [1:0] dbg_comp_state_1_4567b,
    output wire [1:0] dbg_comp_state_2_4567b,

    output wire [1:0] dbg_ev_counter_1_0123a,
    output wire [1:0] dbg_ev_counter_2_0123a,
    output wire [1:0] dbg_ev_counter_1_0123b,
    output wire [1:0] dbg_ev_counter_2_0123b,
    output wire [1:0] dbg_ev_counter_1_4567a,
    output wire [1:0] dbg_ev_counter_2_4567a,
    output wire [1:0] dbg_ev_counter_1_4567b,
    output wire [1:0] dbg_ev_counter_2_4567b,

	output wire dbg_cmp_1a_hi_a,
	output wire dbg_cmp_1b_hi_a,
	output wire dbg_cmp_2a_hi_a,
	output wire dbg_cmp_2b_hi_a,
	output wire dbg_cmp_3a_hi_a,
	output wire dbg_cmp_3b_hi_a,
	output wire dbg_cmp_4a_hi_a,
	output wire dbg_cmp_4b_hi_a,
	
	output wire dbg_cmp_1a_lo_a,
	output wire dbg_cmp_1b_lo_a,
	output wire dbg_cmp_2a_lo_a,
	output wire dbg_cmp_2b_lo_a,
	output wire dbg_cmp_3a_lo_a,
	output wire dbg_cmp_3b_lo_a,
	output wire dbg_cmp_4a_lo_a,
	output wire dbg_cmp_4b_lo_a,
	
	output dbg_trig_src_1a_group_a,
	output dbg_trig_src_1b_group_a,
	output dbg_trig_src_2a_group_a,
	output dbg_trig_src_2b_group_a,
	output dbg_trig_src_3a_group_a,
	output dbg_trig_src_3b_group_a,
	output dbg_trig_src_4a_group_a,
	output dbg_trig_src_4b_group_a,
	
	output dbg_trig_src_1a_group_b,
	output dbg_trig_src_1b_group_b,
	output dbg_trig_src_2a_group_b,
	output dbg_trig_src_2b_group_b,
	output dbg_trig_src_3a_group_b,
	output dbg_trig_src_3b_group_b,
	output dbg_trig_src_4a_group_b,
	output dbg_trig_src_4b_group_b,
	
	output dbg_trig_edge_out,
	
    output dbg_edge_trig_logic,
    output [2:0] dbg_trig_sum_word,
    
    output dbg_edge_trig_ch_code_valid,
    output dbg_edge_decode_rst,
    
    output [1:0] dbg_trig_src_4a4b_dly2,
    output [2:0] dbg_trig_ch_code_state,
        
    output dbg_resv,
	
    output wire trig_out,
    output reg [2:0] trig_sub_word
);

// Types of trigger supported
parameter TRIG_TYPE_NEVER   = 0;
parameter TRIG_TYPE_ALWAYS  = 1;
parameter TRIG_TYPE_EDGE    = 2;

// Types of trigger edge
parameter TRIG_EDGE_NONE    = 2'b00;
parameter TRIG_EDGE_RISING  = 2'b01;
parameter TRIG_EDGE_FALLING = 2'b10;
parameter TRIG_EDGE_EITHER  = 2'b11;

// ADC channel indexes
parameter ADC_1A = 0;
parameter ADC_1B = 1;
parameter ADC_2A = 2;
parameter ADC_2B = 3;
parameter ADC_3A = 4;
parameter ADC_3B = 5;
parameter ADC_4A = 6;
parameter ADC_4B = 7;

// Trigger channel indexes
parameter TRCHAN_1A = 0;
parameter TRCHAN_2A = 1;
parameter TRCHAN_3A = 2;
parameter TRCHAN_4A = 3;
parameter TRCHAN_1B = 4;
parameter TRCHAN_2B = 5;
parameter TRCHAN_3B = 6;
parameter TRCHAN_4B = 7;

// Trigger modes: normal and auto
parameter TRIG_MODE_NORMAL = 1'b10;
parameter TRIG_MODE_AUTO   = 1'b01;

// Trigger state machine
parameter TRIG_STATE_WAIT_FOR_ARM = 1;
parameter TRIG_STATE_ARMED_WAITING = 2;
parameter TRIG_STATE_TRIGD_HOLDOFF_LOAD = 3;
parameter TRIG_STATE_TRIGD_HOLDOFF = 4;
parameter TRIG_STATE_TRIGD_HOLDOFF_ACK = 5;
parameter TRIG_STATE_TRIGD_AUTO_INITIAL = 6;
parameter TRIG_STATE_TRIGD_AUTO_REPEAT = 7;
parameter TRIG_STATE_TRIGD_FORCE_AUTO = 8;

wire [11:0] trig_level_hi[7:0];
wire [11:0] trig_level_lo[7:0];

wire [7:0] trig_ena;
wire [7:0] trig_pol;

assign trig_level_hi[TRCHAN_1A] = trig_level_0[31:20];
assign trig_level_lo[TRCHAN_1A] = trig_level_0[15: 4];
assign trig_level_hi[TRCHAN_2A] = trig_level_1[31:20];
assign trig_level_lo[TRCHAN_2A] = trig_level_1[15: 4];
assign trig_level_hi[TRCHAN_3A] = trig_level_2[31:20];
assign trig_level_lo[TRCHAN_3A] = trig_level_2[15: 4];
assign trig_level_hi[TRCHAN_4A] = trig_level_3[31:20];
assign trig_level_lo[TRCHAN_4A] = trig_level_3[15: 4];
assign trig_level_hi[TRCHAN_1B] = trig_level_4[31:20];
assign trig_level_lo[TRCHAN_1B] = trig_level_4[15: 4];
assign trig_level_hi[TRCHAN_2B] = trig_level_5[31:20];
assign trig_level_lo[TRCHAN_2B] = trig_level_5[15: 4];
assign trig_level_hi[TRCHAN_3B] = trig_level_6[31:20];
assign trig_level_lo[TRCHAN_3B] = trig_level_6[15: 4];
assign trig_level_hi[TRCHAN_4B] = trig_level_7[31:20];
assign trig_level_lo[TRCHAN_4B] = trig_level_7[15: 4]; 

assign trig_ena[TRCHAN_1A] = trig_level_0[0];
assign trig_ena[TRCHAN_2A] = trig_level_1[0];
assign trig_ena[TRCHAN_3A] = trig_level_2[0];
assign trig_ena[TRCHAN_4A] = trig_level_3[0];
assign trig_ena[TRCHAN_1B] = trig_level_4[0];
assign trig_ena[TRCHAN_2B] = trig_level_5[0];
assign trig_ena[TRCHAN_3B] = trig_level_6[0];
assign trig_ena[TRCHAN_4B] = trig_level_7[0];

assign trig_pol[TRCHAN_1A] = trig_level_0[1];
assign trig_pol[TRCHAN_2A] = trig_level_1[1];
assign trig_pol[TRCHAN_3A] = trig_level_2[1];
assign trig_pol[TRCHAN_4A] = trig_level_3[1];
assign trig_pol[TRCHAN_1B] = trig_level_4[1];
assign trig_pol[TRCHAN_2B] = trig_level_5[1];
assign trig_pol[TRCHAN_3B] = trig_level_6[1];
assign trig_pol[TRCHAN_4B] = trig_level_7[1];

wire trig_global_enable = trig_config_a[0];
wire comp_rst = trig_config_a[2];
wire trig_rst = trig_config_a[3];
wire trig_force = trig_config_a[4];
wire trig_clear_trigd = trig_config_a[5];
wire trig_general_mask = trig_config_a[6];
wire trig_arm = trig_config_a[7];
wire trig_holdoff_enable = trig_config_a[16];
wire [1:0] trig_ext_sel = trig_config_a[21:20];
wire [1:0] trig_norm_auto = trig_config_a[23:22];
wire [1:0] trig_edge_a = trig_config_a[25:24];
wire [1:0] trig_edge_b = trig_config_a[27:26];
wire [3:0] trig_mode = trig_config_a[31:28]; 

reg trig_level_working[7:0];
wire [7:0] adc_data[7:0];
wire [7:0] comp_adc_data[7:0];

assign adc_data[0] = adc_bus[ 7: 0];
assign adc_data[1] = adc_bus[15: 8];
assign adc_data[2] = adc_bus[23:16];
assign adc_data[3] = adc_bus[31:24];
assign adc_data[4] = adc_bus[39:32];
assign adc_data[5] = adc_bus[47:40];
assign adc_data[6] = adc_bus[55:48];
assign adc_data[7] = adc_bus[63:56];

assign comp_adc_data[0] = adc_data[0];
assign comp_adc_data[1] = adc_data[1];
assign comp_adc_data[2] = adc_data[2];
assign comp_adc_data[3] = adc_data[3];
assign comp_adc_data[4] = adc_data[4];
assign comp_adc_data[5] = adc_data[5];
assign comp_adc_data[6] = adc_data[6];
assign comp_adc_data[7] = adc_data[7];

reg trig_internal_arm = 0;

// 
// Trigger comparator core
//
wire [3:0] trig_sig_a;
wire [3:0] trig_sig_b;

wire [1:0] trig_src_1a1b_group_a;
wire [1:0] trig_src_2a2b_group_a;
wire [1:0] trig_src_3a3b_group_a;
wire [1:0] trig_src_4a4b_group_a;

wire [1:0] trig_src_1a1b_group_b;
wire [1:0] trig_src_2a2b_group_b;
wire [1:0] trig_src_3a3b_group_b;
wire [1:0] trig_src_4a4b_group_b;

assign dbg_trig_src_1a_group_a = trig_src_1a1b_group_a[0];
assign dbg_trig_src_1b_group_a = trig_src_1a1b_group_a[1];
assign dbg_trig_src_2a_group_a = trig_src_2a2b_group_a[0];
assign dbg_trig_src_2b_group_a = trig_src_2a2b_group_a[1];
assign dbg_trig_src_3a_group_a = trig_src_3a3b_group_a[0];
assign dbg_trig_src_3b_group_a = trig_src_3a3b_group_a[1];
assign dbg_trig_src_4a_group_a = trig_src_4a4b_group_a[0];
assign dbg_trig_src_4b_group_a = trig_src_4a4b_group_a[1];

assign dbg_trig_src_1a_group_b = trig_src_1a1b_group_b[0];
assign dbg_trig_src_1b_group_b = trig_src_1a1b_group_b[1];
assign dbg_trig_src_2a_group_b = trig_src_2a2b_group_b[0];
assign dbg_trig_src_2b_group_b = trig_src_2a2b_group_b[1];
assign dbg_trig_src_3a_group_b = trig_src_3a3b_group_b[0];
assign dbg_trig_src_3b_group_b = trig_src_3a3b_group_b[1];
assign dbg_trig_src_4a_group_b = trig_src_4a4b_group_b[0];
assign dbg_trig_src_4b_group_b = trig_src_4a4b_group_b[1];

assign dbg_trig_sig_a = trig_sig_a;
assign dbg_trig_sig_b = trig_sig_b;

adc_trigger_core adc_trigger_core_0123a (
    // CH1A,CH1B,CH2A,CH2B  for comparator 'A'
    .adc_data_clk(adc_data_clk),
    .adc_1a(comp_adc_data[ADC_1A]),
    .adc_1b(comp_adc_data[ADC_1B]),
    .adc_2a(comp_adc_data[ADC_2A]),
    .adc_2b(comp_adc_data[ADC_2B]),
    .lvl_hi_1(trig_level_hi[TRCHAN_1A]),
    .lvl_lo_1(trig_level_lo[TRCHAN_1A]),
    .lvl_hi_2(trig_level_hi[TRCHAN_2A]),
    .lvl_lo_2(trig_level_lo[TRCHAN_2A]),
    .comp_pol_1(trig_pol[TRCHAN_1A]),
    .comp_pol_2(trig_pol[TRCHAN_2A]),
    .comp_ena_1(trig_ena[TRCHAN_1A] && trig_global_enable),
    .comp_ena_2(trig_ena[TRCHAN_2A] && trig_global_enable),
    .comp_sig_1(trig_sig_a[0]),
    .comp_sig_2(trig_sig_a[1]),
    .comp_ch_1a(trig_src_1a1b_group_a[0]),
    .comp_ch_1b(trig_src_1a1b_group_a[1]),
    .comp_ch_2a(trig_src_2a2b_group_a[0]),
    .comp_ch_2b(trig_src_2a2b_group_a[1]),
    .comp_rst(comp_rst),
    
    // Debug signals
    .dbg_comp_state_1(dbg_comp_state_1_0123a),
    .dbg_comp_state_2(dbg_comp_state_2_0123a),
    .dbg_ev_counter_1(dbg_ev_counter_1_0123a),
    .dbg_ev_counter_2(dbg_ev_counter_2_0123a),
    
    .dbg_adc_1a_hi_x(dbg_cmp_1a_hi_a),
    .dbg_adc_1a_lo_x(dbg_cmp_1a_lo_a),
    .dbg_adc_1b_hi_x(dbg_cmp_1b_hi_a),
    .dbg_adc_1b_lo_x(dbg_cmp_1b_lo_a),
    .dbg_adc_2a_hi_x(dbg_cmp_2a_hi_a),
    .dbg_adc_2a_lo_x(dbg_cmp_2a_lo_a),
    .dbg_adc_2b_hi_x(dbg_cmp_2b_hi_a),
    .dbg_adc_2b_lo_x(dbg_cmp_2b_lo_a)
);

adc_trigger_core adc_trigger_core_4567a (
    // CH3A,CH3B,CH4A,CH4B for comparator 'A'
    .adc_data_clk(adc_data_clk),
    .adc_1a(comp_adc_data[ADC_3A]),
    .adc_1b(comp_adc_data[ADC_3B]),
    .adc_2a(comp_adc_data[ADC_4A]),
    .adc_2b(comp_adc_data[ADC_4B]),
    .lvl_hi_1(trig_level_hi[TRCHAN_3A]),
    .lvl_lo_1(trig_level_lo[TRCHAN_3A]),
    .lvl_hi_2(trig_level_hi[TRCHAN_4A]),
    .lvl_lo_2(trig_level_lo[TRCHAN_4A]),
    .comp_pol_1(trig_pol[TRCHAN_3A]),
    .comp_pol_2(trig_pol[TRCHAN_4A]),
    .comp_ena_1(trig_ena[TRCHAN_3A] && trig_global_enable),
    .comp_ena_2(trig_ena[TRCHAN_4A] && trig_global_enable),
    .comp_sig_1(trig_sig_a[2]),
    .comp_sig_2(trig_sig_a[3]),
    .comp_ch_1a(trig_src_3a3b_group_a[0]),
    .comp_ch_1b(trig_src_3a3b_group_a[1]),
    .comp_ch_2a(trig_src_4a4b_group_a[0]),
    .comp_ch_2b(trig_src_4a4b_group_a[1]),
    .comp_rst(comp_rst),
    
    // Debug signals
    .dbg_comp_state_1(dbg_comp_state_1_4567a),
    .dbg_comp_state_2(dbg_comp_state_2_4567a),
    .dbg_ev_counter_1(dbg_ev_counter_1_4567a),
    .dbg_ev_counter_2(dbg_ev_counter_2_4567a),
    
    .dbg_adc_1a_hi_x(dbg_cmp_3a_hi_a),
    .dbg_adc_1a_lo_x(dbg_cmp_3a_lo_a),
    .dbg_adc_1b_hi_x(dbg_cmp_3b_hi_a),
    .dbg_adc_1b_lo_x(dbg_cmp_3b_lo_a),
    .dbg_adc_2a_hi_x(dbg_cmp_4a_hi_a),
    .dbg_adc_2a_lo_x(dbg_cmp_4a_lo_a),
    .dbg_adc_2b_hi_x(dbg_cmp_4b_hi_a),
    .dbg_adc_2b_lo_x(dbg_cmp_4b_lo_a)
);

adc_trigger_core adc_trigger_core_0123b (
    // CH1A,CH1B,CH2A,CH2B  for comparator 'B'
    .adc_data_clk(adc_data_clk),
    .adc_1a(comp_adc_data[ADC_1A]),
    .adc_1b(comp_adc_data[ADC_1B]),
    .adc_2a(comp_adc_data[ADC_2A]),
    .adc_2b(comp_adc_data[ADC_2B]),
    .lvl_hi_1(trig_level_hi[TRCHAN_1B]),
    .lvl_lo_1(trig_level_lo[TRCHAN_1B]),
    .lvl_hi_2(trig_level_hi[TRCHAN_2B]),
    .lvl_lo_2(trig_level_lo[TRCHAN_2B]),
    .comp_pol_1(trig_pol[TRCHAN_1B]),
    .comp_pol_2(trig_pol[TRCHAN_2B]),
    .comp_ena_1(trig_ena[TRCHAN_1B] && trig_global_enable),
    .comp_ena_2(trig_ena[TRCHAN_2B] && trig_global_enable),
    .comp_sig_1(trig_sig_b[0]),
    .comp_sig_2(trig_sig_b[1]),
    .comp_ch_1a(trig_src_1a1b_group_b[0]),
    .comp_ch_1b(trig_src_1a1b_group_b[1]),
    .comp_ch_2a(trig_src_2a2b_group_b[0]),
    .comp_ch_2b(trig_src_2a2b_group_b[1]),
    .comp_rst(comp_rst),
    .dbg_comp_state_1(dbg_comp_state_1_0123b),
    .dbg_comp_state_2(dbg_comp_state_2_0123b),
    .dbg_ev_counter_1(dbg_ev_counter_1_0123b),
    .dbg_ev_counter_2(dbg_ev_counter_2_0123b),
    
    .dbg_adc_1a_hi_x(dbg_cmp_1a_hi_b),
    .dbg_adc_1a_lo_x(dbg_cmp_1a_lo_b),
    .dbg_adc_1b_hi_x(dbg_cmp_1b_hi_b),
    .dbg_adc_1b_lo_x(dbg_cmp_1b_lo_b),
    .dbg_adc_2a_hi_x(dbg_cmp_2a_hi_b),
    .dbg_adc_2a_lo_x(dbg_cmp_2a_lo_b),
    .dbg_adc_2b_hi_x(dbg_cmp_2b_hi_b),
    .dbg_adc_2b_lo_x(dbg_cmp_2b_lo_b)
);

adc_trigger_core adc_trigger_core_4567b (
    // CH3A,CH3B,CH4A,CH4B for comparator 'B'
    .adc_data_clk(adc_data_clk),
    .adc_1a(comp_adc_data[ADC_3A]),
    .adc_1b(comp_adc_data[ADC_3B]),
    .adc_2a(comp_adc_data[ADC_4A]),
    .adc_2b(comp_adc_data[ADC_4B]),
    .lvl_hi_1(trig_level_hi[TRCHAN_3B]),
    .lvl_lo_1(trig_level_lo[TRCHAN_3B]),
    .lvl_hi_2(trig_level_hi[TRCHAN_4B]),
    .lvl_lo_2(trig_level_lo[TRCHAN_4B]),
    .comp_pol_1(trig_pol[TRCHAN_3B]),
    .comp_pol_2(trig_pol[TRCHAN_4B]),
    .comp_ena_1(trig_ena[TRCHAN_3B] && trig_global_enable),
    .comp_ena_2(trig_ena[TRCHAN_4B] && trig_global_enable),
    .comp_sig_1(trig_sig_b[2]),
    .comp_sig_2(trig_sig_b[3]),
    .comp_ch_1a(trig_src_3a3b_group_b[0]),
    .comp_ch_1b(trig_src_3a3b_group_b[1]),
    .comp_ch_2a(trig_src_4a4b_group_b[0]),
    .comp_ch_2b(trig_src_4a4b_group_b[1]),
    .comp_rst(comp_rst),
    .dbg_comp_state_1(dbg_comp_state_1_4567b),
    .dbg_comp_state_2(dbg_comp_state_2_4567b),
    .dbg_ev_counter_1(dbg_ev_counter_1_4567b),
    .dbg_ev_counter_2(dbg_ev_counter_2_4567b),
    
    .dbg_adc_1a_hi_x(dbg_cmp_3a_hi_b),
    .dbg_adc_1a_lo_x(dbg_cmp_3a_lo_b),
    .dbg_adc_1b_hi_x(dbg_cmp_3b_hi_b),
    .dbg_adc_1b_lo_x(dbg_cmp_3b_lo_b),
    .dbg_adc_2a_hi_x(dbg_cmp_4a_hi_b),
    .dbg_adc_2a_lo_x(dbg_cmp_4a_lo_b),
    .dbg_adc_2b_hi_x(dbg_cmp_4b_hi_b),
    .dbg_adc_2b_lo_x(dbg_cmp_4b_lo_b)
);

//
// Edge trigger core
//
wire trig_edge_out;
wire [2:0] trig_edge_out_word;

adc_trigger_edge (
    .mod_en(trig_mode == TRIG_TYPE_EDGE),
    .mod_global_en(trig_global_enable && trig_internal_arm),
    .trig_rst(trig_rst),
    .mod_clk(adc_data_clk),
    .trig_ext_sel(trig_ext_sel),
    .trig_input_external(trig_input_external),
    .trig_input_ac(trig_input_ac),
    .trig_edge_mode(trig_edge_a),
    .trig_sig_a(trig_sig_a),
    .trig_src_1a1b_group_a(trig_src_1a1b_group_a),
    .trig_src_2a2b_group_a(trig_src_2a2b_group_a),
    .trig_src_3a3b_group_a(trig_src_3a3b_group_a),
    .trig_src_4a4b_group_a(trig_src_4a4b_group_a),
    .trig_gen(trig_edge_out),
    .trig_ch_code(trig_edge_out_word),
    
    .dbg_trig_logic(dbg_edge_trig_logic),
    .dbg_trig_ch_code_valid(dbg_edge_trig_ch_code_valid),
    .dbg_decode_rst(dbg_edge_decode_rst),
    .dbg_trig_src_4a4b_dly2(dbg_trig_src_4a4b_dly2),
    .dbg_trig_ch_code_state(dbg_trig_ch_code_state)
);

assign dbg_trig_edge_out = trig_edge_out;

// 
// Force trigger logic.  The relevant bit going high forces a trigger output to occur.
//
reg trig_force_last;
reg trig_force_out = 0;

always @(posedge adc_data_clk) begin

    if (trig_internal_arm) begin
        if (trig_force && !trig_force_last) begin
            trig_force_out <= 1;
        end else begin
            trig_force_out <= 0;
        end
    end else begin
        trig_force_out <= 0;
    end
    
    trig_force_last <= trig_force;

end

// 
// Always trigger block.  As soon as the acquisition engine reports it is armed,
// a trigger is generated.  This will not always be used by the acquisition engine,
// for instance if the engine has triggers masked.
// 
/*
reg trig_always_out = 0;
reg trig_acq_armed_last = 0;

always @(posedge adc_data_clk) begin

    if (trig_internal_arm && (!trig_general_mask)) begin
        if (trig_mode == TRIG_TYPE_ALWAYS) begin
            if (acq_armed && !trig_acq_armed_last) begin
                trig_always_out <= 1;
            end else begin
                trig_always_out <= 0;
            end
        
            trig_acq_armed_last <= acq_armed;
        end else begin
            trig_acq_armed_last <= 0;
            trig_always_out <= 0;
        end
    end else begin
        trig_always_out <= 0;
    end

end
*/

// 
// Holdoff core
//
reg trig_holdoff_load = 0;
wire trig_holdoff_inhibit;

adc_trigger_holdoff (
    .mod_clk(adc_data_clk),
    .holdoff_timer_load_value(trig_holdoff),
    .holdoff_load(trig_holdoff_load),
    .trig_rst(trig_rst),
    .holdoff_trigger_inhibit(trig_holdoff_inhibit),
    .holdoff_debug_time(trig_holdoff_debug)
);

//
// Auto trigger core
//
reg trig_auto_recv = 0;
reg trig_auto_init = 0;
reg trig_auto_arm = 0;
wire trig_auto_out;
wire [2:0] dbg_auto_state;

adc_trigger_autotrig (
    .mod_clk(adc_data_clk),
    .auto_initial_load(trig_auto_timers[15:4]), 
    .auto_repeat_load(trig_auto_timers[31:20]),
    .auto_trig_recv(trig_auto_recv),
    .auto_init(trig_auto_init),
    .auto_arm(trig_auto_arm),
    .auto_out(trig_auto_out),
    .auto_init_rep(trig_auto_init_rep),
    .dbg_auto_state(dbg_auto_state)
);

//
// Register inputs from the ADC AXI Stream state machine (running on the AXI bus clock)
// against our trigger clock (running on the ADC data bus clock).  This avoids metastability
// issues caused by sampling the buses at different times.
//
reg acq_done_regd;
reg acq_done_post_regd;
reg acq_have_trig_regd;
reg acq_armed_waiting_trig_regd;
    
always @(posedge adc_data_clk) begin

    acq_done_regd <= acq_done;
    acq_done_post_regd <= acq_done_post;
    acq_have_trig_regd <= acq_have_trig;
    acq_armed_waiting_trig_regd <= acq_armed_waiting_trig;

end

//
// Trigger state machine.  
//
reg trig_status_trigd = 0;
wire trig_status_armed_signals = trig_arm && trig_global_enable;
reg trig_status_armed_state = 0;
reg trig_status_holdoff = 0;
reg trig_waiting_acq_done_trig = 0;

// Auto init and rep state are determined by trig_auto_out & state of trig_auto_init_rep (low = init, high = rep).
wire trig_has_auto_mode = (trig_norm_auto == TRIG_MODE_AUTO);

wire trig_status_auto_init   = (trig_auto_out && trig_has_auto_mode) ? (~trig_auto_init_rep) : 0;
wire trig_status_auto_repeat = (trig_auto_out && trig_has_auto_mode) ? ( trig_auto_init_rep) : 0;

// Sum of all trigger sources, with only one trigger enabled at any one time
wire trig_sum = (trig_edge_out) && (!trig_general_mask);

// OR of all trigger index words.  Blocks that are disabled should output all zeroes, so 
// this function should work.
wire [2:0] trig_sum_word = trig_edge_out_word;
assign dbg_trig_sum_word = trig_sum_word;

// Output register for trigger signal (rising edge indicates trigger event)
reg trig_out_reg = 0;

reg [3:0] trig_state = TRIG_STATE_WAIT_FOR_ARM;

always @(posedge adc_data_clk) begin

    if (trig_clear_trigd) begin
        trig_status_trigd <= 0;
    end
    
    if (trig_rst) begin
        trig_state <= TRIG_STATE_WAIT_FOR_ARM;
        trig_auto_init <= 1;
        trig_sub_word <= 0;
    end

    case (trig_state) 
        TRIG_STATE_WAIT_FOR_ARM : begin
            //acq_holdoff <= 1;  // Should we start acquiring while waiting for a trigger to be ARMed?
            trig_holdoff_load <= 0;
            trig_out_reg <= 0;
            trig_auto_arm <= 0;
            trig_auto_init <= 0;
            
            if (trig_arm && trig_global_enable) begin
                trig_state <= TRIG_STATE_ARMED_WAITING;
                trig_internal_arm <= 1;
                trig_status_armed_state <= 1;
                acq_holdoff <= 0;
            end else begin
                trig_internal_arm <= 0;
                trig_status_armed_state <= 0; // but NOT cleared after triggering; only cleared if ARMed state disabled
            end
        end
        
        TRIG_STATE_ARMED_WAITING : begin
            trig_auto_init <= 0;
            
            if (trig_has_auto_mode) begin
                trig_auto_arm <= 1;
            end else begin
                trig_auto_arm <= 0;
            end
        
            // Wait for acquisition engine to be armed and waiting for a trigger, before generating any trigger
            // To save power we might consider inhibiting comparator blocks until such a time
            if (acq_armed_waiting_trig_regd) begin
                if (trig_mode == TRIG_TYPE_ALWAYS) begin
                    // Always trigger goes through HOLDOFF block to allow variable frequency triggering
                    trig_state <= TRIG_STATE_TRIGD_HOLDOFF_LOAD;
                    trig_out_reg <= 1;
                    trig_status_trigd <= 1;
                    trig_auto_recv <= 1;
                    trig_sub_word <= 0;
                end else if (trig_sum) begin
                    // Any other trigger also goes through HOLDOFF block
                    trig_state <= TRIG_STATE_TRIGD_HOLDOFF_LOAD;
                    trig_out_reg <= 1;
                    trig_status_trigd <= 1;
                    trig_auto_recv <= 1;
                    trig_sub_word <= trig_sum_word;
                end else if (trig_auto_out) begin
                    // Auto trigger due to no trigger occurring within the trigger window
                    trig_state <= TRIG_STATE_TRIGD_FORCE_AUTO;
                    trig_out_reg <= 1;
                    trig_status_trigd <= 0;
                    trig_sub_word <= 0;
                end else if (trig_force_out) begin
                    // Force trigger does not go through HOLDOFF block but does force a reload of HOLDOFF value
                    trig_state <= TRIG_STATE_TRIGD_FORCE_AUTO;
                    trig_out_reg <= 1;
                    trig_status_trigd <= 1;
                    trig_auto_recv <= 1;
                    trig_sub_word <= 0;
                end
            end
        end
        
        // Here we might want to wait before generating another trigger until the 
        // acquisition engine has captured the post-trigger event (this would be 
        // controlled by a signal from the PS)
        TRIG_STATE_TRIGD_HOLDOFF_LOAD : begin
            // Clear trig_out_reg so that we only generate a 1-pulse wide trigger
            trig_out_reg <= 0;
            
            // If holdoff is disabled then we re-arm immediately (a few clock cycles
            // at most.)  If not then we load the holdoff engine.
            if (trig_holdoff_enable) begin
                // Wait for acquisition engine to finish acquisition before starting
                // holdoff period
                trig_internal_arm <= 0;
                trig_waiting_acq_done_trig <= 1;
                
                if (acq_done_post_regd) begin
                    // We got the trigger,  so enter a hold-off period
                    trig_holdoff_load <= 1;
                    trig_auto_init <= 1; // Reset auto-trigger
                    trig_auto_recv <= 0;
                    trig_waiting_acq_done_trig <= 0;
                    trig_state <= TRIG_STATE_TRIGD_HOLDOFF_ACK;
                end else if (acq_done_regd && !acq_have_trig_regd) begin
                    // We missed the trigger for some reason, so we should immediately re-arm
                    trig_internal_arm <= 0;
                    trig_auto_init <= 1; // Reset auto-trigger
                    trig_auto_recv <= 0;
                    trig_waiting_acq_done_trig <= 0;
                    trig_state <= TRIG_STATE_WAIT_FOR_ARM;
                end
            end else begin
                trig_internal_arm <= 0;
                trig_auto_init <= 1; // Reset auto-trigger
                trig_auto_recv <= 0;
                trig_waiting_acq_done_trig <= 0;
                trig_state <= TRIG_STATE_WAIT_FOR_ARM;
            end
        end
        
        TRIG_STATE_TRIGD_HOLDOFF_ACK : begin
            trig_holdoff_load <= 0;
            trig_state <= TRIG_STATE_TRIGD_HOLDOFF;
        end
        
        TRIG_STATE_TRIGD_HOLDOFF : begin
            if (!trig_holdoff_inhibit) begin
                trig_state <= TRIG_STATE_WAIT_FOR_ARM;
                trig_status_holdoff <= 0;
                acq_holdoff <= 0;
            end else begin
                trig_status_holdoff <= 1; 
                acq_holdoff <= 1;  // Signal to acquisition engine to hold off on start of next acquisition (saves power)
            end
        end
        
        TRIG_STATE_TRIGD_FORCE_AUTO : begin
            trig_state <= TRIG_STATE_WAIT_FOR_ARM;
            trig_internal_arm <= 0;
            trig_holdoff_load <= 1;
            trig_out_reg <= 0; // Clear trig_out_reg so that we only generate a 1-pulse wide trigger
            trig_auto_arm <= 0;
            trig_auto_recv <= 0;
        end
    endcase

end

assign trig_state_a[0] = trig_status_trigd;
assign trig_state_a[1] = trig_status_auto_init;
assign trig_state_a[2] = trig_status_auto_repeat;
assign trig_state_a[3] = trig_status_armed_signals;
assign trig_state_a[4] = acq_armed_waiting_trig_regd;
assign trig_state_a[5] = trig_status_holdoff;
assign trig_state_a[6] = trig_waiting_acq_done_trig;
assign trig_state_a[7] = trig_internal_arm;
assign trig_state_a[8] = acq_done_post_regd;
assign trig_state_a[16] = acq_have_trig_regd;
assign trig_state_a[17] = trig_holdoff_inhibit;

assign trig_state_a[11: 9] = dbg_auto_state;
assign trig_state_a[15:12] = trig_state;

assign trig_out = trig_out_reg;

endmodule

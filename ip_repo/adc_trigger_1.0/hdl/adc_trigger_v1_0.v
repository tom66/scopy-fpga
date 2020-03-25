
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
    
    input trig_input_external,
    input trig_input_ac,
    
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

    output wire trigger_out,
    output wire [2:0] trigger_sub_word
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
wire trig_load = trig_config_a[1];
wire [1:0] trig_ext_sel = trig_config_a[21:20];
wire [1:0] trig_ctrl = trig_config_a[23:22];
wire [1:0] trig_edge_a = trig_config_a[25:24];
wire [1:0] trig_edge_b = trig_config_a[27:26];
wire [3:0] trig_mode = trig_config_a[31:28]; 
wire comp_rst = trig_config_a[2];
wire trig_rst = trig_config_a[3];
wire trig_force = trig_config_a[4];

reg trig_load_last = 0;

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

reg [7:0] trigger_prio = 8'b00000000;
reg trigger_state = 0; // 0 = rising, 1 = falling

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
    .comp_ena_1(trig_ena[TRCHAN_1A]),
    .comp_ena_2(trig_ena[TRCHAN_2A]),
    .comp_sig_1(trig_sig_a[0]),
    .comp_sig_2(trig_sig_a[1]),
    .comp_ch_1a(trig_src_1a1b_group_a[0]),
    .comp_ch_1b(trig_src_1a1b_group_a[1]),
    .comp_ch_2a(trig_src_2a2b_group_a[0]),
    .comp_ch_2b(trig_src_2a2b_group_a[1]),
    .comp_rst(comp_rst),
    .g_comp_ena(trig_global_enable),
    .dbg_comp_state_1(dbg_comp_state_1_0123a),
    .dbg_comp_state_2(dbg_comp_state_2_0123a),
    .dbg_ev_counter_1(dbg_ev_counter_1_0123a),
    .dbg_ev_counter_2(dbg_ev_counter_2_0123a)
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
    .comp_ena_1(trig_ena[TRCHAN_3A]),
    .comp_ena_2(trig_ena[TRCHAN_4A]),
    .comp_sig_1(trig_sig_a[2]),
    .comp_sig_2(trig_sig_a[3]),
    .comp_ch_1a(trig_src_3a3b_group_a[0]),
    .comp_ch_1b(trig_src_3a3b_group_a[1]),
    .comp_ch_2a(trig_src_4a4b_group_a[0]),
    .comp_ch_2b(trig_src_4a4b_group_a[1]),
    .comp_rst(comp_rst),
    .g_comp_ena(trig_global_enable),
    .dbg_comp_state_1(dbg_comp_state_1_4567a),
    .dbg_comp_state_2(dbg_comp_state_2_4567a),
    .dbg_ev_counter_1(dbg_ev_counter_1_4567a),
    .dbg_ev_counter_2(dbg_ev_counter_2_4567a)
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
    .comp_ena_1(trig_ena[TRCHAN_1B]),
    .comp_ena_2(trig_ena[TRCHAN_2B]),
    .comp_sig_1(trig_sig_b[0]),
    .comp_sig_2(trig_sig_b[1]),
    .comp_ch_1a(trig_src_1a1b_group_b[0]),
    .comp_ch_1b(trig_src_1a1b_group_b[1]),
    .comp_ch_2a(trig_src_2a2b_group_b[0]),
    .comp_ch_2b(trig_src_2a2b_group_b[1]),
    .comp_rst(comp_rst),
    .g_comp_ena(trig_global_enable),
    .dbg_comp_state_1(dbg_comp_state_1_0123b),
    .dbg_comp_state_2(dbg_comp_state_2_0123b),
    .dbg_ev_counter_1(dbg_ev_counter_1_0123b),
    .dbg_ev_counter_2(dbg_ev_counter_2_0123b)
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
    .comp_ena_1(trig_ena[TRCHAN_3B]),
    .comp_ena_2(trig_ena[TRCHAN_4B]),
    .comp_sig_1(trig_sig_b[2]),
    .comp_sig_2(trig_sig_b[3]),
    .comp_ch_1a(trig_src_3a3b_group_b[0]),
    .comp_ch_1b(trig_src_3a3b_group_b[1]),
    .comp_ch_2a(trig_src_4a4b_group_b[0]),
    .comp_ch_2b(trig_src_4a4b_group_b[1]),
    .comp_rst(comp_rst),
    .g_comp_ena(trig_global_enable),
    .dbg_comp_state_1(dbg_comp_state_1_4567b),
    .dbg_comp_state_2(dbg_comp_state_2_4567b),
    .dbg_ev_counter_1(dbg_ev_counter_1_4567b),
    .dbg_ev_counter_2(dbg_ev_counter_2_4567b)
);

//
// Edge trigger core
//
wire trig_edge_out;
wire [2:0] trig_edge_out_word;

adc_trigger_edge (
    .mod_en(trig_mode == TRIG_TYPE_EDGE),
    .mod_global_en(trig_global_enable),
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
    .trig_ch_code(trig_edge_out_word)
);

// 
// Force trigger logic.  The relevant bit going high forces a trigger output to occur.
//
reg trig_force_last;
reg trig_force_out = 0;

always @(posedge adc_data_clk) begin

    if (trig_force && !trig_force_last) begin
        trig_force_out <= 1;
    end else begin
        trig_force_out <= 0;
    end
    
    trig_force_last <= trig_force;

end

// 
// Overall summing logic.  Force trigger sets trigger output word to all zeroes,
// as the exact time of the trigger is unimportant.
// 
assign trigger_out = trig_edge_out | trig_force_out;
assign trigger_sub_word = (trig_force_out) ? 3'b000 : trig_edge_out_word;

endmodule

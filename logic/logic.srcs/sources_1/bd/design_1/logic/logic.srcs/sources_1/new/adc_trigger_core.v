`timescale 1ns / 1ps

module adc_trigger_core (
    // Four ADC words.  Normally these come from a twin pair of ADC LVDS channels 
	// (ex: LVDS1A-LVDS1B, LVDS2A-LVDS2B) which is guaranteed to be routed to data 
	// from one channel.  But it might be a time-multiplexed slice for that channel.  
	// Also, it could be routed from a filter engine. 
	// 
	// A pair of ADC inputs is used to implement this block using a DSP48E1 in future.
    input [7:0] adc_1a,
    input [7:0] adc_1b,
    input [7:0] adc_2a,
    input [7:0] adc_2b,
    
    // Core ADC clock on which the above words are sampled (nom. 125MHz) and on which all logic runs.
    input adc_data_clk,
    
    // High level and low level for comparison.  We support 12-bit input for comparison, but we 
    // truncate MSBs.
    input [11:0] lvl_hi_1,
    input [11:0] lvl_lo_1,
    input [11:0] lvl_hi_2,
    input [11:0] lvl_lo_2,
    
    // Reset input, active high.  Used to restart a comparator at the start level.
    input comp_rst,
    
    // Polarity select.  Switches between start high and start low behaviour.
    input comp_pol_1,
	input comp_pol_2,
    
    // Enable input, active high.  Inhibiting this disables the whole block.
    input comp_ena_1,
    input comp_ena_2,
    input g_comp_ena,
    
    // Output signals:  Comparator signal (pulses guaranteed at least 3 ADCCLK wide), 
	// and channel indicators  for priority encoder.
    output comp_sig_1,
    output comp_sig_2,
    output comp_ch_1a,
    output comp_ch_1b,
    output comp_ch_2a,
    output comp_ch_2b,
	
	// Debug signals
	output [1:0] dbg_comp_state_1,
	output [2:0] dbg_ev_counter_1,
	output [1:0] dbg_comp_state_2,
	output [2:0] dbg_ev_counter_2
);

// Currently all trigger logic operates on 8-bit data so truncate comparator levels to 8-bit
wire [7:0] lvl_hi_local_1 = lvl_hi_1[7:0];
wire [7:0] lvl_lo_local_1 = lvl_lo_1[7:0];
wire [7:0] lvl_hi_local_2 = lvl_hi_2[7:0];
wire [7:0] lvl_lo_local_2 = lvl_lo_2[7:0];

// Comparison units for synchronous logic block
wire adc_1a_hi = adc_1a > lvl_hi_local_1;
wire adc_1a_lo = adc_1a < lvl_lo_local_1;
wire adc_1b_hi = adc_1b > lvl_hi_local_1;
wire adc_1b_lo = adc_1b < lvl_lo_local_1;
wire adc_2a_hi = adc_2a > lvl_hi_local_2;
wire adc_2a_lo = adc_2a < lvl_lo_local_2;
wire adc_2b_hi = adc_2b > lvl_hi_local_2;
wire adc_2b_lo = adc_2b < lvl_lo_local_2;

/*
 * Comparators 1A/1B logic block.
 */
adc_trigger_core_inner_logic adc_trigger_core_inner_1a1b (
	.comp_rst(comp_rst),
	.comp_pol(comp_pol_1),
	.comp_ena(comp_ena_1),
	.adc_data_clk(adc_data_clk),
	.adc_a_hi_comp(adc_1a_hi),
	.adc_a_lo_comp(adc_1a_lo),
	.adc_b_hi_comp(adc_1b_hi),
	.adc_b_lo_comp(adc_1b_lo),
	.comp_sig(comp_sig_1),
	.comp_ch_a(comp_ch_1a),
	.comp_ch_b(comp_ch_1b),
	.dbg_comp_state(dbg_comp_state_1),
	.dbg_ev_counter(dbg_ev_counter_1)
);

/*
 * Comparators 2A/2B logic block.
 */
adc_trigger_core_inner_logic adc_trigger_core_inner_2a2b (
	.comp_rst(comp_rst),
	.comp_pol(comp_pol_2),
	.comp_ena(comp_ena_2),
	.adc_data_clk(adc_data_clk),
	.adc_a_hi_comp(adc_2a_hi),
	.adc_a_lo_comp(adc_2a_lo),
	.adc_b_hi_comp(adc_2b_hi),
	.adc_b_lo_comp(adc_2b_lo),
	.comp_sig(comp_sig_2),
	.comp_ch_a(comp_ch_2a),
	.comp_ch_b(comp_ch_2b),
	.dbg_comp_state(dbg_comp_state_2),
	.dbg_ev_counter(dbg_ev_counter_2)
);

endmodule

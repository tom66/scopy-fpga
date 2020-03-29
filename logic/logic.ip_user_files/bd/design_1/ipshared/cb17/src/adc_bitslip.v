`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS.
//
//////////////////////////////////////////////////////////////////////////////////

/*
 * Implementation of the bitslip and reset generator.  
 *
 * The reset generator produces a reset pulse if N clock pulses have passed
 * with no toggle from the FCLK line.
 */

// number of CLK50 cycles we need to see without FCLK being toggled
// XXX: clk50 will become clk125 eventually - what changes here?
parameter num_clk50_before_reset = 1000;
parameter rst_clkloss_ctr_bitsize = 11;

// number of bitslip no lock events before sending a reset signal to all ISERDESE2
parameter num_bitslip_no_lock_before_reset = 96;
parameter rst_bitslip_ctr_bitsize = 11;

// global width of reset pulse for ISERDESE2 blocks in clk50 pulses
parameter num_clk50_rst_pulse = 32;

module adc_bitslip(
    // High speed clock input
    input adc_clk_in_p,
    
    // Divided clock input
    input adc_clk_div_in,
    
    // Frame clock from the ADC
    input adc_frame_clock_in,
    
    // Global CE and RST signals.  RST must be CLKDIV aligned.
    input ce,
    input rst,
    
    // Output signal from bitslip engine
    output bitslip_out,
    
    // State signal to indicate we've locked to the ADC output.
    output reg bitslip_is_locked,
    
    // Precision mode: 0 = 8-bit high speed (sync to 8'f0h), 1 = 16-bit high speed (sync to 16'ff00h; to be implemented)
    input bit_depth_mode,
    
    // Bitslip pattern for debug purposes
    output [7:0] bitslip_pattern_debug,
    
    // Reference clock input for reset generator
    input clk_ref,
    
    // Reset generator output
    output rst_gen
);

reg bitslip_gen;
assign bitslip_out = bitslip_gen;

wire [7:0] bitslip_pattern;
assign bitslip_pattern_debug = bitslip_pattern;

wire fclk_comb;

ISERDESE2 #(
    .DATA_RATE("DDR"),
    .DATA_WIDTH(8),
    .INTERFACE_TYPE("NETWORKING"),
    .NUM_CE(1),
    .INIT_Q1(1),
    .INIT_Q2(1),
    .INIT_Q3(1),
    .INIT_Q4(1),
    .SRVAL_Q1(0),
    .SRVAL_Q2(0),
    .SRVAL_Q3(0),
    .SRVAL_Q4(0),
    .IOBDELAY("NONE"),
    .OFB_USED("FALSE"),
    .SERDES_MODE("MASTER"),
    .DYN_CLKDIV_INV_EN("FALSE"),
    .DYN_CLK_INV_EN("FALSE"),
    .SERDES_MODE("MASTER")
) ISERDESE2_adc_inst (
    .D(adc_frame_clock_in),
    .CLK(adc_clk_in_p),
    .CLKB(~adc_clk_in_p),
    .CLKDIV(adc_clk_div_in),
    .CE1(ce),
    .RST(rst),
    .Q1(bitslip_pattern[0]),
    .Q2(bitslip_pattern[1]),
    .Q3(bitslip_pattern[2]),
    .Q4(bitslip_pattern[3]),
    .Q5(bitslip_pattern[4]),
    .Q6(bitslip_pattern[5]),
    .Q7(bitslip_pattern[6]),
    .Q8(bitslip_pattern[7]),
    .BITSLIP(bitslip_gen),
    .CLKDIVP(0)
);


// Reset logic.  Observes the FCLK line that feeds the ISERDESE2 and looks for edges.  
// One edge must occur at least within num_clk50_before_reset cycles (derived from 50MHz 
// CLK).  If this does not occur, a reset signal will be asserted for num_clk50_rst_pulse 
// cycles.
//
// This logic is necessary to ensure that if the ADC restarts that we sync correctly.  
// To ensure it works correctly the control processor must allow at least num_clk50_rst_pulse *
// (1/50MHz) cycles, e.g. ~100us or so between ADC stop and start.
//
// In addition the number of Bitslip events are counted.  If this count exceeds an upper 
// threshold (power-of-two preferred) before lock is achieved them a reset signal will be
// emitted.
reg last_fclk_comb;

reg rst_gen_clkloss_state = 0;
reg rst_gen_bitslip_state = 0;
reg [rst_clkloss_ctr_bitsize:0] rst_gen_clkloss_ctr = 0;
reg [rst_bitslip_ctr_bitsize:0] rst_gen_bitslip_ctr = 0;

reg rst_gen_clkloss = 0;
reg rst_gen_bitslip = 0;

assign rst_gen = rst_gen_clkloss | rst_gen_bitslip;

always @(posedge clk_ref) begin

    if (last_fclk_comb != adc_frame_clock_in) begin
        rst_gen_clkloss_ctr <= 0;
        rst_gen_clkloss_state <= 0;
    end else begin
        rst_gen_clkloss_ctr <= rst_gen_clkloss_ctr + 1;
        
        if ((rst_gen_clkloss_state == 1) && (rst_gen_clkloss_ctr == num_clk50_rst_pulse)) begin
            rst_gen_clkloss_ctr <= 0;
            rst_gen_clkloss_state <= 0;
            rst_gen_clkloss <= 0;
        end
        
        if ((rst_gen_clkloss_state == 0) && (rst_gen_clkloss_ctr == num_clk50_before_reset)) begin
            rst_gen_clkloss_ctr <= 0;
            rst_gen_clkloss_state <= 1;
            rst_gen_clkloss <= 1;
        end
    end
    
    if (rst_gen_bitslip_ctr > num_bitslip_no_lock_before_reset) begin
        if (rst_gen_bitslip_ctr < (num_bitslip_no_lock_before_reset + num_clk50_rst_pulse)) begin
            rst_gen_bitslip <= 1;
        end else begin
            rst_gen_bitslip <= 0;
        end
    end
    
    last_fclk_comb <= adc_frame_clock_in;

end

// Bitslip operation:
//  - Bitslip cannot be asserted continuously; it can only be asserted
//    on every other CLKDIV cycle.
//
//  - We verify bitslip_pattern against "11110000" in 8-bit mode or "11111111"
//    in 16-bit mode which indicates alignment of the FCLK signal from the ADC.
//
//  - Once matched the module does not drive BITSLIP but continues to monitor
//    the state of bitslip_pattern. If bit slippage occurs it issues a corrective
//    action.
//
//  - Once we have aligned our bitslip pattern the bitslip_is_locked signal
//    is set.

// This logic operates on /8 clock from the CLK signal, essentially an /32 of the
// main input clock; it only executes a decision on one in eight clocks (otherwise, BITSLIP
// signal is asserted LOW.)
reg [2:0] bitslip_state;

wire [7:0] bitslip_match = (bit_depth_mode) ? 8'b11111111 : 8'b11110000;

always @(posedge adc_clk_div_in) begin

    bitslip_state <= bitslip_state + 1;
    
    if (bitslip_state == 0) begin

        if (bitslip_pattern != bitslip_match) begin
            // It is quicker to simply issue BITSLIP signal and await the result
            // on the next cycle, rather than work out the correct shift pattern,
            // so this is the method we use.
            //
            // The bitslip submodule shifts by either 1 or -3, we don't know what it
            // will be, so the behaviour here can be a little unpredictable at first,
            // but it will lock after a small number of cycles.  Re-lock will be necessary
            // should the ADC clock change.
            bitslip_gen <= 1;
            bitslip_is_locked <= 0;
            rst_gen_bitslip_ctr <= rst_gen_bitslip_ctr + 1;
        end else begin
            bitslip_gen <= 0;
            bitslip_is_locked <= 1;
            rst_gen_bitslip_ctr <= 0;  // If locked reset our reset counter
        end
        
    end else begin
        bitslip_gen <= 0;
    end
        
end

endmodule

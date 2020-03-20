/////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS.
//
/////////////////////////////////////////////////////////////////////////////////

module adc_receiver(

    // LVDS differential input ports
    input adc_l1a_p,
    input adc_l1a_n,
    input adc_l1b_p,
    input adc_l1b_n,
    input adc_l2a_p,
    input adc_l2a_n,
    input adc_l2b_p,
    input adc_l2b_n,
    input adc_l3a_p,
    input adc_l3a_n,
    input adc_l3b_p,
    input adc_l3b_n,
    input adc_l4a_p,
    input adc_l4a_n,
    input adc_l4b_p,
    input adc_l4b_n,
    input adc_lclk_p,
    input adc_lclk_n,
    input adc_fclk_p,
    input adc_fclk_n,
    
    // Mode selection.
    // 
    // 00 = off
    // 01 = 8-bit high speed (1GSa/s)
    // 10 = Reserved/do not use
    // 11 = Reserved/do not use
    input [1:0] adc_mode,
    
    // Data output.
    output [13:0] adc_data_0,
    output [13:0] adc_data_1,
    output [13:0] adc_data_2,
    output [13:0] adc_data_3,
    output [13:0] adc_data_4,
    output [13:0] adc_data_5,
    output [13:0] adc_data_6,
    output [13:0] adc_data_7,
    
    // Data ready/valid signal for the ADC channels
    output reg adc_data_rdy,
    
    // Clock for ADC data
    output adc_data_clk,
    
    // Debug outputs
    output [7:0] debug,
    
    // Training state & control
    input train_start,
    output train_done,
    output train_ok,
    output [5:0] train_count,
    output idelay_rdy,
    input idelay_refclk,    // xx MHz refclk
    output [7:0] train_data_debug,
    
    // Global CE & reset signals
    input g_rst,
    input g_rx_ce,
    
    // Reference clock for timing purposes
    input clk_ref
);

wire idelay_rdy, idelay_refclk;

reg adc_data_wri_latch = 0;

// Internal register set for the received data.  This is latched into adc_data_latched_N when complete.
reg [13:0] adc_data_rx[7:0];
wire [13:0] adc_data_0, adc_data_1, adc_data_2, adc_data_3, adc_data_4, adc_data_5, adc_data_6, adc_data_7;

// Netlist set for ISERDESE2 data.
wire [7:0] adc_iserdese2_data[7:0];

/*
 * Differential to SE blocks.  No logic is permitted between or after these blocks.  Any
 * data manipulation must be done on the parallel data side.
 */
wire adc_d1a, adc_d1b, adc_d2a, adc_d2b, adc_d3a, adc_d3b, adc_d4a, adc_d4b, adc_fclk;
wire adc_clk_unbuf;

IBUFDS (
    .I(adc_l1a_p),
    .IB(adc_l1a_n),
    .O(adc_d1a)
);

IBUFDS (
    .I(adc_l1b_p),
    .IB(adc_l1b_n),
    .O(adc_d1b)
);

IBUFDS (
    .I(adc_l2a_p),
    .IB(adc_l2a_n),
    .O(adc_d2a)
);

IBUFDS (
    .I(adc_l2b_p),
    .IB(adc_l2b_n),
    .O(adc_d2b)
);

IBUFDS (
    .I(adc_l3a_p),
    .IB(adc_l3a_n),
    .O(adc_d3a)
);

IBUFDS (
    .I(adc_l3b_p),
    .IB(adc_l3b_n),
    .O(adc_d3b)
);

IBUFDS (
    .I(adc_l4a_p),
    .IB(adc_l4a_n),
    .O(adc_d4a)
);

IBUFDS (
    .I(adc_l4b_p),
    .IB(adc_l4b_n),
    .O(adc_d4b)
);

IBUFDS (
    .I(adc_fclk_p),
    .IB(adc_fclk_n),
    .O(adc_fclk)
);

IBUFGDS (
    .I(adc_lclk_p),
    .IB(adc_lclk_n),
    .O(adc_clk_unbuf)
);

/* 
 * It is not a valid configuration to use the word clock for the ADC peripheral to drive the
 * ISERDESE2. Therefore we use a BUFR instance to divide by 4 instead.  This regional clock
 * is distributed to all of our ISERDESE2 modules.  
 *
 * I am also considering using an MMCM to generate the divided ADC clock signal.
 */
wire adc_clk;
wire adc_clk_div;

BUFIO (
    .I(adc_clk_unbuf),
    .O(adc_clk)
);

BUFR #(
    .BUFR_DIVIDE("4")
) bufr_adc_ref_clkdiv (
    .I(adc_clk_unbuf),
    .O(adc_clk_div),
    .CE(1'b1),
    .CLR(1'b0)
);

/*
 * The ISERDESE2 requires g_rst to fall low not less than two CLKDIV cycles after being
 * asserted, and for that falling edge to be guaranteed synchronous with the falling edge
 * of CLKDIV.  This logic ensures that and generates a g_rst_clkdiv signal as its output.
 *
 * In addition, we assert an additional reset pulse after a number of cycles of no FCLK
 * activity.  This behaviour is controlled by the bitslip module.  
 */ 
reg g_rst_clkdiv = 0;
reg g_ce_clkdiv = 0;
reg g_rst_clkdiv_state_complete = 0;
reg [7:0] g_rst_clkdiv_ctr = 0;  // size 2:0 ?
wire rst_gen_bitslip; // reset from bitslip module

always @(negedge adc_clk_div) begin

    if (g_rst || rst_gen_bitslip) begin
        g_rst_clkdiv <= 1;
        g_rst_clkdiv_ctr <= 0;
        g_rst_clkdiv_state_complete <= 0;
        g_ce_clkdiv <= 0;
    end else begin
        if (!g_rst_clkdiv_state_complete) begin
            g_rst_clkdiv_ctr <= g_rst_clkdiv_ctr + 1;
            g_ce_clkdiv <= 1;  // Clock enable asserted.  Hold reset until counter reaches target.
            
            if (g_rst_clkdiv_ctr == 8) begin
                g_rst_clkdiv <= 0;
                g_rst_clkdiv_state_complete <= 1;
            end
        end
    end

end

/*
 * Implementation of the IDELAYCTRLE2 block which is required for delay calibration.
 */
IDELAYCTRL (
    .RST(g_rst),
    .REFCLK(idelay_refclk),
    .RDY(idelay_rdy)
);

/*
 * Implementation of the BITSLIP generator, which measures the FCLK signal
 * from the ADC and generates BITSLIP pulses to maintain alignment.
 */
wire bitslip_com;
wire bitslip_lock_state;
wire [7:0] bitslip_pattern_debug;

adc_bitslip (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_frame_clock_in(adc_fclk),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip_out(bitslip_com),
    .bitslip_is_locked(bitslip_lock_state), 
    .bit_depth_mode(0),
    .bitslip_pattern_debug(bitslip_pattern_debug),
    .clk_ref(clk_ref),
    .rst_gen(rst_gen_bitslip)
);

/*
 * Common training signals and vectors.
 */
wire [7:0] debug_train_value;
wire lvds_train_start = train_start;
assign train_done = lvds_train_done[0];
assign train_ok = lvds_train_ok[0];
assign train_count = lvds_train_count[0];
assign train_data_debug = adc_iserdese2_data[0];
//assign train_data_debug = debug_train_value;

wire [7:0] lvds_train_done;
wire [7:0] lvds_train_ok;
wire [7:0] lvds_train_count [5:0];

wire [2:0] debug_train_state;

assign debug[4:2] = debug_train_state;

/*
 * Implementation of the 8 x 8-bit ISERDESE2 blocks.
 */
wire train_debug2;

// D1A, non-inverted
adc_iserdese2_mod asi2_mod_inst0 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d1a),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(1),
    .oq_data(adc_iserdese2_data[0]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[0]),
    .train_ok(lvds_train_ok[0]),
    .train_count_out(lvds_train_count[0]),
    .train_state_out(debug_train_state),
    .train_debug(debug_train_value),
    .train_debug2(train_debug2),
    .clk_ref(clk_ref)
);

// D1B, non-inverted
adc_iserdese2_mod asi2_mod_inst1 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d1b),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(1),
    .oq_data(adc_iserdese2_data[1]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[1]),
    .train_ok(lvds_train_ok[1]),
    .train_count_out(lvds_train_count[1]),
    .clk_ref(clk_ref)
);

// D2A, non-inverted
adc_iserdese2_mod asi2_mod_inst2 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d2a),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(1),
    .oq_data(adc_iserdese2_data[2]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[2]),
    .train_ok(lvds_train_ok[2]),
    .train_count_out(lvds_train_count[2]),
    .clk_ref(clk_ref)
);

// D2B, inverted
adc_iserdese2_mod asi2_mod_inst3 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d2b),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(0),
    .oq_data(adc_iserdese2_data[3]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[3]),
    .train_ok(lvds_train_ok[3]),
    .train_count_out(lvds_train_count[3]),
    .clk_ref(clk_ref)
);

// D3A, inverted
adc_iserdese2_mod asi2_mod_inst4 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d3a),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(0),
    .oq_data(adc_iserdese2_data[4]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[4]),
    .train_ok(lvds_train_ok[4]),
    .train_count_out(lvds_train_count[4]),
    .clk_ref(clk_ref)
);

// D3B, inverted
adc_iserdese2_mod asi2_mod_inst5 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d3b),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(0),
    .oq_data(adc_iserdese2_data[5]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[5]),
    .train_ok(lvds_train_ok[5]),
    .train_count_out(lvds_train_count[5]),
    .clk_ref(clk_ref)
);

// D4A, inverted
adc_iserdese2_mod asi2_mod_inst6 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d4a),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(0),
    .oq_data(adc_iserdese2_data[6]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[6]),
    .train_ok(lvds_train_ok[6]),
    .train_count_out(lvds_train_count[6]),
    .clk_ref(clk_ref)
);

// D4B, non-inverted
adc_iserdese2_mod asi2_mod_inst7 (
    .adc_clk_in_p(adc_clk),
    .adc_clk_div_in(adc_clk_div),
    .adc_lane_data(adc_d4b),
    .ce(g_ce_clkdiv),
    .rst(g_rst_clkdiv),
    .bitslip(bitslip_com),
    .package_invert(1),
    .oq_data(adc_iserdese2_data[7]),
    .train_start(lvds_train_start),
    .train_done(lvds_train_done[7]),
    .train_ok(lvds_train_ok[7]),
    .train_count_out(lvds_train_count[7]),
    .clk_ref(clk_ref)
);

//assign debug[0] = bitslip_com;
//assign debug[1] = bitslip_lock_state;
 
 assign debug[0] = adc_clk_div;
 assign debug[1] = idelay_refclk;
    
/* 
 * All logic runs from a divide-by-4 clock from the ADC inclk.  
 *
 * A phase state machine is used to pack the data from the 8-bit SERDES blocks into the output
 * register, and drive the latch when ready.
 *
 * Data is latched out into the main latch registers at an Fmax of 125MHz on every 8th or 16th 
 * bit read.
 */
integer i;

assign adc_data_clk = adc_clk_div;

assign adc_data_0 = adc_iserdese2_data[0];
assign adc_data_1 = adc_iserdese2_data[1];
assign adc_data_2 = adc_iserdese2_data[2];
assign adc_data_3 = adc_iserdese2_data[3];
assign adc_data_4 = adc_iserdese2_data[4];
assign adc_data_5 = adc_iserdese2_data[5];
assign adc_data_6 = adc_iserdese2_data[6];
assign adc_data_7 = adc_iserdese2_data[7];

/*
always @(posedge adc_clk_div) begin

    //test_iserdese2_data <= test_iserdese2_data + 1;

    if (g_rst) begin
        // initialise? may not be needed.
        for (i = 0; i < 8; i = i + 1) begin
            adc_data_rx[i] <= 16'b0000000000000000;
        end
    end else begin
        case (adc_mode) 
        
            2'b01 : begin
            
                // clear unused bits
                for (i = 0; i < 8; i = i + 1) begin
                    adc_data_rx[i][13:8] <= 8'h00;
                end
                
                // Latch data
                for (i = 0; i < 8; i = i + 1) begin
                    adc_data_rx[i][7:0] <= adc_iserdese2_data[i];
                end
                
                adc_data_wri_latch <= 1;
            
            end
            
        endcase
    end
    
    if (adc_data_wri_latch) begin
        adc_data_latched_0 <= adc_data_rx[0];
        adc_data_latched_1 <= adc_data_rx[1];
        adc_data_latched_2 <= adc_data_rx[2];
        adc_data_latched_3 <= adc_data_rx[3];
        adc_data_latched_4 <= adc_data_rx[4];
        adc_data_latched_5 <= adc_data_rx[5];
        adc_data_latched_6 <= adc_data_rx[6];
        adc_data_latched_7 <= adc_data_rx[7];
        adc_data_rdy <= 1;
    end else begin
        adc_data_rdy <= 0;
    end

end
*/

endmodule

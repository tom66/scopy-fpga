/////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS.
//
/////////////////////////////////////////////////////////////////////////////////

/*
 * Implementation of one of the deserialisers for the ADC LVDS inputs.
 *
 * The module deserialises received LVDS data into 4 data bits.
 */
module adc_iserdese2_mod (
    // ADC clock input
    input adc_clk_in_p,
    
    // Divided regional clock
    input adc_clk_div_in,
    
    // ADC data input
    input adc_lane_data,
    
    // CE and reset.  Reset signal to be aligned to divided clock.
    input ce,
    input rst,
    
    // Bitslip input from the bitslip synchroniser
    input bitslip,
    
    // Invert signal.  If set then package P/N are inverted and data is 
    // inverted by this module to compensate.
    input package_invert,
    
    // Training state machine signals
    //  - train_start = assert to begin training state machine (Input word should be 11110000)
    //  - train_done = asserts when training complete
    //  - train_ok = asserts if training successfully completed (if train_ok low but train_done high
    //    then line training failed to complete.)
    input train_start,
    output reg train_done,
    output reg train_ok,
    output [5:0] train_count_out,
    output [2:0] train_state_out,           // for debug
    output [7:0] train_debug,               // for debug II
    output train_debug2,                    // for debug III
    
    // Reference clock (~125MHz) used to clock training state machine and IDELAY block
    input clk_ref,
    
    // Output port
    output [7:0] oq_data
);

wire [7:0] oq_data_raw;
wire [7:0] oq_data_corr;

assign oq_data_corr = oq_data_raw ^ ((package_invert) ? (8'hff) : (8'h00));
assign oq_data = oq_data_corr;

// Train state machine actual state
reg [2:0] train_state = TRAIN_IDLE;

parameter TRAIN_IDLE = 1;
parameter TRAIN_FIND_LOW_DELAY = 2;
parameter TRAIN_FIND_HIGH_DELAY = 3;
parameter TRAIN_DONE = 4;

// how many valid results before training is completed
parameter TRAIN_SEARCH_COUNT = 127;
parameter TRAIN_COUNT_BITSIZE = 8;

// escape to the next training level or abort if reached at high level
parameter TRAIN_ESCAPE_COUNT = 511;
parameter TRAIN_COUNT_ESCAPE_BITSIZE = 10;

// set to the maximum delaycount for IDELAYE2
parameter TRAIN_MAX_IDELAYE2 = 31;

reg [TRAIN_COUNT_BITSIZE:0] train_counter;
reg [TRAIN_COUNT_ESCAPE_BITSIZE:0] train_escape_counter;
reg [5:0] train_high;
reg [5:0] train_low;
reg train_fail = 0;
reg train_ld_gen = 0;
reg train_ld_dly = 0;

assign train_count_out = train_output;
assign train_state_out = train_state;

/*
 * Training state machine.
 *
 * Training starts in TRAIN_IDLE.  The @train_start signal causes the initial
 * low delay search to start.  After 128 clear low delay results are received,
 * training advances to find the high delay.  After 128 clear high delay results
 * are received, training is complete.
 *
 * If either high or low training reach the final terminal count without successfully
 * finding a valid delay then training fails and TRAIN_DONE is advanced to immediately.
 *
 * Generally training should only be used for bitrates >250Mbit/s;  it may fail 
 * to complete below this bitrate or produce incorrect output codes.
 */
wire train_data_valid;
reg [5:0] train_output;

assign train_data_valid = (oq_data_corr == 8'hf0);

/* This logic clocked on negative edge, as IDELAYE2 latches
 * new values on the positive edge. */
always @(negedge clk_ref) begin

    /*
    if (rst) begin
        // Default training delay is 1/2
        train_output <= (TRAIN_MAX_IDELAYE2 / 2);
        train_state <= TRAIN_IDLE;
        train_high <= 0;
        train_low <= 0;
        train_counter <= 0;
        train_escape_counter <= 0;
        train_done <= 0;
    end
    */
    
    // drive for 2CLK only
    if (train_ld_gen) begin
        if (train_ld_dly) begin
            train_ld_gen <= 0;
            train_ld_dly <= 0;
        end else begin
            train_ld_dly <= 1;
        end
    end

    case (train_state) 
    
        TRAIN_IDLE : begin
            if (train_start) begin
                train_high <= 0;
                train_low <= 0;
                train_counter <= 0;
                train_state <= TRAIN_FIND_LOW_DELAY;
                train_escape_counter <= 0;
                train_output <= train_low; // Start low
                train_done <= 0;
                train_ok <= 0;
            end
        end
        
        TRAIN_FIND_LOW_DELAY : begin
            train_ld_gen <= 0;
            
            if (train_data_valid) begin
                train_counter <= train_counter + 1;
                
                // If we match N entries at this count then accept this as the low training value
                if (train_counter == TRAIN_SEARCH_COUNT) begin
                    train_counter <= 0;
                    train_escape_counter <= 0;
                    train_state <= TRAIN_FIND_HIGH_DELAY;
                    
                     // Must start at least one higher than train_low
                    train_output <= train_low + 1;
                    train_high <= train_low + 1;
                end
            end else begin
                train_escape_counter <= train_escape_counter + 1;
                train_counter <= 0;
                
                // If we reach the escape count (more than N errors),
                // then increment to the next train_low count or fail.
                if (train_escape_counter == TRAIN_ESCAPE_COUNT) begin
                    // Fail at two counts before the maximum to ensure headroom for finding
                    // the high count.
                    if (train_low == (TRAIN_MAX_IDELAYE2 - 2)) begin
                        train_state <= TRAIN_DONE;
                        train_fail <= 1;
                    end else begin
                        train_escape_counter <= 0;
                        train_low <= train_low + 1;
                        train_output <= train_low;
                        train_ld_gen <= 1;
                    end
                end
            end
        end
        
        TRAIN_FIND_HIGH_DELAY : begin
            if (train_data_valid) begin
                train_counter <= train_counter + 1;
                
                // If we match N entries at this count then accept this as the low training value
                if (train_counter == TRAIN_SEARCH_COUNT) begin
                    train_counter <= 0;
                    train_state <= TRAIN_DONE;
                end
            end else begin
                train_escape_counter <= train_escape_counter + 1;
                train_counter <= 0;
                
                // If we reach the escape count (more than N errors),
                // then increment to the next train_low count or fail.
                if (train_escape_counter == TRAIN_ESCAPE_COUNT) begin
                    if (train_high == TRAIN_MAX_IDELAYE2) begin
                        train_state <= TRAIN_DONE;
                        train_fail <= 1;
                    end else begin
                        train_escape_counter <= 0;
                        train_high <= train_high + 1;
                        train_output <= train_high;
                        train_ld_gen <= 1;
                    end
                end
            end
        end
        
        TRAIN_DONE : begin
            if (train_fail) begin
                // Load default training (1/2)
                train_output <= (TRAIN_MAX_IDELAYE2 / 2);
                train_ok <= 0;
            end else begin
                // Load halfway point between high and low
                train_output <= (train_high + train_low) >> 1;
                train_ok <= 1;
            end
            
            train_done <= 1;
            
            // Only return to IDLE after train_start goes LOW otherwise remain in DONE
            if (!train_start) begin
                train_state <= TRAIN_IDLE;
            end else begin
                train_state <= TRAIN_DONE;
            end
        end
        
    endcase

end

reg [25:0] traintst_delay_ctr;
reg [5:0] train_counterXXX = 0;
reg train_ld_genXXX;

/*
always @(posedge clk_ref) begin

    train_ld_genXXX <= ~train_ld_genXXX;
    traintst_delay_ctr <= traintst_delay_ctr + 1;    
    
    if (traintst_delay_ctr == 0) begin
        train_counterXXX <= train_counterXXX + 1;
    end
    
end
*/

assign train_debug2 = train_counterXXX & 1;

/*
 * IDELAYE2 block for input delay adjustment.  Controlled by the training engine.
 */
wire adc_lane_data_delayed;

IDELAYE2 #(
    .IDELAY_TYPE("VAR_LOAD"),
    .DELAY_SRC("IDATAIN"),              // Data source is not logic
    .HIGH_PERFORMANCE_MODE("TRUE"),     // Sure, why not;  evaluate if needed later
    .SIGNAL_PATTERN("DATA"),            
    .REFCLK_FREQUENCY(200),             // Assume 200MHz REFCLK (Provided to IDELAYCTRL block in adc_receiver.v)
    .CINVCTRL_SEL("FALSE"),
    .PIPE_SEL("FALSE")
) IDELAYE2_adc_inst (
    .C(clk_ref),                        // Distinct from REFCLK despite similar name
    .REGRST(1'b0),                      // Unused
    .LD(train_ld_genXXX),
    .CE(1'b0),                          // Unused
    .INC(1'b0),                         // Unused
    .CINVCTRL(1'b0),                    // Unused
    .CNTVALUEIN(train_counterXXX),      // Fabric input for the present training value; either dynamically adjusts or is fixed
    .CNTVALUEOUT(train_debug),          // Fabric output for debug
    .IDATAIN(adc_lane_data),
    .LDPIPEEN(1'b0),                    // Unused
    .DATAOUT(adc_lane_data_delayed)     // Trained/delayed output to ISERDESE2 block
);

/* 
 * Module operates on 8-bit words.
 *
 * In high-speed 8-bit mode to device reads individual data words.  In 12- and 14-bit
 * mode, data is padded into 16-bit words with remaining bits set to zero.
 */
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
    .DDLY(adc_lane_data_delayed),
    .CLK(adc_clk_in_p),
    .CLKB(~adc_clk_in_p),
    .CLKDIV(adc_clk_div_in),
    .CE1(ce),
    .RST(rst),
    .Q1(oq_data_raw[7]),
    .Q2(oq_data_raw[6]),
    .Q3(oq_data_raw[5]),
    .Q4(oq_data_raw[4]),
    .Q5(oq_data_raw[3]),
    .Q6(oq_data_raw[2]),
    .Q7(oq_data_raw[1]),
    .Q8(oq_data_raw[0]),
    .BITSLIP(bitslip),
    .CLKDIVP(0)
);

endmodule

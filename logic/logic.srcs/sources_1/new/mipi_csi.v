`timescale 1ns / 1ns

/////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module mipi_csi(
    // Master CSI clock (two phases - I/Q, 0 & 90 deg) for OSERDESE2 block
    input mod_clk_I,
    input mod_clk_Q,
    
    // Output clock for other logic that needs to be synchronous to the MIPI block
    output clk_out,
    
    // State control.  This is used to initiate a type of transfer.
    // 
    // Driving init_short_packet high will start a SHORT transfer.
    // Driving init_long_packet high will start a LONG transfer.
    // Driving init_idle high will switch to LP11 idle state.
    //
    // All other states unused currently.
    input init_short_packet,
    input init_long_packet,
    input init_idle,
    
    // Reserved for future expansion: reset interface.
    input rst_in,
    
    // Sleep mode control.  If high, the clock is inhibited, and state commands
    // will be ignored.
    //
    // Toggling this in the middle of a transaction has undefined effects and is not
    // recommended.
    input sleep_mode,
    
    // State initiation input.  Toggling this input HIGH will trigger the state in state_in
    // to be assessed.
    input state_go,
    
    // Size of any upcoming transfer in bytes (8 bits each).  This is copied into an 
    // internal counter when the transfer begins.
    input [15:0] tx_size,
    
    // Test word input for debugging
    input [7:0] test_word,
    
    // Clock gating mode.  
    // 
    // If set to 0 clock gating is disabled apart from upon initialisation.
    // If set to 1 then clock gating is enabled during idle packets.  This saves power and reduces EMC.
    //
    // Changing this parameter while a transmission is in progress is likely to cause issues;
    // only set after reset and before first transmission.
    input clock_gate_en,
    
    // State DONE output / BUSY output.
    // The BUSY line is HIGH during a transaction.
    // The DONE line goes HIGH after a transaction finishes (last byte clocked out and bus
    // returns to idle state.)
    // The ERROR line toggles if an error occurs (which may require controller reset).
    // The DEBUG lines are used for timing/logic checks.
    output reg done,
    output reg busy,
    output reg error,
    output reg [3:0] debug,
    
    // Memory bus interface.  This should be an interface to a BlockRAM large enough
    // for the current transfer.  Data is transferred from the DDR into a BlockRAM buffer
    // for transfer.
    //
    // Data is read in 16-bit chunks at typically 1/4th the CSI clock (e.g. 100MHz @ 16-bit
    // for a 800Mbit/s per lane transfer). The MIPI controller must have exclusive read access
    // to this block through a dedicated read port.
    //
    // Note this controller does not support the MIPI standard for an odd number of bytes.
    // The bytes transferred will always be even.  This is to avoid early line termination logic,
    // which gets pretty hairy.
    output mem_read_clk,
    output reg mem_read_en,
    output reg [11:0] mem_addr,
    input [15:0] mem_data,
    
    // counter for bytes output, no reset per frame
    output [15:0] bytes_output,
    
    // Virtual channel identifier for packet header.  This is normally 00.
    input [1:0] vc_id,
    
    // Data type identifier for packet header (6 bits).  This needs to be set to different
    // values when sending a short packet. 
    input [5:0] dt_id,
    
    // Word count input for packet header.
    input [15:0] wct_short,
    
    // Interface to the real world.  The application circuit as used in XAPP462 is used.
    output csi_clkp,             // Gated clocks,  DIFF_HSTL_I_18 logic
    output csi_clkn,             //
    output csi_dp0,              // Driven high-Z during LP mode, must be connected to DIFF_HSTL_I_18 logic
    output csi_dn0,              //
    output csi_dp1,              //
    output csi_dn1,              //
    output reg csi_dn0_lp_lat,   // Low power drivers 
    output reg csi_dp0_lp_lat,   //
    output reg csi_dn1_lp_lat,   //
    output reg csi_dp1_lp_lat,   //
    output reg csi_clkn_lp_lat,  //
    output reg csi_clkp_lp_lat   //
);
    
`include "mipi_crc16_x25_x.v"

// Unlatched lowpower line states
reg csi_dn0_lp, csi_dp0_lp, csi_dn1_lp, csi_dp1_lp;

// Latched lowpower line states
reg csi_dn0_lp_lat_1, csi_dp0_lp_lat_1, csi_dn1_lp_lat_1, csi_dp1_lp_lat_1;
reg csi_clkn_lp_lat, csi_clkp_lp_lat;

// Latch registers for the LP states implemented as a simple state machine
reg [1:0] csi_lp_state = LP_STATE_BUS_IDLE_11;
reg [1:0] csi_lp_state_lat = LP_STATE_BUS_IDLE_11;

parameter LP_STATE_BUS_IDLE_11    = 2'b00;
parameter LP_STATE_PREP_HS_01     = 2'b01;
parameter LP_STATE_HS_INIT_00     = 2'b10;
parameter LP_STATE_HS_DATA_ZZ     = 2'b11;

// Latch registers for the LP CLK states implemented as a simple state machine
reg [2:0] csi_lpclk_state = LPCLK_STATE_IDLE_11;

// LP states for clock lane
parameter LPCLK_STATE_IDLE_11     = 3'b000;
parameter LPCLK_STATE_PREP_CLK_01 = 3'b001;
parameter LPCLK_STATE_CLK_INIT_00 = 3'b010;
parameter LPCLK_STATE_CLK_ZERO    = 3'b100;
parameter LPCLK_STATE_CLK_RUN     = 3'b101;

// Block to generate a 1/4 clock (eg 100MHz from 400MHz); this drives the byte update.
// This is used to clock the state & load logic, to keep the routing sane and the
// clock rate moderate.
reg [1:0] mod_clk_div;
wire mod_clk_div4;

//assign mod_clk_div4 = (mod_clk_div & 4'b0010) != 0;
assign clk_out = mod_clk_div4;

always @(posedge mod_clk_I) begin
    mod_clk_div <= mod_clk_div + 1;
end

// ** Internal state registers **
// Last input state - used to advance state on change
reg [3:0] last_input_state;

// Ready to accept new state; set once in idle state
reg ready_state;

// Set to "1" to enable/gate output clocks,  only disabled in low power sleep
reg clk_out_en = 1;
wire clk_out_en_sum;
assign clk_out_en_sum = clk_out_en & (~sleep_mode);

// Output DDR clock enable
reg oddr_clk_en = 1;

// Output DDR controller tristate for line idle condition
// Set to 1 to tristate outputs.  Outputs are always tristated if sleep_mode is high
reg oddr_hiz = 1;
//wire oddr_hiz_sum;
//assign oddr_hiz_sum = oddr_hiz | sleep_mode;

// Current state. Only adjusted by state machine logic.
//
//   0 = LP state both lines high;                      advances to state 1 (on initiation), drives BUSY
//   1 = LP state 01 at initialisation point;           advances to state 2
//   2 = LP state 00 for T(hs-settle);                  advances to state 3
//   3 = LP state 00 with HS drivers enabled;           advances to state 4
//   4 = HS zero state for T(hs-zero);                  advances to state 5
//   5 = HS sync state (transmits HS sync byte);        advances to state 6
//   6 = HS packet header transmission;                 advances to state 7
//   7 = HS long packet data transmission;              advances to state 8
//   8 = HS packet CRC/footer transmission;             advances to state 10
//  10 = HS trail at end of packet for T(hs-trail);     advances to state 11
//  11 = LP line return pre-init state;                 advances to state 12
//  12 = LP line return at end of packet for T(reot);   resets to state 0 (idle), drives DONE, resets BUSY
//  15 = TX inactive state;                             idle until state change then jumps to prepare clock state 16 (from clk LP-11)
//  16 = Clock prepare state;                           LP-01 for clock lane then advances to state 17
//  17 = Clock low state;                               LP-00 for clock lane then advances to state 18
//  18 = Clock zero state;                              HS-00 for clock lane then advances to state 19
//  19 = Clock active state;                            clock enabled then advances to state 0 to begin transmission
//
reg [7:0] current_state;

parameter STATE_LP_IDLE    = 0;
parameter STATE_LP_INIT    = 1;
parameter STATE_LP_SETTLE = 2;
parameter STATE_LP_SETTLE_POST = 3;
//parameter STATE_LP_SETTLE_HS_ZERO_INIT = 3;
parameter STATE_HS_ZERO = 4;
parameter STATE_HS_SYNC = 5;
parameter STATE_HS_PACKET_HEADER = 6;
parameter STATE_HS_PACKET_DATA_TX = 7;
parameter STATE_HS_PACKET_CRC = 8;
parameter STATE_HS_TRAIL = 10;
parameter STATE_LP_RETURN_PRE = 11;
parameter STATE_LP_RETURN = 12;
parameter STATE_TX_INACTIVE = 13;
parameter STATE_PRE_RESET_STATE = 14;
parameter STATE_CLK_OFF_STATE = 15;
parameter STATE_CLK_PREP_STATE = 16;
parameter STATE_CLK_LOW_STATE = 17;
parameter STATE_CLK_ZERO_STATE = 18;
parameter STATE_CLK_ACTIVE_STATE = 19;
parameter STATE_CLK_EXIT_TX_END = 20;

// Diagnostic registers
reg [31:0] tx_counter;
reg [7:0] test = 8'h55;

// State timer - arbitrary timer used by multiple states
reg [15:0] state_timer;
reg [2:0] state_timer_2;

// New state change register.  Set when the state is changed, this triggers a reset of the state timer shared
// resource.
// TODO: use separate timers instead?
reg state_timer_rst;

// Short packet/long packet register (0 or 1)
// 0 = short,  1 = long
reg packet_type = PACKET_TYPE_SHORT;

parameter PACKET_TYPE_SHORT = 0;
parameter PACKET_TYPE_LONG = 1;

// Number of words remaining in current transaction (as above)
reg [15:0] tx_words_counter;

// Latched copies of input registers and pre-computed ECC
reg [1:0] vc_id_latch;
reg [5:0] dt_id_latch;
reg [15:0] wct_latch;

// HS transmit byte registers
reg [7:0] hs_tx_byte_d0;
reg [7:0] hs_tx_byte_d1;
reg hs_tx_byte_out_en = 0;

// ODDR bit counter; 3-bit counter that overflows which indicates which bit is being transmitted
reg [2:0] oddr_bit_counter;
reg oddr_ctr_reset;

// Memory read clock output
// Until metastability issues addressed we do not listen to clock enable
// TODO: use a BUFHCE for clock enable here?
reg mem_read_clk_en = 0;
assign mem_read_clk = mod_clk_div4;

// ODDR nets for DDR halves (A = 0',  B = 180')
wire d0_bit_a, d0_bit_b;
wire d1_bit_a, d1_bit_b;

// Initial state
initial begin

    busy <= 0;
    done <= 0;
    error <= 0;
    mem_read_en <= 0;
    // mem_read_clk_en <= 0;
    ready_state <= 1;
    current_state <= STATE_TX_INACTIVE;
    oddr_hiz <= 0;
    ready_state <= 1;
    oddr_ctr_reset <= 0;

end

// Set if an end of line trail is to be generated.  Two clock cycle delay implemented
// to position trail in correct location.
//
// FIXME: better way to infer the two-cycle delay as it's just a pair of SR's...
reg oddr_trail = 0;
reg oddr_trail_dly_a = 0;
reg oddr_trail_dly_b = 0;

// ODDR driver reset, should toggle at start of transaction to reset SERDESes
// Init state is in reset.
reg oddr_rst = 1;

// for alternate trail generation mechanism
reg oddr_trail_latch = 0;

reg [7:0] d0_latch;
reg [7:0] d1_latch;

// Regional BUFR divider for OSERDESE clkdiv port
// BUFG for OSERDESE to comply with clocking requirements in UG471
// TODO: clk enable based on hs tx;  save a few mW
wire mod_clk_div4_oserdese_ln0;
wire mod_clk_div4_oserdese_ln1;
wire mod_clk_I_bufg_oserdese;

BUFR #(
    .BUFR_DIVIDE("BYPASS"),
    .SIM_DEVICE("7SERIES")
) BUFR_mipi_clkdiv_ln0 (
    .I(mod_clk_div4),
    .O(mod_clk_div4_oserdese_ln0),
    .CE(1),
    .CLR(0)
);

BUFR #(
    .BUFR_DIVIDE("BYPASS"),
    .SIM_DEVICE("7SERIES")
) BUFR_mipi_clkdiv_ln1 (
    .I(mod_clk_div4),
    .O(mod_clk_div4_oserdese_ln1),
    .CE(1),
    .CLR(0)
);

BUFGCE BUFGCE_mipi_oserderse_clk (
    .I(mod_clk_I),
    .O(mod_clk_I_bufg_oserdese),
    .CE(1)
);

// clock-aligned ODDR reset (aligned to rising edge of clkdiv)
reg oddr_rst_clkalign, oddr_hiz_latch;

// clock-aligned clock enables
reg oddr_oclk_en_clkalign, oddr_tclk_en_clkalign;
reg oddr_oclk_en, oddr_tclk_en;

// clock output control - high impedance and enable outputs
reg clkout_hiz = 1;
reg clkout_gen = 0;

// initial line state, prior to clock output enable
initial begin

   csi_dn0_lp_lat <= 1;
   csi_dp0_lp_lat <= 1;
   csi_dn1_lp_lat <= 1;
   csi_dp1_lp_lat <= 1;
   oddr_hiz_latch <= 1;
   oddr_hiz <= 1;
   clkout_hiz <= 1;  // high disables output
   oddr_rst <= 0;
   oddr_rst_clkalign <= 0;
   clkout_gen <= 0;
   csi_clkp_lp_lat <= 1;
   csi_clkn_lp_lat <= 1;
   oddr_oclk_en_clkalign <= 0;
   oddr_tclk_en_clkalign <= 0;

end

always @(posedge mod_clk_div4_oserdese_ln0) begin
    
    d0_latch <= hs_tx_byte_d0;
    d1_latch <= hs_tx_byte_d1;
    oddr_oclk_en_clkalign <= oddr_oclk_en;
    oddr_tclk_en_clkalign <= oddr_tclk_en;
    oddr_rst_clkalign <= oddr_rst;
    oddr_hiz_latch <= oddr_hiz;
    csi_lp_state_lat <= csi_lp_state; 
    
end

// This block ensures that our final output LP signals are one high speed
// clock cycle delayed from the shift register, which keeps them aligned nicely.
// Again, almost certainly a more elegant way of doing this, but it works for now.
always @(posedge mod_clk_I_bufg_oserdese) begin

    // Read the state of the LP state input register and latch the next values.
    // There's effectively a 5-cycle delay on this, from the source to output.
    case (csi_lp_state_lat)
       LP_STATE_BUS_IDLE_11 : begin
           csi_dn0_lp_lat <= 1;
           csi_dp0_lp_lat <= 1;
           csi_dn1_lp_lat <= 1;
           csi_dp1_lp_lat <= 1;
       end
       
       LP_STATE_PREP_HS_01 : begin
           csi_dn0_lp_lat <= 1;
           csi_dp0_lp_lat <= 0;
           csi_dn1_lp_lat <= 1;
           csi_dp1_lp_lat <= 0;
       end
       
       LP_STATE_HS_INIT_00 : begin
           csi_dn0_lp_lat <= 0;
           csi_dp0_lp_lat <= 0;
           csi_dn1_lp_lat <= 0;
           csi_dp1_lp_lat <= 0;
       end
       
       LP_STATE_HS_DATA_ZZ : begin
           csi_dn0_lp_lat <= 1'bZ;
           csi_dp0_lp_lat <= 1'bZ;
           csi_dn1_lp_lat <= 1'bZ;
           csi_dp1_lp_lat <= 1'bZ;
       end                    
    endcase
    
end

// This block generates the clock start/stop logic signals
always @(posedge mod_clk_I_bufg_oserdese) begin

    // Read the state of the LP CLK state input register and latch the next values.
    case (csi_lpclk_state)
    
        // Both LP lines high and clk disabled
        LPCLK_STATE_IDLE_11 : begin
            clkout_hiz <= 1;  // high disables output
            clkout_gen <= 0;
            csi_clkp_lp_lat <= 1;
            csi_clkn_lp_lat <= 1;
        end
        
        // P line falls first, first part of terminator start sequence
        LPCLK_STATE_PREP_CLK_01 : begin
            clkout_hiz <= 1; 
            clkout_gen <= 0;
            csi_clkp_lp_lat <= 0;
            csi_clkn_lp_lat <= 1;
        end
        
        // Both LP lines low which triggers terminator (glitch seen on scope)
        LPCLK_STATE_CLK_INIT_00 : begin
            clkout_hiz <= 1;  // high disables output
            clkout_gen <= 0;
            csi_clkp_lp_lat <= 0;
            csi_clkn_lp_lat <= 0;
        end
    
        // LP lines stay low and clock is transmitting zero in this period
        // Also performed at end of clock operation keeping lines low
        LPCLK_STATE_CLK_ZERO : begin
            clkout_hiz <= 0;  // output enabled
            clkout_gen <= 0;  // clock not generated
            csi_clkp_lp_lat <= 1'bZ; // LP lines tristated
            csi_clkn_lp_lat <= 1'bZ;
        end
        
        // Both LP lines high and clk disabled
        LPCLK_STATE_CLK_RUN : begin
            clkout_hiz <= 0;  // output enabled
            clkout_gen <= 1;  // clock generated - this should sync with a clock edge
            csi_clkp_lp_lat <= 1'bZ; // LP lines tristated
            csi_clkn_lp_lat <= 1'bZ;
        end
            
    endcase
    
end

// ** Serialising OSERDESE block **
// This generates a 25% duty clock.  But that is not an issue for this design
BUFGCE bufgce_mipi_clkdiv (
    .I(mod_clk_I),
    .O(mod_clk_div4),
    .CE(mod_clk_div == 1'b11)
);

wire d0_oddr_out, d1_oddr_out;
wire d0_t_oddr_out, d1_t_oddr_out;

OSERDESE2 #(
    .DATA_RATE_OQ("DDR"),
    .DATA_RATE_TQ("SDR"),
    .DATA_WIDTH(8),
    .INIT_OQ(1'b0),
    .INIT_TQ(1'b1),
    .SERDES_MODE("MASTER"),
    .SRVAL_OQ(1'b0),
    .SRVAL_TQ(1'b1),
    .TBYTE_CTL("FALSE"),
    .TBYTE_SRC("FALSE"),
    .TRISTATE_WIDTH(1)
) OSERDESE2_lane_d0_inst (
    .OQ(d0_oddr_out),
    .CLK(mod_clk_I_bufg_oserdese),
    .CLKDIV(mod_clk_div4_oserdese_ln0),
    .TQ(d0_t_oddr_out),
    .T1(oddr_hiz_latch),
    //.OCE(oddr_clk_en),
    //.TCE(oddr_clk_en),
    .OCE(oddr_oclk_en_clkalign),
    .TCE(oddr_tclk_en_clkalign),
    .RST(oddr_rst_clkalign),
    // Bits are numbered 1-8.
    .D1(d0_latch[0]),
    .D2(d0_latch[1]),
    .D3(d0_latch[2]),
    .D4(d0_latch[3]),
    .D5(d0_latch[4]),
    .D6(d0_latch[5]),
    .D7(d0_latch[6]),
    .D8(d0_latch[7])
);

OSERDESE2 #(
    .DATA_RATE_OQ("DDR"),
    .DATA_RATE_TQ("SDR"),
    .DATA_WIDTH(8),
    .INIT_OQ(1'b0),
    .INIT_TQ(1'b1),
    .SERDES_MODE("MASTER"),
    .SRVAL_OQ(1'b0),
    .SRVAL_TQ(1'b1),
    .TBYTE_CTL("FALSE"),
    .TBYTE_SRC("FALSE"),
    .TRISTATE_WIDTH(1)
) OSERDESE2_lane_d1_inst (
    .OQ(d1_oddr_out),
    .CLK(mod_clk_I_bufg_oserdese),
    .CLKDIV(mod_clk_div4_oserdese_ln0),
    .TQ(d1_t_oddr_out),
    .T1(oddr_hiz_latch),
    .OCE(oddr_oclk_en_clkalign),
    .TCE(oddr_tclk_en_clkalign),
    .RST(oddr_rst_clkalign),
    // Bits are numbered 1-8.
    .D1(d1_latch[0]),
    .D2(d1_latch[1]),
    .D3(d1_latch[2]),
    .D4(d1_latch[3]),
    .D5(d1_latch[4]),
    .D6(d1_latch[5]),
    .D7(d1_latch[6]),
    .D8(d1_latch[7])
);

OBUFTDS #(
    .IOSTANDARD("DIFF_HSTL_I_18")
) OBUFDS_inst_lane0 (
    .O(csi_dp0),
    .OB(csi_dn0),
    .I(d0_oddr_out),    // d0_oddr_out, mod_clk_div4_oserdese_ln0
    .T(d0_t_oddr_out)   // oddr_hiz
);

OBUFTDS #(
    .IOSTANDARD("DIFF_HSTL_I_18")
) OBUFDS_inst_lane1 (
    .O(csi_dp1), 
    .OB(csi_dn1),
    .I(d1_oddr_out),    // d1_oddr_out, mod_clk_div4_oserdese_ln1
    .T(d1_t_oddr_out)   // oddr_hiz
);

//wire mod_clk_p_out_gate, mod_clk_n_out_gate;

// This OSERDESE2 is used to generate the output clock.  It is loaded with "01010101" to accomplish
// this task.
wire mod_clk_Q_oserdese_bufg_clk;
wire mod_clk_Q_div4_clk;
wire clk_t_oserdese_out; // Output from OSERDESE2 module for clock tristate
wire clk_q_oserdese_out; // Actual clock output generated by OSERDESE2

BUFR #(
    .BUFR_DIVIDE("BYPASS"),
    .SIM_DEVICE("7SERIES")
) BUFR_mipi_clk_out1 (
    .I(mod_clk_Q),
    .O(mod_clk_Q_oserdese_bufg_clk),
    .CE(1),
    .CLR(0)
);

BUFGCE bufgce_mipi_clkout_div (
    .I(mod_clk_Q_oserdese_bufg_clk),
    .O(mod_clk_Q_div4_clk),
    .CE(mod_clk_div == 1'b11)
);

OSERDESE2 #(
    .DATA_RATE_OQ("DDR"),
    .DATA_RATE_TQ("SDR"),
    .DATA_WIDTH(8),
    .INIT_OQ(1'b0),
    .INIT_TQ(1'b1),
    .SERDES_MODE("MASTER"),
    .SRVAL_OQ(1'b0),
    .SRVAL_TQ(1'b1),
    .TBYTE_CTL("FALSE"),
    .TBYTE_SRC("FALSE"),
    .TRISTATE_WIDTH(1)
) OSERDESE2_lane_clk_inst (
    .OQ(clk_q_oserdese_out),
    .CLK(mod_clk_Q_oserdese_bufg_clk),
    .CLKDIV(mod_clk_Q_div4_clk),
    .TQ(clk_t_oserdese_out),
    .T1(clkout_hiz),
    //.OCE(oddr_clk_en),
    //.TCE(oddr_clk_en),
    .OCE(clkout_gen),
    .TCE(oddr_tclk_en_clkalign),
    .RST(oddr_rst_clkalign),
    // Bits are numbered 1-8.
    .D1(1),
    .D2(0),
    .D3(1),
    .D4(0),
    .D5(1),
    .D6(0),
    .D7(1),
    .D8(0)
);
    
OBUFTDS #(
    .IOSTANDARD("DIFF_HSTL_I_18")
) OBUFDS_inst_lane_clk (
    .O(csi_clkp), 
    .OB(csi_clkn),
    .I(clk_q_oserdese_out), 
    .T(clk_t_oserdese_out)
);

// ECC module - implements Hamming(30,24) ECC code
wire [7:0] ecc_byte_0;
wire [7:0] ecc_byte_1;
wire [7:0] ecc_byte_2;
wire [7:0] ecc_result;
reg ecc_start;
wire ecc_ready;

assign ecc_byte_0 = (vc_id_latch >> 6) | (dt_id_latch & 8'h3f);
assign ecc_byte_1 = wct_latch & 8'hff;
assign ecc_byte_2 = (wct_latch >> 8) & 8'hff;

ecc24_fast ecc24_fast_x (
    // Data input
    .byte_0(ecc_byte_0),
    .byte_1(ecc_byte_1),
    .byte_2(ecc_byte_2),
    
    // ECC output
    .ecc(ecc_result)
);

reg [7:0] temp;

// CRC16 according to X25 (x^16+x^12+x^5+1);  see mipi_crc16_x25.v for implementation
reg [15:0] crc16;
wire [15:0] crc16_data;
assign crc16_data = hs_tx_byte_d0 | (hs_tx_byte_d1 << 8);

reg clock_exited = 1;

reg [15:0] bytes_output_ctr;
assign bytes_output = bytes_output_ctr;

// Main state logic
always @(posedge mod_clk_div4) begin
    
    // Disable clock if in sleep mode
    // XXX: this needs to be reviewed - ideally would put clk lines in inactive state as they will
    // be biggest power hog
    if (sleep_mode) begin
        oddr_clk_en <= 0;
        current_state <= STATE_TX_INACTIVE;
        clock_exited <= 1;
    end

    // Handle the shared timer resource
    // XXX: This is broken but the verilog is hacked to work with this.  Prob. best to use
    // independent simple timers.
    if (state_timer_rst) begin
        state_timer_rst = 0;
        state_timer <= 0;
    end else begin
        state_timer <= state_timer + 1;
    end
    
    //current_state <= STATE_CLK_OFF_STATE;
    
    // Handle the current state, and transitions to new states
    case (current_state)

        // Pre-reset state - advances to clock off state, drives reset line of ODDR module
        STATE_PRE_RESET_STATE : begin
            clock_exited <= 0;
            current_state <= STATE_CLK_OFF_STATE;
        end
            
        // Clock off state.  Sets clock lane to 11 to ensure line starts in OFF state.
        STATE_CLK_OFF_STATE : begin
            csi_lpclk_state <= LPCLK_STATE_IDLE_11;
            current_state <= STATE_CLK_PREP_STATE;
        end
        
        // Clock prep state. Sets clock lane to 01 state in preparation for clock termination
        STATE_CLK_PREP_STATE : begin
            csi_lpclk_state <= LPCLK_STATE_PREP_CLK_01;
            current_state <= STATE_CLK_LOW_STATE;
        end

        // Clock low state. Sets clock lane to 00 state in preparation for clock termination
        // We need to wait for the driver termination to engage (~100ns) so a delay is added.
        STATE_CLK_LOW_STATE : begin
            csi_lpclk_state <= LPCLK_STATE_CLK_INIT_00;
            
            if (state_timer & 4'b1000) begin
                current_state <= STATE_CLK_ZERO_STATE;
                state_timer_rst = 1;
            end
        end

        // Clock zero state. Turns on clock drivers and transmits a zero state while the driver
        // termination settles.
        STATE_CLK_ZERO_STATE : begin
            csi_lpclk_state <= LPCLK_STATE_CLK_ZERO;
            
            if (state_timer & 4'b1000) begin
                current_state <= STATE_CLK_ACTIVE_STATE;
                state_timer_rst = 1;
            end
        end
    
        // Clock run state. Enables clock and advances to LP idle state.
        STATE_CLK_ACTIVE_STATE : begin
            csi_lpclk_state <= LPCLK_STATE_CLK_RUN;
            
            if (state_timer & 5'b10000) begin
                current_state <= STATE_LP_IDLE;
                state_timer_rst = 1;
            end
        end
        
        // Clock exit state - drives extended "zero" from clock and jumps to TX_INACTIVE
        STATE_CLK_EXIT_TX_END : begin
            clock_exited <= 1;
            csi_lpclk_state <= LPCLK_STATE_CLK_ZERO;
            
            if (state_timer & 6'b100000) begin
                csi_lpclk_state <= LPCLK_STATE_IDLE_11;
                current_state <= STATE_TX_INACTIVE;
            end
        end
        
        // TX inactive state.  Effectively idle - keeps LP lines high and data tristated,
        // and clock lane remains inactive.
        STATE_TX_INACTIVE : begin
            // Determine if a packet should be sent
            if ((init_short_packet == 1) || (init_long_packet == 1)) begin
                if (init_short_packet == 1) begin
                    packet_type <= PACKET_TYPE_SHORT;
                    tx_words_counter <= 0;
                end else if (init_long_packet == 1) begin
                    packet_type <= PACKET_TYPE_LONG;
                    tx_words_counter <= tx_size;
                end
                
                // Drive to next state based on clock_exit status
                // If clock was exited we need to go through clock entry procedure
                if (clock_exited) begin
                    current_state <= STATE_PRE_RESET_STATE;
                end else begin
                    // Otherwise start tx immediately
                    current_state <= STATE_LP_IDLE; 
                end
                
                // Set transmission parameters
                vc_id_latch <= vc_id;
                dt_id_latch <= dt_id;
                wct_latch <= wct_short;
                done <= 0;
                busy <= 1;
                error <= 0;
                ready_state <= 0;
                oddr_trail_latch <= 0;
            end else begin
                // Set bus state to idle
                csi_lp_state <= LP_STATE_BUS_IDLE_11;
                
                // Set clock idle if we have stopped the output clock
                if (clock_exited) begin
                    csi_lpclk_state <= LPCLK_STATE_IDLE_11;
                end
                
                // If in idle state, set clock exit flag
                // This will cause the clock to return to LP-11 after 
                if (init_idle == 1) begin
                    clock_exited <= 1;
                end
            end
            
            state_timer_rst = 1;
            oddr_rst <= 1;
            mem_read_clk_en <= 0;
        end

        // LP idle state
        // All data lines at 1.2V (LP-11)
        // Data output is disabled
        // Clock IS active
        // Advances to LP_INIT almost immediately
        STATE_LP_IDLE : begin
            oddr_rst <= 0; // remove ODDR reset signal so subsequent ops can use the ODDR hiz control
            oddr_oclk_en <= 0;
            oddr_tclk_en <= 0;
            oddr_hiz <= 1;
            csi_lp_state <= LP_STATE_BUS_IDLE_11;
            oddr_ctr_reset <= 0;            
            test <= test + 1;
            
            if (state_timer & 1'b1) begin
                current_state <= STATE_LP_INIT;
                //state_timer_rst = 1;
            end
        end
        
        // LP init state (LP-01)
        // Holds state DP LP low and DN LP high for N cycles
        // Then advances to LP_SETTLE
        STATE_LP_INIT : begin
            csi_lp_state <= LP_STATE_PREP_HS_01;
            
            if (state_timer & 1'b1) begin
                current_state <= STATE_LP_SETTLE;
                //state_timer_rst = 1;
            end
        end
        
        // LP settle state (LP-00)
        // Holds state DP LP low and DN LP low for N cycles
        // The receiver shall enable its line terminators at this point
        // Then advances to STATE_LP_SETTLE_POST in which we enable our transmitter
        STATE_LP_SETTLE : begin
            csi_lp_state <= LP_STATE_HS_INIT_00;
            
            // ensure data byte is zero
            oddr_oclk_en <= 1;
            hs_tx_byte_d0 <= 0;
            hs_tx_byte_d1 <= 0;
            
            if (state_timer & 3'b110) begin
                current_state <= STATE_LP_SETTLE_POST;
                //state_timer_rst = 1;
            end
        end
        
        // LP post settle state (LP-00 but post init for highspeed drive)
        // LP lines are held low and the highspeed driver is initialised
        // Then advances to STATE_HS_ZERO immediately
        STATE_LP_SETTLE_POST : begin
            oddr_hiz <= 0;  // Enable output driver (1-byte delay)
            //oddr_rst <= 0;  // Remove reset assertion
            oddr_trail <= 0;
            hs_tx_byte_d0 <= 0;
            hs_tx_byte_d1 <= 0;
                        
            csi_lp_state <= LP_STATE_HS_DATA_ZZ;
                        
            oddr_ctr_reset <= 1;
            current_state <= STATE_HS_ZERO;
        end
        
        // HS zero state
        // Transmits on the high-speed bus a zero bit state for some cycles
        // Then advances to HS_SYNC.
        STATE_HS_ZERO : begin
            // Enable ODDR drivers, tx byte zero
            oddr_tclk_en <= 1;
            hs_tx_byte_d0 <= 0;
            hs_tx_byte_d1 <= 0;
            
            if (state_timer & 5'b10000) begin
                current_state <= STATE_HS_SYNC;
                state_timer_rst = 1;
            end
        end
        
        // HS sync state
        // Transmits sync packet on both lanes
        // This is transmitted once before transmission of data occurs
        // Immediately advances to the next state
        STATE_HS_SYNC : begin
            // transmit sync byte / HS leader sequence 11101,  this is a SoT on
            // both lanes simultaneously.
            hs_tx_byte_d0 <= 8'b10111000;
            hs_tx_byte_d1 <= 8'b10111000;
            
            // immediately advance to transmit state
            current_state <= STATE_HS_PACKET_HEADER;
            //state_timer_rst = 1;
        end
        
        // HS packet header
        // Transmits the packet header which is a 32-bit word:
        // 8-bit channel identification, 16-bit word count and 8-bit ECC
        // ECC module computes the ECC word on the 24-bit packet
        // Timer is used to compute which byte to send
        //
        // This advances to the HS_PACKET_DATA_TX state if a large payload follows,  or to HS_TRAIL
        // if packet_type == 0.
        STATE_HS_PACKET_HEADER : begin
            mem_read_en <= 0;
            mem_addr <= 0;
            
            if (state_timer == 0) begin
                hs_tx_byte_d0 <= ecc_byte_0;
                hs_tx_byte_d1 <= ecc_byte_1;
                crc16 = 16'hffff;  // reset crc16 before HS-TX
            end else if (state_timer == 1) begin
                hs_tx_byte_d0 <= ecc_byte_2;
                hs_tx_byte_d1 <= ecc_result;
                
                // then advance state
                if (packet_type == PACKET_TYPE_SHORT) begin
                    current_state <= STATE_HS_TRAIL;
                    state_timer_rst = 1;
                end else if (packet_type == PACKET_TYPE_LONG) begin
                    current_state <= STATE_HS_PACKET_DATA_TX;
                    state_timer_rst = 1;
                end
            end
        end
        
        STATE_HS_PACKET_DATA_TX : begin
            // Transmit 16-bit words on each cycle
            // Increment memory pointer, read memory and latch into output register
            
            // Decrement internal output word counter; two bytes per transmission cycle
            // N.B. this is one part of the logic design that limits us to even byte lengths... headaches otherwise!
            tx_words_counter <= tx_words_counter - 2;
            
            if (tx_words_counter == 0) begin
                // Load CRC into output registers
                hs_tx_byte_d0 <= (crc16 >> 8) & 8'hff;
                hs_tx_byte_d1 <= crc16 & 8'hff;
                
                // Jump state to complete trail sequence
                current_state <= STATE_HS_TRAIL;  
                state_timer_rst = 1;
                mem_read_en <= 0;
            end else begin
                // CRC16 not used currently
                crc16 = 16'hffff; // mipi_crc16_x25_imp(crc16_data, crc16);
                
                // Load data into output registers, increment memory pointer
                hs_tx_byte_d0 <= (mem_data >> 8) & 8'hff;
                hs_tx_byte_d1 <= mem_data & 8'hff;
                mem_read_en <= 1;
                mem_addr <= mem_addr + 1;
                bytes_output_ctr <= bytes_output_ctr + 2;
            end
        end
        
        STATE_HS_TRAIL : begin
            // ODDR trail - set state and drive trail state for N byte cycles before going line IDLE
            // This inverts state of DDR lines for last bit and will hold the state until LP mode is entered
            // Unclear whether this can be omitted to reduce logic complexity; may trip up CSI receiver.
            //
            // 23/9/2018: appears to be crucial for rx to work correctly, trail must be present and correct,
            // therefore will leave it in for now.
            //
            // check last bit and latch the opposite bit
            if (oddr_trail_latch == 0) begin
                if (hs_tx_byte_d0 & 8'b10000000) begin
                    hs_tx_byte_d0 <= 8'h00;
                end else begin
                    hs_tx_byte_d0 <= 8'hff;
                end
                
                if (hs_tx_byte_d1 & 8'b10000000) begin
                    hs_tx_byte_d1 <= 8'h00;
                end else begin
                    hs_tx_byte_d1 <= 8'hff;
                end
                
                oddr_trail_latch <= 1;
                state_timer_2 <= 0;
            end

            // this kinda works but not as expected - may need to be fixed
            state_timer_2 <= state_timer_2 + 1;
            if (state_timer_2 == 2) begin
                current_state <= STATE_LP_RETURN_PRE;
                state_timer_rst = 1;
            end
        end
        
        STATE_LP_RETURN_PRE : begin
            // Pre-latch data for return to LP state - used to get OSERDESE2 module in correct mode
            oddr_hiz <= 1;
            csi_lp_state <= LP_STATE_BUS_IDLE_11;
            
            // Then jump to next state.
            if (state_timer & 5'b01000) begin
                current_state <= STATE_LP_RETURN;
                state_timer_rst = 1;
            end
        end
        
        STATE_LP_RETURN : begin
            // Drive reset, will be latched on next byte
            oddr_rst <= 1; 
            
            // Disable ODDR clk so no more hs tx packets, latch zero bytes in
            oddr_clk_en <= 0;
            
            // Disable memory read clock
            mem_read_clk_en <= 0;
            
            // Set DONE flag, clear BUSY flag
            busy <= 0;
            done <= 1;
            tx_counter <= tx_counter + 1;
            
            // Advance to TX_INACTIVE as new idle state, where we remain until we receive
            // another request
            if (clock_gate_en) begin
                current_state <= STATE_CLK_EXIT_TX_END;
            end else begin
                current_state <= STATE_TX_INACTIVE;
            end
            state_timer_rst = 1;
        end
        
        default : begin
            current_state <= STATE_TX_INACTIVE;
        end
    
    endcase
    
end

endmodule

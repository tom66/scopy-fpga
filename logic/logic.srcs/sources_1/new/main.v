  
`timescale 1ns / 1ns

//////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module main(
    csi_clk_p,      // clock lane positive
    csi_clk_n,      // clock lane negative
    csi_d0_p,       // data lane positive 0
    csi_d0_n,       // data lane negative 0
    csi_d1_p,       // data lane positive 1
    csi_d1_n,       // data lane negative 1
    
    csi_lpd0_n,     // low power state driver lane 0 neg
    csi_lpd0_p,     // low power state driver lane 0 pos
    csi_lpd1_n,     // low power state driver lane 1 neg
    csi_lpd1_p,     // low power state driver lane 1 pos
    csi_lpclk_n,    // low power state driver clk neg
    csi_lpclk_p,    // low power state driver clk pos
    
    led_PL0,        // diagnostic LED PL0
    led_PL1         // diagnostic LED PL1
 );

output csi_clk_p, csi_clk_n, csi_d0_p, csi_d0_n, csi_d1_p, csi_d1_n, csi_lpd0_n, csi_lpd0_p, csi_lpd1_n, csi_lpd1_p, csi_lpclk_n, csi_lpclk_p;
output led_PL0, led_PL1;

// 50MHz clock from PS clock source
// This is derived from a 33.33MHz clock from the PS_CLK input.
// 
// Clock breakdown:
//  -  50MHz logic clock for general logic                                         [clk_master_50]
//  - 800MHz QDR clocks (x3) for CSI output (in testing these are set to low-MHz)  [clk_mipi, clk_mipi_0,90,180,270]
//

wire clk_master_50, clk_mipi_0, clk_mipi_90, clk_mipi_180, clk_mipi_270, pll_locked;

design_1 (
    .FCLK_CLK0(clk_master_50)
);

clk_wiz_0 (
    .clk_out1_0(clk_mipi_0),
    .clk_out1_90(clk_mipi_90), // unused
    .clk_out1_180(clk_mipi_180),
    .clk_out1_270(clk_mipi_270),
    //.reset(0),
    .power_down(0),
    .locked(pll_locked),
    .clk_in1(clk_master_50)
);

parameter STATE_FRAME_START = 10;                   // Send start-of-frame packet
parameter STATE_FRAME_START_BUSY_WAIT = 20;         // Wait for start-of-frame packet to complete
parameter STATE_FRAME_START_IDLE = 30;              // Idle period after start-of-frame packet 
parameter STATE_FRAME_DATA_LINE_PREP = 35;          // Prepare to send data lines
parameter STATE_FRAME_DATA_LINE = 40;               // Send data line
parameter STATE_FRAME_DATA_LINE_BUSY_WAIT = 50;     // Wait for data line packet to complete
parameter STATE_FRAME_END = 60;                     // Send end-of-frame packet
parameter STATE_FRAME_END_BUSY_WAIT = 70;           // Wait for end-of-frame packet to complete
parameter STATE_FRAME_END_IDLE_PREP = 75;           // Prepare for end-of-frame idle period
parameter STATE_FRAME_END_IDLE = 80;                // Idle period after end-of-frame and before next reset of state machine

// LFSR noise height for sine wave, must be power of two
parameter NOISE_HEIGHT = 16;

// MIPI CSI controller
reg [15:0] mipi_tx_size;
reg mipi_long_packet;
reg mipi_short_packet;
reg mipi_idle_packet;
wire mipi_done_status;
wire mipi_busy_status;
wire mipi_error_status;
wire [3:0] mipi_debug;
wire mipi_mem_read_clk;
wire mipi_mem_read_en;
wire [11:0] mipi_mem_addr;
//wire [15:0] mipi_mem_data;
wire clk_mipi_ref;
wire [7:0] mipi_test_word;

reg [1:0] mipi_vc_id = 0;
reg [5:0] mipi_dt_id = 0;
reg [15:0] mipi_wct_short = 0;

// Test counters for test pattern generation
reg [31:0] counter;
reg [31:0] counter2;

reg [15:0] mem_test_data = 16'hf0f0;
reg [15:0] mem_test_reg = 1;

// *** testing ***
reg [15:0] data_lines;
reg [15:0] frame = 1;
reg [15:0] xcoord;

reg [11:0] sine_addr;
wire [15:0] sine_data; 
reg [31:0] sine_scale_reg;
reg [15:0] sine_scale;

wire [15:0] mipi_bytes_output;

mipi_csi (
    // master clock references
    .mod_clk_I(clk_mipi_0),
    .mod_clk_Q(clk_mipi_90),
    
    // clock output - used to clock some logic
    .clk_out(clk_mipi_ref),
    
    // test word
    .test_word(mipi_test_word),
    
    // state interface
    .init_short_packet(mipi_short_packet),
    .init_long_packet(mipi_long_packet),
    .init_idle(mipi_idle_packet),
    .sleep_mode(0),
    .tx_size(mipi_tx_size),
    .done(mipi_done_status),
    .busy(mipi_busy_status),
    .error(mipi_error_status),
    .debug(mipi_debug),
    
    // Clock gating: 
    //  1 - clock stops during idle periods
    //  0 - clock continues after initialisation period indefinitely
    //
    // Note that '1' seems to break the Pi's communication interface - further work required on this
    .clock_gate_en(0),
    
    // BlockRAM memory interface
    .mem_read_clk(mipi_mem_read_clk),
    .mem_read_en(mipi_mem_read_en),
    .mem_addr(mipi_mem_addr),
    .mem_data(mem_test_data), 
    .bytes_output(mipi_bytes_output),
    
    // Virtual channel ID, for debugging attach to s7/s6
    .vc_id(mipi_vc_id),
    
    // Other packet header parameters
    .dt_id(mipi_dt_id),
    .wct_short(mipi_wct_short),
    
    // Interface to outside world
    .csi_clkp(csi_clk_p),
    .csi_clkn(csi_clk_n),
    .csi_dp0(csi_d0_p),
    .csi_dn0(csi_d0_n),
    .csi_dp1(csi_d1_p),
    .csi_dn1(csi_d1_n),
    .csi_dp0_lp_lat(csi_lpd0_p),
    .csi_dn0_lp_lat(csi_lpd0_n),
    .csi_dp1_lp_lat(csi_lpd1_p),
    .csi_dn1_lp_lat(csi_lpd1_n),
    .csi_clkp_lp_lat(csi_lpclk_p),
    .csi_clkn_lp_lat(csi_lpclk_n)
);

// BlockRAM interface for sample data buffer
blk_mem_gen_0 blk_mem_gen_0_x (
    .clka(clk_mipi_ref),
    .ena(1),
    .addra(sine_addr),
    .douta(sine_data)
);

reg status_led;

// main state machine state
parameter STATE_IDLE = 1;
parameter STATE_INIT_MIPI = 2;
parameter STATE_SEND_PACKET = 3;
reg test0, test1;

reg [7:0] cam_state = STATE_FRAME_START;
reg [23:0] cam_start_idle_counter = 16'h0100;
reg [23:0] cam_end_idle_counter = 16'h8000;

reg [15:0] sine_addr_offs;

reg [23:0] sent_lines;

// based off https://www.nandland.com/vhdl/modules/lfsr-linear-feedback-shift-register.html
reg xor_lfsr;
reg [32:1] reg_lfsr = 0;
reg [32:1] val_lfsr = 0;

reg [31:0] prng_base = 0;
reg [31:0] prng_squared = 0;
integer prng_signed = 0;

integer sine_scale_int = 0;

// blinkenled
reg [22:0] blinky_ctr;
reg blinky_led = 1;

assign led_PL0 = blinky_led;

always @(posedge clk_mipi_ref) begin

    if (blinky_ctr == 0) begin
        blinky_led <= ~blinky_led;
    end
    
    blinky_ctr <= blinky_ctr + 1;

    case (cam_state) 
    
        // start of frame - 00h with frame counter (typically)
        STATE_FRAME_START: begin
            // Virtual Channel 0 with Frame Start Code 0x00
            mipi_vc_id <= 0;            
            mipi_dt_id <= 6'h00;        
            
            // Frame counter (can be zero), TX size also zero
            mipi_wct_short <= frame;    
            mipi_tx_size <= 0;      
                
            // Preload lines counter, set short packet flag
            mipi_short_packet <= 1;   
            mipi_long_packet <= 0;   
            mipi_idle_packet <= 0;
            
            // Advance to waiting state
            cam_state <= STATE_FRAME_START_BUSY_WAIT;  
            
            // Increment frame counter
            frame <= frame + 1;
        end
        
        // wait for start of frame short packet to complete
        STATE_FRAME_START_BUSY_WAIT: begin
            if (!mipi_busy_status) begin
                // Move to STATE_FRAME_START_IDLE state with idle counter loaded
                cam_state <= STATE_FRAME_START_IDLE;
                cam_start_idle_counter <= 16'h0200;
            end
        end
                    
        STATE_FRAME_START_IDLE: begin
            mipi_long_packet <= 0;
            mipi_short_packet <= 0;
            mipi_idle_packet <= 1;
            
            //am_state <= STATE_FRAME_DATA_LINE;
            //data_lines <= 10;
                            
            // Pause of "N" clocks before sending data
            if (cam_start_idle_counter == 0) begin      
                // Move to LINE prpe tx state, with loaded line counter
                cam_state <= STATE_FRAME_DATA_LINE_PREP;
                
                // Clear idle packet flag.  Lanes stay idle till next packet sent.
                mipi_idle_packet <= 0;  
                
                // Load line counter
                data_lines <= 256; // 2048;
            end else begin
                cam_start_idle_counter = cam_start_idle_counter - 1;
                cam_state <= STATE_FRAME_START_IDLE; // almost certainly redundant
            end
        end
    
        // prepares for data lines transmission
        // RAW10 with WC representing bytes to be sent
        // immediately advances to STATE_FRAME_DATA_LINE state
        STATE_FRAME_DATA_LINE_PREP: begin
            // Virtual Channel 0 and RAW10 format 0x2b
            mipi_vc_id <= 0;            
            mipi_dt_id <= 6'h2a; // RAW8      
            
            // Jump state
            cam_state <= STATE_FRAME_DATA_LINE;
        end
        
        // start of data line
        // this transitions to STATE_FRAME_DATA_LINE_BUSY_WAIT while the packet
        // is being transferred
        STATE_FRAME_DATA_LINE: begin    
            // Wordcount - representing bytes to be sent after PH and before PF
            // Transmission size is identical to wordcount.
            //
            // The tx size must be in blocks of 2 bytes as the module works on 16-bit packets,
            // to reduce input clock rates.  FIXME:  Data length transmitted seems to be wrong?
            //mipi_wct_short <= 16'h0800; 
            //mipi_tx_size <= 16'h0800; 
            //mipi_wct_short <= 16'b1010101010101010; 
            mipi_wct_short <= 2048; // 3240 typically.  this sets us to 2456 real pixels width.
            mipi_tx_size <= 2048; 
                    
            // Set flag for long packet
            mipi_short_packet <= 0;   
            mipi_long_packet <= 1;   
                            
            // Jump to STATE_FRAME_DATA_LINE_BUSY_WAIT state.   This state will jump back here
            // if a packet is complete.
            cam_state <= STATE_FRAME_DATA_LINE_BUSY_WAIT;
        end
        
        // Busy wait for the high speed transmission to complete.
        // 
        // Wait for busy flag to clear then count down line counter
        // When line counter hits zero transition out of this state into
        // end of frame state
        STATE_FRAME_DATA_LINE_BUSY_WAIT: begin      
            if (!mipi_busy_status) begin
                data_lines <= data_lines - 1;
                sent_lines <= sent_lines + 1;
                if (data_lines == 0) begin
                    cam_state <= STATE_FRAME_END;
                    mipi_long_packet <= 0; // terminate xfer
                end else begin
                    cam_state <= STATE_FRAME_DATA_LINE;
                    mipi_long_packet <= 0; // restart xfer
                end
            end
        end
        
        // End of frame state; set up EOF packet then transition
        // to busy-wait state
        STATE_FRAME_END: begin
            // Virtual Channel 0 with Frame End Code 0x01
            mipi_vc_id <= 0;            
            mipi_dt_id <= 6'h01;        
            
            // Frame counter (can be zero), TX size also zero
            mipi_wct_short <= frame;    
            mipi_tx_size <= 0;
            
            mipi_long_packet <= 0;
            mipi_short_packet <= 1;
            cam_state <= STATE_FRAME_END_BUSY_WAIT;
        end
        
        // Busy wait for EOF packet to be sent
        // This transitions to the idle state upon exit.
        STATE_FRAME_END_BUSY_WAIT: begin
            if (!mipi_busy_status) begin
                // Move to IDLE state and reset counter for idle timing
                mipi_short_packet <= 0;
                cam_state <= STATE_FRAME_END_IDLE_PREP;
                
                // Increment frame counter
                frame <= frame + 1;
            end
        end
        
        STATE_FRAME_END_IDLE_PREP: begin
            mipi_long_packet <= 0;
            mipi_short_packet <= 0;
            mipi_idle_packet <= 1;
            cam_end_idle_counter <= 16'h0200;
            cam_state <= STATE_FRAME_END_IDLE;
        end
        
        STATE_FRAME_END_IDLE: begin
            // Pause of "N" clocks before going back to frame start
            if (cam_end_idle_counter == 0) begin      
                cam_state <= STATE_FRAME_START;
            end else begin
                cam_end_idle_counter <= cam_end_idle_counter - 1;
                //cam_state <= STATE_FRAME_END_IDLE; // almost certainly redundant
            end
        end
        
    endcase

    //mem_test_data <= xcoord;
    counter <= counter + 1;
    xcoord <= xcoord + 1;

    /* Test Pattern for Slow AM Sine */
    if (1) begin
        sine_addr <= ((mipi_bytes_output >> 1) + 0) & 2047;
        sine_scale_int <= ((((16'h8000 - sine_data) * ((((data_lines & 255) * 3) >> 2) + 30)) >> 8) * ((frame >> 4) & 255)) >> 8;
        sine_scale_reg <= (((sine_scale_int + 16'h8000) & 16'hff00) >> 8) * 16'h0101;
        //sine_scale_reg <= ((((sine_data * (data_lines & 255)) >> 8) & 16'hff00) >> 8) * 16'h0101;
        mem_test_data <= sine_scale_reg;
    end
            
    /* Test Pattern for Noisy Sine */
    if (0) begin
        sine_addr <= ((mipi_bytes_output >> 1) + 0) & 2047;
        sine_scale_reg <= (((sine_data & 16'hff00) >> 8) >> 1) + 64 + prng_signed; // (NOISE_HEIGHT / 2) - (val_lfsr & (NOISE_HEIGHT - 1));
        //sine_scale_reg <= (sine_scale_reg >> 1) + 128;
        mem_test_data <= sine_scale_reg * 16'h0101;
    end
    
    /* Process LFSR for noise generation function */
    xor_lfsr <= reg_lfsr[32] ^ ~reg_lfsr[22] ^ ~reg_lfsr[2] ^ ~reg_lfsr[1];
    reg_lfsr <= {reg_lfsr[31:1], xor_lfsr};
    val_lfsr <= reg_lfsr;
    
    /* Create squaring function, and bipolar signed integer output */
    if (0) begin
        prng_base <= val_lfsr & (NOISE_HEIGHT - 1);
        prng_squared <= (prng_base * prng_base * NOISE_HEIGHT) / (NOISE_HEIGHT * NOISE_HEIGHT);
        
        if (reg_lfsr[20]) begin
            prng_signed <= prng_squared;
        end else begin
            prng_signed <= -prng_squared;
        end
    end
    
    /* Create random walk function */
    if (0) begin
        /*
        if (reg_lfsr[22]) begin
            prng_signed <= prng_signed + 5;
        end else begin
            prng_signed <= prng_signed - 5;
        end
        */
        
        if (reg_lfsr[20]) begin
            prng_signed <= prng_signed + 1;
        end else begin
            prng_signed <= prng_signed - 1;
        end
        
        if (prng_signed > 8) begin
            prng_signed = 8;
        end else if (prng_signed < -8) begin
            prng_signed = -8;
        end
    end
    
end

endmodule
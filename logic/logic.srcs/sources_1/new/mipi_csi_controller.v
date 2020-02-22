`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module mipi_csi_controller(
    // CSI signals to toplevel
    output csi_clk_p,
    output csi_clk_n,   
    output csi_d0_p, 
    output csi_d0_n,
    output csi_d1_p,  
    output csi_d1_n, 
    output csi_lpd0_n,  
    output csi_lpd0_p, 
    output csi_lpd1_n,
    output csi_lpd1_p,   
    output csi_lpclk_n,
    output csi_lpclk_p,
    
    // Pinswap inputs for CSI bus
    input pn_swap_d0,
    input pn_swap_d1,
    input pn_swap_clk,
    
    // Master CSI clock
    input mod_clk_I,
    input mod_clk_Q,
    
    // General reset
    input g_rst,
    
    // EMIO interface signals (on PS clock domain)
    input em_mipi_sleep,
    input em_mipi_start_lines,
    input em_mipi_start_frame,
    input em_mipi_end_frame,
    input em_mipi_stop,
    output reg em_mipi_done,
    
    // Fabric config interface signals
    input [15:0] R_csi_line_count,              // Number of lines to do before signalling DONE
    input [20:0] R_csi_line_byte_count,         // Wordcount is half this
    input [7:0] R_csi_data_type,                // VC_ID + DT_ID concat
    input [15:0] R_csi_wct_frame,               // Optional wordcount for CSI frames for sequencing
    input R_clk_gating_enable,                  // Clock gating control signal (not currently used) 
    
    // Debug interface
    output [5:0] csi_ctrl_state_dbg,
    
    // BRAM interface
    output mipi_mem_read_clk,
    output mipi_mem_read_en,
    output [15:0] mipi_mem_addr,
    input [15:0] mipi_mem_data
);

parameter CSICTRL_STATE_NOT_STARTED = 0;        // Everything idle (possibly including bus clock)
parameter CSICTRL_STATE_START_FRAME = 1;        // Generating Start-of-Frame sequence
parameter CSICTRL_STATE_START_FRAME_WAIT = 2;   // Waiting for Start-of-Frame to complete
parameter CSICTRL_STATE_WAIT_TO_GEN_LINES = 3;  // Waiting to start line generation (activated by em_mipi_start_lines)
parameter CSICTRL_STATE_OUTPUT_LINE = 4;        // Sending line
parameter CSICTRL_STATE_OUTPUT_LINE_WAIT = 5;   // Waiting for line completion
parameter CSICTRL_STATE_END_FRAME = 6;          // Generating End-of-Frame sequence
parameter CSICTRL_STATE_END_FRAME_WAIT = 7;     // Waiitng for End-of-Frame sequence to complete (returns to CSICTRL_STATE_NOT_STARTED)

wire clk_mipi_ref;
reg mipi_short_packet, mipi_long_packet, mipi_idle_packet;
reg [5:0] csi_ctrl_state = CSICTRL_STATE_NOT_STARTED;
assign csi_ctrl_state_dbg = csi_ctrl_state;

// Always assigned
wire [1:0] mipi_vc_id;
assign mipi_vc_id = R_csi_data_type[7:6];
wire [5:0] mipi_dt_id_tx;
assign mipi_dt_id_tx = R_csi_data_type[5:0];
reg [5:0] mipi_dt_id;

reg [15:0] mipi_tx_size;
reg [15:0] mipi_wct_short;
reg [15:0] csi_ctrl_bram_base;
reg [7:0] csi_ctrl_num_lines_to_tx;

wire mipi_busy_status, mipi_done_status, mipi_error_status;

wire [15:0] mipi_mem_addr;
assign mipi_mem_addr = mipi_mem_addr_base + csi_ctrl_bram_base;

parameter MIPI_SOF_DT = 6'h00;
parameter MIPI_EOF_DT = 6'h01;

mipi_csi mipi_csi0 (
    // master clock reference
    .mod_clk_I(mod_clk_I),
    .mod_clk_Q(mod_clk_Q),
    
    // clock output - used to clock some logic
    .clk_out(clk_mipi_ref),
    
    // test word
    .test_word(16'h0000),
    
    // pinswap inputs
    .pn_swap_d0(pn_swap_d0),
    .pn_swap_d1(pn_swap_d1),
    .pn_swap_clk(pn_swap_clk),
    
    // state interface
    .init_short_packet(mipi_short_packet),
    .init_long_packet(mipi_long_packet),
    .init_idle(mipi_idle_packet),
    .sleep_mode(0),
    .tx_size(mipi_tx_size),
    .done(mipi_done_status),
    .busy(mipi_busy_status),
    .error(mipi_error_status),
    //.debug(mipi_debug),
    
    // Clock gating: 
    //  1 - clock stops during idle periods
    //  0 - clock continues after initialisation period indefinitely
    //
    // Note that '1' seems to break the Pi's communication interface - further work required on this
    .clock_gate_en(0),
    
    // BlockRAM memory interface
    .mem_read_clk(mipi_mem_read_clk),
    .mem_read_en(mipi_mem_read_en),
    .mem_addr(mipi_mem_addr_base),           // MIPI peripheral request address, offset by this fabric
    .mem_data(mipi_mem_data),
    
    // Virtual channel ID
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

always @(posedge clk_mipi_ref) begin

    if (g_rst) begin
        csi_ctrl_state <= CSICTRL_STATE_NOT_STARTED;
    end

    case (csi_ctrl_state) 
    
        CSICTRL_STATE_NOT_STARTED : begin
            // Advance to SoF if em_mipi_start_frame goes active
            if (em_mipi_start_frame) begin
                csi_ctrl_state <= CSICTRL_STATE_START_FRAME;
            end
        end
        
        CSICTRL_STATE_START_FRAME : begin
            // Generate SoF frame on MIPI controller
            mipi_dt_id <= MIPI_SOF_DT;
            mipi_wct_short <= R_csi_wct_frame;
            mipi_tx_size <= 0;
            mipi_short_packet <= 1; 
            mipi_long_packet <= 0; 
            mipi_idle_packet <= 0;
            csi_ctrl_state <= CSICTRL_STATE_START_FRAME_WAIT;
        end
        
        CSICTRL_STATE_START_FRAME_WAIT : begin
            if (!mipi_busy_status) begin
                csi_ctrl_state <= CSICTRL_STATE_WAIT_TO_GEN_LINES; // TODO: Need to add pause here possibly?  Implied by PS control...?
                em_mipi_done <= 1;
            end
        end
        
        CSICTRL_STATE_WAIT_TO_GEN_LINES : begin
            if (em_mipi_start_lines) begin
                em_mipi_done <= 0;
                csi_ctrl_num_lines_to_tx <= R_csi_line_count;
                csi_ctrl_bram_base <= 0;
                mipi_short_packet <= 0; 
                csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE;
            end
            
            if (em_mipi_end_frame) begin
                csi_ctrl_state <= CSICTRL_STATE_END_FRAME;
            end
        end
        
        CSICTRL_STATE_OUTPUT_LINE : begin
            mipi_wct_short <= (R_csi_line_byte_count >> 1);
            mipi_tx_size <= mipi_wct_short;
            mipi_long_packet <= 1;
            csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE_WAIT;
        end
        
        CSICTRL_STATE_OUTPUT_LINE_WAIT : begin
            if (!mipi_busy_status) begin
                csi_ctrl_num_lines_to_tx <= csi_ctrl_num_lines_to_tx - 1;
                
                if (csi_ctrl_num_lines_to_tx == 0) begin
                    // TODO: should we latch R_csi_line_byte_count into a reg to ensure changes to this value on the fly
                    // (which are not permitted, mind) do not cause odd behaviours?
                    csi_ctrl_bram_base <= csi_ctrl_bram_base + (R_csi_line_byte_count >> 1);
                    csi_ctrl_state <= CSICTRL_STATE_WAIT_TO_GEN_LINES;
                end else begin
                    // TODO: Inter-line pause may be needed
                    csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE;
                end
            end
        end
        
        CSICTRL_STATE_END_FRAME : begin
            // Generate EoF frame on MIPI controller
            mipi_dt_id <= MIPI_EOF_DT;
            mipi_wct_short <= R_csi_wct_frame;
            mipi_tx_size <= 0;
            mipi_short_packet <= 1; 
            mipi_long_packet <= 0; 
            mipi_idle_packet <= 0;
            csi_ctrl_state <= CSICTRL_STATE_END_FRAME_WAIT;
        end
        
        CSICTRL_STATE_END_FRAME_WAIT : begin
            if (!mipi_busy_status) begin
                csi_ctrl_state <= CSICTRL_STATE_NOT_STARTED; 
                em_mipi_done <= 1;
            end
        end
        
    endcase

end

endmodule

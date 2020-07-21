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
    output reg em_mipi_running,
    
    // Fabric config interface signals
    input [15:0] R_csi_line_count,              // Number of lines to do before signalling DONE
    input [15:0] R_csi_line_byte_count,         // Wordcount is half this
    input [7:0] R_csi_data_type,                // VC_ID + DT_ID concat
    input [15:0] R_csi_wct_frame,               // Optional wordcount for CSI frames for sequencing
    input R_clk_gating_enable,                  // Clock gating control signal (not currently used) 
    
    // Debug interface
    output [5:0] csi_ctrl_state_dbg,
    output csi_mipi_busy_dbg,
    output csi_mipi_done_dbg,
    output csi_mipi_init_short_dbg,
    output csi_mipi_init_long_dbg,
    output csi_mipi_init_idle_dbg,
    output [15:0] csi_debug_tx_size,
    output [5:0] csi_debug_mipi_state,
    output [15:0] csi_debug_state_timer,
    output [15:0] csi_debug_state_timer2,
    output csi_debug_state_timer_rst,
    output [15:0] csi_debug_data_mux_out,
    output [5:0] csi_debug_ctrl_bram_base,
    output [1:0] csi_debug_lp_state,
    output [2:0] csi_debug_lpclk_state,
    output [15:0] csi_debug_num_lines_rem,
    
    // Clock debug output
    output clk_mipi_ref_dbg,
    
    // BRAM interface
    output mipi_fifo_clk,
    output mipi_fifo_read_req,
    input mipi_fifo_read_avail,
    input [15:0] mipi_fifo_data                 // 16-bit wide FIFO interface
);

parameter CSICTRL_STATE_NOT_STARTED = 0;        // Everything idle (possibly including bus clock)
parameter CSICTRL_STATE_START_FRAME = 1;        // Generating Start-of-Frame sequence
parameter CSICTRL_STATE_START_FRAME_WAIT = 2;   // Waiting for Start-of-Frame to complete
parameter CSICTRL_STATE_WAIT_TO_GEN_LINES = 3;  // Waiting to start line generation (activated by em_mipi_start_lines)
parameter CSICTRL_STATE_OUTPUT_LINE_PRE = 4;    // Prepare to send line (init registers)
parameter CSICTRL_STATE_OUTPUT_LINE = 5;        // Sending line
parameter CSICTRL_STATE_OUTPUT_LINE_WAIT = 6;   // Waiting for line completion
parameter CSICTRL_STATE_END_FRAME = 7;          // Generating End-of-Frame sequence
parameter CSICTRL_STATE_END_FRAME_WAIT = 8;     // Waiitng for End-of-Frame sequence to complete (returns to CSICTRL_STATE_NOT_STARTED)

wire clk_mipi_ref;
reg mipi_short_packet, mipi_long_packet, mipi_idle_packet;
reg [5:0] csi_ctrl_state = CSICTRL_STATE_NOT_STARTED;
assign csi_ctrl_state_dbg = csi_ctrl_state;

// Always assigned
wire [1:0] mipi_vc_id_regd;
assign mipi_vc_id = R_csi_data_type_regd[7:6];
wire [5:0] mipi_dt_id_regd;
assign mipi_dt_id_regd = R_csi_data_type_regd[5:0];
reg [5:0] mipi_dt_id_tx;

reg [15:0] mipi_tx_size;
reg [15:0] mipi_wct_short;
reg [5:0] csi_ctrl_bram_base_reg = 0;
reg [15:0] csi_ctrl_num_lines_to_tx;

wire mipi_busy_status, mipi_done_status, mipi_error_status;
wire [15:0] csi_debug_tx_size;
wire [15:0] csi_debug_state_timer, csi_debug_state_timer2;
wire csi_debug_state_timer_rst;

/*
// BRAM memory address is half the requested address with LSB used to mux between pairs of 16-bit words
wire [11:0] mipi_mem_addr_req;
wire [13:0] mipi_mem_addr_req_scaled;
assign mipi_mem_addr_req_scaled = (mipi_mem_addr_req >> 1) * 4;
wire [17:0] mipi_mem_addr;
assign mipi_mem_addr = {4'b0000, csi_ctrl_bram_base_reg[5:0], mipi_mem_addr_req_scaled[10:0]};
wire [5:0] csi_debug_ctrl_bram_base;
assign csi_debug_ctrl_bram_base = csi_ctrl_bram_base_reg[5:0];

// 32-bit data from main memory is demuxed into two 16-bit reads using a continuous assign
// the reason is this keeps the BRAM at dual 32-bit ports, which keeps the Xilinx blockdesign happy as
// we're using a 32-bit AXI interface to this BRAM.
wire [15:0] mipi_mem_data_mux;
assign mipi_mem_data_mux = (!mipi_mem_addr_req[0]) ? (mipi_mem_data[15:0]) : (mipi_mem_data[31:16]);
*/

// Debug data path: to be eliminated
wire [15:0] csi_debug_data_mux_out;
assign csi_debug_data_mux_out = mipi_fifo_data;

assign clk_mipi_ref_dbg = clk_mipi_ref;
assign csi_mipi_busy_dbg = mipi_busy_status;
assign csi_mipi_init_short_dbg = mipi_short_packet;
assign csi_mipi_init_long_dbg = mipi_long_packet;
assign csi_mipi_init_idle_dbg = mipi_idle_packet;

reg last_start_lines;

parameter MIPI_SOF_DT = 6'h00;
parameter MIPI_EOF_DT = 6'h01;

mipi_csi mipi_csi0 (
    // master clock reference
    .mod_clk_I_in(mod_clk_I),
    .mod_clk_Q_in(mod_clk_Q),
    
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
    .debug_tx_size(csi_debug_tx_size),
    .debug_mipi_state(csi_debug_mipi_state),
    .debug_state_timer(csi_debug_state_timer),
    .debug_state_timer2(csi_debug_state_timer2),
    .debug_state_timer_rst(csi_debug_state_timer_rst),
    .debug_lp_state(csi_debug_lp_state),
    .debug_lpclk_state(csi_debug_lpclk_state),
    
    //.debug(mipi_debug),
    
    // Clock gating: 
    //  1 - clock stops during idle periods
    //  0 - clock continues after initialisation period indefinitely
    //
    // Note that '1' seems to break the Pi's communication interface - further work required on this
    .clock_gate_en(R_clk_gating_enable_regd),
    
    // BlockRAM memory interface
    .mem_read_clk(mipi_fifo_clk),
    .mem_read_en(mipi_fifo_read_req),
    //.mem_addr(mipi_mem_addr_req),           // Request address, not used (FIFO streams data)
    .mem_data(mipi_fifo_data),
    
    // Virtual channel ID
    .vc_id(mipi_vc_id_regd),
    
    // Other packet header parameters
    .dt_id(mipi_dt_id_tx),
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

reg em_mipi_start_lines_regd = 0;
reg em_mipi_start_frame_regd = 0;
reg em_mipi_end_frame_regd = 0;
reg em_mipi_stop_regd = 0;

reg [7:0] R_csi_data_type_regd;
reg [5:0] R_csi_line_count_regd;
reg [15:0] R_csi_line_byte_count_regd;
reg [15:0] R_csi_wct_frame_regd;
reg R_clk_gating_enable_regd;

wire [15:0] csi_debug_num_lines_rem;
assign csi_debug_num_lines_rem = csi_ctrl_num_lines_to_tx;

always @(posedge clk_mipi_ref) begin

    // Register all inputs against clock.  Avoids metastability issue(s) when 
    // crossing from PS to PL clock domains.
    last_start_lines <= em_mipi_start_lines_regd;
    em_mipi_start_lines_regd <= em_mipi_start_lines;
    em_mipi_start_frame_regd <= em_mipi_start_frame;
    em_mipi_end_frame_regd <= em_mipi_end_frame;
    em_mipi_stop_regd <= em_mipi_stop;
    
    // Register combinational inputs against clock as well (these are registered
    // in the fabric controller but that runs at a distinct clock.)
    R_csi_data_type_regd <= R_csi_data_type;
    R_csi_line_count_regd <= R_csi_line_count;
    R_csi_line_byte_count_regd <= R_csi_line_byte_count;
    R_csi_wct_frame_regd <= R_csi_wct_frame;
    R_clk_gating_enable_regd <= R_clk_gating_enable;
    
    // External reset signal asserted forces start back to NOT_STARTED; CSI will
    // also reset at the same time so no need to wait for busy, etc.
    if (g_rst) begin
        csi_ctrl_state <= CSICTRL_STATE_NOT_STARTED;
    end

    case (csi_ctrl_state) 
    
        CSICTRL_STATE_NOT_STARTED : begin
            em_mipi_running <= 0;
            
            // Send IDLE signal if clock gating enabled
            if (R_clk_gating_enable) begin
                mipi_idle_packet <= 1;
            end
        
            // Advance to SoF if em_mipi_start_frame goes active
            if (em_mipi_start_frame_regd) begin
                mipi_idle_packet <= 0;
                em_mipi_done <= 0;
                csi_ctrl_state <= CSICTRL_STATE_START_FRAME;
            end
        end
        
        CSICTRL_STATE_START_FRAME : begin
            // Generate SoF frame on MIPI controller
            em_mipi_running <= 1;
            mipi_dt_id_tx <= MIPI_SOF_DT;
            mipi_wct_short <= R_csi_wct_frame;
            mipi_tx_size <= 0;
            mipi_short_packet <= 1; 
            mipi_long_packet <= 0; 
            mipi_idle_packet <= 0;
            
            // Wait for BUSY to assert to advance state machine;  this gives the MIPI engine
            // time to get its state ready
            if (mipi_busy_status) begin
                csi_ctrl_state <= CSICTRL_STATE_START_FRAME_WAIT;
            end
        end
        
        CSICTRL_STATE_START_FRAME_WAIT : begin
            mipi_short_packet <= 0; 
            
            if (!mipi_busy_status) begin
                csi_ctrl_state <= CSICTRL_STATE_WAIT_TO_GEN_LINES; // TODO: Need to add pause here possibly?  Implied by PS control...?
                em_mipi_done <= 1;
            end
        end
        
        CSICTRL_STATE_WAIT_TO_GEN_LINES : begin
            // Send idle packet if waiting to generate lines and clock gating is enabled
            if (R_clk_gating_enable) begin
                mipi_idle_packet <= 1;
            end
                
            // go back to idle state if we receive stop command
            if (em_mipi_stop_regd) begin
                em_mipi_done <= 0;
                csi_ctrl_state <= CSICTRL_STATE_NOT_STARTED;
            end
            
            // look for rising edge of start_lines signal
            if (em_mipi_start_lines_regd && !last_start_lines) begin
                mipi_idle_packet <= 0;
                em_mipi_done <= 0;
                csi_ctrl_num_lines_to_tx <= R_csi_line_count;
                csi_ctrl_bram_base_reg <= 0;
                csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE_PRE;
            end
            
            if (em_mipi_end_frame_regd) begin
                mipi_idle_packet <= 0;
                em_mipi_done <= 0;
                csi_ctrl_state <= CSICTRL_STATE_END_FRAME;
            end
        end
        
        CSICTRL_STATE_OUTPUT_LINE_PRE : begin
            // Prepare to send a new line by loading registers.  Adds the required extra clock
            // signal to make these registrable by the MIPI controller logic (possible bug).
            mipi_dt_id_tx <= mipi_dt_id_regd;
            mipi_wct_short <= R_csi_line_byte_count_regd << 1; 
            mipi_tx_size <= R_csi_line_byte_count_regd & 16'hfffe;  // Clear last bit ensuring even value
            
            csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE;
        end
        
        CSICTRL_STATE_OUTPUT_LINE : begin
            // We hold off here until mipi_fifo_read_avail indicates that data is ready in the FIFO,
            // allowing us to advance.
            if (mipi_fifo_read_avail) begin
                mipi_long_packet <= 1;
                
                // Wait for BUSY to assert to advance state machine;  this gives the MIPI engine
                // time to get its state ready
                if (mipi_busy_status) begin
                    csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE_WAIT;
                end
            end
        end
        
        CSICTRL_STATE_OUTPUT_LINE_WAIT : begin
            mipi_long_packet <= 0; 
            
            if (!mipi_busy_status) begin
                // go back to idle state if we receive stop command
                if (em_mipi_stop_regd) begin
                    csi_ctrl_state <= CSICTRL_STATE_NOT_STARTED;
                    em_mipi_done <= 0;
                end else begin
                    csi_ctrl_num_lines_to_tx <= csi_ctrl_num_lines_to_tx - 1;
                    
                    if (csi_ctrl_num_lines_to_tx == 0) begin
                        // TODO: should we latch R_csi_line_byte_count into a reg to ensure changes to this value on the fly
                        // (which are not permitted, mind) do not cause odd behaviours?
                        csi_ctrl_state <= CSICTRL_STATE_WAIT_TO_GEN_LINES;
                        em_mipi_done <= 1;
                    end else begin
                        // TODO: Inter-line pause may be needed.  Nominally it would go here.
                        csi_ctrl_state <= CSICTRL_STATE_OUTPUT_LINE;
                        csi_ctrl_bram_base_reg <= csi_ctrl_bram_base_reg + 1;
                    end
                end
            end
        end
        
        CSICTRL_STATE_END_FRAME : begin
            // Generate EoF frame on MIPI controller
            mipi_dt_id_tx <= MIPI_EOF_DT;
            mipi_wct_short <= R_csi_wct_frame;
            mipi_tx_size <= 0;
            mipi_short_packet <= 1; 
            mipi_long_packet <= 0; 
            mipi_idle_packet <= 0;
            
            if (mipi_busy_status) begin
                csi_ctrl_state <= CSICTRL_STATE_END_FRAME_WAIT;
            end
        end
        
        CSICTRL_STATE_END_FRAME_WAIT : begin
            mipi_short_packet <= 0;
            
            if (!mipi_busy_status) begin
                csi_ctrl_state <= CSICTRL_STATE_NOT_STARTED; 
                em_mipi_done <= 1;
            end
        end
        
    endcase

end

endmodule

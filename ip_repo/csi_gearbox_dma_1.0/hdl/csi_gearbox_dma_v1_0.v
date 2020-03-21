
`timescale 1 ns / 1 ps

module csi_gearbox_dma_v1_0 #
(
    // Parameters of Axi Slave Bus Interface S00_AXIS
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
    
    // User parameters
    parameter integer C_PN_SWAP_D0              = 1,
    parameter integer C_PN_SWAP_D1              = 1,
    parameter integer C_PN_SWAP_CLK             = 1
)
(
    // CSI output port
    output csi_clk_p, csi_clk_n,
    output csi_d0_p, csi_d0_n,
    output csi_d1_p, csi_d1_n,
    output csi_lpd0_p, csi_lpd0_n,
    output csi_lpd1_p, csi_lpd1_n,
    output csi_lpclk_p, csi_lpclk_n,
    
    // MIPI input clocks
    input mod_clk_I,
    input mod_clk_Q,
    
    // EMIO interface port
    input csi_sleep,
    input csi_start_lines,
    input csi_start_frame,
    input csi_end_frame,
    input csi_stop,
    output csi_done,
    
    // Register interface
    input [15:0] R_csi_line_count,
    input [20:0] R_csi_line_byte_count,
    input [7:0] R_csi_data_type,
    input [15:0] R_csi_wct_frame,
    input [15:0] R_csi_control_flags,
    
    // Debug interface (optional)
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
    output csi_debug_fifo_read_valid,
    output csi_debug_fifo_space_available,
    output csi_debug_mipi_read_req,
    output [11:0] dbg_fifo_data_ct,
    output dbg_ref_clk,
        
    // Global reset (might be deprecated in future release as AXI reset serves similar purpose,
    // although this is an independent reset signal)
    input g_rst,
    
    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface S00_AXIS
    input wire  s00_axis_aclk,
    input wire  s00_axis_aresetn,
    output wire  s00_axis_tready,
    input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
    input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
    input wire  s00_axis_tlast,
    input wire  s00_axis_tvalid
);

parameter FIFO_DATA_LOW         = 3072;                 // Threshold to pack more data into FIFO
parameter FIFO_DATA_LOW_UNLAT   = FIFO_DATA_LOW + 128;  // Threshold to stop packing data into FIFO
parameter FIFO_DATA_MIPI_VALID  = 2048;                 // Should equal chosen MIPI line size

// Debug output signals generated from within this module
wire csi_debug_fifo_space_available, csi_debug_fifo_read_valid, csi_debug_mipi_read_req;

// Read busy/write busy reset signals.  If either is asserted, reading and writing is impossible.
wire fifo_wr_rst_busy, fifo_rd_rst_busy;

// Counter refers to the number of readable words.  This should be >2048 to initiate a read.
wire [11:0] fifo_data_count;
assign dbg_fifo_data_ct = fifo_data_count;

// TReady is driven when not more than 3072 words are present in the output FIFO.
// Hysteretic behaviour: it toggles off only when 128 additional words are present, to avoid
// making small and inefficient transfers.
reg fifo_space_available = 0;

always @(posedge s00_axis_aclk) begin
    if (fifo_data_count < 3072) begin
        fifo_space_available <= 1;
    end else if (fifo_data_count > (3072 + 128)) begin
        fifo_space_available <= 0;
    end
end

assign s00_axis_tready = s00_axis_tvalid && fifo_space_available;
assign csi_debug_fifo_space_available = fifo_space_available;

// Output read valid signal indicating that a read is possible (at least 2048 words available)
wire mipi_fifo_read_valid = (fifo_data_count > FIFO_DATA_MIPI_VALID);
assign csi_debug_fifo_read_valid = mipi_fifo_read_valid;

// All bytes reversed and alternate bytes swapped to correct endianness
wire [63:0] din_reverse;
assign din_reverse[ 7: 0] = s00_axis_tdata[55:48];
assign din_reverse[15: 8] = s00_axis_tdata[63:56];
assign din_reverse[23:16] = s00_axis_tdata[39:32];
assign din_reverse[31:24] = s00_axis_tdata[47:40];
assign din_reverse[39:32] = s00_axis_tdata[23:16];
assign din_reverse[47:40] = s00_axis_tdata[31:24]; 
assign din_reverse[55:48] = s00_axis_tdata[ 7: 0];
assign din_reverse[63:56] = s00_axis_tdata[15: 8];

wire [15:0] mipi_fifo_data;
wire mipi_fifo_clk;
wire mipi_fifo_read_req;
assign csi_debug_mipi_read_req = mipi_fifo_read_req;

fifo_generator_csi_gearbox (
    .din(din_reverse),
    .wr_en(fifo_space_available && s00_axis_tvalid),
    .dout(mipi_fifo_data),
    .rd_en(mipi_fifo_read_req /* && mipi_read_valid_int*/),
    .rst(~s00_axis_aresetn),
    .wr_clk(s00_axis_aclk),
    .rd_clk(mipi_fifo_clk),
    .rd_data_count(fifo_data_count),
    .rd_rst_busy(fifo_rd_rst_busy),
    .wr_rst_busy(fifo_wr_rst_busy)
);

assign dbg_ref_clk = mipi_fifo_clk;

/*
 * MIPI CSI Controller
 */
mipi_csi_controller (
    // CSI signals to toplevel
    .csi_clk_p(csi_clk_p),
    .csi_clk_n(csi_clk_n),
    .csi_d0_p(csi_d0_p),
    .csi_d0_n(csi_d0_n), 
    .csi_d1_p(csi_d1_p),
    .csi_d1_n(csi_d1_n), 
    .csi_lpd0_n(csi_lpd0_n),
    .csi_lpd0_p(csi_lpd0_p),
    .csi_lpd1_n(csi_lpd1_n),
    .csi_lpd1_p(csi_lpd1_p),
    .csi_lpclk_n(csi_lpclk_n),
    .csi_lpclk_p(csi_lpclk_p),
    
    // All P/N pairs swapped on Scopy MVP hardware
    .pn_swap_d0(C_PN_SWAP_D0),
    .pn_swap_d1(C_PN_SWAP_D1),
    .pn_swap_clk(C_PN_SWAP_CLK),
    
    // Master CSI clock
    .mod_clk_I(mod_clk_I),
    .mod_clk_Q(mod_clk_Q),
    
    // General reset
    .g_rst(g_rst),
    
    // EMIO interface signals (on PS clock domain)
    .em_mipi_sleep(csi_sleep),
    .em_mipi_start_lines(csi_start_lines),
    .em_mipi_start_frame(csi_start_frame),
    .em_mipi_end_frame(csi_end_frame),
    .em_mipi_stop(csi_stop),
    .em_mipi_done(csi_done),
    
    // Fabric config interface signals
    .R_csi_line_count(R_csi_line_count),
    .R_csi_line_byte_count(R_csi_line_byte_count),
    .R_csi_data_type(R_csi_data_type),
    .R_csi_wct_frame(R_csi_wct_frame),
    .R_clk_gating_enable(R_csi_control_flags[0]),   // Flag index 0 for clock gating (energy save mode, slight performance impact for segmented transfers.)
    
    .csi_ctrl_state_dbg(csi_ctrl_state_dbg),
    .clk_mipi_ref_dbg(clk_mipi_ref_dbg),
    .csi_mipi_busy_dbg(csi_mipi_busy_dbg),
    .csi_mipi_done_dbg(csi_mipi_done_dbg),
    .csi_mipi_init_short_dbg(csi_mipi_init_short_dbg),
    .csi_mipi_init_long_dbg(csi_mipi_init_long_dbg),
    .csi_mipi_init_idle_dbg(csi_mipi_init_idle_dbg),
    .csi_debug_tx_size(csi_debug_tx_size),
    .csi_debug_mipi_state(csi_debug_mipi_state),
    .csi_debug_state_timer(csi_debug_state_timer),
    .csi_debug_state_timer2(csi_debug_state_timer2),
    .csi_debug_state_timer_rst(csi_debug_state_timer_rst),
    .csi_debug_data_mux_out(csi_debug_data_mux_out),
    .csi_debug_ctrl_bram_base(csi_debug_ctrl_bram_base),
    
    // FIFO interface
    .mipi_fifo_clk(mipi_fifo_clk),
    .mipi_fifo_read_req(mipi_fifo_read_req),
    .mipi_fifo_read_avail(mipi_fifo_read_valid),
    .mipi_fifo_data(mipi_fifo_data)
);


endmodule

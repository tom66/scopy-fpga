
`timescale 1 ns / 1 ps

module csi_gearbox_dma_v1_0 #
(
    // Parameters of Axi Slave Bus Interface S00_AXIS
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 32
)
(
    // Users to add ports here
    input mipi_mx_clk,                  // Scaled MIPI clock (~125MHz for now, but liable to increase to 250MHz)
    input wire mipi_read_req,           // Request to read (active high indicating read desired soon)
    output wire mipi_read_valid,        // Data is ready to be read (at least one line of data is available)
    output [15:0] mipi_data,            // 16-bit data output port
    output [11:0] dbg_fifo_data_ct,     // FIFO data count for diagnostics/debug
    
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
parameter FIFO_DATA_MIPI_VALID  = 2048;                 // Should equal MIPI line size

// Read busy/write busy reset signals.  If either is asserted, reading and writing is impossible.
wire fifo_wr_rst_busy, fifo_rd_rst_busy;

// Counter refers to the number of readable words.  This should be >2048 to initiate a read.
wire [11:0] fifo_data_count;
assign dbg_fifo_data_ct = fifo_data_count;

// TReady is driven when not more than 3072 words are present in the output FIFO.
reg fifo_space_available = 0;

always @(posedge s00_axis_aclk) begin
    if (fifo_data_count < 3072) begin
        fifo_space_available <= 1;
    end else if (fifo_data_count > (3072 + 128)) begin
        fifo_space_available <= 0;
    end
end

assign s00_axis_tready = s00_axis_tvalid && fifo_space_available;

// Output read valid signal indicating that a read is possible (at least 2048 words available)
wire mipi_read_valid_int = (fifo_data_count > FIFO_DATA_MIPI_VALID);
assign mipi_read_valid = mipi_read_valid_int;

// All bytes reversed and alternate bytes swapped
wire [63:0] din_reverse;
assign din_reverse[ 7: 0] = s00_axis_tdata[55:48];
assign din_reverse[15: 8] = s00_axis_tdata[63:56];
assign din_reverse[23:16] = s00_axis_tdata[39:32];
assign din_reverse[31:24] = s00_axis_tdata[47:40];
assign din_reverse[39:32] = s00_axis_tdata[23:16];
assign din_reverse[47:40] = s00_axis_tdata[31:24]; 
assign din_reverse[55:48] = s00_axis_tdata[ 7: 0];
assign din_reverse[63:56] = s00_axis_tdata[15: 8];

fifo_generator_csi_gearbox (
    .din(din_reverse),
    .wr_en(fifo_space_available && s00_axis_tvalid),
    .dout(mipi_data),
    .rd_en(mipi_read_req /* && mipi_read_valid_int*/),
    .rst(~s00_axis_aresetn),
    .wr_clk(s00_axis_aclk),
    .rd_clk(mipi_mx_clk),
    .rd_data_count(fifo_data_count),
    .rd_rst_busy(fifo_rd_rst_busy),
    .wr_rst_busy(fifo_wr_rst_busy)
);

endmodule

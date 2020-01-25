`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2020 09:49:20
// Design Name: 
// Module Name: main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main();

reg adc_clk = 0;
reg adc_frame_clk = 0;
reg [63:0] adc_data = 64'h0000000000000000;

reg adc_valid = 1'b0;
reg adc_fifo_rst = 1'b1;
reg adc_eof = 1'b0;
reg axi_clk = 1'b0;
reg axi_aresetn = 1'b0;

wire [63:0] axi_tdata_out;
reg axi_tready_mux = 1'b0;
reg axi_tready_in;              // TREADY signal from external AXI slave
wire axi_tlast_out;
wire axi_tvalid_out;
wire adc_fifo_full_sig;         // debug signal from FIFO

design_1 adc_block (
    .ADC_BUS(adc_data),
    .ADC_DATA_CLK(adc_frame_clk),
    .ADC_DATA_VALID(adc_valid),
    .ADC_FIFO_RST(adc_fifo_rst),
    .ADC_EOF(adc_eof),
    .AXI_CLK(axi_clk),
    .AXI_ARESETN(axi_aresetn),
    .M00_TREADY(axi_tready_in),
    .M00_TDATA(axi_tdata_out),
    .M00_TLAST(axi_tlast_out),
    .M00_TVALID(axi_tvalid_out),
    .ADC_FIFO_FULL(adc_fifo_full_sig)
);

always #1 adc_clk = ~adc_clk;

always #5 axi_clk = ~axi_clk;
always #8 adc_frame_clk = ~adc_frame_clk;

always @(posedge adc_frame_clk) begin

    adc_data <= adc_data + 1;
    
    if (axi_tvalid_out == 0) begin
        axi_tready_in <= 1'b0;
    end else begin
        axi_tready_in <= axi_tready_mux;
    end

end

initial begin
    // reset states get activated
    #32 axi_aresetn <= 1'b1;
    #32 adc_fifo_rst <= 1'b0;
     
    #64 adc_valid <= 1'b1;
    
    // start with TREADY high
    #80 axi_tready_mux <= 1'b1;
    
    // after 512 clocks (64 transfers) drive TREADY low
    #512 axi_tready_mux <= 1'b0;
    
    // after 560 clocks (70 transfers) drive TREADY high
    #560 axi_tready_mux <= 1'b1;
    
    // after 1024 clocks simulate end of data by driving EOF high
    #1024 adc_eof <= 1'b1;
    
end
 
endmodule


`timescale 1 ns / 1 ps

	module adc_test_streamer_v2_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 64,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
		
		// Connection to ADC/trigger demux block
		input [63:0] adc_bus,
		input adc_data_clk,
        input wire adc_data_valid,
        output wire adc_fifo_full,
        input wire adc_fifo_reset,
        input wire adc_eof,
        output wire [9:0] dbg_rd_data_count,
        output wire [9:0] dbg_wr_data_count,
		
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
// Instantiation of Axi Bus Interface M00_AXIS
	adc_test_streamer_v2_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) adc_test_streamer_v2_0_M00_AXIS_inst (
	    .ADC_BUS(adc_bus),
        .ADC_DATA_CLK(adc_data_clk),
        .ADC_DATA_VALID(adc_data_valid),
        .ADC_FIFO_FULL(adc_fifo_full),
        .ADC_FIFO_RESET(adc_fifo_reset),
        .ADC_EOF(adc_eof),
        .dbg_rd_data_count(dbg_rd_data_count),
        .dbg_wr_data_count(dbg_wr_data_count),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

	// User logic ends

	endmodule

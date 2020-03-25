
`timescale 1 ns / 1 ps

	module FabCfg_NextGen_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 10
	)
	(
	    // General purpose registers
		output [1:0] R_gpio_test,
		
		// Acquisition registers:
		output [28:0] R_acq_size_a,
		output [28:0] R_acq_size_b,
		input [31:0] R_acq_trigger_ptr,
		output [31:0] R_acq_ctrl_a,
		input [31:0] R_acq_status_a,
		input [31:0] R_acq_status_b,
		
		// Trigger registers
		output [31:0] R_trig_level_0,
		output [31:0] R_trig_level_1,
		output [31:0] R_trig_level_2,
		output [31:0] R_trig_level_3,
		output [31:0] R_trig_level_4,
		output [31:0] R_trig_level_5,
		output [31:0] R_trig_level_6,
		output [31:0] R_trig_level_7,
		output [31:0] R_trig_config_a,
		
		// CSI registers:
		output [15:0] R_csi_line_count,
		output [20:0] R_csi_line_byte_count,
		output [7:0] R_csi_data_type,
		output [15:0] R_csi_control_flags,
		
		// Constant inputs for permanent configuration
		input [31:0] K_in_bitstream_version,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	FabCfg_NextGen_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) FabCfg_NextGen_v1_0_S00_AXI_inst (
	    .R_acq_size_a(R_acq_size_a),
	    .R_acq_size_b(R_acq_size_b),
	    .R_acq_trigger_ptr(R_acq_trigger_ptr),
	    .R_acq_ctrl_a(R_acq_ctrl_a),
	    .R_acq_status_a(R_acq_status_a),
	    .R_acq_status_b(R_acq_status_b),
	    
	    .R_trig_level_0(R_trig_level_0),
	    .R_trig_level_1(R_trig_level_1),
	    .R_trig_level_2(R_trig_level_2),
	    .R_trig_level_3(R_trig_level_3),
	    .R_trig_level_4(R_trig_level_4),
	    .R_trig_level_5(R_trig_level_5),
	    .R_trig_level_6(R_trig_level_6),
	    .R_trig_level_7(R_trig_level_7),
	    .R_trig_config_a(R_trig_config_a),
	    
	    .R_gpio_test(R_gpio_test),
	    .R_csi_line_count(R_csi_line_count),
	    .R_csi_line_byte_count(R_csi_line_byte_count),
	    .R_csi_data_type(R_csi_data_type),
	    .R_csi_control_flags(R_csi_control_flags),
	    .K_in_bitstream_version(K_in_bitstream_version),
	    
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule

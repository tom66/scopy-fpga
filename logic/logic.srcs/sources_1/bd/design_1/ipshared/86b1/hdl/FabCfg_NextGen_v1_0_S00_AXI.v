
`timescale 1 ns / 1 ps

	module FabCfg_NextGen_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 10
	)
	(
	    // General purpose registers
	    output [31:0] R_clock_ctrl,
	    output [31:0] R_led_ctrl,
		
		// Acquisition registers:
		output [28:0] R_acq_size_a,
		output [28:0] R_acq_size_b,
		input [31:0] R_acq_trigger_ptr,
		output [31:0] R_acq_ctrl_a,
		input [31:0] R_acq_status_a,
		input [31:0] R_acq_status_b,
		input [31:0] R_acq_status_c,
		output [31:0] R_acq_train_a,
		output [31:0] R_acq_train_b,
		
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
		input [31:0] R_trig_state_a,
		output [31:0] R_trig_holdoff,
		output [31:0] R_trig_auto_timers,
		output [31:0] R_trig_delay_reg0,
		output [31:0] R_trig_delay_reg1,
		input [31:0] R_trig_holdoff_debug,
		
		// CSI registers:
		output [31:0] R_csi_ctrl_a,
		output [31:0] R_csi_ctrl_b,
		output [31:0] R_csi_ctrl_c,
		input [31:0] R_csi_status_a,
		
		// Constant inputs for permanent configuration
		input [31:0] K_in_bitstream_version,
		
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 7;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 256
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg16;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg17;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg18;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg19;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg20;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg21;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg22;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg23;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg24;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg25;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg26;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg27;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg28;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg29;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg30;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg31;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg32;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg33;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg34;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg35;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg36;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg37;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg38;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg39;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg40;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg41;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg42;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg43;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg44;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg45;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg46;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg47;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg48;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg49;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg50;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg51;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg52;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg53;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg54;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg55;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg56;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg57;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg58;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg59;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg60;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg61;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg62;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg63;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg64;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg65;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg66;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg67;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg68;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg69;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg70;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg71;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg72;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg73;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg74;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg75;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg76;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg77;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg78;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg79;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg80;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg81;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg82;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg83;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg84;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg85;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg86;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg87;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg88;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg89;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg90;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg91;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg92;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg93;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg94;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg95;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg96;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg97;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg98;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg99;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg100;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg101;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg102;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg103;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg104;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg105;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg106;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg107;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg108;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg109;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg110;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg111;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg112;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg113;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg114;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg115;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg116;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg117;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg118;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg119;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg120;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg121;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg122;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg123;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg124;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg125;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg126;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg127;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg128;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg129;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg130;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg131;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg132;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg133;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg134;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg135;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg136;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg137;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg138;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg139;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg140;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg141;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg142;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg143;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg144;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg145;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg146;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg147;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg148;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg149;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg150;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg151;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg152;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg153;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg154;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg155;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg156;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg157;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg158;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg159;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg160;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg161;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg162;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg163;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg164;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg165;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg166;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg167;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg168;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg169;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg170;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg171;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg172;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg173;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg174;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg175;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg176;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg177;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg178;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg179;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg180;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg181;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg182;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg183;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg184;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg185;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg186;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg187;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg188;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg189;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg190;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg191;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg192;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg193;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg194;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg195;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg196;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg197;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg198;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg199;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg200;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg201;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg202;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg203;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg204;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg205;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg206;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg207;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg208;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg209;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg210;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg211;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg212;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg213;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg214;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg215;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg216;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg217;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg218;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg219;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg220;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg221;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg222;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg223;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg224;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg225;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg226;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg227;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg228;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg229;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg230;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg231;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg232;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg233;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg234;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg235;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg236;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg237;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg238;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg239;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg240;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg241;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg242;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg243;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg244;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg245;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg246;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg247;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg248;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg249;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg250;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg251;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg252;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg253;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg254;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg255;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;
	
	wire [31:0] K_usraccess_bitstream_id;

    USR_ACCESSE2 (
        .DATA(K_usraccess_bitstream_id)
    );

	// Read only register list: 1 ~ 4, 12
	// Implemented register list: 0 ~ 4, 16 ~ 20, 64 ~ 67 
	// Other registers: read zero and write has no effect.
	
	// Implement "Dummy Register" behaviour where reg1 echoes reg0 data for self-test.
	// Core bank starts from 0x0000
	always @(posedge S_AXI_ACLK) begin
		slv_reg1 <= slv_reg0;
	end
	
	// System control registers 0x0030 ~ 0x0034
	assign R_clock_ctrl             = slv_reg12;
	assign R_led_ctrl               = slv_reg13;
	
	// Acquisition register bank starts from 0x0040
	// Register 0x12 (R_acq_trigger_ptr) is read only; writes are ignored
	assign R_acq_size_a 			= slv_reg16;
	assign R_acq_size_b 			= slv_reg17;
	//assign R_acq_demux_mode 		= slv_reg19; // < Deprecated, to be moved
	assign R_acq_ctrl_a             = slv_reg20;
	assign R_acq_train_a            = slv_reg25;
	assign R_acq_train_b            = slv_reg26;
	
	//assign R_gpio_test 				= slv_reg20;  // < Deprecated, to be moved
	
	always @(posedge S_AXI_ACLK) begin
		slv_reg18 <= R_acq_trigger_ptr;
		slv_reg22 <= R_acq_status_a;
		slv_reg23 <= R_acq_status_b;
		slv_reg24 <= R_acq_status_c;
	end
	
	// Trigger register bank starts from 0x0090
	assign R_trig_level_0           = slv_reg36;
	assign R_trig_level_1           = slv_reg37;
	assign R_trig_level_2           = slv_reg38;
	assign R_trig_level_3           = slv_reg39;
	assign R_trig_level_4           = slv_reg40;
	assign R_trig_level_5           = slv_reg41;
	assign R_trig_level_6           = slv_reg42;
	assign R_trig_level_7           = slv_reg43;
	assign R_trig_config_a          = slv_reg44;
	assign R_trig_holdoff           = slv_reg48;
	assign R_trig_auto_timers       = slv_reg49;
	assign R_trig_delay_reg0        = slv_reg50;
	assign R_trig_delay_reg1        = slv_reg51;
	
	always @(posedge S_AXI_ACLK) begin
		slv_reg46 <= R_trig_state_a;
		slv_reg53 <= R_trig_holdoff_debug;
	end
	
	// CSI register bank starts from 0x0100
	assign R_csi_ctrl_a 		    = slv_reg64;
	assign R_csi_ctrl_b 	        = slv_reg65;
	assign R_csi_ctrl_c 			= slv_reg66;
	
	always @(posedge S_AXI_ACLK) begin
		slv_reg67 <= R_csi_status_a;
	end
	
	// I/O Connections assignments
	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
		  
		  slv_reg12 <= 0;
		  slv_reg13 <= 0;
		  
	      slv_reg16 <= 0;
	      slv_reg17 <= 0;
	      
	      slv_reg19 <= 0;
	      slv_reg20 <= 0;
	      slv_reg25 <= 0;
	      slv_reg26 <= 0;
	      
	      slv_reg36 <= 0;
	      slv_reg37 <= 0;
	      slv_reg38 <= 0;
	      slv_reg39 <= 0;
	      slv_reg40 <= 0;
	      slv_reg41 <= 0;
	      slv_reg42 <= 0;
	      slv_reg43 <= 0;
	      slv_reg44 <= 0;
	      slv_reg48 <= 0;
	      slv_reg49 <= 0;
	      slv_reg50 <= 0;
	      slv_reg51 <= 0;
	      
	      slv_reg64 <= 0;
	      slv_reg65 <= 0;
	      slv_reg66 <= 0;
	    end 
	    
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          8'h00:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	              
	          8'h0c:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg12[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h0d:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg13[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
				  
	          8'h10:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg16[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h11:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg17[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h13:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg19[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h14:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg20[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h19:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg25[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h1a:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg26[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
				  
	          8'h24:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg36[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h25:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg37[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h26:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg38[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h27:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg39[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h28:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg40[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h29:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg41[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h2a:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg42[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h2b:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg43[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h2c:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg44[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h30:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg48[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h31:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg49[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h32:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg50[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h33:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg51[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	              
	          8'h40:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg64[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h41:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg65[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          8'h42:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                slv_reg66[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    
		
	// Implement memory mapped register select and read logic generation
	// Also implements certain constant registers.
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        8'h00   : reg_data_out <= slv_reg0;
	        8'h01   : reg_data_out <= slv_reg1;
	        8'h02   : reg_data_out <= 32'h536d7670;
	        8'h03   : reg_data_out <= K_in_bitstream_version;
	        8'h04   : reg_data_out <= K_usraccess_bitstream_id;
			
	        8'h10   : reg_data_out <= slv_reg16;
	        8'h11   : reg_data_out <= slv_reg17;
	        8'h12   : reg_data_out <= slv_reg18;
	        
	        8'h14   : reg_data_out <= slv_reg20;
	        
	        8'h16   : reg_data_out <= slv_reg22;
	        8'h17   : reg_data_out <= slv_reg23;
	                                            
            8'h19   : reg_data_out <= slv_reg25;
            8'h1a   : reg_data_out <= slv_reg26;

	        8'h24   : reg_data_out <= slv_reg36;
	        8'h25   : reg_data_out <= slv_reg37;
	        8'h26   : reg_data_out <= slv_reg38;
	        8'h27   : reg_data_out <= slv_reg39;
	        8'h28   : reg_data_out <= slv_reg40;
	        8'h29   : reg_data_out <= slv_reg41;
	        8'h2a   : reg_data_out <= slv_reg42;
	        8'h2b   : reg_data_out <= slv_reg43;
	        
	        8'h2c   : reg_data_out <= slv_reg44;
	        
	        8'h2e   : reg_data_out <= slv_reg46;
	        
	        8'h30   : reg_data_out <= slv_reg48;
	        8'h31   : reg_data_out <= slv_reg49;
	        8'h32   : reg_data_out <= slv_reg50;
	        8'h33   : reg_data_out <= slv_reg51;
			
	        8'h35   : reg_data_out <= slv_reg53;
	        
	        8'h40   : reg_data_out <= slv_reg64;
	        8'h41   : reg_data_out <= slv_reg65;
	        8'h42   : reg_data_out <= slv_reg66;
	        8'h43   : reg_data_out <= slv_reg67;
			
	        8'h60   : reg_data_out <= slv_reg96;
	        8'h61   : reg_data_out <= slv_reg97;
	        8'h62   : reg_data_out <= slv_reg98;
			
	        default : reg_data_out <= 32'hXXXXXXXX;  // Output for invalid addresses is undefined/dont-care
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	endmodule

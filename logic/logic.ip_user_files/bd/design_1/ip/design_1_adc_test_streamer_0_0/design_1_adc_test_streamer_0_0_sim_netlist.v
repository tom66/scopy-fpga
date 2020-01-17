// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sun Jan 12 18:07:37 2020
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_adc_test_streamer_0_0/design_1_adc_test_streamer_0_0_sim_netlist.v
// Design      : design_1_adc_test_streamer_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_adc_test_streamer_0_0,adc_test_streamer_v2_0,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "adc_test_streamer_v2_0,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module design_1_adc_test_streamer_0_0
   (m00_axis_tdata,
    m00_axis_tstrb,
    m00_axis_tlast,
    m00_axis_tvalid,
    m00_axis_tready,
    adc_bus,
    m00_axis_aclk,
    m00_axis_aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TDATA" *) output [63:0]m00_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TSTRB" *) output [7:0]m00_axis_tstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TLAST" *) output m00_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TVALID" *) output m00_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_ADC_DATA_CLK, LAYERED_METADATA undef, INSERT_VIP 0" *) input m00_axis_tready;
  input [63:0]adc_bus;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_CLK, ASSOCIATED_BUSIF M00_AXIS, ASSOCIATED_RESET m00_axis_aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_ADC_DATA_CLK, INSERT_VIP 0" *) input m00_axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input m00_axis_aresetn;

  wire \<const0> ;
  wire \<const1> ;
  wire [63:0]adc_bus;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [63:0]m00_axis_tdata;
  wire m00_axis_tready;
  wire m00_axis_tvalid;

  assign m00_axis_tlast = \<const0> ;
  assign m00_axis_tstrb[7] = \<const1> ;
  assign m00_axis_tstrb[6] = \<const1> ;
  assign m00_axis_tstrb[5] = \<const1> ;
  assign m00_axis_tstrb[4] = \<const1> ;
  assign m00_axis_tstrb[3] = \<const1> ;
  assign m00_axis_tstrb[2] = \<const1> ;
  assign m00_axis_tstrb[1] = \<const1> ;
  assign m00_axis_tstrb[0] = \<const1> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0 inst
       (.adc_bus(adc_bus),
        .m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "adc_test_streamer_v2_0" *) 
module design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0
   (m00_axis_tdata,
    m00_axis_tvalid,
    m00_axis_aresetn,
    m00_axis_aclk,
    adc_bus,
    m00_axis_tready);
  output [63:0]m00_axis_tdata;
  output m00_axis_tvalid;
  input m00_axis_aresetn;
  input m00_axis_aclk;
  input [63:0]adc_bus;
  input m00_axis_tready;

  wire [63:0]adc_bus;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [63:0]m00_axis_tdata;
  wire m00_axis_tready;
  wire m00_axis_tvalid;

  design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0_M00_AXIS adc_test_streamer_v2_0_M00_AXIS_inst
       (.adc_bus(adc_bus),
        .m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "adc_test_streamer_v2_0_M00_AXIS" *) 
module design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0_M00_AXIS
   (m00_axis_tdata,
    m00_axis_tvalid,
    m00_axis_aresetn,
    m00_axis_aclk,
    adc_bus,
    m00_axis_tready);
  output [63:0]m00_axis_tdata;
  output m00_axis_tvalid;
  input m00_axis_aresetn;
  input m00_axis_aclk;
  input [63:0]adc_bus;
  input m00_axis_tready;

  wire \FSM_sequential_mst_exec_state[0]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_2_n_0 ;
  wire [63:0]adc_bus;
  wire axis_tvalid_delay_i_1_n_0;
  wire count;
  wire \count[2]_i_1_n_0 ;
  wire [4:0]count_reg__0;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [63:0]m00_axis_tdata;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire [1:0]mst_exec_state;
  wire [4:0]p_0_in;
  wire \stream_data_out[63]_i_1_n_0 ;
  wire tx_en;

  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h9D00)) 
    \FSM_sequential_mst_exec_state[0]_i_1 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .I2(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .I3(m00_axis_aresetn),
        .O(\FSM_sequential_mst_exec_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'hEA00)) 
    \FSM_sequential_mst_exec_state[1]_i_1 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .I2(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .I3(m00_axis_aresetn),
        .O(\FSM_sequential_mst_exec_state[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \FSM_sequential_mst_exec_state[1]_i_2 
       (.I0(count_reg__0[3]),
        .I1(count_reg__0[1]),
        .I2(count_reg__0[0]),
        .I3(count_reg__0[4]),
        .I4(count_reg__0[2]),
        .O(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ));
  (* FSM_ENCODED_STATES = "INIT_COUNTER:01,SEND_STREAM:10,IDLE:00" *) 
  FDRE \FSM_sequential_mst_exec_state_reg[0] 
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_mst_exec_state[0]_i_1_n_0 ),
        .Q(mst_exec_state[0]),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "INIT_COUNTER:01,SEND_STREAM:10,IDLE:00" *) 
  FDRE \FSM_sequential_mst_exec_state_reg[1] 
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_mst_exec_state[1]_i_1_n_0 ),
        .Q(mst_exec_state[1]),
        .R(1'b0));
  LUT3 #(
    .INIT(8'h40)) 
    axis_tvalid_delay_i_1
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .I2(m00_axis_aresetn),
        .O(axis_tvalid_delay_i_1_n_0));
  FDRE axis_tvalid_delay_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(axis_tvalid_delay_i_1_n_0),
        .Q(m00_axis_tvalid),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \count[0]_i_1 
       (.I0(count_reg__0[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \count[1]_i_1 
       (.I0(count_reg__0[0]),
        .I1(count_reg__0[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \count[2]_i_1 
       (.I0(count_reg__0[0]),
        .I1(count_reg__0[1]),
        .I2(count_reg__0[2]),
        .O(\count[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \count[3]_i_1 
       (.I0(count_reg__0[1]),
        .I1(count_reg__0[0]),
        .I2(count_reg__0[2]),
        .I3(count_reg__0[3]),
        .O(p_0_in[3]));
  LUT3 #(
    .INIT(8'h04)) 
    \count[4]_i_1 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .I2(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .O(count));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \count[4]_i_2 
       (.I0(count_reg__0[2]),
        .I1(count_reg__0[0]),
        .I2(count_reg__0[1]),
        .I3(count_reg__0[3]),
        .I4(count_reg__0[4]),
        .O(p_0_in[4]));
  FDRE \count_reg[0] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in[0]),
        .Q(count_reg__0[0]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \count_reg[1] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in[1]),
        .Q(count_reg__0[1]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \count_reg[2] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(\count[2]_i_1_n_0 ),
        .Q(count_reg__0[2]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \count_reg[3] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in[3]),
        .Q(count_reg__0[3]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \count_reg[4] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in[4]),
        .Q(count_reg__0[4]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \stream_data_out[63]_i_1 
       (.I0(m00_axis_aresetn),
        .O(\stream_data_out[63]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h20)) 
    \stream_data_out[63]_i_2 
       (.I0(m00_axis_tready),
        .I1(mst_exec_state[0]),
        .I2(mst_exec_state[1]),
        .O(tx_en));
  FDSE \stream_data_out_reg[0] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[0]),
        .Q(m00_axis_tdata[0]),
        .S(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[10] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[10]),
        .Q(m00_axis_tdata[10]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[11] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[11]),
        .Q(m00_axis_tdata[11]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[12] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[12]),
        .Q(m00_axis_tdata[12]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[13] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[13]),
        .Q(m00_axis_tdata[13]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[14] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[14]),
        .Q(m00_axis_tdata[14]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[15] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[15]),
        .Q(m00_axis_tdata[15]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[16] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[16]),
        .Q(m00_axis_tdata[16]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[17] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[17]),
        .Q(m00_axis_tdata[17]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[18] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[18]),
        .Q(m00_axis_tdata[18]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[19] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[19]),
        .Q(m00_axis_tdata[19]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[1] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[1]),
        .Q(m00_axis_tdata[1]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[20] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[20]),
        .Q(m00_axis_tdata[20]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[21] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[21]),
        .Q(m00_axis_tdata[21]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[22] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[22]),
        .Q(m00_axis_tdata[22]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[23] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[23]),
        .Q(m00_axis_tdata[23]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[24] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[24]),
        .Q(m00_axis_tdata[24]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[25] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[25]),
        .Q(m00_axis_tdata[25]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[26] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[26]),
        .Q(m00_axis_tdata[26]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[27] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[27]),
        .Q(m00_axis_tdata[27]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[28] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[28]),
        .Q(m00_axis_tdata[28]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[29] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[29]),
        .Q(m00_axis_tdata[29]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[2] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[2]),
        .Q(m00_axis_tdata[2]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[30] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[30]),
        .Q(m00_axis_tdata[30]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[31] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[31]),
        .Q(m00_axis_tdata[31]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[32] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[32]),
        .Q(m00_axis_tdata[32]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[33] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[33]),
        .Q(m00_axis_tdata[33]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[34] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[34]),
        .Q(m00_axis_tdata[34]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[35] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[35]),
        .Q(m00_axis_tdata[35]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[36] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[36]),
        .Q(m00_axis_tdata[36]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[37] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[37]),
        .Q(m00_axis_tdata[37]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[38] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[38]),
        .Q(m00_axis_tdata[38]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[39] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[39]),
        .Q(m00_axis_tdata[39]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[3] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[3]),
        .Q(m00_axis_tdata[3]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[40] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[40]),
        .Q(m00_axis_tdata[40]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[41] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[41]),
        .Q(m00_axis_tdata[41]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[42] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[42]),
        .Q(m00_axis_tdata[42]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[43] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[43]),
        .Q(m00_axis_tdata[43]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[44] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[44]),
        .Q(m00_axis_tdata[44]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[45] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[45]),
        .Q(m00_axis_tdata[45]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[46] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[46]),
        .Q(m00_axis_tdata[46]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[47] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[47]),
        .Q(m00_axis_tdata[47]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[48] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[48]),
        .Q(m00_axis_tdata[48]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[49] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[49]),
        .Q(m00_axis_tdata[49]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[4] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[4]),
        .Q(m00_axis_tdata[4]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[50] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[50]),
        .Q(m00_axis_tdata[50]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[51] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[51]),
        .Q(m00_axis_tdata[51]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[52] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[52]),
        .Q(m00_axis_tdata[52]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[53] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[53]),
        .Q(m00_axis_tdata[53]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[54] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[54]),
        .Q(m00_axis_tdata[54]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[55] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[55]),
        .Q(m00_axis_tdata[55]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[56] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[56]),
        .Q(m00_axis_tdata[56]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[57] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[57]),
        .Q(m00_axis_tdata[57]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[58] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[58]),
        .Q(m00_axis_tdata[58]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[59] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[59]),
        .Q(m00_axis_tdata[59]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[5] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[5]),
        .Q(m00_axis_tdata[5]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[60] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[60]),
        .Q(m00_axis_tdata[60]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[61] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[61]),
        .Q(m00_axis_tdata[61]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[62] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[62]),
        .Q(m00_axis_tdata[62]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[63] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[63]),
        .Q(m00_axis_tdata[63]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[6] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[6]),
        .Q(m00_axis_tdata[6]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[7] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[7]),
        .Q(m00_axis_tdata[7]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[8] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[8]),
        .Q(m00_axis_tdata[8]),
        .R(\stream_data_out[63]_i_1_n_0 ));
  FDRE \stream_data_out_reg[9] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(adc_bus[9]),
        .Q(m00_axis_tdata[9]),
        .R(\stream_data_out[63]_i_1_n_0 ));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif

// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 20 00:21:15 2019
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_adc_test_streamer_0_0/design_1_adc_test_streamer_0_0_sim_netlist.v
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
    m00_axis_aclk,
    m00_axis_aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TDATA" *) output [31:0]m00_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TSTRB" *) output [3:0]m00_axis_tstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TLAST" *) output m00_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TVALID" *) output m00_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 5e+07, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) input m00_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_CLK, ASSOCIATED_BUSIF M00_AXIS, ASSOCIATED_RESET m00_axis_aresetn, FREQ_HZ 5e+07, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input m00_axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input m00_axis_aresetn;

  wire \<const0> ;
  wire \<const1> ;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [30:0]\^m00_axis_tdata ;
  wire m00_axis_tlast;
  wire m00_axis_tready;
  wire m00_axis_tvalid;

  assign m00_axis_tdata[31] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[30] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[29] = \<const0> ;
  assign m00_axis_tdata[28] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[27] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[26] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[25] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[24] = \<const0> ;
  assign m00_axis_tdata[23] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[22] = \<const0> ;
  assign m00_axis_tdata[21] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[20] = \<const0> ;
  assign m00_axis_tdata[19] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[18] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[17] = \<const0> ;
  assign m00_axis_tdata[16] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[15] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[14] = \<const0> ;
  assign m00_axis_tdata[13] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[12] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[11] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[10] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[9] = \^m00_axis_tdata [30];
  assign m00_axis_tdata[8] = \^m00_axis_tdata [8];
  assign m00_axis_tdata[7] = \^m00_axis_tdata [6];
  assign m00_axis_tdata[6:0] = \^m00_axis_tdata [6:0];
  assign m00_axis_tstrb[3] = \<const1> ;
  assign m00_axis_tstrb[2] = \<const1> ;
  assign m00_axis_tstrb[1] = \<const1> ;
  assign m00_axis_tstrb[0] = \<const1> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0 inst
       (.m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata({\^m00_axis_tdata [30],\^m00_axis_tdata [8],\^m00_axis_tdata [6:0]}),
        .m00_axis_tlast(m00_axis_tlast),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "adc_test_streamer_v2_0" *) 
module design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0
   (m00_axis_tvalid,
    m00_axis_tdata,
    m00_axis_tlast,
    m00_axis_tready,
    m00_axis_aclk,
    m00_axis_aresetn);
  output m00_axis_tvalid;
  output [8:0]m00_axis_tdata;
  output m00_axis_tlast;
  input m00_axis_tready;
  input m00_axis_aclk;
  input m00_axis_aresetn;

  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [8:0]m00_axis_tdata;
  wire m00_axis_tlast;
  wire m00_axis_tready;
  wire m00_axis_tvalid;

  design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0_M00_AXIS adc_test_streamer_v2_0_M00_AXIS_inst
       (.m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tlast(m00_axis_tlast),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "adc_test_streamer_v2_0_M00_AXIS" *) 
module design_1_adc_test_streamer_0_0_adc_test_streamer_v2_0_M00_AXIS
   (m00_axis_tvalid,
    m00_axis_tdata,
    m00_axis_tlast,
    m00_axis_tready,
    m00_axis_aclk,
    m00_axis_aresetn);
  output m00_axis_tvalid;
  output [8:0]m00_axis_tdata;
  output m00_axis_tlast;
  input m00_axis_tready;
  input m00_axis_aclk;
  input m00_axis_aresetn;

  wire \FSM_sequential_mst_exec_state[0]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_2_n_0 ;
  wire axis_tlast;
  wire axis_tvalid;
  wire count;
  wire \count[2]_i_1_n_0 ;
  wire [4:0]count_reg__0;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [8:0]m00_axis_tdata;
  wire m00_axis_tlast;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire [1:0]mst_exec_state;
  wire [5:3]p_0_in;
  wire [4:0]p_0_in__0;
  wire \read_pointer[1]_i_1_n_0 ;
  wire \read_pointer[2]_i_1_n_0 ;
  wire \read_pointer[5]_i_1_n_0 ;
  wire [5:0]read_pointer_reg__0;
  wire [8:0]stream_data_out0;
  wire \stream_data_out[2]_i_1_n_0 ;
  wire \stream_data_out[31]_i_1_n_0 ;
  wire \stream_data_out[3]_i_1_n_0 ;
  wire \stream_data_out[5]_i_1_n_0 ;
  wire tx_done_i_1_n_0;
  wire tx_done_i_2_n_0;
  wire tx_done_reg_n_0;
  wire tx_en;

  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hC7)) 
    \FSM_sequential_mst_exec_state[0]_i_1 
       (.I0(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .I1(mst_exec_state[0]),
        .I2(mst_exec_state[1]),
        .O(\FSM_sequential_mst_exec_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'hF3A0)) 
    \FSM_sequential_mst_exec_state[1]_i_1 
       (.I0(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .I1(tx_done_reg_n_0),
        .I2(mst_exec_state[0]),
        .I3(mst_exec_state[1]),
        .O(\FSM_sequential_mst_exec_state[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
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
        .R(\stream_data_out[31]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "INIT_COUNTER:01,SEND_STREAM:10,IDLE:00" *) 
  FDRE \FSM_sequential_mst_exec_state_reg[1] 
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_mst_exec_state[1]_i_1_n_0 ),
        .Q(mst_exec_state[1]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    axis_tlast_delay_i_1
       (.I0(read_pointer_reg__0[5]),
        .I1(read_pointer_reg__0[3]),
        .I2(read_pointer_reg__0[4]),
        .I3(read_pointer_reg__0[2]),
        .I4(read_pointer_reg__0[0]),
        .I5(read_pointer_reg__0[1]),
        .O(axis_tlast));
  FDRE axis_tlast_delay_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(axis_tlast),
        .Q(m00_axis_tlast),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h04)) 
    axis_tvalid_delay_i_1
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .I2(read_pointer_reg__0[5]),
        .O(axis_tvalid));
  FDRE axis_tvalid_delay_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(axis_tvalid),
        .Q(m00_axis_tvalid),
        .R(\stream_data_out[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \count[0]_i_1 
       (.I0(count_reg__0[0]),
        .O(p_0_in__0[0]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \count[1]_i_1 
       (.I0(count_reg__0[0]),
        .I1(count_reg__0[1]),
        .O(p_0_in__0[1]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \count[2]_i_1 
       (.I0(count_reg__0[0]),
        .I1(count_reg__0[1]),
        .I2(count_reg__0[2]),
        .O(\count[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \count[3]_i_1 
       (.I0(count_reg__0[1]),
        .I1(count_reg__0[0]),
        .I2(count_reg__0[2]),
        .I3(count_reg__0[3]),
        .O(p_0_in__0[3]));
  LUT3 #(
    .INIT(8'h04)) 
    \count[4]_i_1 
       (.I0(mst_exec_state[1]),
        .I1(mst_exec_state[0]),
        .I2(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .O(count));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \count[4]_i_2 
       (.I0(count_reg__0[2]),
        .I1(count_reg__0[0]),
        .I2(count_reg__0[1]),
        .I3(count_reg__0[3]),
        .I4(count_reg__0[4]),
        .O(p_0_in__0[4]));
  FDRE \count_reg[0] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in__0[0]),
        .Q(count_reg__0[0]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \count_reg[1] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in__0[1]),
        .Q(count_reg__0[1]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \count_reg[2] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(\count[2]_i_1_n_0 ),
        .Q(count_reg__0[2]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \count_reg[3] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in__0[3]),
        .Q(count_reg__0[3]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \count_reg[4] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in__0[4]),
        .Q(count_reg__0[4]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \read_pointer[1]_i_1 
       (.I0(read_pointer_reg__0[0]),
        .I1(read_pointer_reg__0[1]),
        .O(\read_pointer[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \read_pointer[2]_i_1 
       (.I0(read_pointer_reg__0[1]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[2]),
        .O(\read_pointer[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \read_pointer[3]_i_1 
       (.I0(read_pointer_reg__0[1]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[2]),
        .I3(read_pointer_reg__0[3]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \read_pointer[4]_i_1 
       (.I0(read_pointer_reg__0[2]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[1]),
        .I3(read_pointer_reg__0[3]),
        .I4(read_pointer_reg__0[4]),
        .O(p_0_in[4]));
  LUT4 #(
    .INIT(16'h0040)) 
    \read_pointer[5]_i_1 
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .I2(m00_axis_tready),
        .I3(read_pointer_reg__0[5]),
        .O(\read_pointer[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \read_pointer[5]_i_2 
       (.I0(read_pointer_reg__0[3]),
        .I1(read_pointer_reg__0[1]),
        .I2(read_pointer_reg__0[0]),
        .I3(read_pointer_reg__0[2]),
        .I4(read_pointer_reg__0[4]),
        .O(p_0_in[5]));
  FDRE \read_pointer_reg[0] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[5]_i_1_n_0 ),
        .D(stream_data_out0[0]),
        .Q(read_pointer_reg__0[0]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[1] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[5]_i_1_n_0 ),
        .D(\read_pointer[1]_i_1_n_0 ),
        .Q(read_pointer_reg__0[1]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[2] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[5]_i_1_n_0 ),
        .D(\read_pointer[2]_i_1_n_0 ),
        .Q(read_pointer_reg__0[2]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[3] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[5]_i_1_n_0 ),
        .D(p_0_in[3]),
        .Q(read_pointer_reg__0[3]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[4] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[5]_i_1_n_0 ),
        .D(p_0_in[4]),
        .Q(read_pointer_reg__0[4]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[5] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[5]_i_1_n_0 ),
        .D(p_0_in[5]),
        .Q(read_pointer_reg__0[5]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \stream_data_out[0]_i_1 
       (.I0(read_pointer_reg__0[0]),
        .O(stream_data_out0[0]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'h9)) 
    \stream_data_out[1]_i_1 
       (.I0(read_pointer_reg__0[1]),
        .I1(read_pointer_reg__0[0]),
        .O(stream_data_out0[1]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hE1)) 
    \stream_data_out[2]_i_1 
       (.I0(read_pointer_reg__0[1]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[2]),
        .O(\stream_data_out[2]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \stream_data_out[31]_i_1 
       (.I0(m00_axis_aresetn),
        .O(\stream_data_out[31]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0020)) 
    \stream_data_out[31]_i_2 
       (.I0(m00_axis_tready),
        .I1(read_pointer_reg__0[5]),
        .I2(mst_exec_state[1]),
        .I3(mst_exec_state[0]),
        .O(tx_en));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hFE01)) 
    \stream_data_out[3]_i_1 
       (.I0(read_pointer_reg__0[2]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[1]),
        .I3(read_pointer_reg__0[3]),
        .O(\stream_data_out[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h0001FFFE)) 
    \stream_data_out[4]_i_1 
       (.I0(read_pointer_reg__0[3]),
        .I1(read_pointer_reg__0[1]),
        .I2(read_pointer_reg__0[0]),
        .I3(read_pointer_reg__0[2]),
        .I4(read_pointer_reg__0[4]),
        .O(stream_data_out0[4]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h0001FFFF)) 
    \stream_data_out[5]_i_1 
       (.I0(read_pointer_reg__0[2]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[1]),
        .I3(read_pointer_reg__0[3]),
        .I4(read_pointer_reg__0[4]),
        .O(\stream_data_out[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h55555557)) 
    \stream_data_out[7]_i_1 
       (.I0(read_pointer_reg__0[4]),
        .I1(read_pointer_reg__0[3]),
        .I2(read_pointer_reg__0[1]),
        .I3(read_pointer_reg__0[0]),
        .I4(read_pointer_reg__0[2]),
        .O(stream_data_out0[7]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hFFFE0000)) 
    \stream_data_out[8]_i_1 
       (.I0(read_pointer_reg__0[2]),
        .I1(read_pointer_reg__0[0]),
        .I2(read_pointer_reg__0[1]),
        .I3(read_pointer_reg__0[3]),
        .I4(read_pointer_reg__0[4]),
        .O(stream_data_out0[8]));
  FDSE \stream_data_out_reg[0] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(stream_data_out0[0]),
        .Q(m00_axis_tdata[0]),
        .S(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[1] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(stream_data_out0[1]),
        .Q(m00_axis_tdata[1]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[2] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\stream_data_out[2]_i_1_n_0 ),
        .Q(m00_axis_tdata[2]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[31] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(1'b1),
        .Q(m00_axis_tdata[8]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[3] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\stream_data_out[3]_i_1_n_0 ),
        .Q(m00_axis_tdata[3]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[4] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(stream_data_out0[4]),
        .Q(m00_axis_tdata[4]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[5] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(\stream_data_out[5]_i_1_n_0 ),
        .Q(m00_axis_tdata[5]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[7] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(stream_data_out0[7]),
        .Q(m00_axis_tdata[6]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[8] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(stream_data_out0[8]),
        .Q(m00_axis_tdata[7]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE0E000E0)) 
    tx_done_i_1
       (.I0(tx_done_reg_n_0),
        .I1(tx_done_i_2_n_0),
        .I2(m00_axis_aresetn),
        .I3(tx_en),
        .I4(read_pointer_reg__0[5]),
        .O(tx_done_i_1_n_0));
  LUT6 #(
    .INIT(64'h0000000000000010)) 
    tx_done_i_2
       (.I0(read_pointer_reg__0[2]),
        .I1(read_pointer_reg__0[3]),
        .I2(read_pointer_reg__0[5]),
        .I3(read_pointer_reg__0[1]),
        .I4(read_pointer_reg__0[4]),
        .I5(read_pointer_reg__0[0]),
        .O(tx_done_i_2_n_0));
  FDRE tx_done_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(tx_done_i_1_n_0),
        .Q(tx_done_reg_n_0),
        .R(1'b0));
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

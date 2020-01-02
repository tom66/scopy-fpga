// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 20 00:42:15 2019
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_adc_test_streamer_0_0_sim_netlist.v
// Design      : design_1_adc_test_streamer_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0
   (m00_axis_tvalid,
    m00_axis_tdata,
    m00_axis_tlast,
    m00_axis_tready,
    m00_axis_aresetn,
    m00_axis_aclk);
  output m00_axis_tvalid;
  output [31:0]m00_axis_tdata;
  output m00_axis_tlast;
  input m00_axis_tready;
  input m00_axis_aresetn;
  input m00_axis_aclk;

  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [31:0]m00_axis_tdata;
  wire m00_axis_tlast;
  wire m00_axis_tready;
  wire m00_axis_tvalid;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0_M00_AXIS adc_test_streamer_v2_0_M00_AXIS_inst
       (.m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tlast(m00_axis_tlast),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0_M00_AXIS
   (m00_axis_tvalid,
    m00_axis_tdata,
    m00_axis_tlast,
    m00_axis_tready,
    m00_axis_aresetn,
    m00_axis_aclk);
  output m00_axis_tvalid;
  output [31:0]m00_axis_tdata;
  output m00_axis_tlast;
  input m00_axis_tready;
  input m00_axis_aresetn;
  input m00_axis_aclk;

  wire \FSM_sequential_mst_exec_state[0]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_1_n_0 ;
  wire \FSM_sequential_mst_exec_state[1]_i_2_n_0 ;
  wire axis_tlast;
  wire axis_tlast_delay_i_2_n_0;
  wire axis_tlast_delay_i_3_n_0;
  wire axis_tvalid;
  wire count;
  wire \count[2]_i_1_n_0 ;
  wire [4:0]count_reg__0;
  wire endless;
  wire \endless[0]_i_3_n_0 ;
  wire [31:0]endless_reg;
  wire \endless_reg[0]_i_2_n_0 ;
  wire \endless_reg[0]_i_2_n_1 ;
  wire \endless_reg[0]_i_2_n_2 ;
  wire \endless_reg[0]_i_2_n_3 ;
  wire \endless_reg[0]_i_2_n_4 ;
  wire \endless_reg[0]_i_2_n_5 ;
  wire \endless_reg[0]_i_2_n_6 ;
  wire \endless_reg[0]_i_2_n_7 ;
  wire \endless_reg[12]_i_1_n_0 ;
  wire \endless_reg[12]_i_1_n_1 ;
  wire \endless_reg[12]_i_1_n_2 ;
  wire \endless_reg[12]_i_1_n_3 ;
  wire \endless_reg[12]_i_1_n_4 ;
  wire \endless_reg[12]_i_1_n_5 ;
  wire \endless_reg[12]_i_1_n_6 ;
  wire \endless_reg[12]_i_1_n_7 ;
  wire \endless_reg[16]_i_1_n_0 ;
  wire \endless_reg[16]_i_1_n_1 ;
  wire \endless_reg[16]_i_1_n_2 ;
  wire \endless_reg[16]_i_1_n_3 ;
  wire \endless_reg[16]_i_1_n_4 ;
  wire \endless_reg[16]_i_1_n_5 ;
  wire \endless_reg[16]_i_1_n_6 ;
  wire \endless_reg[16]_i_1_n_7 ;
  wire \endless_reg[20]_i_1_n_0 ;
  wire \endless_reg[20]_i_1_n_1 ;
  wire \endless_reg[20]_i_1_n_2 ;
  wire \endless_reg[20]_i_1_n_3 ;
  wire \endless_reg[20]_i_1_n_4 ;
  wire \endless_reg[20]_i_1_n_5 ;
  wire \endless_reg[20]_i_1_n_6 ;
  wire \endless_reg[20]_i_1_n_7 ;
  wire \endless_reg[24]_i_1_n_0 ;
  wire \endless_reg[24]_i_1_n_1 ;
  wire \endless_reg[24]_i_1_n_2 ;
  wire \endless_reg[24]_i_1_n_3 ;
  wire \endless_reg[24]_i_1_n_4 ;
  wire \endless_reg[24]_i_1_n_5 ;
  wire \endless_reg[24]_i_1_n_6 ;
  wire \endless_reg[24]_i_1_n_7 ;
  wire \endless_reg[28]_i_1_n_1 ;
  wire \endless_reg[28]_i_1_n_2 ;
  wire \endless_reg[28]_i_1_n_3 ;
  wire \endless_reg[28]_i_1_n_4 ;
  wire \endless_reg[28]_i_1_n_5 ;
  wire \endless_reg[28]_i_1_n_6 ;
  wire \endless_reg[28]_i_1_n_7 ;
  wire \endless_reg[4]_i_1_n_0 ;
  wire \endless_reg[4]_i_1_n_1 ;
  wire \endless_reg[4]_i_1_n_2 ;
  wire \endless_reg[4]_i_1_n_3 ;
  wire \endless_reg[4]_i_1_n_4 ;
  wire \endless_reg[4]_i_1_n_5 ;
  wire \endless_reg[4]_i_1_n_6 ;
  wire \endless_reg[4]_i_1_n_7 ;
  wire \endless_reg[8]_i_1_n_0 ;
  wire \endless_reg[8]_i_1_n_1 ;
  wire \endless_reg[8]_i_1_n_2 ;
  wire \endless_reg[8]_i_1_n_3 ;
  wire \endless_reg[8]_i_1_n_4 ;
  wire \endless_reg[8]_i_1_n_5 ;
  wire \endless_reg[8]_i_1_n_6 ;
  wire \endless_reg[8]_i_1_n_7 ;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [31:0]m00_axis_tdata;
  wire m00_axis_tlast;
  wire m00_axis_tready;
  wire m00_axis_tvalid;
  wire [1:0]mst_exec_state;
  wire [4:0]p_0_in;
  wire \read_pointer[0]_i_1_n_0 ;
  wire \read_pointer[0]_i_3_n_0 ;
  wire [11:0]read_pointer_reg;
  wire \read_pointer_reg[0]_i_2_n_0 ;
  wire \read_pointer_reg[0]_i_2_n_1 ;
  wire \read_pointer_reg[0]_i_2_n_2 ;
  wire \read_pointer_reg[0]_i_2_n_3 ;
  wire \read_pointer_reg[0]_i_2_n_4 ;
  wire \read_pointer_reg[0]_i_2_n_5 ;
  wire \read_pointer_reg[0]_i_2_n_6 ;
  wire \read_pointer_reg[0]_i_2_n_7 ;
  wire \read_pointer_reg[4]_i_1_n_0 ;
  wire \read_pointer_reg[4]_i_1_n_1 ;
  wire \read_pointer_reg[4]_i_1_n_2 ;
  wire \read_pointer_reg[4]_i_1_n_3 ;
  wire \read_pointer_reg[4]_i_1_n_4 ;
  wire \read_pointer_reg[4]_i_1_n_5 ;
  wire \read_pointer_reg[4]_i_1_n_6 ;
  wire \read_pointer_reg[4]_i_1_n_7 ;
  wire \read_pointer_reg[8]_i_1_n_1 ;
  wire \read_pointer_reg[8]_i_1_n_2 ;
  wire \read_pointer_reg[8]_i_1_n_3 ;
  wire \read_pointer_reg[8]_i_1_n_4 ;
  wire \read_pointer_reg[8]_i_1_n_5 ;
  wire \read_pointer_reg[8]_i_1_n_6 ;
  wire \read_pointer_reg[8]_i_1_n_7 ;
  wire \stream_data_out[31]_i_1_n_0 ;
  wire tx_done_i_1_n_0;
  wire tx_done_i_2_n_0;
  wire tx_done_i_3_n_0;
  wire tx_done_i_4_n_0;
  wire tx_done_i_5_n_0;
  wire tx_done_reg_n_0;
  wire tx_en;
  wire [3:3]\NLW_endless_reg[28]_i_1_CO_UNCONNECTED ;
  wire [3:3]\NLW_read_pointer_reg[8]_i_1_CO_UNCONNECTED ;

  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hC7)) 
    \FSM_sequential_mst_exec_state[0]_i_1 
       (.I0(\FSM_sequential_mst_exec_state[1]_i_2_n_0 ),
        .I1(mst_exec_state[0]),
        .I2(mst_exec_state[1]),
        .O(\FSM_sequential_mst_exec_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
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
  LUT2 #(
    .INIT(4'h2)) 
    axis_tlast_delay_i_1
       (.I0(axis_tlast_delay_i_2_n_0),
        .I1(axis_tlast_delay_i_3_n_0),
        .O(axis_tlast));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    axis_tlast_delay_i_2
       (.I0(read_pointer_reg[11]),
        .I1(read_pointer_reg[9]),
        .I2(read_pointer_reg[10]),
        .I3(read_pointer_reg[8]),
        .I4(read_pointer_reg[6]),
        .I5(read_pointer_reg[7]),
        .O(axis_tlast_delay_i_2_n_0));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    axis_tlast_delay_i_3
       (.I0(read_pointer_reg[0]),
        .I1(read_pointer_reg[1]),
        .I2(read_pointer_reg[2]),
        .I3(read_pointer_reg[3]),
        .I4(read_pointer_reg[4]),
        .I5(read_pointer_reg[5]),
        .O(axis_tlast_delay_i_3_n_0));
  FDRE axis_tlast_delay_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(axis_tlast),
        .Q(m00_axis_tlast),
        .R(\stream_data_out[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h04)) 
    axis_tvalid_delay_i_1
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .I2(read_pointer_reg[11]),
        .O(axis_tvalid));
  FDRE axis_tvalid_delay_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(axis_tvalid),
        .Q(m00_axis_tvalid),
        .R(\stream_data_out[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \count[0]_i_1 
       (.I0(count_reg__0[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
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
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
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
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \count_reg[1] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in[1]),
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
        .D(p_0_in[3]),
        .Q(count_reg__0[3]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \count_reg[4] 
       (.C(m00_axis_aclk),
        .CE(count),
        .D(p_0_in[4]),
        .Q(count_reg__0[4]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00200000)) 
    \endless[0]_i_1 
       (.I0(m00_axis_aresetn),
        .I1(mst_exec_state[0]),
        .I2(mst_exec_state[1]),
        .I3(read_pointer_reg[11]),
        .I4(m00_axis_tready),
        .O(endless));
  LUT1 #(
    .INIT(2'h1)) 
    \endless[0]_i_3 
       (.I0(endless_reg[0]),
        .O(\endless[0]_i_3_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[0] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[0]_i_2_n_7 ),
        .Q(endless_reg[0]),
        .R(1'b0));
  CARRY4 \endless_reg[0]_i_2 
       (.CI(1'b0),
        .CO({\endless_reg[0]_i_2_n_0 ,\endless_reg[0]_i_2_n_1 ,\endless_reg[0]_i_2_n_2 ,\endless_reg[0]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\endless_reg[0]_i_2_n_4 ,\endless_reg[0]_i_2_n_5 ,\endless_reg[0]_i_2_n_6 ,\endless_reg[0]_i_2_n_7 }),
        .S({endless_reg[3:1],\endless[0]_i_3_n_0 }));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[10] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[8]_i_1_n_5 ),
        .Q(endless_reg[10]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[11] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[8]_i_1_n_4 ),
        .Q(endless_reg[11]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[12] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[12]_i_1_n_7 ),
        .Q(endless_reg[12]),
        .R(1'b0));
  CARRY4 \endless_reg[12]_i_1 
       (.CI(\endless_reg[8]_i_1_n_0 ),
        .CO({\endless_reg[12]_i_1_n_0 ,\endless_reg[12]_i_1_n_1 ,\endless_reg[12]_i_1_n_2 ,\endless_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[12]_i_1_n_4 ,\endless_reg[12]_i_1_n_5 ,\endless_reg[12]_i_1_n_6 ,\endless_reg[12]_i_1_n_7 }),
        .S(endless_reg[15:12]));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[13] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[12]_i_1_n_6 ),
        .Q(endless_reg[13]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[14] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[12]_i_1_n_5 ),
        .Q(endless_reg[14]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[15] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[12]_i_1_n_4 ),
        .Q(endless_reg[15]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[16] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[16]_i_1_n_7 ),
        .Q(endless_reg[16]),
        .R(1'b0));
  CARRY4 \endless_reg[16]_i_1 
       (.CI(\endless_reg[12]_i_1_n_0 ),
        .CO({\endless_reg[16]_i_1_n_0 ,\endless_reg[16]_i_1_n_1 ,\endless_reg[16]_i_1_n_2 ,\endless_reg[16]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[16]_i_1_n_4 ,\endless_reg[16]_i_1_n_5 ,\endless_reg[16]_i_1_n_6 ,\endless_reg[16]_i_1_n_7 }),
        .S(endless_reg[19:16]));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[17] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[16]_i_1_n_6 ),
        .Q(endless_reg[17]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[18] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[16]_i_1_n_5 ),
        .Q(endless_reg[18]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[19] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[16]_i_1_n_4 ),
        .Q(endless_reg[19]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[1] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[0]_i_2_n_6 ),
        .Q(endless_reg[1]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[20] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[20]_i_1_n_7 ),
        .Q(endless_reg[20]),
        .R(1'b0));
  CARRY4 \endless_reg[20]_i_1 
       (.CI(\endless_reg[16]_i_1_n_0 ),
        .CO({\endless_reg[20]_i_1_n_0 ,\endless_reg[20]_i_1_n_1 ,\endless_reg[20]_i_1_n_2 ,\endless_reg[20]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[20]_i_1_n_4 ,\endless_reg[20]_i_1_n_5 ,\endless_reg[20]_i_1_n_6 ,\endless_reg[20]_i_1_n_7 }),
        .S(endless_reg[23:20]));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[21] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[20]_i_1_n_6 ),
        .Q(endless_reg[21]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[22] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[20]_i_1_n_5 ),
        .Q(endless_reg[22]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[23] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[20]_i_1_n_4 ),
        .Q(endless_reg[23]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[24] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[24]_i_1_n_7 ),
        .Q(endless_reg[24]),
        .R(1'b0));
  CARRY4 \endless_reg[24]_i_1 
       (.CI(\endless_reg[20]_i_1_n_0 ),
        .CO({\endless_reg[24]_i_1_n_0 ,\endless_reg[24]_i_1_n_1 ,\endless_reg[24]_i_1_n_2 ,\endless_reg[24]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[24]_i_1_n_4 ,\endless_reg[24]_i_1_n_5 ,\endless_reg[24]_i_1_n_6 ,\endless_reg[24]_i_1_n_7 }),
        .S(endless_reg[27:24]));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[25] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[24]_i_1_n_6 ),
        .Q(endless_reg[25]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[26] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[24]_i_1_n_5 ),
        .Q(endless_reg[26]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[27] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[24]_i_1_n_4 ),
        .Q(endless_reg[27]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[28] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[28]_i_1_n_7 ),
        .Q(endless_reg[28]),
        .R(1'b0));
  CARRY4 \endless_reg[28]_i_1 
       (.CI(\endless_reg[24]_i_1_n_0 ),
        .CO({\NLW_endless_reg[28]_i_1_CO_UNCONNECTED [3],\endless_reg[28]_i_1_n_1 ,\endless_reg[28]_i_1_n_2 ,\endless_reg[28]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[28]_i_1_n_4 ,\endless_reg[28]_i_1_n_5 ,\endless_reg[28]_i_1_n_6 ,\endless_reg[28]_i_1_n_7 }),
        .S(endless_reg[31:28]));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[29] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[28]_i_1_n_6 ),
        .Q(endless_reg[29]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[2] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[0]_i_2_n_5 ),
        .Q(endless_reg[2]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[30] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[28]_i_1_n_5 ),
        .Q(endless_reg[30]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[31] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[28]_i_1_n_4 ),
        .Q(endless_reg[31]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[3] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[0]_i_2_n_4 ),
        .Q(endless_reg[3]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \endless_reg[4] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[4]_i_1_n_7 ),
        .Q(endless_reg[4]),
        .R(1'b0));
  CARRY4 \endless_reg[4]_i_1 
       (.CI(\endless_reg[0]_i_2_n_0 ),
        .CO({\endless_reg[4]_i_1_n_0 ,\endless_reg[4]_i_1_n_1 ,\endless_reg[4]_i_1_n_2 ,\endless_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[4]_i_1_n_4 ,\endless_reg[4]_i_1_n_5 ,\endless_reg[4]_i_1_n_6 ,\endless_reg[4]_i_1_n_7 }),
        .S(endless_reg[7:4]));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[5] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[4]_i_1_n_6 ),
        .Q(endless_reg[5]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[6] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[4]_i_1_n_5 ),
        .Q(endless_reg[6]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[7] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[4]_i_1_n_4 ),
        .Q(endless_reg[7]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[8] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[8]_i_1_n_7 ),
        .Q(endless_reg[8]),
        .R(1'b0));
  CARRY4 \endless_reg[8]_i_1 
       (.CI(\endless_reg[4]_i_1_n_0 ),
        .CO({\endless_reg[8]_i_1_n_0 ,\endless_reg[8]_i_1_n_1 ,\endless_reg[8]_i_1_n_2 ,\endless_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\endless_reg[8]_i_1_n_4 ,\endless_reg[8]_i_1_n_5 ,\endless_reg[8]_i_1_n_6 ,\endless_reg[8]_i_1_n_7 }),
        .S(endless_reg[11:8]));
  FDRE #(
    .INIT(1'b1)) 
    \endless_reg[9] 
       (.C(m00_axis_aclk),
        .CE(endless),
        .D(\endless_reg[8]_i_1_n_6 ),
        .Q(endless_reg[9]),
        .R(1'b0));
  LUT4 #(
    .INIT(16'h0040)) 
    \read_pointer[0]_i_1 
       (.I0(mst_exec_state[0]),
        .I1(mst_exec_state[1]),
        .I2(m00_axis_tready),
        .I3(read_pointer_reg[11]),
        .O(\read_pointer[0]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \read_pointer[0]_i_3 
       (.I0(read_pointer_reg[0]),
        .O(\read_pointer[0]_i_3_n_0 ));
  FDRE \read_pointer_reg[0] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[0]_i_2_n_7 ),
        .Q(read_pointer_reg[0]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  CARRY4 \read_pointer_reg[0]_i_2 
       (.CI(1'b0),
        .CO({\read_pointer_reg[0]_i_2_n_0 ,\read_pointer_reg[0]_i_2_n_1 ,\read_pointer_reg[0]_i_2_n_2 ,\read_pointer_reg[0]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\read_pointer_reg[0]_i_2_n_4 ,\read_pointer_reg[0]_i_2_n_5 ,\read_pointer_reg[0]_i_2_n_6 ,\read_pointer_reg[0]_i_2_n_7 }),
        .S({read_pointer_reg[3:1],\read_pointer[0]_i_3_n_0 }));
  FDRE \read_pointer_reg[10] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[8]_i_1_n_5 ),
        .Q(read_pointer_reg[10]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[11] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[8]_i_1_n_4 ),
        .Q(read_pointer_reg[11]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[1] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[0]_i_2_n_6 ),
        .Q(read_pointer_reg[1]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[2] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[0]_i_2_n_5 ),
        .Q(read_pointer_reg[2]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[3] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[0]_i_2_n_4 ),
        .Q(read_pointer_reg[3]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[4] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[4]_i_1_n_7 ),
        .Q(read_pointer_reg[4]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  CARRY4 \read_pointer_reg[4]_i_1 
       (.CI(\read_pointer_reg[0]_i_2_n_0 ),
        .CO({\read_pointer_reg[4]_i_1_n_0 ,\read_pointer_reg[4]_i_1_n_1 ,\read_pointer_reg[4]_i_1_n_2 ,\read_pointer_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\read_pointer_reg[4]_i_1_n_4 ,\read_pointer_reg[4]_i_1_n_5 ,\read_pointer_reg[4]_i_1_n_6 ,\read_pointer_reg[4]_i_1_n_7 }),
        .S(read_pointer_reg[7:4]));
  FDRE \read_pointer_reg[5] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[4]_i_1_n_6 ),
        .Q(read_pointer_reg[5]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[6] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[4]_i_1_n_5 ),
        .Q(read_pointer_reg[6]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[7] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[4]_i_1_n_4 ),
        .Q(read_pointer_reg[7]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \read_pointer_reg[8] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[8]_i_1_n_7 ),
        .Q(read_pointer_reg[8]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  CARRY4 \read_pointer_reg[8]_i_1 
       (.CI(\read_pointer_reg[4]_i_1_n_0 ),
        .CO({\NLW_read_pointer_reg[8]_i_1_CO_UNCONNECTED [3],\read_pointer_reg[8]_i_1_n_1 ,\read_pointer_reg[8]_i_1_n_2 ,\read_pointer_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\read_pointer_reg[8]_i_1_n_4 ,\read_pointer_reg[8]_i_1_n_5 ,\read_pointer_reg[8]_i_1_n_6 ,\read_pointer_reg[8]_i_1_n_7 }),
        .S(read_pointer_reg[11:8]));
  FDRE \read_pointer_reg[9] 
       (.C(m00_axis_aclk),
        .CE(\read_pointer[0]_i_1_n_0 ),
        .D(\read_pointer_reg[8]_i_1_n_6 ),
        .Q(read_pointer_reg[9]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \stream_data_out[31]_i_1 
       (.I0(m00_axis_aresetn),
        .O(\stream_data_out[31]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0020)) 
    \stream_data_out[31]_i_2 
       (.I0(m00_axis_tready),
        .I1(read_pointer_reg[11]),
        .I2(mst_exec_state[1]),
        .I3(mst_exec_state[0]),
        .O(tx_en));
  FDSE \stream_data_out_reg[0] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[0]),
        .Q(m00_axis_tdata[0]),
        .S(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[10] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[10]),
        .Q(m00_axis_tdata[10]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[11] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[11]),
        .Q(m00_axis_tdata[11]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[12] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[12]),
        .Q(m00_axis_tdata[12]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[13] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[13]),
        .Q(m00_axis_tdata[13]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[14] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[14]),
        .Q(m00_axis_tdata[14]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[15] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[15]),
        .Q(m00_axis_tdata[15]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[16] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[16]),
        .Q(m00_axis_tdata[16]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[17] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[17]),
        .Q(m00_axis_tdata[17]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[18] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[18]),
        .Q(m00_axis_tdata[18]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[19] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[19]),
        .Q(m00_axis_tdata[19]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[1] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[1]),
        .Q(m00_axis_tdata[1]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[20] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[20]),
        .Q(m00_axis_tdata[20]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[21] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[21]),
        .Q(m00_axis_tdata[21]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[22] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[22]),
        .Q(m00_axis_tdata[22]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[23] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[23]),
        .Q(m00_axis_tdata[23]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[24] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[24]),
        .Q(m00_axis_tdata[24]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[25] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[25]),
        .Q(m00_axis_tdata[25]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[26] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[26]),
        .Q(m00_axis_tdata[26]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[27] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[27]),
        .Q(m00_axis_tdata[27]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[28] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[28]),
        .Q(m00_axis_tdata[28]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[29] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[29]),
        .Q(m00_axis_tdata[29]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[2] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[2]),
        .Q(m00_axis_tdata[2]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[30] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[30]),
        .Q(m00_axis_tdata[30]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[31] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[31]),
        .Q(m00_axis_tdata[31]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[3] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[3]),
        .Q(m00_axis_tdata[3]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[4] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[4]),
        .Q(m00_axis_tdata[4]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[5] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[5]),
        .Q(m00_axis_tdata[5]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[6] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[6]),
        .Q(m00_axis_tdata[6]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[7] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[7]),
        .Q(m00_axis_tdata[7]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[8] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[8]),
        .Q(m00_axis_tdata[8]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  FDRE \stream_data_out_reg[9] 
       (.C(m00_axis_aclk),
        .CE(tx_en),
        .D(endless_reg[9]),
        .Q(m00_axis_tdata[9]),
        .R(\stream_data_out[31]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000AAAAAAAE)) 
    tx_done_i_1
       (.I0(tx_done_reg_n_0),
        .I1(read_pointer_reg[11]),
        .I2(tx_done_i_2_n_0),
        .I3(tx_done_i_3_n_0),
        .I4(tx_done_i_4_n_0),
        .I5(tx_done_i_5_n_0),
        .O(tx_done_i_1_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    tx_done_i_2
       (.I0(read_pointer_reg[6]),
        .I1(read_pointer_reg[7]),
        .I2(read_pointer_reg[4]),
        .I3(read_pointer_reg[5]),
        .O(tx_done_i_2_n_0));
  LUT4 #(
    .INIT(16'hFFEF)) 
    tx_done_i_3
       (.I0(read_pointer_reg[2]),
        .I1(read_pointer_reg[3]),
        .I2(read_pointer_reg[11]),
        .I3(read_pointer_reg[1]),
        .O(tx_done_i_3_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    tx_done_i_4
       (.I0(read_pointer_reg[0]),
        .I1(read_pointer_reg[10]),
        .I2(read_pointer_reg[8]),
        .I3(read_pointer_reg[9]),
        .O(tx_done_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h0040FFFF)) 
    tx_done_i_5
       (.I0(read_pointer_reg[11]),
        .I1(m00_axis_tready),
        .I2(mst_exec_state[1]),
        .I3(mst_exec_state[0]),
        .I4(m00_axis_aresetn),
        .O(tx_done_i_5_n_0));
  FDRE tx_done_reg
       (.C(m00_axis_aclk),
        .CE(1'b1),
        .D(tx_done_i_1_n_0),
        .Q(tx_done_reg_n_0),
        .R(1'b0));
endmodule

(* CHECK_LICENSE_TYPE = "design_1_adc_test_streamer_0_0,adc_test_streamer_v2_0,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "adc_test_streamer_v2_0,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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

  wire \<const1> ;
  wire m00_axis_aclk;
  wire m00_axis_aresetn;
  wire [31:0]m00_axis_tdata;
  wire m00_axis_tlast;
  wire m00_axis_tready;
  wire m00_axis_tvalid;

  assign m00_axis_tstrb[3] = \<const1> ;
  assign m00_axis_tstrb[2] = \<const1> ;
  assign m00_axis_tstrb[1] = \<const1> ;
  assign m00_axis_tstrb[0] = \<const1> ;
  VCC VCC
       (.P(\<const1> ));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0 inst
       (.m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tlast(m00_axis_tlast),
        .m00_axis_tready(m00_axis_tready),
        .m00_axis_tvalid(m00_axis_tvalid));
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

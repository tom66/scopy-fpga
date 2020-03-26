// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Thu Mar 26 17:37:46 2020
// Host        : TomsDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_simple_reset_control_0_0_sim_netlist.v
// Design      : design_1_simple_reset_control_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z014sclg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_simple_reset_control_0_0,simple_reset_controller_v1_0,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "simple_reset_controller_v1_0,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk_master,
    g_rst_trig_ps,
    g_rst_gen);
  input clk_master;
  input g_rst_trig_ps;
  output g_rst_gen;

  wire clk_master;
  wire g_rst_gen;
  wire g_rst_trig_ps;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_simple_reset_controller_v1_0 inst
       (.clk_master(clk_master),
        .g_rst_gen(g_rst_gen),
        .g_rst_trig_ps(g_rst_trig_ps));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_simple_reset_controller_v1_0
   (g_rst_gen,
    clk_master,
    g_rst_trig_ps);
  output g_rst_gen;
  input clk_master;
  input g_rst_trig_ps;

  wire clk_master;
  wire g_rst_counter;
  wire \g_rst_counter[7]_i_4_n_0 ;
  wire [7:0]g_rst_counter_reg;
  wire g_rst_gen;
  wire g_rst_gen_reg_i_1_n_0;
  wire g_rst_gen_reg_i_2_n_0;
  wire g_rst_state_i_1_n_0;
  wire g_rst_state_reg_n_0;
  wire g_rst_trig_ps;
  wire [7:0]p_0_in;
  wire p_0_in_0;

  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \g_rst_counter[0]_i_1 
       (.I0(g_rst_counter_reg[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \g_rst_counter[1]_i_1 
       (.I0(g_rst_counter_reg[0]),
        .I1(g_rst_counter_reg[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \g_rst_counter[2]_i_1 
       (.I0(g_rst_counter_reg[0]),
        .I1(g_rst_counter_reg[1]),
        .I2(g_rst_counter_reg[2]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \g_rst_counter[3]_i_1 
       (.I0(g_rst_counter_reg[3]),
        .I1(g_rst_counter_reg[0]),
        .I2(g_rst_counter_reg[1]),
        .I3(g_rst_counter_reg[2]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \g_rst_counter[4]_i_1 
       (.I0(g_rst_counter_reg[4]),
        .I1(g_rst_counter_reg[2]),
        .I2(g_rst_counter_reg[1]),
        .I3(g_rst_counter_reg[0]),
        .I4(g_rst_counter_reg[3]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \g_rst_counter[5]_i_1 
       (.I0(g_rst_counter_reg[5]),
        .I1(g_rst_counter_reg[3]),
        .I2(g_rst_counter_reg[0]),
        .I3(g_rst_counter_reg[1]),
        .I4(g_rst_counter_reg[2]),
        .I5(g_rst_counter_reg[4]),
        .O(p_0_in[5]));
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \g_rst_counter[6]_i_1 
       (.I0(g_rst_counter_reg[6]),
        .I1(g_rst_counter_reg[4]),
        .I2(\g_rst_counter[7]_i_4_n_0 ),
        .I3(g_rst_counter_reg[3]),
        .I4(g_rst_counter_reg[5]),
        .O(p_0_in[6]));
  LUT2 #(
    .INIT(4'h8)) 
    \g_rst_counter[7]_i_1 
       (.I0(g_rst_state_reg_n_0),
        .I1(g_rst_trig_ps),
        .O(g_rst_counter));
  LUT1 #(
    .INIT(2'h1)) 
    \g_rst_counter[7]_i_2 
       (.I0(g_rst_state_reg_n_0),
        .O(p_0_in_0));
  LUT6 #(
    .INIT(64'h6AAAAAAAAAAAAAAA)) 
    \g_rst_counter[7]_i_3 
       (.I0(g_rst_counter_reg[7]),
        .I1(g_rst_counter_reg[5]),
        .I2(g_rst_counter_reg[3]),
        .I3(\g_rst_counter[7]_i_4_n_0 ),
        .I4(g_rst_counter_reg[4]),
        .I5(g_rst_counter_reg[6]),
        .O(p_0_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \g_rst_counter[7]_i_4 
       (.I0(g_rst_counter_reg[2]),
        .I1(g_rst_counter_reg[1]),
        .I2(g_rst_counter_reg[0]),
        .O(\g_rst_counter[7]_i_4_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[0] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[0]),
        .Q(g_rst_counter_reg[0]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[1] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[1]),
        .Q(g_rst_counter_reg[1]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[2] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[2]),
        .Q(g_rst_counter_reg[2]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[3] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[3]),
        .Q(g_rst_counter_reg[3]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[4] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[4]),
        .Q(g_rst_counter_reg[4]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[5] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[5]),
        .Q(g_rst_counter_reg[5]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[6] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[6]),
        .Q(g_rst_counter_reg[6]),
        .R(g_rst_counter));
  FDRE #(
    .INIT(1'b0)) 
    \g_rst_counter_reg[7] 
       (.C(clk_master),
        .CE(p_0_in_0),
        .D(p_0_in[7]),
        .Q(g_rst_counter_reg[7]),
        .R(g_rst_counter));
  LUT5 #(
    .INIT(32'hAA8EAAAA)) 
    g_rst_gen_reg_i_1
       (.I0(g_rst_gen),
        .I1(g_rst_counter_reg[2]),
        .I2(g_rst_counter_reg[7]),
        .I3(g_rst_counter_reg[0]),
        .I4(g_rst_gen_reg_i_2_n_0),
        .O(g_rst_gen_reg_i_1_n_0));
  LUT6 #(
    .INIT(64'h0000000000000001)) 
    g_rst_gen_reg_i_2
       (.I0(g_rst_counter_reg[6]),
        .I1(g_rst_counter_reg[4]),
        .I2(g_rst_state_reg_n_0),
        .I3(g_rst_counter_reg[3]),
        .I4(g_rst_counter_reg[1]),
        .I5(g_rst_counter_reg[5]),
        .O(g_rst_gen_reg_i_2_n_0));
  FDRE g_rst_gen_reg_reg
       (.C(clk_master),
        .CE(1'b1),
        .D(g_rst_gen_reg_i_1_n_0),
        .Q(g_rst_gen),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h5575555500300000)) 
    g_rst_state_i_1
       (.I0(g_rst_trig_ps),
        .I1(g_rst_counter_reg[2]),
        .I2(g_rst_counter_reg[7]),
        .I3(g_rst_counter_reg[0]),
        .I4(g_rst_gen_reg_i_2_n_0),
        .I5(g_rst_state_reg_n_0),
        .O(g_rst_state_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    g_rst_state_reg
       (.C(clk_master),
        .CE(1'b1),
        .D(g_rst_state_i_1_n_0),
        .Q(g_rst_state_reg_n_0),
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

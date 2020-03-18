//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_f60c.bd
//Design : bd_f60c
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd_f60c,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_f60c,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=SBD,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1_system_ila_0_0.hwdef" *) 
module bd_f60c
   (clk,
    probe0,
    probe1,
    probe10,
    probe11,
    probe12,
    probe13,
    probe14,
    probe15,
    probe16,
    probe17,
    probe18,
    probe19,
    probe2,
    probe20,
    probe21,
    probe22,
    probe23,
    probe24,
    probe25,
    probe26,
    probe27,
    probe28,
    probe29,
    probe3,
    probe30,
    probe31,
    probe4,
    probe5,
    probe6,
    probe7,
    probe8,
    probe9);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN design_1_csi_gearbox_dma_0_0_dbg_ref_clk, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000" *) input clk;
  input [5:0]probe0;
  input [0:0]probe1;
  input [0:0]probe10;
  input [15:0]probe11;
  input [5:0]probe12;
  input [0:0]probe13;
  input [0:0]probe14;
  input [11:0]probe15;
  input [0:0]probe16;
  input [0:0]probe17;
  input [0:0]probe18;
  input [0:0]probe19;
  input [0:0]probe2;
  input [0:0]probe20;
  input [5:0]probe21;
  input [20:0]probe22;
  input [7:0]probe23;
  input [63:0]probe24;
  input [15:0]probe25;
  input [0:0]probe26;
  input [0:0]probe27;
  input [0:0]probe28;
  input [0:0]probe29;
  input [0:0]probe3;
  input [0:0]probe30;
  input [0:0]probe31;
  input [0:0]probe4;
  input [0:0]probe5;
  input [15:0]probe6;
  input [5:0]probe7;
  input [15:0]probe8;
  input [15:0]probe9;

  wire clk_1;
  wire [5:0]probe0_1;
  wire [0:0]probe10_1;
  wire [15:0]probe11_1;
  wire [5:0]probe12_1;
  wire [0:0]probe13_1;
  wire [0:0]probe14_1;
  wire [11:0]probe15_1;
  wire [0:0]probe16_1;
  wire [0:0]probe17_1;
  wire [0:0]probe18_1;
  wire [0:0]probe19_1;
  wire [0:0]probe1_1;
  wire [0:0]probe20_1;
  wire [5:0]probe21_1;
  wire [20:0]probe22_1;
  wire [7:0]probe23_1;
  wire [63:0]probe24_1;
  wire [15:0]probe25_1;
  wire [0:0]probe26_1;
  wire [0:0]probe27_1;
  wire [0:0]probe28_1;
  wire [0:0]probe29_1;
  wire [0:0]probe2_1;
  wire [0:0]probe30_1;
  wire [0:0]probe31_1;
  wire [0:0]probe3_1;
  wire [0:0]probe4_1;
  wire [0:0]probe5_1;
  wire [15:0]probe6_1;
  wire [5:0]probe7_1;
  wire [15:0]probe8_1;
  wire [15:0]probe9_1;

  assign clk_1 = clk;
  assign probe0_1 = probe0[5:0];
  assign probe10_1 = probe10[0];
  assign probe11_1 = probe11[15:0];
  assign probe12_1 = probe12[5:0];
  assign probe13_1 = probe13[0];
  assign probe14_1 = probe14[0];
  assign probe15_1 = probe15[11:0];
  assign probe16_1 = probe16[0];
  assign probe17_1 = probe17[0];
  assign probe18_1 = probe18[0];
  assign probe19_1 = probe19[0];
  assign probe1_1 = probe1[0];
  assign probe20_1 = probe20[0];
  assign probe21_1 = probe21[5:0];
  assign probe22_1 = probe22[20:0];
  assign probe23_1 = probe23[7:0];
  assign probe24_1 = probe24[63:0];
  assign probe25_1 = probe25[15:0];
  assign probe26_1 = probe26[0];
  assign probe27_1 = probe27[0];
  assign probe28_1 = probe28[0];
  assign probe29_1 = probe29[0];
  assign probe2_1 = probe2[0];
  assign probe30_1 = probe30[0];
  assign probe31_1 = probe31[0];
  assign probe3_1 = probe3[0];
  assign probe4_1 = probe4[0];
  assign probe5_1 = probe5[0];
  assign probe6_1 = probe6[15:0];
  assign probe7_1 = probe7[5:0];
  assign probe8_1 = probe8[15:0];
  assign probe9_1 = probe9[15:0];
  bd_f60c_ila_lib_0 ila_lib
       (.clk(clk_1),
        .probe0(probe0_1),
        .probe1(probe1_1),
        .probe10(probe10_1),
        .probe11(probe11_1),
        .probe12(probe12_1),
        .probe13(probe13_1),
        .probe14(probe14_1),
        .probe15(probe15_1),
        .probe16(probe16_1),
        .probe17(probe17_1),
        .probe18(probe18_1),
        .probe19(probe19_1),
        .probe2(probe2_1),
        .probe20(probe20_1),
        .probe21(probe21_1),
        .probe22(probe22_1),
        .probe23(probe23_1),
        .probe24(probe24_1),
        .probe25(probe25_1),
        .probe26(probe26_1),
        .probe27(probe27_1),
        .probe28(probe28_1),
        .probe29(probe29_1),
        .probe3(probe3_1),
        .probe30(probe30_1),
        .probe31(probe31_1),
        .probe4(probe4_1),
        .probe5(probe5_1),
        .probe6(probe6_1),
        .probe7(probe7_1),
        .probe8(probe8_1),
        .probe9(probe9_1));
endmodule

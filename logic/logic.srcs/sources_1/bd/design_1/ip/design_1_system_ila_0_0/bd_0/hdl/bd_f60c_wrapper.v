//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_f60c_wrapper.bd
//Design : bd_f60c_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_f60c_wrapper
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
  input clk;
  input [5:0]probe0;
  input [0:0]probe1;
  input [0:0]probe10;
  input [0:0]probe11;
  input [31:0]probe12;
  input [0:0]probe13;
  input [63:0]probe14;
  input [0:0]probe15;
  input [0:0]probe16;
  input [0:0]probe17;
  input [63:0]probe18;
  input [0:0]probe19;
  input [0:0]probe2;
  input [0:0]probe20;
  input [0:0]probe21;
  input [0:0]probe22;
  input [0:0]probe23;
  input [0:0]probe24;
  input [0:0]probe25;
  input [0:0]probe26;
  input [0:0]probe27;
  input [0:0]probe28;
  input [0:0]probe29;
  input [31:0]probe3;
  input [2:0]probe30;
  input [0:0]probe31;
  input [31:0]probe4;
  input [10:0]probe5;
  input [15:0]probe6;
  input [15:0]probe7;
  input [0:0]probe8;
  input [0:0]probe9;

  wire clk;
  wire [5:0]probe0;
  wire [0:0]probe1;
  wire [0:0]probe10;
  wire [0:0]probe11;
  wire [31:0]probe12;
  wire [0:0]probe13;
  wire [63:0]probe14;
  wire [0:0]probe15;
  wire [0:0]probe16;
  wire [0:0]probe17;
  wire [63:0]probe18;
  wire [0:0]probe19;
  wire [0:0]probe2;
  wire [0:0]probe20;
  wire [0:0]probe21;
  wire [0:0]probe22;
  wire [0:0]probe23;
  wire [0:0]probe24;
  wire [0:0]probe25;
  wire [0:0]probe26;
  wire [0:0]probe27;
  wire [0:0]probe28;
  wire [0:0]probe29;
  wire [31:0]probe3;
  wire [2:0]probe30;
  wire [0:0]probe31;
  wire [31:0]probe4;
  wire [10:0]probe5;
  wire [15:0]probe6;
  wire [15:0]probe7;
  wire [0:0]probe8;
  wire [0:0]probe9;

  bd_f60c bd_f60c_i
       (.clk(clk),
        .probe0(probe0),
        .probe1(probe1),
        .probe10(probe10),
        .probe11(probe11),
        .probe12(probe12),
        .probe13(probe13),
        .probe14(probe14),
        .probe15(probe15),
        .probe16(probe16),
        .probe17(probe17),
        .probe18(probe18),
        .probe19(probe19),
        .probe2(probe2),
        .probe20(probe20),
        .probe21(probe21),
        .probe22(probe22),
        .probe23(probe23),
        .probe24(probe24),
        .probe25(probe25),
        .probe26(probe26),
        .probe27(probe27),
        .probe28(probe28),
        .probe29(probe29),
        .probe3(probe3),
        .probe30(probe30),
        .probe31(probe31),
        .probe4(probe4),
        .probe5(probe5),
        .probe6(probe6),
        .probe7(probe7),
        .probe8(probe8),
        .probe9(probe9));
endmodule

//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sun Dec  1 21:38:14 2019
//Host        : TomsDesktop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (FCLK_CLK0);
  output FCLK_CLK0;

  wire FCLK_CLK0;

  design_1 design_1_i
       (.FCLK_CLK0(FCLK_CLK0));
endmodule

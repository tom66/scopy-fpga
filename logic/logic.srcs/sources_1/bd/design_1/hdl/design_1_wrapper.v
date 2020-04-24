//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Thu Apr 23 22:54:51 2020
//Host        : TomsDesktop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (ADC_FCLK_N,
    ADC_FCLK_P,
    ADC_L1A_N,
    ADC_L1A_P,
    ADC_L1B_N,
    ADC_L1B_P,
    ADC_L2A_N,
    ADC_L2A_P,
    ADC_L2B_N,
    ADC_L2B_P,
    ADC_L3A_N,
    ADC_L3A_P,
    ADC_L3B_N,
    ADC_L3B_P,
    ADC_L4A_N,
    ADC_L4A_P,
    ADC_L4B_N,
    ADC_L4B_P,
    ADC_LCLK_N,
    ADC_LCLK_P,
    CLKWIZ0_CLKOUT1,
    CLKWIZ0_CLKOUT2,
    CSI_CLK_N,
    CSI_CLK_P,
    CSI_D0_N,
    CSI_D0_P,
    CSI_D1_N,
    CSI_D1_P,
    CSI_DONE,
    CSI_END_FRAME,
    CSI_LPCLK_N,
    CSI_LPCLK_P,
    CSI_LPD0_N,
    CSI_LPD0_P,
    CSI_LPD1_N,
    CSI_LPD1_P,
    CSI_SLEEP,
    CSI_START_FRAME,
    CSI_START_LINES,
    CSI_STOP,
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    EMIO_I,
    EMIO_O,
    FCLK_CLK0,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    GPIO_TEST,
    SPI_CLK,
    SPI_CSN,
    SPI_DATA_IN,
    SPI_DATA_OUT,
    SPI_DATA_OUT_TRIS,
    TRIGGER_OUT);
  input ADC_FCLK_N;
  input ADC_FCLK_P;
  input ADC_L1A_N;
  input ADC_L1A_P;
  input ADC_L1B_N;
  input ADC_L1B_P;
  input ADC_L2A_N;
  input ADC_L2A_P;
  input ADC_L2B_N;
  input ADC_L2B_P;
  input ADC_L3A_N;
  input ADC_L3A_P;
  input ADC_L3B_N;
  input ADC_L3B_P;
  input ADC_L4A_N;
  input ADC_L4A_P;
  input ADC_L4B_N;
  input ADC_L4B_P;
  input ADC_LCLK_N;
  input ADC_LCLK_P;
  output CLKWIZ0_CLKOUT1;
  output CLKWIZ0_CLKOUT2;
  output CSI_CLK_N;
  output CSI_CLK_P;
  output CSI_D0_N;
  output CSI_D0_P;
  output CSI_D1_N;
  output CSI_D1_P;
  output CSI_DONE;
  input CSI_END_FRAME;
  output CSI_LPCLK_N;
  output CSI_LPCLK_P;
  output CSI_LPD0_N;
  output CSI_LPD0_P;
  output CSI_LPD1_N;
  output CSI_LPD1_P;
  input CSI_SLEEP;
  input CSI_START_FRAME;
  input CSI_START_LINES;
  input CSI_STOP;
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  input [63:0]EMIO_I;
  output [63:0]EMIO_O;
  output FCLK_CLK0;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [1:0]GPIO_TEST;
  input SPI_CLK;
  input SPI_CSN;
  input SPI_DATA_IN;
  output SPI_DATA_OUT;
  output SPI_DATA_OUT_TRIS;
  output TRIGGER_OUT;

  wire ADC_FCLK_N;
  wire ADC_FCLK_P;
  wire ADC_L1A_N;
  wire ADC_L1A_P;
  wire ADC_L1B_N;
  wire ADC_L1B_P;
  wire ADC_L2A_N;
  wire ADC_L2A_P;
  wire ADC_L2B_N;
  wire ADC_L2B_P;
  wire ADC_L3A_N;
  wire ADC_L3A_P;
  wire ADC_L3B_N;
  wire ADC_L3B_P;
  wire ADC_L4A_N;
  wire ADC_L4A_P;
  wire ADC_L4B_N;
  wire ADC_L4B_P;
  wire ADC_LCLK_N;
  wire ADC_LCLK_P;
  wire CLKWIZ0_CLKOUT1;
  wire CLKWIZ0_CLKOUT2;
  wire CSI_CLK_N;
  wire CSI_CLK_P;
  wire CSI_D0_N;
  wire CSI_D0_P;
  wire CSI_D1_N;
  wire CSI_D1_P;
  wire CSI_DONE;
  wire CSI_END_FRAME;
  wire CSI_LPCLK_N;
  wire CSI_LPCLK_P;
  wire CSI_LPD0_N;
  wire CSI_LPD0_P;
  wire CSI_LPD1_N;
  wire CSI_LPD1_P;
  wire CSI_SLEEP;
  wire CSI_START_FRAME;
  wire CSI_START_LINES;
  wire CSI_STOP;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire [63:0]EMIO_I;
  wire [63:0]EMIO_O;
  wire FCLK_CLK0;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [1:0]GPIO_TEST;
  wire SPI_CLK;
  wire SPI_CSN;
  wire SPI_DATA_IN;
  wire SPI_DATA_OUT;
  wire SPI_DATA_OUT_TRIS;
  wire TRIGGER_OUT;

  design_1 design_1_i
       (.ADC_FCLK_N(ADC_FCLK_N),
        .ADC_FCLK_P(ADC_FCLK_P),
        .ADC_L1A_N(ADC_L1A_N),
        .ADC_L1A_P(ADC_L1A_P),
        .ADC_L1B_N(ADC_L1B_N),
        .ADC_L1B_P(ADC_L1B_P),
        .ADC_L2A_N(ADC_L2A_N),
        .ADC_L2A_P(ADC_L2A_P),
        .ADC_L2B_N(ADC_L2B_N),
        .ADC_L2B_P(ADC_L2B_P),
        .ADC_L3A_N(ADC_L3A_N),
        .ADC_L3A_P(ADC_L3A_P),
        .ADC_L3B_N(ADC_L3B_N),
        .ADC_L3B_P(ADC_L3B_P),
        .ADC_L4A_N(ADC_L4A_N),
        .ADC_L4A_P(ADC_L4A_P),
        .ADC_L4B_N(ADC_L4B_N),
        .ADC_L4B_P(ADC_L4B_P),
        .ADC_LCLK_N(ADC_LCLK_N),
        .ADC_LCLK_P(ADC_LCLK_P),
        .CLKWIZ0_CLKOUT1(CLKWIZ0_CLKOUT1),
        .CLKWIZ0_CLKOUT2(CLKWIZ0_CLKOUT2),
        .CSI_CLK_N(CSI_CLK_N),
        .CSI_CLK_P(CSI_CLK_P),
        .CSI_D0_N(CSI_D0_N),
        .CSI_D0_P(CSI_D0_P),
        .CSI_D1_N(CSI_D1_N),
        .CSI_D1_P(CSI_D1_P),
        .CSI_DONE(CSI_DONE),
        .CSI_END_FRAME(CSI_END_FRAME),
        .CSI_LPCLK_N(CSI_LPCLK_N),
        .CSI_LPCLK_P(CSI_LPCLK_P),
        .CSI_LPD0_N(CSI_LPD0_N),
        .CSI_LPD0_P(CSI_LPD0_P),
        .CSI_LPD1_N(CSI_LPD1_N),
        .CSI_LPD1_P(CSI_LPD1_P),
        .CSI_SLEEP(CSI_SLEEP),
        .CSI_START_FRAME(CSI_START_FRAME),
        .CSI_START_LINES(CSI_START_LINES),
        .CSI_STOP(CSI_STOP),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .EMIO_I(EMIO_I),
        .EMIO_O(EMIO_O),
        .FCLK_CLK0(FCLK_CLK0),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .GPIO_TEST(GPIO_TEST),
        .SPI_CLK(SPI_CLK),
        .SPI_CSN(SPI_CSN),
        .SPI_DATA_IN(SPI_DATA_IN),
        .SPI_DATA_OUT(SPI_DATA_OUT),
        .SPI_DATA_OUT_TRIS(SPI_DATA_OUT_TRIS),
        .TRIGGER_OUT(TRIGGER_OUT));
endmodule

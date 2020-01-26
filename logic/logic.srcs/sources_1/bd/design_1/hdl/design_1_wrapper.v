//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sat Jan 25 22:55:53 2020
//Host        : TomsDesktop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (ADC_BUS,
    ADC_DATA_CLK,
    ADC_DATA_EOF,
    ADC_DATA_VALID,
    ADC_FIFO_RESET,
    CFG_BRAM_ADDRB,
    CFG_BRAM_BUSYB,
    CFG_BRAM_CLKB,
    CFG_BRAM_DINB,
    CFG_BRAM_DOUTB,
    CFG_BRAM_ENB,
    CFG_BRAM_RSTB,
    CFG_BRAM_WEB,
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
    PL_IRQ);
  input [63:0]ADC_BUS;
  input ADC_DATA_CLK;
  input ADC_DATA_EOF;
  input ADC_DATA_VALID;
  input ADC_FIFO_RESET;
  input [31:0]CFG_BRAM_ADDRB;
  output CFG_BRAM_BUSYB;
  input CFG_BRAM_CLKB;
  input [31:0]CFG_BRAM_DINB;
  output [31:0]CFG_BRAM_DOUTB;
  input CFG_BRAM_ENB;
  input CFG_BRAM_RSTB;
  input [3:0]CFG_BRAM_WEB;
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
  input [13:0]PL_IRQ;

  wire [63:0]ADC_BUS;
  wire ADC_DATA_CLK;
  wire ADC_DATA_EOF;
  wire ADC_DATA_VALID;
  wire ADC_FIFO_RESET;
  wire [31:0]CFG_BRAM_ADDRB;
  wire CFG_BRAM_BUSYB;
  wire CFG_BRAM_CLKB;
  wire [31:0]CFG_BRAM_DINB;
  wire [31:0]CFG_BRAM_DOUTB;
  wire CFG_BRAM_ENB;
  wire CFG_BRAM_RSTB;
  wire [3:0]CFG_BRAM_WEB;
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
  wire [13:0]PL_IRQ;

  design_1 design_1_i
       (.ADC_BUS(ADC_BUS),
        .ADC_DATA_CLK(ADC_DATA_CLK),
        .ADC_DATA_EOF(ADC_DATA_EOF),
        .ADC_DATA_VALID(ADC_DATA_VALID),
        .ADC_FIFO_RESET(ADC_FIFO_RESET),
        .CFG_BRAM_ADDRB(CFG_BRAM_ADDRB),
        .CFG_BRAM_BUSYB(CFG_BRAM_BUSYB),
        .CFG_BRAM_CLKB(CFG_BRAM_CLKB),
        .CFG_BRAM_DINB(CFG_BRAM_DINB),
        .CFG_BRAM_DOUTB(CFG_BRAM_DOUTB),
        .CFG_BRAM_ENB(CFG_BRAM_ENB),
        .CFG_BRAM_RSTB(CFG_BRAM_RSTB),
        .CFG_BRAM_WEB(CFG_BRAM_WEB),
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
        .PL_IRQ(PL_IRQ));
endmodule

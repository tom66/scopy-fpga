//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Sat Feb 15 21:20:20 2020
//Host        : TomsDesktop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (ACQ_ABORT,
    ACQ_AXI_RUN,
    ACQ_DATA_LOSS,
    ACQ_DEPTH_A,
    ACQ_DEPTH_B,
    ACQ_DEPTH_MUX,
    ACQ_DONE,
    ACQ_HAVE_TRIG,
    ACQ_RUN,
    ACQ_TRIG_MASK,
    ACQ_TRIG_RST,
    ADC_BUS,
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
    FABCFG_COMMIT_MON,
    FABCFG_DONE_MON,
    FCLK_CLK0,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    PL_IRQ,
    TRIGGER_IN,
    TRIGGER_OUT,
    TRIGGER_POS,
    TRIGGER_SUB_WORD);
  input ACQ_ABORT;
  input ACQ_AXI_RUN;
  output ACQ_DATA_LOSS;
  input [28:0]ACQ_DEPTH_A;
  input [28:0]ACQ_DEPTH_B;
  input ACQ_DEPTH_MUX;
  output ACQ_DONE;
  output ACQ_HAVE_TRIG;
  input ACQ_RUN;
  input ACQ_TRIG_MASK;
  input ACQ_TRIG_RST;
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
  input FABCFG_COMMIT_MON;
  input FABCFG_DONE_MON;
  output FCLK_CLK0;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input [13:0]PL_IRQ;
  input TRIGGER_IN;
  output TRIGGER_OUT;
  output [31:0]TRIGGER_POS;
  input [2:0]TRIGGER_SUB_WORD;

  wire ACQ_ABORT;
  wire ACQ_AXI_RUN;
  wire ACQ_DATA_LOSS;
  wire [28:0]ACQ_DEPTH_A;
  wire [28:0]ACQ_DEPTH_B;
  wire ACQ_DEPTH_MUX;
  wire ACQ_DONE;
  wire ACQ_HAVE_TRIG;
  wire ACQ_RUN;
  wire ACQ_TRIG_MASK;
  wire ACQ_TRIG_RST;
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
  wire FABCFG_COMMIT_MON;
  wire FABCFG_DONE_MON;
  wire FCLK_CLK0;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [13:0]PL_IRQ;
  wire TRIGGER_IN;
  wire TRIGGER_OUT;
  wire [31:0]TRIGGER_POS;
  wire [2:0]TRIGGER_SUB_WORD;

  design_1 design_1_i
       (.ACQ_ABORT(ACQ_ABORT),
        .ACQ_AXI_RUN(ACQ_AXI_RUN),
        .ACQ_DATA_LOSS(ACQ_DATA_LOSS),
        .ACQ_DEPTH_A(ACQ_DEPTH_A),
        .ACQ_DEPTH_B(ACQ_DEPTH_B),
        .ACQ_DEPTH_MUX(ACQ_DEPTH_MUX),
        .ACQ_DONE(ACQ_DONE),
        .ACQ_HAVE_TRIG(ACQ_HAVE_TRIG),
        .ACQ_RUN(ACQ_RUN),
        .ACQ_TRIG_MASK(ACQ_TRIG_MASK),
        .ACQ_TRIG_RST(ACQ_TRIG_RST),
        .ADC_BUS(ADC_BUS),
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
        .FABCFG_COMMIT_MON(FABCFG_COMMIT_MON),
        .FABCFG_DONE_MON(FABCFG_DONE_MON),
        .FCLK_CLK0(FCLK_CLK0),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .PL_IRQ(PL_IRQ),
        .TRIGGER_IN(TRIGGER_IN),
        .TRIGGER_OUT(TRIGGER_OUT),
        .TRIGGER_POS(TRIGGER_POS),
        .TRIGGER_SUB_WORD(TRIGGER_SUB_WORD));
endmodule

//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Tue Mar 17 23:44:34 2020
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
    G_RST,
    PL_IRQ,
    TRIGGER_IN,
    TRIGGER_OUT,
    TRIGGER_SUB_WORD);
  input ACQ_ABORT;
  input ACQ_AXI_RUN;
  output ACQ_DATA_LOSS;
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
  input G_RST;
  input [3:0]PL_IRQ;
  input TRIGGER_IN;
  output TRIGGER_OUT;
  input [2:0]TRIGGER_SUB_WORD;

  wire ACQ_ABORT;
  wire ACQ_AXI_RUN;
  wire ACQ_DATA_LOSS;
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
  wire G_RST;
  wire [3:0]PL_IRQ;
  wire TRIGGER_IN;
  wire TRIGGER_OUT;
  wire [2:0]TRIGGER_SUB_WORD;

  design_1 design_1_i
       (.ACQ_ABORT(ACQ_ABORT),
        .ACQ_AXI_RUN(ACQ_AXI_RUN),
        .ACQ_DATA_LOSS(ACQ_DATA_LOSS),
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
        .G_RST(G_RST),
        .PL_IRQ(PL_IRQ),
        .TRIGGER_IN(TRIGGER_IN),
        .TRIGGER_OUT(TRIGGER_OUT),
        .TRIGGER_SUB_WORD(TRIGGER_SUB_WORD));
endmodule

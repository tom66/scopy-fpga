//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Thu Jan 23 11:31:47 2020
//Host        : TomsDesktop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (ADC_BUS,
    ADC_DATA_CLK,
    ADC_DATA_VALID,
    ADC_EOF,
    ADC_FIFO_FULL,
    ADC_FIFO_RST,
    AXI_ARESETN,
    AXI_CLK,
    M00_TDATA,
    M00_TLAST,
    M00_TREADY,
    M00_TSTRB,
    M00_TVALID);
  input [63:0]ADC_BUS;
  input ADC_DATA_CLK;
  input ADC_DATA_VALID;
  input ADC_EOF;
  output ADC_FIFO_FULL;
  input ADC_FIFO_RST;
  input AXI_ARESETN;
  input AXI_CLK;
  output [63:0]M00_TDATA;
  output M00_TLAST;
  input M00_TREADY;
  output [7:0]M00_TSTRB;
  output M00_TVALID;

  wire [63:0]ADC_BUS;
  wire ADC_DATA_CLK;
  wire ADC_DATA_VALID;
  wire ADC_EOF;
  wire ADC_FIFO_FULL;
  wire ADC_FIFO_RST;
  wire AXI_ARESETN;
  wire AXI_CLK;
  wire [63:0]M00_TDATA;
  wire M00_TLAST;
  wire M00_TREADY;
  wire [7:0]M00_TSTRB;
  wire M00_TVALID;

  design_1 design_1_i
       (.ADC_BUS(ADC_BUS),
        .ADC_DATA_CLK(ADC_DATA_CLK),
        .ADC_DATA_VALID(ADC_DATA_VALID),
        .ADC_EOF(ADC_EOF),
        .ADC_FIFO_FULL(ADC_FIFO_FULL),
        .ADC_FIFO_RST(ADC_FIFO_RST),
        .AXI_ARESETN(AXI_ARESETN),
        .AXI_CLK(AXI_CLK),
        .M00_TDATA(M00_TDATA),
        .M00_TLAST(M00_TLAST),
        .M00_TREADY(M00_TREADY),
        .M00_TSTRB(M00_TSTRB),
        .M00_TVALID(M00_TVALID));
endmodule

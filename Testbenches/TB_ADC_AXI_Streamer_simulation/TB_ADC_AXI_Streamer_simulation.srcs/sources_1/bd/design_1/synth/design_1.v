//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Thu Jan 23 11:31:47 2020
//Host        : TomsDesktop running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.AXI_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.AXI_CLK, ASSOCIATED_RESET AXI_ARESETN, CLK_DOMAIN design_1_AXI_CLK, FREQ_HZ 200000000, INSERT_VIP 0, PHASE 0.000" *) input AXI_CLK;
  output [63:0]M00_TDATA;
  output M00_TLAST;
  input M00_TREADY;
  output [7:0]M00_TSTRB;
  output M00_TVALID;

  wire [63:0]ADC_BUS_1;
  wire ADC_DATA_CLK_1;
  wire ADC_DATA_VALID_1;
  wire ADC_EOF_1;
  wire AXI_ARESETN_1;
  wire AXI_CLK_1;
  wire AXI_FIFO_RST_1;
  wire M00_TREADY_1;
  wire adc_streamer_0_adc_fifo_full;
  wire [63:0]adc_streamer_0_m00_axis_tdata;
  wire adc_streamer_0_m00_axis_tlast;
  wire [7:0]adc_streamer_0_m00_axis_tstrb;
  wire adc_streamer_0_m00_axis_tvalid;

  assign ADC_BUS_1 = ADC_BUS[63:0];
  assign ADC_DATA_CLK_1 = ADC_DATA_CLK;
  assign ADC_DATA_VALID_1 = ADC_DATA_VALID;
  assign ADC_EOF_1 = ADC_EOF;
  assign ADC_FIFO_FULL = adc_streamer_0_adc_fifo_full;
  assign AXI_ARESETN_1 = AXI_ARESETN;
  assign AXI_CLK_1 = AXI_CLK;
  assign AXI_FIFO_RST_1 = ADC_FIFO_RST;
  assign M00_TDATA[63:0] = adc_streamer_0_m00_axis_tdata;
  assign M00_TLAST = adc_streamer_0_m00_axis_tlast;
  assign M00_TREADY_1 = M00_TREADY;
  assign M00_TSTRB[7:0] = adc_streamer_0_m00_axis_tstrb;
  assign M00_TVALID = adc_streamer_0_m00_axis_tvalid;
  design_1_adc_streamer_0_0 adc_streamer_0
       (.adc_bus(ADC_BUS_1),
        .adc_data_clk(ADC_DATA_CLK_1),
        .adc_data_valid(ADC_DATA_VALID_1),
        .adc_eof(ADC_EOF_1),
        .adc_fifo_full(adc_streamer_0_adc_fifo_full),
        .adc_fifo_reset(AXI_FIFO_RST_1),
        .m00_axis_aclk(AXI_CLK_1),
        .m00_axis_aresetn(AXI_ARESETN_1),
        .m00_axis_tdata(adc_streamer_0_m00_axis_tdata),
        .m00_axis_tlast(adc_streamer_0_m00_axis_tlast),
        .m00_axis_tready(M00_TREADY_1),
        .m00_axis_tstrb(adc_streamer_0_m00_axis_tstrb),
        .m00_axis_tvalid(adc_streamer_0_m00_axis_tvalid));
endmodule

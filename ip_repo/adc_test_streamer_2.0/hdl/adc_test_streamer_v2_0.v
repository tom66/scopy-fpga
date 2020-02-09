
`timescale 1 ns / 1 ps

// This module could probably be eliminated and merged in with the actual logic module,
// but this is how it was done in the template from Xilinx that's been heavily modified, 
// so it'll stay this way for now.   9/2/2020 TGO.

module adc_test_streamer_v2_0 #
(
    // Parameters of Axi Master Bus Interface M00_AXIS
    parameter integer C_M00_AXIS_TDATA_WIDTH	= 64,
    parameter integer C_M00_AXIS_START_COUNT	= 32
)
(
    // Connection to ADC/trigger demux block
    input [63:0] adc_bus,
    input adc_data_clk,
    input wire adc_data_valid,
    input wire adc_fifo_reset,
    input wire adc_eof,
    
    // Debug signals
    output wire [5:0] dbg_adcstream_state,
    output wire dbg_axi_rdy,
    output wire dbg_acq_axi_running,
    output wire [31:0] dbg_acq_axi_upcounter,
    output wire [31:0] dbg_acq_axi_downcounter,
    output wire [10:0] dbg_acq_trigger_out_ctr,
    output wire [15:0] dbg_rd_data_count,
    output wire [15:0] dbg_wr_data_count,
    
    // Control signals
    input acq_run,
    input acq_abort,
    input acq_trig_mask,
    input acq_trig_rst,
    input acq_depth_mux,     // EMIO multiplex signal
    input [28:0] acq_depth_a,
    input [28:0] acq_depth_b,
    output acq_done,
    output acq_have_trig,
    input acq_axi_run,
    output acq_full_data_loss,
    
    // Trigger control inputs
    input trigger_in,
    input [2:0] trigger_sub_word,   // Sub word within trigger from trigger engine; merged with trigger position.
    output [31:0] trigger_pos,      // Trigger position data for FabCfg
    output trigger_out,             // Toggles on every trigger event
    
    // Ports of Axi Master Bus Interface M00_AXIS
    input wire  m00_axis_aclk,
    input wire  m00_axis_aresetn,
    output wire  m00_axis_tvalid,
    output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
    output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
    output wire  m00_axis_tlast,
    input wire  m00_axis_tready
);

// Instantiation of Axi Bus Interface M00_AXIS
adc_test_streamer_v2_0_M00_AXIS # ( 
    .C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
    .C_M_START_COUNT(C_M00_AXIS_START_COUNT)
) adc_test_streamer_v2_0_M00_AXIS_inst (
    .ADC_BUS(adc_bus),
    .ADC_DATA_CLK(adc_data_clk),
    .ADC_DATA_VALID(adc_data_valid),
    .ADC_FIFO_FULL(adc_fifo_full),
    .ADC_FIFO_RESET(adc_fifo_reset),
    .ADC_EOF(adc_eof),
    
    .dbg_adcstream_state(dbg_adcstream_state),
    .dbg_axi_rdy(dbg_axi_rdy),
    .dbg_acq_axi_running(dbg_acq_axi_running),
    .dbg_acq_axi_upcounter(dbg_acq_axi_upcounter),
    .dbg_acq_axi_downcounter(dbg_acq_axi_downcounter),
    .dbg_acq_trigger_out_ctr(dbg_acq_trigger_out_ctr),
    .dbg_rd_data_count(dbg_rd_data_count),
    .dbg_wr_data_count(dbg_wr_data_count),
    
    .ACQ_RUN(acq_run),
    .ACQ_ABORT(acq_abort),
    .ACQ_TRIG_MASK(acq_trig_mask),
    .ACQ_TRIG_RST(acq_trig_rst),
    .ACQ_DEPTH_MUX(acq_depth_mux),
    .ACQ_DEPTH_A(acq_depth_a),
    .ACQ_DEPTH_B(acq_depth_b),
    .ACQ_DONE(acq_done),
    .ACQ_HAVE_TRIG(acq_have_trig),
    .ACQ_AXI_RUN(acq_axi_run),
    .ACQ_FULL_DATA_LOSS(acq_full_data_loss),
    .TRIGGER_IN(trigger_in),
    .TRIGGER_SUB_WORD(trigger_sub_word),
    .TRIGGER_POS(trigger_pos),
    .TRIGGER_OUT(trigger_out),
    .M_AXIS_ACLK(m00_axis_aclk),
    .M_AXIS_ARESETN(m00_axis_aresetn),
    .M_AXIS_TVALID(m00_axis_tvalid),
    .M_AXIS_TDATA(m00_axis_tdata),
    .M_AXIS_TSTRB(m00_axis_tstrb),
    .M_AXIS_TLAST(m00_axis_tlast),
    .M_AXIS_TREADY(m00_axis_tready)
);

// User logic ends

endmodule

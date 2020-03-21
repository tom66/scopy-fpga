
`timescale 1 ns / 1 ps

module adc_streamer #
(
    // Parameters of Axi Master Bus Interface M00_AXIS
    parameter integer C_M00_AXIS_TDATA_WIDTH	= 64,
    parameter integer C_M00_AXIS_START_COUNT	= 32
)
(
    // Connection to ADC/trigger demux block
    input [63:0] adc_bus,
    input adc_data_clk,
    
    // Debug signals
    output wire [5:0] dbg_adcstream_state,
    output wire dbg_axi_rdy,
    output wire dbg_acq_axi_running,
    output wire [31:0] dbg_acq_axi_upcounter,
    output wire [31:0] dbg_acq_axi_downcounter,
    output wire [10:0] dbg_acq_trigger_out_ctr,
    output wire [15:0] dbg_rd_data_count,
    output wire [15:0] dbg_wr_data_count,
    output wire dbg_acq_run,
    output wire dbg_acq_axi_run,
    output wire dbg_acq_trig_mask,
    output wire dbg_acq_trig_rst,
    output wire dbg_acq_depth_mux,
    output wire dbg_acq_fifo_reset,
    output wire dbg_acq_abort,
    output wire dbg_acq_eof,
    output wire dbg_acq_data_valid,
    output wire dbg_trig_post_fifo,
    output wire dbg_acq_have_trig,
    output wire dbg_acq_tvalid_mask,
    
    // Control register and status register
    input wire [31:0] acq_ctrl_a,
    output wire [31:0] acq_status_a,
    output wire [31:0] acq_status_b,
    input wire [28:0] acq_depth_a,
    input wire [28:0] acq_depth_b,
    
    // IRQ output(s)
    output wire acq_reset_irq_gen,
    
    // PLL lock signal from IDELAYE2 - used to set bit in status register
    input pll_lock_idelaye2_clkref,
    
    // Trigger control inputs
    input trigger_in,
    input [2:0] trigger_sub_word,   // Sub word within trigger from trigger engine; merged with trigger position.
    output [31:0] trigger_pos,      // Trigger position data for PS
    output trigger_out,             // To be routed out to a BNC in future
    
    // Ports of Axi Master Bus Interface M00_AXIS
    input wire  m00_axis_aclk,
    input wire  m00_axis_aresetn,
    output wire  m00_axis_tvalid,
    output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
    output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
    output wire  m00_axis_tlast,
    input wire  m00_axis_tready
);

// Register signals:  Inputs to module
wire acq_run, acq_axi_run, acq_trig_mask, acq_trig_rst, acq_depth_mux, adc_fifo_reset, acq_abort, adc_eof, adc_data_valid;

assign acq_run = acq_ctrl_a[0];
assign acq_axi_run = acq_ctrl_a[1];
assign acq_trig_mask = acq_ctrl_a[2];
assign acq_trig_rst = acq_ctrl_a[3];
assign acq_depth_mux = acq_ctrl_a[4];
assign adc_fifo_reset = acq_ctrl_a[5];
assign acq_abort = acq_ctrl_a[6];
assign adc_eof = acq_ctrl_a[7];
assign adc_data_valid = acq_ctrl_a[8];

assign dbg_acq_run = acq_run;
assign dbg_acq_axi_run = acq_axi_run;
assign dbg_acq_trig_mask = acq_trig_mask;
assign dbg_acq_trig_rst = acq_trig_rst;
assign dbg_acq_depth_mux = acq_depth_mux;
assign dbg_acq_fifo_reset = adc_fifo_reset;
assign dbg_acq_abort = acq_abort;
assign dbg_acq_eof = adc_eof;
assign dbg_acq_data_valid = adc_data_valid;

wire [10:0] trig_out_width = {acq_ctrl_a[31:21]};

assign acq_status_a[0] = acq_done;
assign acq_status_a[1] = acq_have_trig;
assign acq_status_a[2] = acq_full_data_loss;
assign acq_status_a[3] = pll_lock_idelaye2_clkref;
assign acq_status_a[4] = acq_reset_irq_gen;

assign acq_status_a[15:10] = dbg_adcstream_state;
assign acq_status_a[31:16] = dbg_rd_data_count;

assign acq_status_b[0] = dbg_axi_rdy;
assign acq_status_b[1] = dbg_acq_axi_running;
assign acq_status_b[2] = dbg_trig_post_fifo;

assign acq_status_b[15: 5] = dbg_acq_trigger_out_ctr;
assign acq_status_b[31:16] = dbg_wr_data_count;

// Instantiation of Axi Bus Interface M00_AXIS
adc_streamer_v2_0_M00_AXIS # ( 
    .C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
    .C_M_START_COUNT(C_M00_AXIS_START_COUNT)
) adc_streamer_v2_0_M00_AXIS_inst (
    .ADC_BUS(adc_bus),
    .ADC_DATA_CLK(adc_data_clk),
    .ADC_DATA_VALID(adc_data_valid),
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
    .dbg_trig_post_fifo(dbg_trig_post_fifo),
    .dbg_acq_have_trig(dbg_acq_have_trig),
    .dbg_acq_tvalid_mask(dbg_acq_tvalid_mask),
    
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
    .ACQ_RESET_IRQ_GEN(acq_reset_irq_gen),
    
    .TRIGGER_OUT_WIDTH(trig_out_width),
    
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

`timescale 1 ns / 1 ps

module adc_streamer_v2_0_M00_AXIS #
(
    // Users to add parameters here

    // User parameters ends

    parameter integer C_M_AXIS_TDATA_WIDTH	= 64,
    // Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
    parameter integer C_M_START_COUNT	= 32
)
(
    input wire [63:0] ADC_BUS,
    input wire ADC_DATA_CLK,
    input wire ADC_DATA_VALID,
    input wire ADC_FIFO_RESET,
    input wire ADC_EOF,
    
    input ACQ_RUN,
    input ACQ_ABORT,
    input ACQ_TRIG_MASK,
    input ACQ_TRIG_RST,
    input ACQ_SUSPEND,
    input ACQ_DEPTH_MUX,
    input [28:0] ACQ_DEPTH_A,
    input [28:0] ACQ_DEPTH_B,
    output reg ACQ_DONE,
    output reg ACQ_HAVE_TRIG,
    input ACQ_AXI_RUN,
    output ACQ_FULL_DATA_LOSS,
    input [10:0] TRIGGER_OUT_WIDTH,
    output ACQ_RESET_IRQ_GEN,
    input ACQ_POST_TRIGGER,
    input ACQ_TRIG_SUPER_MASK,
    input ACQ_END_EARLY,
    
    input TRIGGER_IN,
    output reg TRIGGER_OUT,
    output reg [31:0] TRIGGER_POS,
    input [2:0] TRIGGER_SUB_WORD,
    output reg ACQ_ARMED_WAITING_TRIG,
    input ACQ_HOLDOFF,
    output reg ACQ_DONE_POST,
    
    output wire [5:0] dbg_adcstream_state,
    output wire dbg_axi_rdy,
    output wire dbg_acq_axi_running,
    output wire [31:0] dbg_acq_axi_upcounter,
    output wire [31:0] dbg_acq_axi_downcounter,
    output wire [10:0] dbg_acq_trigger_out_ctr,
    output wire [15:0] dbg_rd_data_count,
    output wire [15:0] dbg_wr_data_count,
    output wire dbg_trig_post_fifo,
    output wire dbg_acq_have_trig,
    output wire dbg_acq_tvalid_mask,
    output wire dbg_fifo_wr_en,
    output wire dbg_fifo_rd_en,
    output wire dbg_fifo_wr_rst_busy,
    output wire dbg_fifo_rd_rst_busy,
    output wire dbg_fifo_rst_holdoff,
    output wire dbg_acq_holdoff_regd,
    output wire dbg_adc_fifo_gated_clk,
    output wire [2:0] dbg_trig_pos_post_fifo,
    
    input wire  M_AXIS_ACLK,
    input wire  M_AXIS_ARESETN,
    output wire  M_AXIS_TVALID,
    output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
    output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
    output wire  M_AXIS_TLAST,
    input wire  M_AXIS_TREADY
);               
                                                                           
parameter ST_IDLE = 0;
parameter ST_STREAMING = 1;
parameter ST_STOP_TRIGGERED = 2;
parameter ST_STOP_EOF = 3;

// Debug signals
assign dbg_axi_rdy = M_AXIS_TREADY;
assign dbg_acq_axi_running = acq_axi_running;
assign dbg_adcstream_state = adcstream_state;
assign dbg_trigger_out_ctr = trigger_out_ctr;
assign dbg_acq_axi_upcounter = acq_axi_upcounter;
assign dbg_acq_axi_downcounter = acq_axi_downcounter;
assign dbg_acq_trigger_out_ctr = dbg_acq_trigger_out_ctr;
assign dbg_acq_have_trig = ACQ_HAVE_TRIG;
assign dbg_acq_tvalid_mask = acq_tvalid_mask;
assign dbg_fifo_wr_en = fifo_wr_en;
assign dbg_fifo_rd_en = fifo_rd_en;
assign dbg_fifo_wr_rst_busy = fifo_wr_busy;
assign dbg_fifo_rd_rst_busy = fifo_rd_busy;
    
reg [5:0] adcstream_state = ST_IDLE;

reg acq_tvalid = 0;
reg acq_axi_running = 0;
reg acq_gen_tlast = 0; 
wire acq_gen_tlast_mask;
reg adc_fifo_reset_regd = 0;
reg [1:0] acq_gen_tlast_ctr = 0;
reg acq_tvalid_mask = 0;
 
// AXI run signal, registered to AXI CLK, and last register,
// used to detect rising edge
reg acq_axi_run_regd = 0;
reg acq_axi_run_last = 0;

reg [10:0] trigger_out_ctr;

// TODO: try to figure out how we could common these counters
reg [28:0] acq_axi_downcounter = 0;
reg [28:0] acq_axi_upcounter = 0;

reg adc_fifo_full_latch = 0;                    // Latched state only cleared after FIFO reset
wire adc_fifo_full_state;                       // State from FIFO directly
assign ADC_FIFO_FULL = adc_fifo_full_latch;
assign ACQ_FULL_DATA_LOSS = ADC_FIFO_FULL; // adc_fifo_full_latch;

// TVALID is high when: (FIFO not almost empty, TVALID mask is set, ACQ_SUSPEND not set) or TLAST mask is set
assign M_AXIS_TVALID = (acq_tvalid_mask && (!fifo_almost_empty) && (!ACQ_SUSPEND)) || acq_gen_tlast_mask; 
assign M_AXIS_TDATA	= fifo_data_out;
assign M_AXIS_TLAST	= acq_gen_tlast_mask; 

// TSTRB == not used (set to all 1's)
assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

wire fifo_almost_empty;
wire fifo_full;

// Output busy signals from the FIFO generator (not presently used)
wire fifo_wr_busy;
wire fifo_rd_busy;

// Write enabled when ADC_VALID asserted (Data should start filling FIFO; DMA will ready when ready) and holdoff period not active
wire fifo_wr_en = ADC_DATA_VALID && (!acq_holdoff_regd);  
 
// Read enabled when TREADY asserted & data available in FIFO & acq_axi_running asserted & TVALID not masked & ACQ not suspended
wire fifo_rd_en = M_AXIS_TREADY && (!fifo_almost_empty) && acq_axi_running && acq_tvalid_mask && (!ACQ_SUSPEND); 

// FIFO reset a combination of AXI reset and external slow reset signal
wire fifo_int_reset = ((!M_AXIS_ARESETN) || adc_fifo_reset_regd || fifo_reset_holdoff);    

// Generate combinational trigger signal.  Trigger signal is at least one ADCCLK wide, and once generated
// cannot be re-generated until a TRIG_RST signal is sent.
/*
reg trigger_comb = 0, trigger_comb_sub = 0, trigger_state = 0;

always @(posedge ADC_DATA_CLK) begin

    if (!trigger_state) begin
        if (TRIGGER_IN) begin
            trigger_comb <= 1;
            trigger_state <= 1;
            trigger_comb_sub <= 0;
        end
    end else begin
        if (trigger_comb) begin
            trigger_comb <= 0;
        end
        
        if (ACQ_TRIG_RST) begin
            trigger_state <= 0;
        end
    end

end
*/

reg acq_reset_irq_gen_reg = 0;
assign ACQ_RESET_IRQ_GEN = acq_reset_irq_gen_reg;

reg acq_holdoff_regd;
reg acq_holdoff_last;                           
reg fifo_reset_holdoff = 0;
reg [3:0] fifo_reset_holdoff_ctr = 0;

assign dbg_fifo_rst_holdoff = fifo_reset_holdoff;
assign dbg_acq_holdoff_regd = acq_holdoff_regd;

reg force_tlast = 0;

// Clock gating for FIFO
wire adc_fifo_gated_clock;
assign dbg_adc_fifo_gated_clk = adc_fifo_gated_clock;

BUFGCE (
    .I(ADC_DATA_CLK),
    .O(adc_fifo_gated_clock),
    .CE(!acq_holdoff_regd)
);

always @(posedge M_AXIS_ACLK) begin

    acq_holdoff_regd <= ACQ_HOLDOFF;
    
    if (fifo_reset_holdoff_ctr == 0) begin
        fifo_reset_holdoff <= 0;
    end else begin
        fifo_reset_holdoff_ctr <= fifo_reset_holdoff_ctr - 1;
    end
    
    // Generate a minimum 10-cycle wide reset pulse at the end of holdoff.
    if (acq_holdoff_last && !acq_holdoff_regd) begin
        fifo_reset_holdoff <= 1;
        fifo_reset_holdoff_ctr <= 10;
    end
    
    acq_holdoff_last <= acq_holdoff_regd;

end

// FIFO data in and data out consists of trigger_signal + 64-bit data.  
wire [67:0] fifo_data_in;
assign fifo_data_in[63:0] = ADC_BUS;
assign fifo_data_in[64] = TRIGGER_IN;
assign fifo_data_in[67:65] = TRIGGER_SUB_WORD;
wire [67:0] fifo_data_out;
wire fifo_out_trigger;
assign fifo_out_trigger = fifo_data_out[64];
wire [2:0] fifo_out_trigpos = fifo_data_out[67:65];
assign dbg_trig_post_fifo = fifo_out_trigger;
assign dbg_trig_pos_post_fifo = fifo_out_trigpos;

// FIFO generator connection (block design)
fifo_generator_adc_streamer (
    .full(adc_fifo_full_state),
    .wr_en(fifo_wr_en),
    .prog_empty(fifo_almost_empty),
    .rd_en(fifo_rd_en),
    .din(fifo_data_in),
    .wr_clk(adc_fifo_gated_clock),
    .dout(fifo_data_out),
    .rd_clk(M_AXIS_ACLK),
    .rst(fifo_int_reset),
    .rd_data_count(dbg_rd_data_count),
    .wr_data_count(dbg_wr_data_count)
    //.wr_rst_busy(fifo_wr_busy),
    //.rd_rst_busy(fifo_rd_busy)
);

/*
 * As TLAST needs to occur on the -exact- cycle that a trigger occurs 
 * on or word count reaches zero, we generate it using combinational logic.
 */
assign acq_gen_tlast_mask = ((acq_axi_downcounter == 0) || (fifo_out_trigger && (!ACQ_TRIG_MASK)) || force_tlast) && (adcstream_state == ST_STREAMING);

/*
 * State machine.  This runs on the AXI bus clock. 
 */
always @(posedge M_AXIS_ACLK) begin

    /*
     * Trigger out generator.  Generate an N-clock pulse every time a trigger
     * is accepted by the acquisition engine.  Note this is NOT the same as 
     * the direct trigger signal.  Also note the output pulse width is a multiple
     * of the AXI bus clock, which should be fixed by design.
     */
    if (trigger_out_ctr > 1) begin
        trigger_out_ctr <= trigger_out_ctr - 1;
        TRIGGER_OUT <= 1;
    end else begin
        TRIGGER_OUT <= 0;
    end
    
    /*
     * AXI reset control.  Sets trigger_pos to invalid value during reset.
     */
    if (!M_AXIS_ARESETN) begin
        TRIGGER_POS <= 32'hfffffffd;
    end
    
    /*
     * If FIFO_FULL goes high then we set a state which is only cleared by starting
     * a new acquisition.  This signal indicates that the FIFO must be reset at the
     * next available opportunity.
     */
    if (adc_fifo_full_state) begin
        adc_fifo_full_latch <= 1;
    end else begin
        if (adc_fifo_full_latch && adc_fifo_reset_regd) begin
            adc_fifo_full_latch <= 0;
        end
    end
    
    case (adcstream_state) 
    
        ST_IDLE : begin
            ACQ_HAVE_TRIG <= 0;
            ACQ_DONE <= 0;
            ACQ_ARMED_WAITING_TRIG <= 0;
            ACQ_DONE_POST <= 0;  
            
            // Can't start a new transaction if either ABORT or END_EARLY asserted
            if (!ACQ_ABORT && !ACQ_END_EARLY) begin
                if (acq_axi_run_regd && M_AXIS_TREADY) begin
                    // Load the required downcounter
                    if (!ACQ_DEPTH_MUX) begin
                        acq_axi_downcounter <= ACQ_DEPTH_A;
                    end else begin
                        acq_axi_downcounter <= ACQ_DEPTH_B;
                    end
                    
                    acq_axi_upcounter <= 0;
                    force_tlast <= 0;
                    
                    adc_fifo_full_latch <= 0;
                    acq_axi_running <= 1;
                    acq_tvalid_mask <= 1;
                    adcstream_state <= ST_STREAMING;
                end
            end
        end
        
        ST_STREAMING : begin
            // Do nothing while ACQ_HOLDOFF (registered) set
            if (!acq_holdoff_regd) begin
                // Evaluate state if TLAST asserted, or data in FIFO & master OK to accept.  This is
                // needed to prevent lockup if FIFO goes empty during TLAST generation; we will still
                // be able to advance the state machine.
                if (((!fifo_almost_empty) && M_AXIS_TREADY) || acq_gen_tlast_mask) begin
                    // Only adjust counters and handle triggers, etc. if data is available in FIFO,
                    // and master OK to accept.
                    if ((!fifo_almost_empty) && M_AXIS_TREADY) begin
                        acq_axi_upcounter <= acq_axi_upcounter + 1;
                        acq_axi_downcounter <= acq_axi_downcounter - 1;
                    end
                
                    if (acq_axi_downcounter == 0) begin
                        // Trigger not valid in this instance; set TRIGGER_POS to invalid value
                        acq_tvalid_mask <= 0;
                        adcstream_state <= ST_STOP_EOF;
                        TRIGGER_POS <= 32'hffffffff;
                    end else if (fifo_out_trigger && (!ACQ_TRIG_MASK)) begin
                        // TRIG_MASK is used to void the trigger during post-trigger acquisition,
                        // we completely ignore it.
                        acq_tvalid_mask <= 0;
                        adcstream_state <= ST_STOP_TRIGGERED;
                    
                        // Load merged trigger position register (32 bits)
                        TRIGGER_POS <= {2'b00, acq_axi_upcounter, fifo_out_trigpos};
                        
                        // Load trigger counter to generate trigger pulse (1us at ~177MHz)
                        // TODO: this might be application configurable to consistently generate the same pulse
                        // width at different AXI(?) rates, also for user configurability if desired.
                        trigger_out_ctr <= TRIGGER_OUT_WIDTH; 
                    end
                    
                    // END_EARLY signal going high causes artificial end of acquisition without trigger
                    if (ACQ_END_EARLY) begin
                        acq_tvalid_mask <= 0;
                        
                        if (!force_tlast) begin
                            force_tlast <= 1;
                        end else begin
                            force_tlast <= 0;
                            adcstream_state <= ST_STOP_EOF;
                        end
                        
                        TRIGGER_POS <= 32'hfffffffc;
                    end
                end else begin
                    // While acquiring, but without trigger, load trigger_pos with invalid value
                    TRIGGER_POS <= 32'hfffffffe;
                end
                
                // Send armed, waiting for trigger signal if trig_super_mask is not set.  This allows
                // the trigger engine to generate a trigger for us.  Super mask can be used to ensure no
                // triggers are fed into the FIFO, but a performance benefit is available if we don't 
                // have to wait for triggers to bubble through on shorter acquisitions.
                if (!ACQ_TRIG_SUPER_MASK) begin
                    ACQ_ARMED_WAITING_TRIG <= 1;
                end
            end
        end
        
        ST_STOP_TRIGGERED : begin
            // Leave IOs in the "stopped-with-trig" state;  to exit this state the 
            // PS must drive ACQ_AXI_RUN thru a falling edge
            ACQ_HAVE_TRIG <= 1;
            ACQ_DONE <= 1;
            
            // This doesn't really do anything - we don't set ACQ_POST_TRIGGER on a triggered post-acquisition do we?
            //if (ACQ_POST_TRIGGER) begin
            //    ACQ_DONE_POST <= 1;
            //end
            
            ACQ_ARMED_WAITING_TRIG <= 0;
            acq_tvalid_mask <= 0;
            
            if (!acq_axi_run_regd && acq_axi_run_last) begin
                adcstream_state <= ST_IDLE;
            end
            
            if (ACQ_END_EARLY) begin
                adcstream_state <= ST_IDLE;
            end
        end
        
        ST_STOP_EOF : begin
            // Leave IOs in the "stopped-with-no-trig" state;  to exit this state the 
            // PS must drive ACQ_AXI_RUN thru a falling edge
            ACQ_HAVE_TRIG <= 0;
            ACQ_DONE <= 1;
            force_tlast <= 0;
            
            if (ACQ_POST_TRIGGER) begin
                ACQ_DONE_POST <= 1;
            end
            
            ACQ_ARMED_WAITING_TRIG <= 0;
            acq_tvalid_mask <= 0;
            
            if (!acq_axi_run_regd && acq_axi_run_last && !ACQ_ABORT) begin
                adcstream_state <= ST_IDLE;
            end
            
            if (ACQ_END_EARLY) begin
                adcstream_state <= ST_IDLE;
            end
        end
    
    endcase
    
    // Detect IRQ lockup condition ...
    //
    // Condition occurs when:
    //  - FIFO is full (fifo_full signal asserted)
    //  - State machine is in state 2 or 3 (most commonly 2)
    //  - axi_run signal is still asserted
    //
    // This seems to occur as an interrupt is missed or not handled by the PS.
    //
    // Missing the interrupt causes a lockup so we handle this case here, generating
    // a secondary interrupt via another port which will generate a PL interrupt.
    if (ADC_FIFO_FULL && ((adcstream_state == ST_STOP_TRIGGERED) || (adcstream_state == ST_STOP_EOF)) && acq_axi_run_regd) begin
        acq_reset_irq_gen_reg <= 1;
    end
    
    // Reset condition:  Must drive ACQ_ABORT signal.
    if (ACQ_ABORT && acq_reset_irq_gen_reg) begin
        acq_reset_irq_gen_reg <= 0;
        adcstream_state <= ST_IDLE;
    end

    acq_axi_run_regd <= ACQ_AXI_RUN;
    acq_axi_run_last <= acq_axi_run_regd;
    adc_fifo_reset_regd <= ADC_FIFO_RESET;
    
end

endmodule

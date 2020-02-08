`timescale 1 ns / 1 ps

module adc_test_streamer_v2_0_M00_AXIS #
(
    // Users to add parameters here

    // User parameters ends

    parameter integer C_M_AXIS_TDATA_WIDTH	= 64,
    // Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
    parameter integer C_M_START_COUNT	= 32
)
(
    // Users to add ports here
    input wire [63:0] ADC_BUS,
    input wire ADC_DATA_CLK,
    input wire ADC_DATA_VALID,
    output wire ADC_FIFO_FULL,
    input wire ADC_FIFO_RESET,
    input wire ADC_EOF,
    
    output wire [5:0] dbg_adcstream_state,
    output wire dbg_axi_rdy,
    output wire dbg_acq_axi_running,
    output wire [31:0] dbg_acq_axi_upcounter,
    output wire [31:0] dbg_acq_axi_downcounter,
    output wire [10:0] dbg_acq_trigger_out_ctr,
    output wire [9:0] dbg_rd_data_count,
    output wire [9:0] dbg_wr_data_count,

    input ACQ_RUN,
    input ACQ_ABORT,
    input ACQ_TRIG_MASK,
    input ACQ_TRIG_RST,
    input ACQ_DEPTH_MUX,
    input [28:0] ACQ_DEPTH_A,
    input [28:0] ACQ_DEPTH_B,
    output reg ACQ_DONE,
    output reg ACQ_HAVE_TRIG,
    input ACQ_AXI_RUN,
    
    input TRIGGER_IN,
    output reg TRIGGER_OUT,
    output reg [31:0] TRIGGER_POS,
    input [2:0] TRIGGER_SUB_WORD,
    
    // User ports ends
    // Do not modify the ports beyond this line

    // Global ports
    input wire  M_AXIS_ACLK,
    // 
    input wire  M_AXIS_ARESETN,
    // Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
    output wire  M_AXIS_TVALID,
    // TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
    // TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
    output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
    // TLAST indicates the boundary of a packet.
    output wire  M_AXIS_TLAST,
    // TREADY indicates that the slave can accept a transfer in the current cycle.
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

reg [5:0] adcstream_state = ST_IDLE;

reg acq_tvalid = 0;
reg acq_axi_running = 0;

// TODO: try to figure out how we could common these counters
reg [28:0] acq_axi_downcounter = 0;
reg [28:0] acq_axi_upcounter = 0;

wire [63:0] fifo_data_out;

// TVALID is high when: FIFO reset not busy,  FIFO not almost empty
assign M_AXIS_TVALID = /*(!fifo_rd_busy) && */(!fifo_almost_empty) && acq_gen_tvalid_mask; 
assign M_AXIS_TDATA	= fifo_data_out;
assign M_AXIS_TLAST	= acq_gen_tlast; 

// TSTRB == not used (set to all 1's)
assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

wire fifo_almost_empty;
wire fifo_full;

// Output busy signals from the FIFO generator
wire fifo_wr_busy;
wire fifo_rd_busy;

// Write enabled when ADC_VALID asserted (Data should start filling FIFO; DMA will ready when ready)
wire fifo_wr_en = ADC_DATA_VALID;                             
 
// Read enabled when TREADY asserted & data available in FIFO & acq_axi_running asserted & TVALID present
wire fifo_rd_en = M_AXIS_TREADY && (!fifo_almost_empty) && acq_axi_running && acq_gen_tvalid_mask;        

// FIFO reset a combination of external reset and global slow reset signal
wire fifo_int_reset = ((!M_AXIS_ARESETN) || ADC_FIFO_RESET);    

// FIFO generator connection (block design)
fifo_generator_0 fifo_generator_0_inst (
    .full(ADC_FIFO_FULL),
    .wr_en(fifo_wr_en),
    .prog_empty(fifo_almost_empty),
    .rd_en(fifo_rd_en),
    .din(ADC_BUS),
    .wr_clk(ADC_DATA_CLK),
    .dout(fifo_data_out),
    .rd_clk(M_AXIS_ACLK),
    .rst(fifo_int_reset),
    .rd_data_count(dbg_rd_data_count),
    .wr_data_count(dbg_wr_data_count)
    //.wr_rst_busy(fifo_wr_busy),
    //.rd_rst_busy(fifo_rd_busy)
);

/*
 * TLAST/TVALID generator.  Crosses clock domain to generate short TLAST pulse
 * when signalled.
 */
reg acq_gen_tlast = 0; 
reg acq_gen_tvalid_mask = 0;
reg [1:0] acq_gen_tlast_ctr = 0;
reg adcclkdm_tlast_gen = 0;         // Signal from ADC clock domain that TLAST should be generated
reg adcclkdm_tvalid_init = 0;       // Signal from ADC clock domain that TVALID MASK should be generated
reg adcclkdm_tlast_gen_last = 0;

always @(posedge M_AXIS_ACLK) begin

    // TVALID signal - start generating mask for TVALID
    if (adcclkdm_tvalid_init) begin
        acq_gen_tvalid_mask <= 1; 
    end
    
    // TVALID stays high while TLAST is asserted;  this state will remain for 1 cycle.
    // Only generate TLAST pulse on rising edge of ADC clock domain TLAST signal.
    if (adcclkdm_tlast_gen && !adcclkdm_tlast_gen_last) begin
        acq_gen_tlast <= 1;
        //acq_gen_tvalid_mask <= 1;
        acq_gen_tlast_ctr <= 0;
    end
    
    // Increment our tiny counter if TLAST is being generated.
    if (acq_gen_tlast) begin
        acq_gen_tlast_ctr <= acq_gen_tlast_ctr + 1;
    end
    
    // TVALID and TLAST fall at same time
    if (acq_gen_tlast_ctr == 1) begin
        acq_gen_tvalid_mask <= 0;
        acq_gen_tlast <= 0;
    end

    adcclkdm_tlast_gen_last <= adcclkdm_tlast_gen;  

end
 
reg [10:0] trigger_out_ctr;

/*
 * State machine.  This runs on the ADC clock.  
 * FIXME:  I need to analyse if there are metastability issues regarding
 * reading values from this clock domain into the fabric domain.
 */
always @(posedge ADC_DATA_CLK) begin

    // Trigger out generator.  Generate a 16-clock pulse every time a trigger
    // is accepted by the acquisition engine.  Note this is NOT the same as 
    // the direct trigger signal.
    if (trigger_out_ctr > 1) begin
        trigger_out_ctr <= trigger_out_ctr - 1;
        TRIGGER_OUT <= 1;
    end else begin
        TRIGGER_OUT <= 0;
    end

    case (adcstream_state) 
    
        ST_IDLE : begin
            if (ACQ_AXI_RUN && M_AXIS_TREADY) begin
                ACQ_HAVE_TRIG <= 0;
                ACQ_DONE <= 0;
            
                // Load the required downcounter
                if (ACQ_DEPTH_MUX) begin
                    acq_axi_downcounter <= ACQ_DEPTH_A;
                end else begin
                    acq_axi_downcounter <= ACQ_DEPTH_B;
                end
                
                // Invalid TRIGGER_POS:  Acq not yet run
                TRIGGER_POS <= 32'hfffffffe;
    
                acq_axi_upcounter <= 0;
                acq_axi_running <= 1;
                adcclkdm_tvalid_init <= 1;
                adcstream_state <= ST_STREAMING;
            end
        end
        
        ST_STREAMING : begin
            // Only adjust counters if data is available in FIFO (no underrun)
            acq_axi_upcounter <= acq_axi_upcounter + 1;
            
            // Remove TVALID generator signal after a few ticks;  the exact time
            // is not terribly important, it just needs to have reached the AXI 
            // clock domain.
            if (acq_axi_upcounter == 4) begin
                adcclkdm_tvalid_init <= 0;
            end
        
            // Streaming jumps to STOP_EOF if downcounter is zero
            acq_axi_downcounter <= acq_axi_downcounter - 1;
            
            if (acq_axi_downcounter == 0) begin
                // Trigger not valid in this instance; set TRIGGER_POS to invalid value
                adcstream_state <= ST_STOP_EOF;
                TRIGGER_POS <= 32'hffffffff;
 
                
                // Stop TVALID generation (data is no longer valid); start TLAST pulse generation
                acq_tvalid <= 0;
                adcclkdm_tlast_gen <= 1;
            end else begin
                // Level sensitive trigger:  actual trigger state generated by external trigger machine
                // If TRIG_MASK is high, then TRIGGER_IN is ignored.
                if (TRIGGER_IN && !ACQ_TRIG_MASK) begin
                    adcstream_state <= ST_STOP_TRIGGERED;
                    
                    // Stop TVALID generation (data is no longer valid)
                    acq_tvalid <= 0;
                    adcclkdm_tlast_gen <= 1;
                
                    // Load merged trigger position register (30 bits)
                    TRIGGER_POS <= {2'b00, acq_axi_upcounter, TRIGGER_SUB_WORD};
                    
                    // Load trigger counter to generate trigger pulse (1us at 1GSa/s)
                    // TODO: this will be application configurable to consistently generate the same pulse
                    // width at different sample rates, also for user configurability if desired.
                    trigger_out_ctr <= 124; 
                end
            end
        end
        
        ST_STOP_TRIGGERED : begin
            // Leave IOs in the "stopped-with-trig" state;  to exit this state the 
            // PS must drive ACQ_AXI_RUN low
            ACQ_HAVE_TRIG <= 1;
            ACQ_DONE <= 1;
            
            // Stop sending TLAST signal to TLAST generator block
            adcclkdm_tlast_gen <= 0;
            
            if (!ACQ_AXI_RUN) begin
                adcstream_state <= ST_IDLE;
            end
        end
        
        ST_STOP_EOF : begin
            // Leave IOs in the "stopped-with-no-trig" state;  to exit this state the 
            // PS must drive ACQ_AXI_RUN low
            ACQ_HAVE_TRIG <= 0;
            ACQ_DONE <= 1;
            
            // Stop sending TLAST signal to TLAST generator block
            adcclkdm_tlast_gen <= 0;
            
            if (!ACQ_AXI_RUN) begin
                adcstream_state <= ST_IDLE;
            end
        end
    
    endcase

end

endmodule


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
    output TRIGGER_OUT,
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
// Total number of output data                                                 
localparam NUMBER_OF_OUTPUT_WORDS = 32;                                               
                                                                                     
// function called clogb2 that returns an integer which has the                      
// value of the ceiling of the log base 2.                                           
function integer clogb2 (input integer bit_depth);                                   
  begin                                                                              
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
      bit_depth = bit_depth >> 1;                                                    
  end                                                                                
endfunction                                                                          
                                                                                     
parameter ST_IDLE = 0;                                                               
parameter ST_STREAMING = 1;                                                          
parameter ST_STOP_TRIGGERED = 2;                                                     
parameter ST_STOP_EOF = 3;

reg [5:0] adcstream_state = ST_IDLE;

reg acq_axi_running = 0;

// TODO: try to figure out how we could common these counters
reg [28:0] acq_axi_downcounter = 0;
reg [28:0] acq_axi_upcounter = 0;

// AXI Stream internal signals
//wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
reg [WAIT_COUNT_BITS-1 : 0] 	count;
//streaming data valid
wire  	axis_tvalid;
//streaming data valid delayed by one clock cycle
reg  	axis_tvalid_delay;
//Last of the streaming data 
wire  	axis_tlast;
//Last of the streaming data delayed by one clock cycle
//reg  	axis_tlast_delay;
//FIFO implementation signals
reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;
wire  	tx_en;
//The master has issued all the streaming data stored in FIFO
reg  	tx_done;

// I/O Connections assignments

wire [63:0] fifo_data_out;

// TVALID is high when: FIFO reset not busy,  FIFO not almost empty
assign M_AXIS_TVALID = /*(!fifo_rd_busy) && */(!fifo_almost_empty); 

// TDATA == stream_data_out
assign M_AXIS_TDATA	= fifo_data_out;

// TLAST == ADC_EOF (signal generated external to this module)
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
 
// Read enabled when TREADY asserted & data available in FIFO & acq_axi_running asserted
wire fifo_rd_en = M_AXIS_TREADY && (!fifo_almost_empty) && acq_axi_running;        

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
 * TLAST generator.  Crosses clock domain to generate 1-clock TLAST pulse
 * when signalled.
 */
reg acq_gen_tlast = 0; 
reg adcclkdm_tlast_gen = 0;
reg adcclkdm_tlast_gen_last = 0;

always @(posedge M_AXIS_ACLK) begin

    if (adcclkdm_tlast_gen && !adcclkdm_tlast_gen_last) begin
        acq_gen_tlast <= 1;
        // TODO: Turn off TLAST....
    end

    adcclkdm_tlast_gen_last <= adcclkdm_tlast_gen;  

end
 
/*
 * State machine.  This runs on the ADC clock.  
 * FIXME:  I need to analyse if there are metastability issues regarding
 * reading values from this clock domain into the fabric domain.
 */
always @(posedge ADC_DATA_CLK) begin

    case (adcstream_state) 
    
        ST_IDLE : begin
            ACQ_HAVE_TRIG <= 0;
            ACQ_DONE <= 0;
            
            if (ACQ_AXI_RUN && M_AXIS_TREADY) begin
                // Load the required downcounter
                if (ACQ_DEPTH_MUX) begin
                    acq_axi_downcounter <= ACQ_DEPTH_A;
                end else begin
                    acq_axi_downcounter <= ACQ_DEPTH_B;
                end
                
                acq_axi_upcounter <= 0;
                acq_axi_running <= 1;
                adcstream_state <= ST_STREAMING;
            end
        end
        
        ST_STREAMING : begin
            // Only adjust counters if data is available in FIFO (no underrun)
            acq_axi_upcounter <= acq_axi_upcounter + 1;
        
            // Streaming jumps to STOP_EOF if downcounter is zero
            acq_axi_downcounter <= acq_axi_downcounter - 1;
            if (acq_axi_downcounter == 0) begin
                // Trigger not valid in this instance; set TRIGGER_POS to invalid value (31st bit set)
                adcstream_state <= ST_STOP_EOF;
                TRIGGER_POS <= 32'hffffffff;
            end else begin
                // Level sensitive trigger:  actual trigger state generated by external trigger machine
                if (TRIGGER_IN) begin
                    adcstream_state <= ST_STOP_TRIGGERED;
                    TRIGGER_POS <= {0, acq_axi_upcounter, TRIGGER_SUB_WORD};
                end
            end
        end
        
        ST_STOP_TRIGGERED : begin
            // Leave IOs in the "stopped-with-trig" state;  to exit this state the 
            // PS must drive ACQ_AXI_RUN low
            ACQ_HAVE_TRIG <= 1;
            ACQ_DONE <= 1;
            
            if (!ACQ_AXI_RUN) begin
                adcstream_state <= ST_IDLE;
            end
        end
    
    endcase

end

endmodule

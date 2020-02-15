`timescale 1ns / 1ns

//////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module main(
    /*
    // ### CSI interface ###
    csi_clk_p,      // clock lane positive
    csi_clk_n,      // clock lane negative
    csi_d0_p,       // data lane positive 0
    csi_d0_n,       // data lane negative 0
    csi_d1_p,       // data lane positive 1
    csi_d1_n,       // data lane negative 1
    
    csi_lpd0_n,     // low power state driver lane 0 neg
    csi_lpd0_p,     // low power state driver lane 0 pos
    csi_lpd1_n,     // low power state driver lane 1 neg
    csi_lpd1_p,     // low power state driver lane 1 pos
    csi_lpclk_n,    // low power state driver clk neg
    csi_lpclk_p,    // low power state driver clk pos
    */
    
    // ### ADC interface ###
    adc_l1a_p,
    adc_l1a_n,
    adc_l1b_p,
    adc_l1b_n,
    adc_l2a_p,
    adc_l2a_n,
    adc_l2b_p,
    adc_l2b_n,
    adc_l3a_p,
    adc_l3a_n,
    adc_l3b_p,
    adc_l3b_n,
    adc_l4a_p,
    adc_l4a_n,
    adc_l4b_p,
    adc_l4b_n,
    adc_lclk_p,
    adc_lclk_n,
    adc_fclk_p,
    adc_fclk_n,
     
    // ### GP Interface ###
    led_PL0,        // diagnostic LED PL0
    led_PL1         // diagnostic LED PL1
 );

// EMIO indexes for interface port
parameter EMIO_ACQ_RUN = 0;
parameter EMIO_ACQ_ABORT = 1;
parameter EMIO_ACQ_DONE = 2;
parameter EMIO_CFG_COMMIT = 3;
parameter EMIO_CFG_DONE = 4;
parameter EMIO_ACQ_TRIG_MASK = 5;
parameter EMIO_ACQ_FIFO_RESET = 6;
parameter EMIO_ACQ_HAVE_TRIG = 7;
parameter EMIO_ACQ_TRIG_RST = 8;
parameter EMIO_ACQ_DEPTH_MUX = 9;
parameter EMIO_ACQ_AXI_RUN = 10;
parameter EMIO_ACQ_DATA_LOSS = 12;

//output csi_clk_p, csi_clk_n, csi_d0_p, csi_d0_n, csi_d1_p, csi_d1_n, csi_lpd0_n, csi_lpd0_p, csi_lpd1_n, csi_lpd1_p, csi_lpclk_n, csi_lpclk_p;
input adc_l1a_p, adc_l1a_n, adc_l1b_p, adc_l1b_n, adc_l2a_p, adc_l2a_n, adc_l2b_p, adc_l2b_n, adc_l3a_p, adc_l3a_n;
input adc_l3b_p, adc_l3b_n, adc_l4a_p, adc_l4a_n, adc_l4b_p, adc_l4b_n, adc_lclk_p, adc_lclk_n, adc_fclk_p, adc_fclk_n;
    
output led_PL0, led_PL1;

// ??MHz clock from PS clock source
// This is derived from a 33.33MHz clock from the PS_CLK input.
// 
// Clock breakdown:
//  -  ??MHz logic clock for general logic                                         [clk_master]
//  - 800MHz QDR clocks (x3) for CSI output (in testing these are set to low-MHz)  [clk_mipi_0,90,180,270]
//

wire clk_idelay_refclk;
wire clk_master, clk_mipi_0, clk_mipi_90, clk_mipi_180, clk_mipi_270, pll_locked;

reg g_rst_gen = 0;
reg g_rst_state = 0;
reg [7:0] g_rst_counter = 0;

wire adc_data_clk;

// Reset pulse generator. Generates a one time reset pulse for the following blocks.
// TODO:  I think this should become a global block and be driven by the PS.
always @(posedge clk_master) begin

    if (g_rst_state == 0) begin
    
        g_rst_counter <= g_rst_counter + 1;
        
        if (g_rst_counter == 3) begin
            g_rst_gen <= 1;   
        end
        
        if (g_rst_counter == 150) begin
            g_rst_gen <= 0;
            g_rst_state <= 1;   
        end
    
    end
    
end

/*
 * Connection to Block Design.
 */
wire acq_done, acq_have_trig, acq_data_loss, fabcfg_done;
assign emio_input[EMIO_CFG_DONE] = fabcfg_done;
wire fabcfg_commit = emio_output[EMIO_CFG_COMMIT];
wire acq_run = emio_output[EMIO_ACQ_RUN];
wire acq_abort = emio_output[EMIO_ACQ_ABORT];
assign emio_input[EMIO_ACQ_DONE] = acq_done;
wire acq_trig_mask = emio_output[EMIO_ACQ_TRIG_MASK];
wire acq_trig_rst = emio_output[EMIO_ACQ_TRIG_RST];
wire acq_depth_mux = emio_output[EMIO_ACQ_DEPTH_MUX];
wire acq_axi_run = emio_output[EMIO_ACQ_AXI_RUN];
wire acq_fifo_reset = emio_output[EMIO_ACQ_FIFO_RESET];
assign emio_input[EMIO_ACQ_HAVE_TRIG] = acq_have_trig;
assign emio_input[EMIO_ACQ_DATA_LOSS] = acq_data_loss;

wire [63:0] emio_output;
wire [63:0] emio_input;
reg [14:0] pl_irq;
wire acq_done;
wire [63:0] adc_bus;
wire [31:0] cfg_bram_addrb;
wire [31:0] cfg_bram_doutb;
wire [31:0] cfg_bram_dinb;
wire cfg_bram_clkb;
wire [3:0] cfg_bram_web;
wire cfg_bram_enb;
wire cfg_bram_busyb;

// Test trigger generator
reg trig_gen = 0;

design_1 (
    // 64-bit ADC bus
    .ADC_BUS(adc_bus),
    .ADC_DATA_CLK(adc_data_clk),
    .ADC_DATA_VALID(1'b1),          // TODO: this should be coming from the PS
    .ADC_FIFO_RESET(emio_output[6]),
    .ADC_DATA_EOF(1'b0),            // for now, data never ends
    
    // Acquisition/control bus
    // TODO: EMIO constant indexes to be parameterised
    .ACQ_RUN(acq_run),
    .ACQ_ABORT(acq_abort),
    .ACQ_TRIG_MASK(acq_trig_mask),
    .ACQ_TRIG_RST(acq_trig_rst),
    .ACQ_DEPTH_MUX(acq_depth_mux),
    .ACQ_DEPTH_A(R_acq_size_a),
    .ACQ_DEPTH_B(R_acq_size_b),
    .ACQ_AXI_RUN(acq_axi_run),
    .ACQ_DONE(acq_done),
    .ACQ_HAVE_TRIG(acq_have_trig),
    .ACQ_DATA_LOSS(acq_data_loss),      // Data loss signal to PS indicating that FIFO data may be stale due to read delay
    .TRIGGER_IN(trig_gen),              // Level sensitive trigger input from trigger block
    .TRIGGER_SUB_WORD(3'b000),          // Fixed value for now; later this will indicate which word generated event first
    .TRIGGER_POS(R_acq_trigger_ptr),    // Registered trigger output position for FabCfg
    .TRIGGER_OUT(trig_out),             // Trigger output to GP output multiplexer
    
    // FabCfg interface to AXI BRAM
    .CFG_BRAM_ADDRB(cfg_bram_addrb),
    .CFG_BRAM_DOUTB(cfg_bram_doutb),
    .CFG_BRAM_DINB(cfg_bram_dinb),
    .CFG_BRAM_CLKB(cfg_bram_clkb),
    .CFG_BRAM_ENB(cfg_bram_enb),
    .CFG_BRAM_WEB(cfg_bram_web),
    .CFG_BRAM_BUSYB(cfg_bram_busyb),
    .CFG_BRAM_RSTB(1'b0),
    
    // Monitor signals for ILA
    .FABCFG_COMMIT_MON(fabcfg_commit),
    .FABCFG_DONE_MON(fabcfg_done),
    
    // Master clock (~177MHz currently, actual value not particularly important but must be
    // set up in clock wizards correctly.)
    .FCLK_CLK0(clk_master),
    
    // EMIO 64-bit low speed signalling bus between ARM and fabric
    .EMIO_I(emio_input),            // Data into ARM
    .EMIO_O(emio_output),           // Data from ARM
    
    // IRQ outputs from fabric
    .PL_IRQ(pl_irq)
);

wire [31:0] R_acq_size_a;
wire [31:0] R_acq_size_b;
wire [31:0] R_acq_trigger_ptr;
wire [2:0] R_acq_demux_mode;
wire [1:0] R_gpio_test;

assign led_PL0 = R_gpio_test[0];
assign led_PL1 = R_gpio_test[1];

cfg_bram_controller (
    // BRAM, EMIO, Clock interface
    .cfg_bram_addr(cfg_bram_addrb),
    .cfg_bram_dout(cfg_bram_doutb),
    .cfg_bram_din(cfg_bram_dinb),
    .cfg_bram_clk(cfg_bram_clkb),
    .cfg_bram_en(cfg_bram_enb),
    .cfg_bram_we(cfg_bram_web),
    .cfg_bram_busy(cfg_bram_busyb),
    .cfg_commit(fabcfg_commit),
    .cfg_commit_done(fabcfg_done),
    .g_rst(g_rst_gen),
    .clk_ref(clk_master),
    
    // Register interface
    .R_acq_size_a(R_acq_size_a),
    .R_acq_size_b(R_acq_size_b),
    .R_acq_trigger_ptr(R_acq_trigger_ptr),
    .R_acq_demux_mode(R_acq_demux_mode),
    .R_gpio_test(R_gpio_test)
);

//assign adc_valid = emio_output[0];

reg [15:0] emio_counter;
wire [7:0] train_data_debug;

/*
clk_wiz_0 (
    .clk_out1_0(clk_mipi_0),
    .clk_out1_90(clk_mipi_90), // unused
    .clk_out1_180(clk_mipi_180),
    .clk_out1_270(clk_mipi_270),
    //.reset(0),
    .power_down(0),
    .locked(pll_locked),
    .clk_in1(clk_master)
);
*/

/*
 * REFCLK source for IDELAYCTRL block.
 */
clk_wiz_1_idelay_refclk (
    .clk_out1(clk_idelay_refclk),
    .power_down(0),
    .clk_in1(clk_master)
);

wire [13:0] adc_data_latched_0;
wire [13:0] adc_data_latched_1;
wire [13:0] adc_data_latched_2;
wire [13:0] adc_data_latched_3;
wire [13:0] adc_data_latched_4;
wire [13:0] adc_data_latched_5;
wire [13:0] adc_data_latched_6;
wire [13:0] adc_data_latched_7;

wire [7:0] debug_adc;

reg [23:0] adc_testcntr;
//reg led_PL1 = 0;

//assign led_PL0 = adc_valid; // debug_adc[0];
//assign led_PL1 = debug_adc[1];

adc_receiver (
    // ADC interface
    .adc_l1a_p(adc_l1a_p),
    .adc_l1a_n(adc_l1a_n),
    .adc_l1b_p(adc_l1b_p),
    .adc_l1b_n(adc_l1b_n),
    .adc_l2a_p(adc_l2a_p),
    .adc_l2a_n(adc_l2a_n),
    .adc_l2b_p(adc_l2b_p),
    .adc_l2b_n(adc_l2b_n),
    .adc_l3a_p(adc_l3a_p),
    .adc_l3a_n(adc_l3a_n),
    .adc_l3b_p(adc_l3b_p),
    .adc_l3b_n(adc_l3b_n),
    .adc_l4a_p(adc_l4a_p),
    .adc_l4a_n(adc_l4a_n),
    .adc_l4b_p(adc_l4b_p),
    .adc_l4b_n(adc_l4b_n),
    .adc_lclk_p(adc_lclk_p),
    .adc_lclk_n(adc_lclk_n),
    .adc_fclk_p(adc_fclk_p),
    .adc_fclk_n(adc_fclk_n),
    
    // Mode: fixed to 8-bit for now
    .adc_mode(2'b01),
    
    // 8 x 14-bit output registers
    .adc_data_latched_0(adc_data_latched_0),
    .adc_data_latched_1(adc_data_latched_1),
    .adc_data_latched_2(adc_data_latched_2),
    .adc_data_latched_3(adc_data_latched_3),
    .adc_data_latched_4(adc_data_latched_4),
    .adc_data_latched_5(adc_data_latched_5),
    .adc_data_latched_6(adc_data_latched_6),
    .adc_data_latched_7(adc_data_latched_7),
    
    // adc_data_rdy (ignored)
    .adc_data_clk(adc_data_clk),
    
    // Debug output
    .debug(debug_adc),
    
    // Training state & control
    /*
    .train_start(emio_output[0]),
    .train_done(emio_input[0]),
    .train_ok(emio_input[1]),
    .train_count(emio_input[7:2]),
    .idelay_rdy(emio_input[8]),
    .idelay_refclk(clk_idelay_refclk), // xxx MHz refclk for IDELAYE2
    .train_data_debug(train_data_debug),
    */
    
    // Global reset signal: not asserted for now
    .g_rst(g_rst_gen),
    
    // Global clock enable: always enabled
    .g_rx_ce(1),
    
    // Reference clock input
    .clk_ref(clk_master)
);

/*
wire [63:0] adc_bus;
assign adc_bus[ 7: 0] = adc_data_latched_0[7:0];
assign adc_bus[15: 8] = adc_data_latched_1[7:0];
assign adc_bus[23:16] = adc_data_latched_2[7:0];
assign adc_bus[31:24] = adc_data_latched_3[7:0];
assign adc_bus[39:32] = adc_data_latched_4[7:0];
assign adc_bus[47:40] = adc_data_latched_5[7:0];
assign adc_bus[55:48] = adc_data_latched_6[7:0];
assign adc_bus[63:56] = adc_data_latched_7[7:0];
*/

reg [31:0] adc32_counter;
wire [15:0] adc_trigref = adc32_counter[15:0];

assign adc_bus[31:0 ] = adc32_counter;
assign adc_bus[63:32] = adc32_counter;

always @(posedge adc_data_clk) begin

    //rep_counter <= rep_counter + 1;
    if (acq_run) begin
        adc32_counter <= adc32_counter + 1;
    end
    
    // trigger is 1cyc long max.
    if (trig_gen) begin
        trig_gen <= 0;
    end else if ((adc_trigref == 16'h0200) && acq_run) begin
        // generate trigger on test word
        trig_gen <= 1;
    end 
    
end

endmodule
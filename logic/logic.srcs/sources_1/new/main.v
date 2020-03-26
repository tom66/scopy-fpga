`timescale 1ns / 1ns

//////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module main(  
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
parameter EMIO_CSI_START_LINES = 20;
parameter EMIO_CSI_START_FRAME = 21;
parameter EMIO_CSI_END_FRAME = 22;
parameter EMIO_CSI_STOP = 23;
parameter EMIO_CSI_SLEEP = 24;
parameter EMIO_CSI_DONE = 25;

output csi_clk_p, csi_clk_n, csi_d0_p, csi_d0_n, csi_d1_p, csi_d1_n, csi_lpd0_n, csi_lpd0_p, csi_lpd1_n, csi_lpd1_p, csi_lpclk_n, csi_lpclk_p;
input adc_l1a_p, adc_l1a_n, adc_l1b_p, adc_l1b_n, adc_l2a_p, adc_l2a_n, adc_l2b_p, adc_l2b_n, adc_l3a_p, adc_l3a_n;
input adc_l3b_p, adc_l3b_n, adc_l4a_p, adc_l4a_n, adc_l4b_p, adc_l4b_n, adc_lclk_p, adc_lclk_n, adc_fclk_p, adc_fclk_n;

output led_PL0, led_PL1;
wire g_rst_gen;

/*
 * Global reset generator.
 */
g_rst_controller (
    .clk_master(clk_master),
    .g_rst_trig_ps(0),          // not presently used
    .g_rst_gen(g_rst_gen)
);

wire [1:0] R_gpio_test;
wire clk_mipi_ref_dbg;

assign led_PL0 = R_gpio_test[0]; // clk_mipi_ref_dbg; 
assign led_PL1 = R_gpio_test[1];

/*
 * Connection to Block Design.
 */
wire csi_done;
wire csi_start_lines = emio_output[EMIO_CSI_START_LINES];
wire csi_start_frame = emio_output[EMIO_CSI_START_FRAME];
wire csi_end_frame = emio_output[EMIO_CSI_END_FRAME];
wire csi_stop = emio_output[EMIO_CSI_STOP];
wire csi_sleep = emio_output[EMIO_CSI_SLEEP];
assign emio_input[EMIO_CSI_DONE] = csi_done;

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
wire [2:0] trig_sub_word;

wire [5:0] csi_ctrl_state_dbg;
wire [15:0] csi_fifo_dout;
wire csi_fifo_clk, csi_fifo_read_req, csi_fifo_read_valid;
wire [5:0] csi_debug_mipi_state;

wire clkwiz0_clkout1, clkwiz0_clkout2;
wire csi_mipi_busy_dbg, csi_mipi_done_dbg, csi_mipi_init_short_dbg, csi_mipi_init_long_dbg, csi_mipi_init_idle_dbg;

wire [15:0] csi_debug_tx_size;
wire [15:0] csi_debug_state_timer;
wire [15:0] csi_debug_state_timer2;
wire csi_debug_state_timer_rst;
wire [15:0] csi_debug_data_mux_out;
wire [5:0] csi_debug_ctrl_bram_base;

design_1 (
    // ADC LVDS interface
    .ADC_L1A_P(adc_l1a_p),
    .ADC_L1A_N(adc_l1a_n),
    .ADC_L1B_P(adc_l1b_p),
    .ADC_L1B_N(adc_l1b_n),
    .ADC_L2A_P(adc_l2a_p),
    .ADC_L2A_N(adc_l2a_n),
    .ADC_L2B_P(adc_l2b_p),
    .ADC_L2B_N(adc_l2b_n),
    .ADC_L3A_P(adc_l3a_p),
    .ADC_L3A_N(adc_l3a_n),
    .ADC_L3B_P(adc_l3b_p),
    .ADC_L3B_N(adc_l3b_n),
    .ADC_L4A_P(adc_l4a_p),
    .ADC_L4A_N(adc_l4a_n),
    .ADC_L4B_P(adc_l4b_p),
    .ADC_L4B_N(adc_l4b_n),
    .ADC_LCLK_P(adc_lclk_p),
    .ADC_LCLK_N(adc_lclk_n),
    .ADC_FCLK_P(adc_fclk_p),
    .ADC_FCLK_N(adc_fclk_n),
   
    // CSI output port
    .CSI_CLK_P(csi_clk_p),
    .CSI_CLK_N(csi_clk_n),
    .CSI_D0_P(csi_d0_p),
    .CSI_D0_N(csi_d0_n),
    .CSI_D1_P(csi_d1_p),
    .CSI_D1_N(csi_d1_n),
    .CSI_LPD0_P(csi_lpd0_p),
    .CSI_LPD0_N(csi_lpd0_n),
    .CSI_LPD1_P(csi_lpd1_p),
    .CSI_LPD1_N(csi_lpd1_n),
    .CSI_LPCLK_P(csi_lpclk_p),
    .CSI_LPCLK_N(csi_lpclk_n),
    
    // CSI control signals via EMIO
    .CSI_SLEEP(csi_sleep),
    .CSI_START_LINES(csi_start_lines),
    .CSI_START_FRAME(csi_start_frame),
    .CSI_END_FRAME(csi_end_frame),
    .CSI_STOP(csi_stop),
    .CSI_DONE(csi_done),
    
    // GPIO LED outputs - in future the LEDs will be multiplexable between functions for debugging
    .GPIO_TEST(R_gpio_test),
    
    // EMIO 64-bit low speed signalling bus between ARM and fabric
    .EMIO_I(emio_input),            // Data into ARM
    .EMIO_O(emio_output),           // Data from ARM
    
    // Master clock (nom. 177MHz)
    .FCLK_CLK0(clk_master)
);

endmodule

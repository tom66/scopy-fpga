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

//wire [63:0] adc_bus;
wire adc_data_clk;

wire [63:0] emio_output;
wire [63:0] emio_input;
reg [14:0] pl_irq;

design_1 (
    .ADC_BUS(adc_bus),
    .ADC_DATA_CLK(adc_data_clk),
    .FCLK_CLK0(clk_master),
    
    // EMIO 64-bit low speed signalling bus between ARM and fabric
    .EMIO_I(emio_input),    // Data into ARM
    .EMIO_O(emio_output),   // Data from ARM
    
    // IRQ outputs from PL
    .PL_IRQ(pl_irq)
);

reg g_rst_gen = 0;
reg g_rst_state = 0;
reg [7:0] g_rst_counter = 0;

reg [15:0] emio_counter;
wire [7:0] train_data_debug;

assign emio_input[63:48] = emio_counter;
assign emio_input[9] = emio_output[0];
assign emio_input[15:10] = debug_adc[7:2];
assign emio_input[31:24] = train_data_debug;

// Reset pulse generator. Generates a one time reset pulse for the following blocks.
// TODO:  I think this should become a global block.
always @(posedge clk_master) begin

    // test EMIO
    emio_counter <= emio_counter + 1;

    if (g_rst_state == 0) begin
    
        g_rst_counter <= g_rst_counter + 1;
        
        if (g_rst_counter == 3) begin
            g_rst_gen <= 1;   
        end
        
        if (g_rst_counter == 15) begin
            g_rst_gen <= 0;
            g_rst_state <= 1;   
        end
    
    end
    
end

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

assign led_PL0 = debug_adc[0];
assign led_PL1 = debug_adc[1];

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
    .train_start(emio_output[0]),
    .train_done(emio_input[0]),
    .train_ok(emio_input[1]),
    .train_count(emio_input[7:2]),
    .idelay_rdy(emio_input[8]),
    .idelay_refclk(clk_idelay_refclk), // xxx MHz refclk for IDELAYE2
    .train_data_debug(train_data_debug),
    
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

reg [7:0] rep_counter;

/*
reg [63:0] adc_bus;
*/

wire [63:0] adc_bus;

assign adc_bus[ 7: 0] = rep_counter;
assign adc_bus[15: 8] = rep_counter;
assign adc_bus[23:16] = rep_counter;
assign adc_bus[31:24] = rep_counter;
assign adc_bus[39:32] = rep_counter;
assign adc_bus[47:40] = rep_counter;
assign adc_bus[55:48] = rep_counter;
assign adc_bus[63:56] = rep_counter;

always @(posedge adc_data_clk) begin

    rep_counter <= rep_counter + 1;

end

endmodule
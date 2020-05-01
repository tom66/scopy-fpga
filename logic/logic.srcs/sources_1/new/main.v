`timescale 1ns / 1ns

//////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

module main(  
    // ### MCU interface including SPI (slave) ###
    fpga_heartbeat,
    fpga_irq1,
    fpga_irq2,
    fpga_irq3,
    fpga_spi_miso,
    fpga_spi_mosi,
    fpga_spi_sclk,
    fpga_spi_csn,
    
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

parameter EMIO_HEARTBEAT = 60;      // To be toggled by PS regularly (~5ms tick)
parameter EMIO_IRQ1 = 61;
parameter EMIO_IRQ2 = 62;
parameter EMIO_IRQ3 = 63;

output fpga_heartbeat, fpga_irq1, fpga_irq2, fpga_irq3, fpga_spi_miso;
input fpga_spi_mosi, fpga_spi_sclk, fpga_spi_csn;

output csi_clk_p, csi_clk_n, csi_d0_p, csi_d0_n, csi_d1_p, csi_d1_n, csi_lpd0_n, csi_lpd0_p, csi_lpd1_n, csi_lpd1_p, csi_lpclk_n, csi_lpclk_p;
input adc_l1a_p, adc_l1a_n, adc_l1b_p, adc_l1b_n, adc_l2a_p, adc_l2a_n, adc_l2b_p, adc_l2b_n, adc_l3a_p, adc_l3a_n;
input adc_l3b_p, adc_l3b_n, adc_l4a_p, adc_l4a_n, adc_l4b_p, adc_l4b_n, adc_lclk_p, adc_lclk_n, adc_fclk_p, adc_fclk_n;

output led_PL0, led_PL1;
wire g_rst_gen;

/*
 * SPI Out Tristate Logic
 */
wire fpga_spi_miso_out, fpga_spi_miso_out_tris;

OBUFT (
    .I(fpga_spi_miso_out),
    .T(fpga_spi_miso_out_tris),
    .O(fpga_spi_miso)
);

/*
 * EMIO IRQ assignment
 */
assign fpga_heartbeat = emio_output[EMIO_HEARTBEAT];
assign fpga_irq1 = emio_output[EMIO_IRQ1];
assign fpga_irq2 = emio_output[EMIO_IRQ2];
assign fpga_irq3 = emio_output[EMIO_IRQ3];

/*
 * Global reset generator.
 */
g_rst_controller (
    .clk_master(clk_master),
    .g_rst_trig_ps(0),          // not presently used
    .g_rst_gen(g_rst_gen)
);

wire [1:0] R_gpio_test;
assign led_PL0 = R_gpio_test[0];
assign led_PL1 = R_gpio_test[1];

/*
 * Connection to Block Design.
 *
 * XXX: 26/04/2020 - Much of this was stale and was removed.  Everything on AXI
 * where possible now, with EMIO used only for LEDs and outside world interface.
 */
wire [63:0] emio_output;
wire [63:0] emio_input;
reg [14:0] pl_irq;

design_1 (
    // SPI/MCU interface
    .SPI_DATA_OUT(fpga_spi_miso_out),
    .SPI_DATA_OUT_TRIS(fpga_spi_miso_out_tris),
    .SPI_DATA_IN(fpga_spi_mosi),
    .SPI_CLK(fpga_spi_sclk),
    .SPI_CSN(fpga_spi_csn),

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
    
    // LED channels from LED debug multiplexers
    .LED_CH0(led_PL0),
    .LED_CH1(led_PL1),
    
    // EMIO 64-bit low speed signalling bus between ARM and fabric
    .EMIO_I(emio_input),            // Data into ARM
    .EMIO_O(emio_output),           // Data from ARM
    
    // Master clock (nom. 177MHz)
    .FCLK_CLK0(clk_master)
);

endmodule

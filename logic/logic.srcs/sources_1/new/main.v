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

// 50MHz clock from PS clock source
// This is derived from a 33.33MHz clock from the PS_CLK input.
// 
// Clock breakdown:
//  -  50MHz logic clock for general logic                                         [clk_master_50]
//  - 800MHz QDR clocks (x3) for CSI output (in testing these are set to low-MHz)  [clk_mipi, clk_mipi_0,90,180,270]
//

wire clk_master_50, clk_mipi_0, clk_mipi_90, clk_mipi_180, clk_mipi_270, pll_locked;

reg [31:0] straxi_data_in = 8'h00000000;
reg [31:0] axi_internal_timer = 0;
reg straxi_valid = 0, straxi_rstn = 0; 
wire straxi_clk;
wire straxi_ready;
wire [31:0] straxi_wrtcnt_dbg;
reg [31:0] lvds_test_data_reg;
reg straxi_tlast = 0;

reg led_reg0;
reg led_reg1;

design_1 (
    .FCLK_CLK0(clk_master_50),
    .STRAXI_DATA_PORT(straxi_data_in),
    .STRAXI_DATA_TLAST(straxi_tlast),
    .STRAXI_DATA_VALID(straxi_valid), 
    .STRAXI_DATA_ARSTN(straxi_rstn), 
    .STRAXI_DATA_CLK(straxi_clk),
    .STRAXI_DATA_READY(straxi_ready),
    .STRAXI_DATA_WRTCNT(straxi_wrtcnt_dbg)
);

assign straxi_clk = clk_master_50;

always @(posedge clk_master_50) begin
    // DMA xfer test: data port with continuous counter used
    // PS will DMA this into buffers as required
    axi_internal_timer <= axi_internal_timer + 1;
    
    if (axi_internal_timer > 100) begin
        straxi_rstn <= 1;
    end
    
    if (axi_internal_timer > 200) begin
        straxi_valid <= 1;
        
        if (straxi_ready) begin
            straxi_data_in <= axi_internal_timer; // lvds_test_data_reg;
        
            // toggle LAST on every frame for 2 cycles
            if ((axi_internal_timer & 31) < 2) begin
                straxi_tlast <= 1;
            end else begin
                straxi_tlast <= 0;
            end
            
            led_reg0 <= ~led_reg0;
        end else begin
            straxi_data_in <= 8'h5500ffcc; // invalid data flag
        end
    end else begin
        straxi_valid <= 0;
        straxi_data_in <= 0;
    end
end

assign led_PL0 = led_reg0;
assign led_PL1 = led_reg1;

clk_wiz_0 (
    .clk_out1_0(clk_mipi_0),
    .clk_out1_90(clk_mipi_90), // unused
    .clk_out1_180(clk_mipi_180),
    .clk_out1_270(clk_mipi_270),
    //.reset(0),
    .power_down(0),
    .locked(pll_locked),
    .clk_in1(clk_master_50)
);

endmodule
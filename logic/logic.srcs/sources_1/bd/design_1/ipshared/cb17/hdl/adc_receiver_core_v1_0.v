
`timescale 1 ns / 1 ps

module adc_receiver_core_v1_0 
(
    // ADC LVDS input channels
    input adc_l1a_p,
    input adc_l1a_n, 
    input adc_l1b_p, 
    input adc_l1b_n, 
    input adc_l2a_p, 
    input adc_l2a_n,  
    input adc_l2b_p,  
    input adc_l2b_n,  
    input adc_l3a_p,  
    input adc_l3a_n,
    input adc_l3b_p,  
    input adc_l3b_n,  
    input adc_l4a_p,  
    input adc_l4a_n,  
    input adc_l4b_p,  
    input adc_l4b_n,  
    input adc_lclk_p,  
    input adc_lclk_n,  
    input adc_fclk_p,  
    input adc_fclk_n,
    
    // Global reset signal
    input g_rst,

    // Data output to following blocks
    output [63:0] adc_bus,
    output adc_data_clk,
    
    // Master clock reference
    input clk_master,
    
    // Training state & control
    output bitslip_locked,
    input [5:0] train_l1a,
    input [5:0] train_l1b,
    input [5:0] train_l2a,
    input [5:0] train_l2b,
    input [5:0] train_l3a,
    input [5:0] train_l3b,
    input [5:0] train_l4a,
    input [5:0] train_l4b,
    input delay_load,
    output train_done_load,
    input clk_idelay_refclk,    // 200 MHz refclk
    output idelay_rdy           // Set when IDELAYCTRL is done
);

wire [63:0] adc_bus;
wire [13:0] adc_data[7:0];

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
    .adc_data_0(adc_data[0]),
    .adc_data_1(adc_data[1]),
    .adc_data_2(adc_data[2]),
    .adc_data_3(adc_data[3]),
    .adc_data_4(adc_data[4]),
    .adc_data_5(adc_data[5]),
    .adc_data_6(adc_data[6]),
    .adc_data_7(adc_data[7]),
    
    // adc_data_rdy (ignored)
    .adc_data_clk(adc_data_clk),
    
    // Training state & control
    .bitslip_locked(bitslip_locked),
    .train_l1a(train_l1a),
    .train_l1b(train_l1b),
    .train_l2a(train_l2a),
    .train_l2b(train_l2b),
    .train_l3a(train_l3a),
    .train_l3b(train_l3b),
    .train_l4a(train_l4a),
    .train_l4b(train_l4b),
    .delay_load(delay_load),
    .train_done_load(train_done_load),
    .idelay_refclk(clk_idelay_refclk), // 200 MHz refclk for IDELAYE2
    .idelay_rdy(idelay_rdy),
    
    // Global reset signal: not asserted for now
    .g_rst(g_rst),
    
    // Global clock enable: always enabled
    .g_rx_ce(1),
    
    // Reference clock input
    .clk_ref(clk_master)
);

assign adc_bus[ 7: 0] = adc_data[0];
assign adc_bus[15: 8] = adc_data[1];
assign adc_bus[23:16] = adc_data[2];
assign adc_bus[31:24] = adc_data[3];
assign adc_bus[39:32] = adc_data[4];
assign adc_bus[47:40] = adc_data[5];
assign adc_bus[55:48] = adc_data[6];
assign adc_bus[63:56] = adc_data[7];

endmodule


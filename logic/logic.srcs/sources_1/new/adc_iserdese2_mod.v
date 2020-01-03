/////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS.
//
/////////////////////////////////////////////////////////////////////////////////

/*
 * Implementation of one of the deserialisers for the ADC LVDS inputs.
 *
 * The module deserialises received LVDS data into 4 data bits.
 */
module adc_iserdese2_mod (
    // ADC clock input
    input adc_clk_in_p,
    
    // Divided regional clock
    input adc_clk_div_in,
    
    // ADC data input
    input adc_lane_data,
    
    // CE and reset.  Reset signal to be aligned to divided clock.
    input ce,
    input rst,
    
    // Bitslip input from the bitslip synchroniser
    input bitslip,
    
    // Invert signal.  If set then package P/N are inverted and data is 
    // inverted by this module to compensate.
    input package_invert,
    
    // Output port
    output [7:0] oq_data
);

wire [7:0] oq_data_raw;
assign oq_data = oq_data_raw ^ ((package_invert) ? (8'hff) : (8'h00));

/* 
 * Module operates on 8-bit words.
 *
 * In high-speed 8-bit mode to device reads individual data words.  In 12- and 14-bit
 * mode, data is padded into 16-bit words with remaining bits set to zero.
 */
ISERDESE2 #(
    .DATA_RATE("DDR"),
    .DATA_WIDTH(8),
    .INTERFACE_TYPE("NETWORKING"),
    .NUM_CE(1),
    .INIT_Q1(1),
    .INIT_Q2(1),
    .INIT_Q3(1),
    .INIT_Q4(1),
    .SRVAL_Q1(0),
    .SRVAL_Q2(0),
    .SRVAL_Q3(0),
    .SRVAL_Q4(0),
    .IOBDELAY("NONE"),
    .OFB_USED("FALSE"),
    .SERDES_MODE("MASTER"),
    .DYN_CLKDIV_INV_EN("FALSE"),
    .DYN_CLK_INV_EN("FALSE"),
    .SERDES_MODE("MASTER")
) ISERDESE2_adc_inst (
    .D(adc_lane_data),
    .CLK(adc_clk_in_p),
    .CLKB(~adc_clk_in_p),
    .CLKDIV(adc_clk_div_in),
    .CE1(ce),
    .RST(rst),
    .Q1(oq_data_raw[7]),
    .Q2(oq_data_raw[6]),
    .Q3(oq_data_raw[5]),
    .Q4(oq_data_raw[4]),
    .Q5(oq_data_raw[3]),
    .Q6(oq_data_raw[2]),
    .Q7(oq_data_raw[1]),
    .Q8(oq_data_raw[0]),
    .BITSLIP(bitslip),
    .CLKDIVP(0)
);

endmodule

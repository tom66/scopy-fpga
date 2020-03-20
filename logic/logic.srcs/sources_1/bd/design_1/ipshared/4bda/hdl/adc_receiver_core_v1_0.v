
`timescale 1 ns / 1 ps

module adc_receiver_core_v1_0 
(
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
    
    input g_rst,

    output [63:0] adc_bus,
    output adc_data_clk,
    
    input trigger_unit_in,
    output trigger_out,
    output [2:0] trigger_sub_word,
    
    input clk_master,
    input clk_idelay_refclk
);

reg trigger_gen;
wire trigger_out;
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
    .train_start(0),
    .idelay_refclk(clk_idelay_refclk), // xxx MHz refclk for IDELAYE2
    
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

assign trigger_out = trigger_gen;

reg trigger_state = 0; // 0 = rising, 1 = falling
reg [2:0] trigger_sub_word = 3'b000;

reg [7:0] trigger_prio = 8'b00000000;

integer adc_trig_level_high = 8'h80 + 8'h04;
integer adc_trig_level_low  = 8'h80 - 8'h04;
integer i;

always @(posedge adc_data_clk) begin

    if (trigger_gen) begin
        trigger_gen <= 0;
    end else begin
        for (i = 0; i < 8; i = i + 1) begin
            if ((adc_data[i] > adc_trig_level_high) && (trigger_state == 0)) begin
                trigger_gen <= 1;
                trigger_state <= 1;
                trigger_prio <= trigger_prio | (1 << i);
            end else if ((adc_data[i] < adc_trig_level_low) && (trigger_state == 1)) begin
                trigger_state <= 0;
            end
        end
        
        /*
        if (trig_prio != 0) begin
            // Priority encoder.  Verilog implements in order: we want the first set bit in the trigger matrix
            // to produce the corresponding trigger index 
            for (i = 7; i >= 0; i = i - 1) begin
                if (trig_prio[i]) begin
                    trig_sub_word_test <= i;
                end
            end
        end
        */
        
        case (trigger_prio)
            8'b1XXXXXXX: trigger_sub_word <= 0;
            8'b01XXXXXX: trigger_sub_word <= 1;
            8'b001XXXXX: trigger_sub_word <= 2;
            8'b0001XXXX: trigger_sub_word <= 3;
            8'b00001XXX: trigger_sub_word <= 4;
            8'b000001XX: trigger_sub_word <= 5;
            8'b0000001X: trigger_sub_word <= 6;
            8'b00000001: trigger_sub_word <= 7;
        endcase
    end
    
end

endmodule


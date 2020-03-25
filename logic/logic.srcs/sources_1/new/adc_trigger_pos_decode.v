`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2020 21:56:02
// Design Name: 
// Module Name: adc_trigger_pos_decode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module adc_trigger_pos_decode(
    input clk,
    input trig,
    input mod_en,
    input trig_rst,
    
    input [1:0] trig_src_1a1b,
    input [1:0] trig_src_2a2b,
    input [1:0] trig_src_3a3b,
    input [1:0] trig_src_4a4b,
    
    output reg [2:0] trig_ch_code
);

always @(posedge clk) begin
    if (mod_en && !trig_rst) begin
        if (trig) begin
            if (trig_src_1a1b[0]) begin
                trig_ch_code <= 0;
            end else if (trig_src_1a1b[1]) begin
                trig_ch_code <= 1;
            end else if (trig_src_2a2b[0]) begin
                trig_ch_code <= 2;
            end else if (trig_src_2a2b[1]) begin
                trig_ch_code <= 3;
            end else if (trig_src_3a3b[0]) begin
                trig_ch_code <= 4;
            end else if (trig_src_3a3b[1]) begin
                trig_ch_code <= 5;
            end else if (trig_src_4a4b[0]) begin
                trig_ch_code <= 6;
            end else if (trig_src_4a4b[1]) begin
                trig_ch_code <= 7;
            end
        end
    end else begin
        trig_ch_code <= 0;
    end
end
    
endmodule

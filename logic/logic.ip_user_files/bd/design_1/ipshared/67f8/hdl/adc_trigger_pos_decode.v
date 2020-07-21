`timescale 1ns / 1ps

module adc_trigger_pos_decode(
    input clk,
    input trig,
    input mod_en,
    input decode_rst,
    
    input [3:0] trig_sig,
    input [1:0] trig_src_1a1b,
    input [1:0] trig_src_2a2b,
    input [1:0] trig_src_3a3b,
    input [1:0] trig_src_4a4b,
    
    output reg [2:0] trig_ch_code,
    output reg trig_ch_code_valid
);

always @(posedge clk) begin
    
    /*
    if (decode_rst) begin
        trig_ch_code <= 0;
        trig_ch_code_valid <= 0;
    end else begin
    */
    
    if (trig_src_1a1b[0]) begin
        trig_ch_code <= 0;
        trig_ch_code_valid <= 1;
    end else if (trig_src_1a1b[1]) begin
        trig_ch_code <= 1;
        trig_ch_code_valid <= 1;
    end else if (trig_src_2a2b[0]) begin
        trig_ch_code <= 2;
        trig_ch_code_valid <= 1;
    end else if (trig_src_2a2b[1]) begin
        trig_ch_code <= 3;
        trig_ch_code_valid <= 1;
    end else if (trig_src_3a3b[0]) begin
        trig_ch_code <= 4;
        trig_ch_code_valid <= 1;
    end else if (trig_src_3a3b[1]) begin
        trig_ch_code <= 5;
        trig_ch_code_valid <= 1;
    end else if (trig_src_4a4b[0]) begin
        trig_ch_code <= 6;
        trig_ch_code_valid <= 1;
    end else if (trig_src_4a4b[1]) begin
        trig_ch_code <= 7;
        trig_ch_code_valid <= 1;
    end else begin
        trig_ch_code_valid <= 0;
    end
    
end

endmodule

`timescale 1ns / 1ps

module adc_trigger_edge_detect(
    input [1:0] edge_mode,
    input [3:0] trig_sig,
    input [1:0] trig_src_1a1b,
    input [1:0] trig_src_2a2b,
    input [1:0] trig_src_3a3b,
    input [1:0] trig_src_4a4b,
    
    input clk,
    output reg trig_out,
    output reg [2:0] trig_ch_code,
    output reg trig_ch_valid,
    
    output dbg_trig_logic, 
    output dbg_trig_ch_code_valid,
    output dbg_decode_rst,
    output [2:0] dbg_trig_ch_code_state,
    output [1:0] dbg_trig_src_4a4b_dly2
);

reg last_src;

wire rising  = ( src && !last_src);
wire falling = (!src &&  last_src);

wire [2:0] trig_ch_code_state;
wire trig_ch_code_valid;

reg [1:0] trig_src_1a1b_dly1;
reg [1:0] trig_src_2a2b_dly1;
reg [1:0] trig_src_3a3b_dly1;
reg [1:0] trig_src_4a4b_dly1;

reg [1:0] trig_src_1a1b_dly2;
reg [1:0] trig_src_2a2b_dly2;
reg [1:0] trig_src_3a3b_dly2;
reg [1:0] trig_src_4a4b_dly2;

reg trig_ch_code_valid_last = 0;

reg decode_rst = 0;
assign dbg_decode_rst = decode_rst;

// Delay trigger signals 2 clocks to align with other logic
always @(posedge clk) begin

    trig_src_1a1b_dly1 <= trig_src_1a1b;
    trig_src_2a2b_dly1 <= trig_src_2a2b;
    trig_src_3a3b_dly1 <= trig_src_3a3b;
    trig_src_4a4b_dly1 <= trig_src_4a4b;
    
    /*
    trig_src_1a1b_dly2 <= trig_src_1a1b_dly1;
    trig_src_2a2b_dly2 <= trig_src_2a2b_dly1;
    trig_src_3a3b_dly2 <= trig_src_3a3b_dly1;
    trig_src_4a4b_dly2 <= trig_src_4a4b_dly1;
    */
    
end

assign dbg_trig_src_4a4b_dly2 = trig_src_4a4b_dly2;

// Position decoder
adc_trigger_pos_decode (
    .clk(clk),
    .trig(trig_out),
    .mod_en(1),
    .decode_rst(decode_rst),
    .trig_sig(src),
    .trig_src_1a1b(trig_src_1a1b_dly1),
    .trig_src_2a2b(trig_src_2a2b_dly1),
    .trig_src_3a3b(trig_src_3a3b_dly1),
    .trig_src_4a4b(trig_src_4a4b_dly1),
    
    .trig_ch_code(trig_ch_code_state),
    .trig_ch_code_valid(trig_ch_code_valid)
);

assign src = trig_sig[0] | trig_sig[1] | trig_sig[2] | trig_sig[3];
assign dbg_trig_ch_code_valid = trig_ch_code_valid;
assign dbg_trig_ch_code_state = trig_ch_code_state;
assign dbg_trig_logic = trig_out;

// Main trigger logic
always @(posedge clk) begin

    trig_out <= (rising & edge_mode[1]) | (falling & edge_mode[0]);
    
    if (trig_out != 0) begin
        decode_rst <= 0;
        
        //if (trig_ch_code_valid && !trig_ch_code_valid_last) begin
        trig_ch_code <= trig_ch_code_state;
        //end
        
        //trig_ch_code_valid_last <= trig_ch_code_valid;
    end else begin
        decode_rst <= 1;
    end
    
    last_src <= src;    

end

endmodule

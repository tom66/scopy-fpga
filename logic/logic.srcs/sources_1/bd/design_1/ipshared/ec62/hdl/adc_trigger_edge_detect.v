`timescale 1ns / 1ps

module adc_trigger_edge_detect(
    input [1:0] edge_mode,
    input src,
    input clk,
    output reg trig_out
);

reg last_src;

wire rising  = ( src && !last_src);
wire falling = (!src &&  last_src);

always @(posedge clk) begin

    trig_out <= (rising & edge_mode[1]) | (falling & edge_mode[0]);
    last_src <= src;    

end

endmodule

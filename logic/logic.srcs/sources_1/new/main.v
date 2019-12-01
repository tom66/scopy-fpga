`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2019 23:19:34
// Design Name: 
// Module Name: main
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


module main(
        output led_PL0,
        output led_PL1
    );
        
// 50MHz clock source from PS block
wire clk50;

design_1 (
    .FCLK_CLK0(clk50)
);

reg [18:0] counter;
reg led = 1;

assign led_PL0 = led;
assign led_PL1 = ~led;

always @(posedge clk50) begin

    counter <= counter + 1;
    
    if (counter == 0) begin
        led <= !led;
    end

end

endmodule


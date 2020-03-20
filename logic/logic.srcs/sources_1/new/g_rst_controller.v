`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2020 20:38:32
// Design Name: 
// Module Name: g_rst_controller
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

module g_rst_controller(
        input clk_master,           // Master clock reference
        input g_rst_trig_ps,        // PS controlled reset signal
        output g_rst_gen            // Reset signal to blocks
    );

parameter G_RST_START = 4;
parameter G_RST_PULSE_WIDTH = 128;

reg g_rst_gen_reg;
assign g_rst_gen = g_rst_gen_reg;

reg g_rst_state = 0;
reg [7:0] g_rst_counter = 0;

// Reset pulse generator. Generates a one time reset pulse for other blocks.
always @(posedge clk_master) begin

    if (g_rst_trig_ps) begin
        g_rst_state <= 0;
        g_rst_counter <= 0;
    end

    if (g_rst_state == 0) begin
        g_rst_counter <= g_rst_counter + 1;
        
        if (g_rst_counter == G_RST_START) begin
            g_rst_gen_reg <= 1;   
        end
        
        if (g_rst_counter == G_RST_PULSE_WIDTH) begin
            g_rst_gen_reg <= 0;
            g_rst_state <= 1;   
        end
    end
    
end

endmodule

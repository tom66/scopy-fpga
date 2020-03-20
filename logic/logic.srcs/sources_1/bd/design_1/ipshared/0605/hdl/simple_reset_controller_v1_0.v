
`timescale 1 ns / 1 ps

module simple_reset_controller_v1_0 (
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

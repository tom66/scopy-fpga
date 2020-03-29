`timescale 1ns / 1ps

module adc_trigger_holdoff(
    // Module clock (typ. 125MHz, or 1/8th sampling rate)
    input mod_clk,
    
    // Holdoff downcount value
    input [31:0] holdoff_timer_load_value,
    
    // Holdoff load signal
    input holdoff_load,
    
    // General reset signal
    input trig_rst,
    
    // Holdoff trigger inhibit output
    output reg holdoff_trigger_inhibit,
    
    // Holdoff debug output
    output [31:0] holdoff_debug_time
);

reg [31:0] holdoff_reg = 0;
assign holdoff_debug_time = holdoff_reg;

always @(posedge mod_clk) begin

    if (trig_rst) begin
        holdoff_reg <= 0;
        holdoff_trigger_inhibit <= 0;
    end else begin
        if (holdoff_load) begin
            holdoff_trigger_inhibit <= 1;
            holdoff_reg <= holdoff_timer_load_value;
        end else begin
            if (holdoff_reg == 0) begin
                holdoff_trigger_inhibit <= 0;
            end else begin
                holdoff_trigger_inhibit <= 1;
                holdoff_reg <= holdoff_reg - 1;
            end
        end
    end

end
    
endmodule

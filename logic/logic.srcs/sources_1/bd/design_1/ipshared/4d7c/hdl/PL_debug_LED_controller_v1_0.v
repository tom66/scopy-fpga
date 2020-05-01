
`timescale 1 ns / 1 ps
module PL_debug_LED_controller_v1_0 #
(
    parameter integer LED_BYTE_CHANNEL = 0
)
(
    input spi_csn,
    input spi_clk,
    input acq_done,
    input acq_run,
    input trig_sig,
    input axi_clk,
    input axi_resetn,
    input [31:0] R_led_ctrl,
    output reg led_out
);

// Generate 10Hz pulse
reg [23:0] led_counter; 
reg led_10Hz; // roughly 10Hz @ 177MHz

always @(posedge axi_clk) begin
    if (axi_resetn == 0) begin
        led_counter <= 24'hffffff;
        led_10Hz <= 0;
    end else begin
        led_counter <= led_counter - 1;
        
        if (led_counter == 0) begin
            led_10Hz <= ~led_10Hz;
        end
    end
end

// Generate toggle signals for internal logic signals
reg last_spi_csn = 1, last_spi_clk = 0, last_acq_done = 0, last_acq_run = 0, last_trig_sig = 0;
reg tog_spi_csn = 0, tog_spi_clk = 0, tog_acq_done = 0, tog_acq_run = 0, tog_trig_sig = 0;

always @* begin
    
    last_spi_csn <= spi_csn;
    if (spi_csn != last_spi_csn && spi_csn == 0) begin
        tog_spi_csn <= ~tog_spi_csn;
    end
    
    last_spi_clk <= spi_clk;
    if (spi_clk != last_spi_clk && spi_clk == 1) begin
        tog_spi_clk <= ~tog_spi_clk;
    end
    
    last_acq_done <= acq_done;
    if (acq_done != last_acq_done && acq_done == 1) begin
        tog_acq_done <= ~tog_acq_done;
    end
    
    last_acq_run <= acq_run;
    if (acq_run != last_acq_run && acq_run == 1) begin
        tog_acq_run <= ~tog_acq_run;
    end
    
    last_trig_sig <= trig_sig;
    if (trig_sig != last_trig_sig && trig_sig == 1) begin
        tog_trig_sig <= ~tog_trig_sig;
    end
    
end

// hopefully this becomes a compile-time constant mux
wire [7:0] led_ctrl_mux = R_led_ctrl[(8 * (LED_BYTE_CHANNEL + 1)) - 1:(8 * LED_BYTE_CHANNEL)];

always @* begin

    case (led_ctrl_mux) 
        8'h00:   led_out = 0;
        8'h01:   led_out = 1;
        8'h02:   led_out = tog_spi_csn;
        8'h03:   led_out = ~spi_csn;
        8'h04:   led_out = tog_spi_clk;
        8'h05:   led_out = spi_clk;
        8'h06:   led_out = tog_acq_done;
        8'h07:   led_out = acq_done;
        8'h08:   led_out = tog_acq_run;
        8'h09:   led_out = acq_run;
        8'h0a:   led_out = tog_trig_sig;
        8'h0b:   led_out = trig_sig;
        8'h0c:   led_out = led_10Hz;
        8'h0d:   led_out = 1'bX;
        default: led_out = 1'bX;
    endcase

end

endmodule

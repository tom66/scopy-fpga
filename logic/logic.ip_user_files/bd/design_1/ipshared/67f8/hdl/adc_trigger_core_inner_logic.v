`timescale 1ns / 1ps

module adc_trigger_core_inner_logic (
    // Input signals
    input comp_ena,
    input comp_rst,
    input comp_pol,
    input adc_data_clk,
    input adc_a_hi_comp,
    input adc_a_lo_comp,
    input adc_b_hi_comp,
    input adc_b_lo_comp,
    
    // Output signals
    output comp_sig,
    output reg comp_ch_a,
    output reg comp_ch_b,
    
    // Debug signals
    output [1:0] dbg_comp_state,
    output [1:0] dbg_ev_counter
);

// State machine parameters
parameter COMP_STATE_IDLE = 0;
parameter COMP_STATE_HIGH_EDGE = 1;
parameter COMP_STATE_LOW_EDGE = 2;
parameter COMP_STATE_PULSE_OUT = 3;

// Current trigger state
assign dbg_comp_state = comp_state;
assign dbg_ev_counter = comp_ev_counter;

reg [1:0] comp_ev_counter = 0;
reg [1:0] comp_state_next = COMP_STATE_IDLE;
reg [1:0] comp_state = COMP_STATE_IDLE;

reg comp_sig_noninv;
assign comp_sig = (comp_pol) ? (comp_sig_noninv) : (~comp_sig_noninv);

always @(posedge adc_data_clk) begin

    if (comp_rst) begin
        comp_state <= COMP_STATE_IDLE;
        comp_state_next <= COMP_STATE_IDLE;
		
        comp_ev_counter <= 0;
        comp_ch_a <= 0;
        comp_ch_b <= 0;
        comp_sig_noninv <= 0;
    end else begin
        case (comp_state)
            COMP_STATE_IDLE : begin
                if (comp_ena && !comp_rst) begin
                    comp_state <= COMP_STATE_HIGH_EDGE;
                    comp_ch_a <= 0;
                    comp_ch_b <= 0;
                    comp_sig_noninv <= 0;
                end
            end
            
            COMP_STATE_HIGH_EDGE : begin
                if (comp_ena) begin
                    if (adc_a_hi_comp && adc_b_hi_comp) begin
                        comp_state <= COMP_STATE_PULSE_OUT;
                        comp_state_next <= COMP_STATE_LOW_EDGE;
                        comp_ev_counter <= 0;
                        comp_ch_a <= 1;
                        comp_ch_b <= 1;
                        comp_sig_noninv <= ~comp_sig_noninv;
                    end else if (adc_b_hi_comp) begin
                        comp_state <= COMP_STATE_PULSE_OUT;
                        comp_state_next <= COMP_STATE_LOW_EDGE;
                        comp_ev_counter <= 0;
                        comp_ch_a <= 0;
                        comp_ch_b <= 1;
                        comp_sig_noninv <= ~comp_sig_noninv;
                    end else if (adc_a_hi_comp) begin
                        comp_state <= COMP_STATE_PULSE_OUT;
                        comp_state_next <= COMP_STATE_LOW_EDGE;
                        comp_ev_counter <= 0;
                        comp_ch_a <= 1;
                        comp_ch_b <= 0;
                        comp_sig_noninv <= ~comp_sig_noninv;
                    end
                end
            end
            
            COMP_STATE_LOW_EDGE : begin
                if (comp_ena) begin
                    if (adc_a_lo_comp && adc_b_lo_comp) begin
                        comp_state <= COMP_STATE_PULSE_OUT;
                        comp_state_next <= COMP_STATE_HIGH_EDGE;
                        comp_ev_counter <= 0;
                        comp_ch_a <= 1;
                        comp_ch_b <= 1;
                        comp_sig_noninv <= ~comp_sig_noninv;
                    end else if (adc_b_lo_comp) begin
                        comp_state <= COMP_STATE_PULSE_OUT;
                        comp_state_next <= COMP_STATE_HIGH_EDGE;
                        comp_ev_counter <= 0;
                        comp_ch_a <= 0;
                        comp_ch_b <= 1;
                        comp_sig_noninv <= ~comp_sig_noninv;
                    end else if (adc_a_lo_comp) begin
                        comp_state <= COMP_STATE_PULSE_OUT;
                        comp_state_next <= COMP_STATE_HIGH_EDGE;
                        comp_ev_counter <= 0;
                        comp_ch_a <= 1;
                        comp_ch_b <= 0;
                        comp_sig_noninv <= ~comp_sig_noninv;
                    end
                end
            end
            
            COMP_STATE_PULSE_OUT : begin
                if (comp_ev_counter == 2) begin
                    comp_state <= comp_state_next; 
                    comp_ch_a <= 0;
                    comp_ch_b <= 0;
                end
                
                comp_ev_counter <= comp_ev_counter + 1;
            end
            
        endcase
    end
    
end

endmodule

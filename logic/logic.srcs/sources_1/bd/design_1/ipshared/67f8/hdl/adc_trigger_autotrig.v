`timescale 1ns / 1ps

module adc_trigger_autotrig (
    // Module clock (typ. 125MHz, or 1/8th sampling rate)
    input mod_clk,
    
    // Auto trigger timers.  Both timers are 12-bit.
    // The initial timer is at 1/256 the input clock;  the repeat timer is at 1/32 the input clock
    input [11:0] auto_initial_load,
    input [11:0] auto_repeat_load,
    
    // Trigger received signal, resets state back to the initial timer state
    input auto_trig_recv,
    
    // Auto trigger initialiser - starts state machine
    input auto_init,
    
    // Arm signal, enables counters and output generation
    input auto_arm,
    
    // Generated trigger output
    output reg auto_out,
    
    // Initial/repeat state
    output reg auto_init_rep,
    
    // Debug: auto state machine output
    output [2:0] dbg_auto_state
);

// Dividers - one generates a pulse every 256 events, the other every 32 events.
// Perhaps in future these could be combined in some way?
reg [8:0] div256_counter = 0;
reg [6:0] div32_counter = 0;

reg div256 = 0;
reg div32 = 0;

always @(posedge mod_clk) begin

    if (auto_arm) begin
        if (div32_counter == 31) begin
            div32 <= 1;
            div32_counter <= 0;
        end else begin
            div32 <= 0;
            div32_counter <= div32_counter + 1;
        end
        
        if (div256_counter == 255) begin
            div256 <= 1;
            div256_counter <= 0;
        end else begin
            div256 <= 0;
            div256_counter <= div256_counter + 1;
        end
    end else begin
        div32 <= 0;
        div256 <= 0;
    end
    
end

// State machine
parameter AUTO_STATE_NOT_ARMED = 1;
parameter AUTO_STATE_WAIT_INITIAL = 2;
parameter AUTO_STATE_WAIT_REPEAT = 3;

reg [1:0] auto_state = AUTO_STATE_NOT_ARMED;
assign dbg_auto_state = auto_state;

reg [11:0] auto_initial_reg = 0;
reg [11:0] auto_repeat_reg = 0;

always @(posedge mod_clk) begin
    
    case (auto_state)
    
        AUTO_STATE_NOT_ARMED : begin
            auto_out <= 0;
            
            if (auto_init && auto_arm) begin
                auto_initial_reg <= auto_initial_load;
                auto_repeat_reg <= auto_repeat_load;
                
                // To ensure consistent timing, wait until both div256 and div32 are high,
                // so we start on the same beat.  (div32 guaranteed to be set when div256 set,
                // but this is a sanity check on my logic.)
                if (div256 && div32) begin
                    auto_state <= AUTO_STATE_WAIT_INITIAL;
                end
            end
        end
        
        AUTO_STATE_WAIT_INITIAL : begin
            auto_out <= 0;
            
            // if we get a trigger, then reset the state
            if (auto_trig_recv) begin
                auto_state <= AUTO_STATE_NOT_ARMED;
            end else begin
                if (div256) begin
                    auto_initial_reg <= auto_initial_reg - 1;
                
                    if (auto_initial_reg == 0) begin
                        auto_out <= 1;
                        auto_init_rep <= 0;
                        auto_state <= AUTO_STATE_WAIT_REPEAT;
                    end
                end
            end
        end
        
        AUTO_STATE_WAIT_REPEAT : begin
            auto_out <= 0;
            
            // if we get a trigger, then reset the state
            if (auto_trig_recv) begin
                auto_state <= AUTO_STATE_NOT_ARMED;
            end else if (div32) begin
                auto_repeat_reg <= auto_repeat_reg - 1;
            
                if (auto_repeat_reg == 0) begin
                    auto_out <= 1;
                    auto_init_rep <= 1;
                    auto_state <= AUTO_STATE_WAIT_REPEAT;
                end
            end
        end
        
    endcase
    
end

endmodule

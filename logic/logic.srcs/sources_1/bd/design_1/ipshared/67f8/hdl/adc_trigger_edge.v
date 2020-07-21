`timescale 1ns / 1ps

module adc_trigger_edge(
    // Enable signal for edge trigger.  If this is not set, the output of the trigger is all zeroes.
    // Both signals must be asserted.  One signal is intended as a mux and the other as a general enable.
    input mod_en,
    input mod_global_en,
    
    // Global reset signal for trigger
    input trig_rst,
    
    // External trigger source: special mode.  N.B.: Trigger engine should be reset when changing mode here.
    input [1:0] trig_ext_sel,
    input trig_input_external,
    input trig_input_ac,
    
    // Clock signal for logic.
    input mod_clk,
    
    // Edge mode
    input [1:0] trig_edge_mode,
    
    // Trigger input signals (Only channel A used)
    input [3:0] trig_sig_a,
    input [1:0] trig_src_1a1b_group_a,
    input [1:0] trig_src_2a2b_group_a,
    input [1:0] trig_src_3a3b_group_a,
    input [1:0] trig_src_4a4b_group_a,
    
    // Trigger output signals
    output reg trig_gen,
    output [2:0] trig_ch_code,
    
    // Debug signals
    output dbg_trig_ch_code_valid,
    output dbg_decode_rst,
    output dbg_trig_logic,
    output [2:0] dbg_trig_ch_code_state,
    output [1:0] dbg_trig_src_4a4b_dly2
);

reg trig_last_in;
//wire trig_in = trig_sig_a[0] | trig_sig_a[1] | trig_sig_a[2] | trig_sig_a[3];
wire trig_edge_block;

// Trigger signals inhibited while trigger is generated
wire trig_logic = trig_edge_block && !trig_gen;
wire trig_logic_external = trig_input_external && !trig_gen;
wire trig_logic_ac = trig_input_ac && !trig_gen;

assign dbg_trig_logic = trig_logic;

// Edge detection
adc_trigger_edge_detect (
    .edge_mode(trig_edge_mode),
    .trig_sig(trig_sig_a),
    .trig_src_1a1b(trig_src_1a1b_group_a),
    .trig_src_2a2b(trig_src_2a2b_group_a),
    .trig_src_3a3b(trig_src_3a3b_group_a),
    .trig_src_4a4b(trig_src_4a4b_group_a),
    .clk(mod_clk),
    .trig_out(trig_edge_block),
    .trig_ch_code(trig_ch_code),
    .trig_ch_valid(dbg_trig_ch_valid),
    .dbg_trig_ch_code_valid(dbg_trig_ch_code_valid),
    .dbg_decode_rst(dbg_decode_rst),
    .dbg_trig_ch_code_state(dbg_trig_ch_code_state),
    .dbg_trig_src_4a4b_dly2(dbg_trig_src_4a4b_dly2)
);

always @(posedge mod_clk) begin

    if (trig_rst) begin
        trig_gen <= 0;
    end else begin
        if (mod_en && mod_global_en) begin
            case (trig_ext_sel)
                // Normal mode: ext trigger set to 00, wait for comparator event
                2'b00: begin
                    if (trig_logic) begin
                        trig_gen <= 1;
                    end else if (trig_gen) begin
                        trig_gen <= 0;
                    end
                end
                
                // AC Trigger mode:  External AC input signal provides regular mains trigger signal
                2'b01: begin
                    if (trig_logic_ac) begin
                        trig_gen <= 1;
                    end else if (trig_gen) begin
                        trig_gen <= 0;
                    end
                end
                
                // Ext. Trigger mode:  External trigger input signal routed via fabric
                2'b10: begin
                    if (trig_logic_external) begin
                        trig_gen <= 1;
                    end else if (trig_gen) begin
                        trig_gen <= 0;
                    end
                end
                
                default: trig_gen <= 0;
            endcase
        end else begin     
            trig_gen <= 0;
        end
    end
    
end


endmodule

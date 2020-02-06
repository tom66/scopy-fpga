`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 
// This file is part of YAOS and is licenced under the MIT Licence.
//
//////////////////////////////////////////////////////////////////////////////////

//
// The Config BRAM controller implements a writable configuration interface, which
// allows the PS to write to configuration registers via the AXI bus.  The interface
// maintains a copy in the BRAM and synchronises, on request, this data to on-device
// registers, located in various blocks.  The interface must be edited to add any
// further registers;  such should be added as 'in' or 'out' constructs which connect 
// ultimately to registers.
//
// Note it is only possible to represent registers that can be read or registers that
// can be written this way.  Bidirectional use of registers is not implemented to
// reduce logic complexity.
//
// The BRAM block is external and implemented in the Block Design.  Registers are up
// to 32-bit wide.
//

// TODO:  Power optimisation.  Consider reducing clock to /4 main clock to save power.

module cfg_bram_controller(
    // BlockRAM interface
    output reg [31:0] cfg_bram_addr,
    output reg [31:0] cfg_bram_din,
    input [31:0] cfg_bram_dout,
    output cfg_bram_clk,
    output [3:0] cfg_bram_we,
    output reg cfg_bram_en,
    input cfg_bram_busy,
    
    // EMIO control interface
    input cfg_commit,
    output cfg_commit_done,
    
    // General resources
    input g_rst,
    input clk_ref,          // xx MHz master clock source (~170MHz as of writing)
    
    // Register interface
    output reg [31:0] R_acq_size_a,
    output reg [31:0] R_acq_size_b,
    input [31:0] R_acq_trigger_ptr,
    output reg [6:0] R_acq_demux_mode,
    output [1:0] R_gpio_test
);

reg [3:0] cfg_ctrl_state = CFG_BRAM_CTRL_STATE_IDLE;
reg [1:0] cfg_bram_substate = CFG_BRAM_CTRL_SUBSTATE_ADDR;
reg [12:0] cfg_ctrl_idx = 0;
reg cfg_bram_write_en = 0;
reg cfg_last_commit = 0;

wire clk_ref_bram;

assign cfg_bram_we = (cfg_bram_write_en) ? 4'b1111 : 4'b0000;
assign cfg_bram_clk = clk_ref_bram;

reg cfg_commit_done_reg = 0;
assign cfg_commit_done = cfg_commit_done_reg;

//assign R_gpio_test = R_gpio_test_reg;
reg [1:0] R_gpio_test_reg;

assign R_gpio_test[0] = R_gpio_test_reg[0];
assign R_gpio_test[1] = R_gpio_test_reg[1];

reg [31:0] dummy1;

parameter BITSTREAM_VERSION = 32'hb37a0001;

parameter CFG_BRAM_CTRL_STATE_IDLE = 1;
parameter CFG_BRAM_CTRL_STATE_SYNC = 2;

parameter CFG_BRAM_CTRL_SUBSTATE_ADDR = 0;
parameter CFG_BRAM_CTRL_SUBSTATE_DATA = 3;

/*
 * Input clock is divided - no need for this block to run at ~200MHz.
 */
BUFR #(
    .BUFR_DIVIDE("2")
) bufr_bram_cfg_local_div (
    .I(clk_ref),
    .O(clk_ref_bram),
    .CE(1'b1),
    .CLR(1'b0)
);

/*
 * USRACCESSE2 register - encodes bitstream ID.
 */
wire [31:0] usraccess_bitstream_id;

USR_ACCESSE2 (
    .DATA(usraccess_bitstream_id)
);

always @(posedge clk_ref_bram) begin

    // Two states:  CFG BRAM is either idle, or syncing
    case (cfg_ctrl_state) 
    
        CFG_BRAM_CTRL_STATE_IDLE: begin
            cfg_bram_en <= 0;
            cfg_ctrl_idx <= 0;
            
            if (cfg_commit && /*(!cfg_bram_busy) && */(!cfg_last_commit)) begin
                cfg_ctrl_state <= CFG_BRAM_CTRL_STATE_SYNC;
                cfg_commit_done_reg <= 0;
            end
        end
    
        CFG_BRAM_CTRL_STATE_SYNC: begin
            // Address BRAM on cycle 0-2, register data on cycle 1
            if (cfg_bram_substate != CFG_BRAM_CTRL_SUBSTATE_DATA) begin
                cfg_bram_en <= 1;
                cfg_bram_addr <= cfg_ctrl_idx * 4;
                cfg_bram_write_en <= 0;
                cfg_bram_substate <= cfg_bram_substate + 1;
            end else begin
                // Sync registers by address (read or write dependent)
                case (cfg_ctrl_idx)
                
                    // dummy1: read value into internal dummy1 register
                    12'h000: begin
                        cfg_bram_write_en <= 0;
                        dummy1 <= cfg_bram_dout;
                    end
                    
                    // dummy2: BRAM written with contents of dummy1 
                    12'h001: begin
                        cfg_bram_write_en <= 1;
                        cfg_bram_din <= dummy1;
                    end
                    
                    // magic1: BRAM written with magic bit pattern
                    12'h002: begin
                        cfg_bram_write_en <= 1;
                        cfg_bram_din <= 32'h536d7670; // "Smvp"
                    end
                    
                    // version: BRAM written with version bit pattern
                    12'h003: begin
                        cfg_bram_write_en <= 1;
                        cfg_bram_din <= BITSTREAM_VERSION; 
                    end
                    
                    // user_access:  BRAM written with bitstream ID
                    12'h004: begin
                        cfg_bram_write_en <= 1;
                        cfg_bram_din <= usraccess_bitstream_id; 
                    end
                        
                    // acq_size_A
                    12'h005: begin
                        cfg_bram_write_en <= 0;
                        R_acq_size_a <= cfg_bram_dout;
                    end
                        
                    // acq_size_B
                    12'h006: begin
                        cfg_bram_write_en <= 0;
                        R_acq_size_b <= cfg_bram_dout;
                    end
                        
                    // acq_trigger_ptr
                    12'h007: begin
                        cfg_bram_write_en <= 1;
                        cfg_bram_din <= R_acq_trigger_ptr;
                    end
                        
                    // acq_demux_mode
                    12'h008: begin
                        cfg_bram_write_en <= 0;
                        R_acq_demux_mode <= cfg_bram_dout;
                    end
                    
                    // gpio_test
                    12'h009: begin
                        cfg_bram_write_en <= 0;
                        R_gpio_test_reg <= cfg_bram_dout;
                    end
                    
                    // EOF
                    12'h00c: begin
                        cfg_bram_write_en <= 0;
                        cfg_ctrl_state <= CFG_BRAM_CTRL_STATE_IDLE;
                        cfg_commit_done_reg <= 1;
                    end   
                    
                    default: begin
                        cfg_bram_write_en <= 1;
                        cfg_bram_din <= 32'hffffffff;
                    end
                    
                endcase
                
                cfg_ctrl_idx <= cfg_ctrl_idx + 1;
                cfg_bram_substate <= CFG_BRAM_CTRL_SUBSTATE_ADDR;
            end
        end
    
    endcase
    
    cfg_last_commit <= cfg_commit;
            
end
    
endmodule

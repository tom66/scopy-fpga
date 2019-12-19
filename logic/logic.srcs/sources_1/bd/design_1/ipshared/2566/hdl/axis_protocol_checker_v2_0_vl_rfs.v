// (c) Copyright 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//--------------------------------------------

//RESET_POLARITY_SYMBOL, set to ! (or blank) for active low (high)
`define AKRPS !

`timescale 1 ns / 1 ns

//Assertion circuit for vunit: inline
//vunit is bound to module: Axi4StreamPC
module axis_protocol_checker_v2_0_2_asr_inline (Axi4StreamPC_asr_inline_out, reset, ARESETn, TVALID, ACLK, ACLKEN, TREADY, TID, TDEST, TKEEP, TDATA, TLAST, TSTRB, TUSER);
  parameter DATA_WIDTH_BYTES = 3;
  parameter DEST_WIDTH = 4;
  parameter ID_WIDTH = 4;
  parameter USER_WIDTH = 3;
  parameter DATA_MAX = DATA_WIDTH_BYTES ? ( DATA_WIDTH_BYTES * 8 ) - 1 : 0;
  parameter DEST_MAX = DEST_WIDTH ? DEST_WIDTH - 1 : 0;
  parameter STRB_WIDTH = DATA_WIDTH_BYTES;
  parameter STRB_MAX = STRB_WIDTH ? STRB_WIDTH - 1 : 0;
  parameter KEEP_MAX = STRB_WIDTH ? STRB_WIDTH - 1 : 0;
  parameter ID_MAX = ID_WIDTH ? ID_WIDTH - 1 : 0;
  parameter TUSER_MAX = USER_WIDTH ? USER_WIDTH - 1 : 0;
  parameter MAXWAITS = 16;
  output [11:1] Axi4StreamPC_asr_inline_out;
  input reset, ARESETn, TVALID, ACLK, ACLKEN, TREADY, TLAST;
  input [ID_MAX:0] TID;
  input [DEST_MAX:0] TDEST;
  input [KEEP_MAX:0] TKEEP;
  input [DATA_MAX:0] TDATA;
  input [STRB_MAX:0] TSTRB;
  input [TUSER_MAX:0] TUSER;

  wire [2:0] s1s;
  reg [2:0] s1sq;
  reg [ID_MAX:0] s2;
  wire [2:0] s4s;
  reg [2:0] s4sq;
  reg [DEST_MAX:0] s5;
  wire [2:0] s7s;
  reg [2:0] s7sq;
  reg [KEEP_MAX:0] s8;
  wire [4:0] s10s;
  reg [4:0] s10sq;
  wire [4:0] s11s;
  reg [4:0] s11sq;
  wire [2:0] s14s;
  reg [2:0] s14sq;
  reg [STRB_MAX:0] s15;
  wire [4:0] s17s;
  reg [4:0] s17sq;
  wire [2:0] s18s;
  reg [2:0] s18sq;
  wire [4:0] s20s;
  reg [4:0] s20sq;
  
  reg [DATA_MAX:0]  s11sqa;
  wire  s11sqaa;
  reg [TUSER_MAX:0]  s20sqa;
  wire  s20sqaa;
  wire s3, s6, s9, s13, s16;
  reg ASR_1, ASR_2, ASR_3, ASR_4, ASR_5, s12, ASR_6, ASR_7, ASR_8, ASR_9, ASR_10, ASR_11;


  assign Axi4StreamPC_asr_inline_out={ASR_11, ASR_10, ASR_9, ASR_8, ASR_7, ASR_6, ASR_5, ASR_4, ASR_3, ASR_2, ASR_1};

  function integer f_clogb2 (input integer size);
    integer s;
    begin
      s = size;
      s = s - 1;
      for (f_clogb2=1; s>1; f_clogb2=f_clogb2+1)
            s = s >> 1;
    end
  endfunction // clogb2

localparam L_WAIT_WIDTH = f_clogb2(MAXWAITS+1);

  //---------------
  //ASR_1 : assert property ( @(posedge ACLK) ! ( ARESETn ) ##1 ARESETn |-> ! TVALID );
  //---------------
  always @(posedge ACLK) if (`AKRPS reset) s1sq<=3'h4; else
    s1sq<=s1s;
  assign s1s={1'b1,
    (!(ARESETn)),
    (s1sq[1] && (ARESETn && TVALID))};
  always @(posedge ACLK) if (`AKRPS reset) ASR_1<=0; else
    ASR_1 <= (s1s[0]);

  //---------------
  //ASR_2 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TID) );
  //---------------
  always @(posedge ACLK)
    s2<=TID;
  assign s3 = s2 == TID;
  always @(posedge ACLK) if (`AKRPS reset) s4sq<=3'h4; else
    s4sq<=s4s;
  assign s4s={1'b1,
    (((ARESETn & TVALID) & (! TREADY))),
    (s4sq[1] && (ARESETn && !(s3)))};
  always @(posedge ACLK) if (`AKRPS reset) ASR_2<=0; else
    ASR_2 <= (s4s[0]);

  //---------------
  //ASR_3 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TDEST) );
  //---------------
  always @(posedge ACLK)
    s5<=TDEST;
  assign s6 = s5 == TDEST;
  always @(posedge ACLK) if (`AKRPS reset) s7sq<=3'h4; else
    s7sq<=s7s;
  assign s7s={1'b1,
    (((ARESETn & TVALID) & (! TREADY))),
    (s7sq[1] && (ARESETn && !(s6)))};
  always @(posedge ACLK) if (`AKRPS reset) ASR_3<=0; else
    ASR_3 <= (s7s[0]);


  //---------------
  //ASR_4 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TKEEP) );
  //---------------
  //---------------
  //ASR_5 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TDATA & TdataMask) );
  //---------------
  //---------------
  //ASR_7 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TSTRB) );
  //---------------
  //---------------
  //ASR_10 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TUSER & TuserMask) );
  //---------------

localparam integer L_NUM_DATA_BYTES   = DATA_WIDTH_BYTES;
localparam integer L_NUM_DEQ_LANES    = (DATA_WIDTH_BYTES + 7) / 8;
localparam integer L_NUM_DAND1_LANES  = (L_NUM_DEQ_LANES + 7) / 8;
localparam integer L_NUM_DAND2_LANES  = (L_NUM_DAND1_LANES + 7) / 8;
localparam integer L_NUM_USER_BYTES   = ((USER_WIDTH + 7) / 8);
localparam integer L_NUM_UBYTE_LANES  = ((L_NUM_USER_BYTES + 7) / 8) * 8;
localparam integer L_NUM_UEQ_LANES    = (L_NUM_UBYTE_LANES / 8);
localparam integer L_NUM_UAND1_LANES  = (L_NUM_UEQ_LANES + 7) / 8;
localparam integer L_NUM_UAND2_LANES  = (L_NUM_UAND1_LANES + 7) / 8;

wire  [(L_NUM_USER_BYTES*8)-1:0]      tuser_expand;
wire  [(L_NUM_USER_BYTES*8)-1:0]      s20sqa_expand;
reg   [(L_NUM_UBYTE_LANES*8)-1:0]     user_eq = {(L_NUM_UBYTE_LANES*8){1'b1}};
reg   [(8*L_NUM_UAND1_LANES*8)-1:0]   tuser_stage_1_eq = {(8*L_NUM_UAND1_LANES*8){1'b1}};
reg   [(8*L_NUM_UAND2_LANES*8)-1:0]   tuser_stage_2_eq = {(8*L_NUM_UAND2_LANES*8){1'b1}};

reg [(8*L_NUM_DEQ_LANES*8)-1:0]   data_eq = {(8*L_NUM_DEQ_LANES*8){1'b1}};
reg [(8*L_NUM_DEQ_LANES*8)-1:0]   strb_eq = {(8*L_NUM_DEQ_LANES*8){1'b1}};
reg [(8*L_NUM_DEQ_LANES*8)-1:0]   keep_eq = {(8*L_NUM_DEQ_LANES*8){1'b1}};
reg [(8*L_NUM_DAND1_LANES*8)-1:0] tdata_stage_1_eq = {(8*L_NUM_DAND1_LANES*8){1'b1}};
reg [(8*L_NUM_DAND2_LANES*8)-1:0] tdata_stage_2_eq = {(8*L_NUM_DAND2_LANES*8){1'b1}};
reg [(8*L_NUM_DAND1_LANES*8)-1:0] tstrb_stage_1_eq = {(8*L_NUM_DAND1_LANES*8){1'b1}};
reg [(8*L_NUM_DAND2_LANES*8)-1:0] tstrb_stage_2_eq = {(8*L_NUM_DAND2_LANES*8){1'b1}};
reg [(8*L_NUM_DAND1_LANES*8)-1:0] tkeep_stage_1_eq = {(8*L_NUM_DAND1_LANES*8){1'b1}};
reg [(8*L_NUM_DAND2_LANES*8)-1:0] tkeep_stage_2_eq = {(8*L_NUM_DAND2_LANES*8){1'b1}};

  always @(posedge ACLK) begin
    s11sqa<=TDATA;
    s8<=TKEEP;
    s15<=TSTRB;
    s20sqa<=TUSER;
  end

  always @(posedge ACLK) begin
    if (`AKRPS reset) begin
      s11sq<=5'h00; 
      s10sq<=5'h00;
      s17sq<=5'h00;
      s20sq<=5'h00;
    end else begin
      s11sq<=s11s;
      s10sq<=s10s;
      s17sq<=s17s;
      s20sq<=s20s;
    end
  end

  assign s11s={
    (((ARESETn & TVALID) & (! TREADY))),
    (s11sq[4] && ARESETn),
    (s11sq[3]),
    (s11sq[2]),
    (s11sq[1] & !(s11sqaa))
    };

  assign s10s={
    (((ARESETn & TVALID) & (! TREADY))),
    (s10sq[4] && ARESETn),
    (s10sq[3]),
    (s10sq[2]),
    (s10sq[1] & !(s9))
    };

  assign s17s={
    (((ARESETn & TVALID) & (! TREADY))),
    (s17sq[4] && (ARESETn)),
    (s17sq[3]),
    (s17sq[2]),
    (s17sq[1] & !(s16))
    };

  assign s20s={
    (((ARESETn & TVALID) & (! TREADY))),
    (s20sq[4] && (ARESETn)),
    (s20sq[3]),
    (s20sq[2]),
    (s20sq[1] & !(s20sqaa))
    };

  always @(posedge ACLK) begin
    if (`AKRPS reset) begin
      ASR_4<=0;
      ASR_5<=0; 
      ASR_7<=0;
      ASR_10<=0;
    end else begin
      ASR_4 <= (s10s[0]);
      ASR_5 <= (s11s[0]);
      ASR_7 <= (s17s[0]);
      ASR_10 <= (s20s[0]);
    end
  end

genvar byte_exp;
genvar byte_cnt;
integer bc;
genvar data_stage_1;
genvar data_stage_2;
genvar user_bit;

integer user_bc;
genvar user_stage_1;
genvar user_stage_2;
generate
  ///////////////////////////////////////////////////////////////////////////////////////////
  //Expand the TUSER up to the nearest byte
  for (user_bit = 0; user_bit < (L_NUM_USER_BYTES * 8); user_bit = user_bit + 1) begin : UBIT_LOOP
    if (user_bit < USER_WIDTH) begin : VAL
      assign tuser_expand[user_bit] = TUSER[user_bit];
      assign s20sqa_expand[user_bit] = s20sqa[user_bit];
    end else begin
      assign tuser_expand[user_bit] = 1'b0;
      assign s20sqa_expand[user_bit] = 1'b0;
    end
  end

  for (user_stage_1 = 0; user_stage_1 < L_NUM_UAND1_LANES * 8; user_stage_1 = user_stage_1 + 1) begin : US1
    always @(posedge ACLK) begin
      if (user_stage_1 < L_NUM_UEQ_LANES) begin : VAL
        tuser_stage_1_eq[user_stage_1] <= &user_eq[user_stage_1*8 +:8];
      end else begin
        tuser_stage_1_eq[user_stage_1] <= 1'b1;
      end
    end
  end

  for (user_stage_2 = 0; user_stage_2 < L_NUM_UAND2_LANES * 8; user_stage_2 = user_stage_2 + 1) begin : US2
    always @(posedge ACLK) begin
      if (user_stage_2 < L_NUM_UAND1_LANES) begin : VAL
        tuser_stage_2_eq[user_stage_2] <= &tuser_stage_1_eq[user_stage_2*8 +:8];
      end else begin
        tuser_stage_2_eq[user_stage_2] <= 1'b1;
      end
    end
  end

  for (data_stage_1 = 0; data_stage_1 < L_NUM_DAND1_LANES * 8;data_stage_1 = data_stage_1 + 1) begin : DS1
    always @(posedge ACLK) begin
      if (data_stage_1 < L_NUM_DEQ_LANES) begin : VAL
        tdata_stage_1_eq[data_stage_1] <= &data_eq[data_stage_1*8 +:8];
        tkeep_stage_1_eq[data_stage_1] <= &keep_eq[data_stage_1*8 +:8];
        tstrb_stage_1_eq[data_stage_1] <= &strb_eq[data_stage_1*8 +:8];
      end else begin
        tdata_stage_1_eq[data_stage_1] <= 1'b1;
        tkeep_stage_1_eq[data_stage_1] <= 1'b1;
        tstrb_stage_1_eq[data_stage_1] <= 1'b1;
      end
    end
  end
  for (data_stage_2 = 0; data_stage_2 < L_NUM_DAND2_LANES * 8;data_stage_2 = data_stage_2 + 1) begin : DS2
    always @(posedge ACLK) begin
      if (data_stage_2 < L_NUM_DAND1_LANES) begin : VAL
        tdata_stage_2_eq[data_stage_2] <= &tdata_stage_1_eq[data_stage_2*8 +:8];
        tkeep_stage_2_eq[data_stage_2] <= &tkeep_stage_1_eq[data_stage_2*8 +:8];
        tstrb_stage_2_eq[data_stage_2] <= &tstrb_stage_1_eq[data_stage_2*8 +:8];
      end else begin
        tdata_stage_2_eq[data_stage_2] <= 1'b1;
        tkeep_stage_2_eq[data_stage_2] <= 1'b1;
        tstrb_stage_2_eq[data_stage_2] <= 1'b1;
      end
    end
  end
endgenerate

always @(posedge ACLK) begin
  for (user_bc = 0; user_bc < L_NUM_UBYTE_LANES; user_bc = user_bc + 1) begin : UBC_LOOP
    if (user_bc < L_NUM_USER_BYTES) begin : VAL
      user_eq[user_bc] <= tuser_expand[(user_bc*8)+:8] == s20sqa_expand[(user_bc*8)+:8];
    end else begin
      user_eq[user_bc] <= 1'b1;
    end
  end
end

//Take the TDATA
always @(posedge ACLK) begin
  for (bc = 0; bc < L_NUM_DEQ_LANES*8; bc = bc + 1) begin : BC_LOOP
    if (bc < L_NUM_DATA_BYTES) begin : VAL
      data_eq[bc] <= s11sqa[bc*8 +:8] == TDATA[bc*8 +: 8];
      strb_eq[bc] <= s15[bc] == TSTRB[bc];
      keep_eq[bc] <= s8[bc] == TKEEP[bc];
    end else begin
      data_eq[bc] <= 1'b1;
      strb_eq[bc] <= 1'b1;
      keep_eq[bc] <= 1'b1;
    end
  end
end

assign s11sqaa = &tdata_stage_2_eq;
assign s9 = &tkeep_stage_2_eq;
assign s16 = &tstrb_stage_2_eq;
assign s20sqaa = &tuser_stage_2_eq;

  //---------------
  //ASR_6 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> $stable(TLAST) );
  //---------------
  always @(posedge ACLK)
    s12<=TLAST;
  assign s13 = s12 == TLAST;
  always @(posedge ACLK) if (`AKRPS reset) s14sq<=3'h4; else
    s14sq<=s14s;
  assign s14s={1'b1,
    (((ARESETn & TVALID) & (! TREADY))),
    (s14sq[1] && (ARESETn && !(s13)))};
  always @(posedge ACLK) if (`AKRPS reset) ASR_6<=0; else
    ASR_6 <= (s14s[0]);

  //---------------
  //ASR_8 : assert property ( @(posedge ACLK) ARESETn & TVALID & ! TREADY ##1 ARESETn |-> TVALID );
  //---------------
  always @(posedge ACLK) if (`AKRPS reset) s18sq<=3'h4; else
    s18sq<=s18s;
  assign s18s={1'b1,
    (((ARESETn & TVALID) & (! TREADY))),
    (s18sq[1] && (ARESETn && !(TVALID)))};
  always @(posedge ACLK) if (`AKRPS reset) ASR_8<=0; else
    ASR_8 <= (s18s[0]);

  //---------------
  //ASR_9 : assert property ( @(posedge ACLK) ARESETn & ( TVALID & ! TREADY ) |-> ##[1:16] ( ! TVALID | TREADY ) );
  //---------------

  reg [L_WAIT_WIDTH-1:0]  v_cnt;
  wire asr_9_set;

  generate
    if (MAXWAITS > 0) begin : gen_wait
      always @(posedge ACLK) begin
        if (`AKRPS reset) begin
          v_cnt <= {L_WAIT_WIDTH{1'b0}};
        end else if (ACLKEN == 1) begin
          //Valid, not ready, clken
          if (ARESETn & (TVALID & !TREADY)) begin
            v_cnt <= v_cnt + 1;
          end else begin
            v_cnt <= {L_WAIT_WIDTH{1'b0}};
          end
        end
      end

      assign asr_9_set = (v_cnt == MAXWAITS) & (ARESETn & (TVALID & !TREADY));
    end else begin : gen_no_wait
      assign asr_9_set = 1'b0;
    end
  endgenerate

  always @(posedge ACLK) if (`AKRPS reset) ASR_9<=0; else
    ASR_9 <= (asr_9_set);

  //---------------
  //ASR_11 : assert property ( @(posedge ACLK) ARESETn & TVALID |-> ~ ( | ( ~ TKEEP & TSTRB ) ) );
  //---------------
  always @(posedge ACLK) if (`AKRPS reset) ASR_11<=0; else
    ASR_11 <= (((ARESETn & TVALID) && (| ( ((~ TKEEP) & TSTRB) ))));

endmodule //axis_protocol_checker_v2_0_2_asr_inline
/*Instantiation code:
Axi4StreamPC_asr_inline #(DATA_WIDTH_BYTES, DEST_WIDTH, ID_WIDTH, USER_WIDTH, DATA_MAX, DEST_MAX, STRB_WIDTH, STRB_MAX, KEEP_MAX, ID_MAX, TUSER_MAX) i_Axi4StreamPC_asr_inline (Axi4StreamPC_asr_inline_out, reset, ACLKEN, ARESETn, TVALID, ACLK, TREADY, TID, TDEST, TKEEP, TDATA, TdataMask, TLAST, TSTRB, TUSER, TuserMask);
*/
//End of circuit(s) for vunit: inline




// (c) Copyright 2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.


`timescale 1ps/1ps
`default_nettype none
`ifndef AXI4STREAMPC_MESSAGES
  `define AXI4STREAMPC_MESSAGES
  `define ERRM_TVALID_RESET         "AXI4STREAM_ERRM_TVALID_RESET. TVALID must be low for the first clock edge that ARESETn goes high. Spec: section 2.7.2, and figure 2-4 on page 2-11."
  `define ERRM_TID_STABLE           "AXI4STREAM_ERRM_TID_STABLE. TID must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TDEST_STABLE         "AXI4STREAM_ERRM_TDEST_STABLE. TDEST must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TKEEP_STABLE         "AXI4STREAM_ERRM_TKEEP_STABLE. TKEEP must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TDATA_STABLE         "AXI4STREAM_ERRM_TDATA_STABLE. TDATA must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TLAST_STABLE         "AXI4STREAM_ERRM_TLAST_STABLE. TLAST must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TSTRB_STABLE         "AXI4STREAM_ERRM_TSTRB_STABLE. TSTRB must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TVALID_STABLE        "AXI4STREAM_ERRM_TVALID_STABLE. Once TVALID is asserted, it must remain asserted until TREADY is high. Spec: section 2.2.1, and figure 2-1 on page 2-3."
  `define RECS_TREADY_MAX_WAIT      "AXI4STREAM_RECS_TREADY_MAX_WAIT. TREADY should be asserted within MAXWAITS cycles of TVALID being asserted."
  `define ERRM_TID_X                "AXI4STREAM_ERRM_TID_X. When TVALID is high, a value of X on TID is not permitted."
  `define ERRM_TDEST_X              "AXI4STREAM_ERRM_TDEST_X. When TVALID is high, a value of X on TDEST is not permitted."
  `define ERRM_TKEEP_X              "AXI4STREAM_ERRM_TKEEP_X. When TVALID is high, a value of X on TKEEP is not permitted."
  `define ERRM_TDATA_X              "AXI4STREAM_ERRM_TDATA_X. When TVALID is high, a value of X on active byte lanes of TDATA is not permitted."
  `define ERRM_TLAST_X              "AXI4STREAM_ERRM_TLAST_X. When TVALID is high, a value of X on TLAST is not permitted."
  `define ERRM_TSTRB_X              "AXI4STREAM_ERRM_TSTRB_X. When TVALID is high, a value of X on TSTRB is not permitted."
  `define ERRM_TVALID_X             "AXI4STREAM_ERRM_TVALID_X. When not in reset, a value of X on TVALID is not permitted."
  `define ERRS_TREADY_X             "AXI4STREAM_ERRS_TREADY_X. When not in reset, a value of X on TREADY is not permitted."
  `define ERRM_TUSER_X              "AXI4STREAM_ERRM_TUSER_X. When TVALID is high, a value of X on TUSER is not permitted."
  `define ERRM_TUSER_STABLE         "AXI4STREAM_ERRM_TUSER_STABLE. TUSER must remain stable when TVALID is asserted and TREADY low. Spec: section 2.2.1, and figure 2-1, on page 2-3."
  `define ERRM_TKEEP_TSTRB          "AXI4STREAM_ERRM_TKEEP_TSTRB. If TKEEP is deasserted then TSTRB must also be deasserted. Spec: section 2.4.3, and table 2-2, on page 2-9."
  `define ERRM_STREAM_ALL_DONE_EOS  "AXI4STREAM_ERRM_STREAM_ALL_DONE_EOS. There are active streams outstanding at the end of the simulation."
  `define ERRM_TDATA_TIEOFF         "AXI4STREAM_ERRM_TDATA_TIEOFF. TDATA must be stable when DATA_WIDTH_BYTES has been set to zero."
  `define ERRM_TKEEP_TIEOFF         "AXI4STREAM_ERRM_TKEEP_TIEOFF. TKEEP must be stable when DATA_WIDTH_BYTES has been set to zero."
  `define ERRM_TSTRB_TIEOFF         "AXI4STREAM_ERRM_TSTRB_TIEOFF. TSTRB must be stable when DATA_WIDTH_BYTES has been set to zero."
  `define ERRM_TID_TIEOFF           "AXI4STREAM_ERRM_TID_TIEOFF. TID must be stable when ID_WIDTH has been set to zero."
  `define ERRM_TDEST_TIEOFF         "AXI4STREAM_ERRM_TDEST_TIEOFF. TDEST must be stable when DEST_WIDTH has been set to zero."
  `define ERRM_TUSER_TIEOFF         "AXI4STREAM_ERRM_TUSER_TIEOFF. TUSER must be stable when USER_WIDTH has been set to zero."
  `define AUXM_TID_TDEST_WIDTH      "AXI4STREAM_AUXM_TID_TDEST_WIDTH. The value of ID_WIDTH + DEST_WIDTH must not exceed 24."
  `define XILINX_ARESETN_PULSE_WIDTH  "XILINX_ARESETN_PULSE_WIDTH. ARESETn must be low for atleast 16 ACLKn cycles."
`endif

`define REPORTER_MACRO(ERR_BIT, NET_NAME, MSG_TEXT, SEV_NUM) \
  always@(posedge NET_NAME) begin \
    if ((SEV_NUM != 0) && (NET_NAME === 1'b1)) begin \
      $display("%t : %m : BIT(%d) : %s : %s", $time, ERR_BIT, (SEV_NUM == 0) ? "INFO" : (SEV_NUM == 1) ? "WARNING" : "ERROR" , MSG_TEXT); \
      if (SEV_NUM == 3) $stop;\
      if (SEV_NUM == 4) $finish;\
    end else if ((NET_NAME !== 1'b1) && (NET_NAME !== 1'b0)) begin \
      $display("%t : %m : BIT(%d) :   ERROR : Invalid state %b", $time, ERR_BIT, NET_NAME); \
    end \
  end

`define ASSIGN_MARKED_DEBUG(ERR_BIT, DISPLAY_NETNAME) \
  reg DISPLAY_NETNAME;\
  always@(posedge aclk) DISPLAY_NETNAME <= pc_status[ERR_BIT];

module axis_protocol_checker_v2_0_2_reporter #(
  parameter integer C_PC_MESSAGE_LEVEL             = 2,
  parameter integer C_PC_STATUS_WIDTH              = 32 
) (
  input  wire                             aclk,
  input  wire [C_PC_STATUS_WIDTH-1:0]     pc_status
);

`ASSIGN_MARKED_DEBUG(00, PC_00_AXI4STREAM_ERRM_TVALID_RESET      )
`ASSIGN_MARKED_DEBUG(01, PC_01_AXI4STREAM_ERRM_TID_STABLE        )
`ASSIGN_MARKED_DEBUG(02, PC_02_AXI4STREAM_ERRM_TDEST_STABLE      )
`ASSIGN_MARKED_DEBUG(03, PC_03_AXI4STREAM_ERRM_TKEEP_STABLE      )
`ASSIGN_MARKED_DEBUG(04, PC_04_AXI4STREAM_ERRM_TDATA_STABLE      )
`ASSIGN_MARKED_DEBUG(05, PC_05_AXI4STREAM_ERRM_TLAST_STABLE      )
`ASSIGN_MARKED_DEBUG(06, PC_06_AXI4STREAM_ERRM_TSTRB_STABLE      )
`ASSIGN_MARKED_DEBUG(07, PC_07_AXI4STREAM_ERRM_TVALID_STABLE     )
`ASSIGN_MARKED_DEBUG(08, PC_08_AXI4STREAM_RECS_TREADY_MAX_WAIT   )
`ASSIGN_MARKED_DEBUG(09, PC_09_AXI4STREAM_ERRM_TUSER_STABLE      )
`ASSIGN_MARKED_DEBUG(10, PC_10_AXI4STREAM_ERRM_TKEEP_TSTRB       )
`ASSIGN_MARKED_DEBUG(11, PC_11_XILINX_ARESETN_PULSE_WIDTH      )

// synthesis translate_off
`REPORTER_MACRO(00, PC_00_AXI4STREAM_ERRM_TVALID_RESET   , `ERRM_TVALID_RESET      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(01, PC_01_AXI4STREAM_ERRM_TID_STABLE     , `ERRM_TID_STABLE        , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(02, PC_02_AXI4STREAM_ERRM_TDEST_STABLE   , `ERRM_TDEST_STABLE      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(03, PC_03_AXI4STREAM_ERRM_TKEEP_STABLE   , `ERRM_TKEEP_STABLE      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(04, PC_04_AXI4STREAM_ERRM_TDATA_STABLE   , `ERRM_TDATA_STABLE      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(05, PC_05_AXI4STREAM_ERRM_TLAST_STABLE   , `ERRM_TLAST_STABLE      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(06, PC_06_AXI4STREAM_ERRM_TSTRB_STABLE   , `ERRM_TSTRB_STABLE      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(07, PC_07_AXI4STREAM_ERRM_TVALID_STABLE  , `ERRM_TVALID_STABLE     , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(08, PC_08_AXI4STREAM_RECS_TREADY_MAX_WAIT, `RECS_TREADY_MAX_WAIT   , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(09, PC_09_AXI4STREAM_ERRM_TUSER_STABLE   , `ERRM_TUSER_STABLE      , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(10, PC_10_AXI4STREAM_ERRM_TKEEP_TSTRB    , `ERRM_TKEEP_TSTRB       , C_PC_MESSAGE_LEVEL)
`REPORTER_MACRO(11, PC_11_XILINX_ARESETN_PULSE_WIDTH , `XILINX_ARESETN_PULSE_WIDTH , C_PC_MESSAGE_LEVEL)

// synthesis translate_on

endmodule

`ifdef AXI4STREAMPC_MESSAGES
  `undef AXI4STREAMPC_MESSAGES
  `undef ERRM_TVALID_RESET
  `undef ERRM_TID_STABLE
  `undef ERRM_TDEST_STABLE
  `undef ERRM_TKEEP_STABLE
  `undef ERRM_TDATA_STABLE
  `undef ERRM_TLAST_STABLE
  `undef ERRM_TSTRB_STABLE
  `undef ERRM_TVALID_STABLE
  `undef RECS_TREADY_MAX_WAIT
  `undef ERRM_TID_X
  `undef ERRM_TDEST_X
  `undef ERRM_TKEEP_X
  `undef ERRM_TDATA_X
  `undef ERRM_TLAST_X
  `undef ERRM_TSTRB_X
  `undef ERRM_TVALID_X
  `undef ERRS_TREADY_X
  `undef ERRM_TUSER_X
  `undef ERRM_TUSER_STABLE
  `undef ERRM_TKEEP_TSTRB
  `undef ERRM_STREAM_ALL_DONE_EOS
  `undef ERRM_TDATA_TIEOFF
  `undef ERRM_TKEEP_TIEOFF
  `undef ERRM_TSTRB_TIEOFF
  `undef ERRM_TID_TIEOFF
  `undef ERRM_TDEST_TIEOFF
  `undef ERRM_TUSER_TIEOFF
  `undef XILINX_ARESETN_PULSE_WIDTH
`endif

`default_nettype wire


// (c) Copyright 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//--------------------------------------------------------------------------

`timescale 1ps/1ps
`default_nettype none

module axis_protocol_checker_v2_0_2_top #(
///////////////////////////////////////////////////////////////////////////////
// Parameter Definitions
///////////////////////////////////////////////////////////////////////////////
  parameter integer C_AXIS_TDATA_WIDTH = 32,
  parameter integer C_AXIS_TID_WIDTH   = 1,
  parameter integer C_AXIS_TDEST_WIDTH = 1,
  parameter integer C_AXIS_TUSER_WIDTH = 1,
  parameter [31:0]  C_AXIS_SIGNAL_SET  = 32'hFF,
  // C_AXIS_SIGNAL_SET: each bit if enabled specifies which axis optional signals are present
  //   [0] => TREADY present
  //   [1] => TDATA present
  //   [2] => TSTRB present, TDATA must be present
  //   [3] => TKEEP present, TDATA must be present
  //   [4] => TLAST present
  //   [5] => TID present
  //   [6] => TDEST present
  //   [7] => TUSER present
  parameter integer C_PC_MAXWAITS                  = 0,
  parameter integer C_PC_MESSAGE_LEVEL             = 2,
  parameter integer C_PC_HAS_SYSTEM_RESET          = 0,
  parameter integer C_ENABLE_CONTROL               = 0,
  parameter integer C_PC_STATUS_WIDTH              = 32,
  parameter integer C_ENABLE_MARK_DEBUG            = 1
) 
(
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
   // System Signals
   input wire                             aclk,
   input wire                             aresetn,
   input wire                             system_resetn,
   input wire                             aclken,

   // Slave side
   input  wire                            pc_axis_tvalid,
   input  wire                            pc_axis_tready,
   input  wire [C_AXIS_TDATA_WIDTH-1:0]   pc_axis_tdata,
   input  wire [C_AXIS_TDATA_WIDTH/8-1:0] pc_axis_tstrb,
   input  wire [C_AXIS_TDATA_WIDTH/8-1:0] pc_axis_tkeep,
   input  wire                            pc_axis_tlast,
   input  wire [C_AXIS_TID_WIDTH-1:0]     pc_axis_tid,
   input  wire [C_AXIS_TDEST_WIDTH-1:0]   pc_axis_tdest,
   input  wire [C_AXIS_TUSER_WIDTH-1:0]   pc_axis_tuser,
   output wire                            pc_asserted,
   output wire [C_PC_STATUS_WIDTH-1:0]    pc_status,
   // AXI Status Interface (read-only)
   input  wire [10-1:0]                                s_axi_araddr,
   input  wire                                         s_axi_arvalid,
   output wire                                         s_axi_arready,
   output wire [31:0]                                  s_axi_rdata,
   output wire [1:0]                                   s_axi_rresp,
   output wire                                         s_axi_rvalid,
   input  wire                                         s_axi_rready

);

localparam LP_AXIS_USER_BITS_PER_BYTE  = 0;

wire                                                                      TREADY_internal;
wire [(C_AXIS_TDATA_WIDTH   - 1) : 0]                                     TDATA_internal;
wire [((C_AXIS_TDATA_WIDTH/8)-1) : 0]                                     TSTRB_internal;
wire [((C_AXIS_TDATA_WIDTH/8)-1) : 0]                                     TKEEP_internal;
wire                                                                      TLAST_internal;
wire [((C_AXIS_SIGNAL_SET[5] == 0 ) ? 0 : C_AXIS_TID_WIDTH     - 1) : 0]  TID_internal;
wire [((C_AXIS_SIGNAL_SET[6] == 0 ) ? 0 : C_AXIS_TDEST_WIDTH   - 1) : 0]  TDEST_internal;
wire [((C_AXIS_SIGNAL_SET[7] == 0 ) ? 0 : C_AXIS_TUSER_WIDTH   - 1) : 0]  TUSER_internal;

reg                                                                       ARESETn_q;
reg                                                                       ACLKEN_q;
reg                                                                       TVALID_q;
reg                                                                       TREADY_q;
reg  [(C_AXIS_TDATA_WIDTH   - 1) : 0]                                     TDATA_q;
reg  [((C_AXIS_TDATA_WIDTH/8)-1) : 0]                                     TSTRB_q;
reg  [((C_AXIS_TDATA_WIDTH/8)-1) : 0]                                     TKEEP_q;
reg                                                                       TLAST_q;
reg  [((C_AXIS_SIGNAL_SET[5] == 0 ) ? 0 : C_AXIS_TID_WIDTH     - 1) : 0]  TID_q;
reg  [((C_AXIS_SIGNAL_SET[6] == 0 ) ? 0 : C_AXIS_TDEST_WIDTH   - 1) : 0]  TDEST_q;
reg  [((C_AXIS_SIGNAL_SET[7] == 0 ) ? 0 : C_AXIS_TUSER_WIDTH   - 1) : 0]  TUSER_q;


assign TREADY_internal  = (C_AXIS_SIGNAL_SET[0] == 0) ? 1'b1 : pc_axis_tready;
assign TDATA_internal   = (C_AXIS_SIGNAL_SET[1] == 0) ? {C_AXIS_TDATA_WIDTH{1'b0}} : pc_axis_tdata;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//When there isn't a STRB but there is KEEP then STRB must track KEEP
assign TSTRB_internal   = (C_AXIS_SIGNAL_SET[2] == 0) ? TKEEP_internal : pc_axis_tstrb;
assign TKEEP_internal   = (C_AXIS_SIGNAL_SET[3] == 0) ? {(C_AXIS_TDATA_WIDTH/8){1'b1}} : pc_axis_tkeep;
assign TLAST_internal   = (C_AXIS_SIGNAL_SET[4] == 0) ? 1'b1 : pc_axis_tlast;
assign TDEST_internal   = (C_AXIS_SIGNAL_SET[6] == 0) ? 1'b0 : pc_axis_tdest;
assign TID_internal     = (C_AXIS_SIGNAL_SET[5] == 0) ? 1'b0 : pc_axis_tid;
assign TUSER_internal   = (C_AXIS_SIGNAL_SET[7] == 0) ? 1'b0 : pc_axis_tuser;

always @(posedge aclk) begin
  ARESETn_q <= aresetn;
  ACLKEN_q  <= aclken;
  TVALID_q  <= pc_axis_tvalid;
  TREADY_q  <= TREADY_internal;
  TDATA_q   <= TDATA_internal; 
  TSTRB_q   <= TSTRB_internal; 
  TKEEP_q   <= TKEEP_internal; 
  TLAST_q   <= TLAST_internal; 
  TID_q     <= TID_internal;   
  TDEST_q   <= TDEST_internal; 
  TUSER_q   <= TUSER_internal; 
end

wire  reset_i;
wire  resetn_out;
wire  checker_main_resetn;
(* shreg_extract="no", iob="false", equivalent_register_removal = "no" *) reg [2:0] reset_resync;

assign reset_i = ~system_resetn;
assign resetn_out = (C_PC_HAS_SYSTEM_RESET == 1) ? reset_resync[2] : aresetn;

always @(posedge aclk or posedge reset_i) begin
  if (reset_i) begin
    reset_resync <= 3'b000;
  end else begin
    reset_resync <= {reset_resync[1:0], 1'b1};
  end
end

assign checker_main_resetn = resetn_out & aresetn;

wire [C_PC_STATUS_WIDTH-22:0] Axi4StreamPC_asr_inline_out;

axis_protocol_checker_v2_0_2_asr_inline #(
  .DEST_WIDTH          ((C_AXIS_SIGNAL_SET[6] == 0 ) ? 0 : C_AXIS_TDEST_WIDTH   ),
  .DATA_WIDTH_BYTES    ((C_AXIS_SIGNAL_SET[1] == 0 ) ? 1 : C_AXIS_TDATA_WIDTH/8 ),
  .ID_WIDTH            ((C_AXIS_SIGNAL_SET[5] == 0 ) ? 0 : C_AXIS_TID_WIDTH     ),
  .USER_WIDTH          ((C_AXIS_SIGNAL_SET[7] == 0 ) ? 1 : C_AXIS_TUSER_WIDTH   ),
  .MAXWAITS            (C_PC_MAXWAITS)
) PC (
  .Axi4StreamPC_asr_inline_out  ( Axi4StreamPC_asr_inline_out ),
  .reset                        ( resetn_out  ),
  .ACLK                         ( aclk        ),
  .ACLKEN                       ( ACLKEN_q    ),
  .ARESETn                      ( ARESETn_q   ),
  .TVALID                       ( TVALID_q    ),
  .TREADY                       ( TREADY_q    ),
  .TLAST                        ( TLAST_q     ),
  .TID                          ( TID_q       ),
  .TDEST                        ( TDEST_q     ),
  .TKEEP                        ( TKEEP_q     ),
  .TDATA                        ( TDATA_q     ),
  .TSTRB                        ( TSTRB_q     ),
  .TUSER                        ( TUSER_q     )
);

reg [C_PC_STATUS_WIDTH-1:0] pc_snapshot;
reg  [C_PC_STATUS_WIDTH-1:0] pc_status_i;
reg                          pc_asserted_i;
wire [C_PC_STATUS_WIDTH-1:0] pc_status_masked;

always @(posedge aclk) begin : p_errorSeq
  if (!checker_main_resetn) begin
    pc_asserted_i <= 1'b0;
    pc_status_i <= {C_PC_STATUS_WIDTH-1 {1'b0}};
  end else begin
    pc_asserted_i <= |pc_status_i;
    pc_status_i <= pc_status_masked | pc_status_i;
      if (~pc_asserted_i) begin  // Capture first asserted check(s)
        pc_snapshot <= pc_status_i;
      end
    end 
end 

//// Code for RPW Assertion Check ///
wire  sys_resetn;
assign sys_resetn = (C_PC_HAS_SYSTEM_RESET == 1) ? (system_resetn) : 1'b0;
reg aresetn_i_q;
wire rising_edge_rst;
wire falling_edge_rst;
wire reset_pulse_violation;
reg reset_pulse_violation_i;
reg [4:0] count_clk ;
reg en_chk_r;
reg assert_pc_i;


always @(posedge aclk) begin
  if(sys_resetn == 1'b0) begin
    count_clk <= 'h0;
  end else if (en_chk_r && count_clk < 15) begin
    count_clk <= count_clk + 1'h1;
  end else if (en_chk_r == 0) begin 
    count_clk <= 'h0;
  end
end

always @(posedge aclk) begin
  if(sys_resetn == 1'b0) begin
    aresetn_i_q <= 1'b0; 
  end else begin
    aresetn_i_q <= ARESETn_q;
  end
end

assign falling_edge_rst = ( (~ARESETn_q) & aresetn_i_q );

always @(posedge aclk) begin
  if(ARESETn_q == 1'b1) begin
    en_chk_r <= 1'b0; 
  end else if (falling_edge_rst)begin
    en_chk_r <= 1'b1;
  end
end

assign rising_edge_rst = ( (ARESETn_q) & (~aresetn_i_q) );

always @(posedge aclk)begin
  if(sys_resetn == 1'b0) begin
    reset_pulse_violation_i <= 1'b0;
  end else if(rising_edge_rst && en_chk_r && count_clk < 15)begin
    reset_pulse_violation_i <= 1'b1;
  end
end

assign reset_pulse_violation = reset_pulse_violation_i;
assign pc_status = {reset_pulse_violation, pc_status_i};
assign pc_status_masked = {{C_PC_STATUS_WIDTH-11 {1'b0}}, reset_pulse_violation, Axi4StreamPC_asr_inline_out};
assign pc_asserted = pc_asserted_i | assert_pc_i;

// End of RPW Check  ///

axis_protocol_checker_v2_0_2_reporter #(
  .C_PC_MESSAGE_LEVEL         (C_PC_MESSAGE_LEVEL),
  .C_PC_STATUS_WIDTH          (C_PC_STATUS_WIDTH)
) REP (
  .aclk         (aclk),
  .pc_status    (pc_status)
);

// AXI Status Interface
  
  reg s_axi_arready_i;
  reg s_axi_rvalid_i;
  reg [31:0] s_axi_rdata_i;
  assign s_axi_arready = s_axi_arready_i;
  assign s_axi_rvalid  = s_axi_rvalid_i;
  assign s_axi_rdata   = s_axi_rdata_i;
  assign s_axi_rresp   = 2'b0;
  
  always @(posedge aclk) begin
    if (~aresetn) begin
      s_axi_arready_i <= 1'b0;
      s_axi_rvalid_i <= 1'b0;
    end else if (C_ENABLE_CONTROL!=0) begin
      if (s_axi_rready & s_axi_rvalid_i) begin
        s_axi_rvalid_i <= 1'b0;
      end else if (s_axi_arready_i & s_axi_arvalid) begin
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b1;
      end else if (~s_axi_rvalid_i) begin
        s_axi_arready_i <= 1'b1;
      end
    end
  end

  always @(posedge aclk) begin
    if (C_ENABLE_CONTROL!=0 && ~s_axi_rvalid_i) begin
      casex (s_axi_araddr)
        10'b01_xxxx_00xx: s_axi_rdata_i <= pc_status_i[C_PC_STATUS_WIDTH-1:0];
        10'b10_xxxx_00xx: s_axi_rdata_i <= pc_snapshot[C_PC_STATUS_WIDTH-1:0];
        default:          s_axi_rdata_i <= pc_asserted_i; 
      endcase
    end
  end


// synthesis translate_off

reg xilinx_tkeep_check_enable = 1'b0;
/*
*  Function: set_xilinx_tkeep_check
*  Sets xilinx_tkeep_check_enable to turn on warning message when sparse tkeep is 
*  detected in the transaction.
*/
function set_xilinx_tkeep_check;
  input tkeep_check_enable;
  begin
  xilinx_tkeep_check_enable = 1'b1;
  end
endfunction

/*
* Function: clr_xilinx_tkeep_check
* Sets xilinx_tkeep_check_enable to turn off warning message when sparse tkeep is 
* detected in the transaction.
*/
function clr_xilinx_tkeep_check;
  input tkeep_check_disable;
  begin
  xilinx_tkeep_check_enable = 1'b0;
  end
endfunction

// declarations
reg t_first_bit;
reg [C_AXIS_TDATA_WIDTH/8-1:0] tkeep_carry_r;
integer i;
integer toggle_cnt;
integer toggle_cnt_r1;
reg sparse_tkeep_found_r;
reg tlast_r;

//Sparse Tkeep check 

generate 
  if (C_AXIS_TDATA_WIDTH > 8) begin

     always @(posedge aclk) begin
       if (~aresetn) begin
          toggle_cnt <= 0;
          tkeep_carry_r <= 'b1;
       end else if (pc_axis_tlast && pc_axis_tvalid && pc_axis_tready )begin
          toggle_cnt <= 0;
          tkeep_carry_r <= 'b1;
       end else if (pc_axis_tvalid && pc_axis_tready) begin
          for(i =0; i<(C_AXIS_TDATA_WIDTH/8-1); i = i + 1) begin
            if(pc_axis_tkeep[i+1] == ~pc_axis_tkeep[i]) begin
              toggle_cnt <= toggle_cnt + 1'b1;
            end
          end
          if (tkeep_carry_r[C_AXIS_TDATA_WIDTH/8-1] == ~pc_axis_tkeep[0]) begin
                toggle_cnt <= toggle_cnt + 1'b1;
          end
          tkeep_carry_r <= pc_axis_tkeep;
       end
     end
     
     always @(posedge aclk) begin
       if (~aresetn) begin
         sparse_tkeep_found_r <= 1'b0;
       end else if (tlast_r && toggle_cnt_r1 >= 1 && xilinx_tkeep_check_enable )begin
         sparse_tkeep_found_r <= 1'b1;
         $display("WARNING :: Sparse TKEEP is Received in the packet at Time : " , $time);
         end else begin 
         sparse_tkeep_found_r <= 1'b0;
       end
     end
     
     always @(posedge aclk) begin
       if (~aresetn) begin
         tlast_r <= 1'b0;
       end else if (pc_axis_tlast && pc_axis_tvalid && pc_axis_tready )begin
         tlast_r <= 1'b1;
       end else begin
         tlast_r <= 1'b0;
       end
     end 
     
     always @(posedge aclk) begin
       if (~aresetn) begin
         toggle_cnt_r1 <= 'd0;
       end else begin
         toggle_cnt_r1 <= toggle_cnt;
       end
     end 
   end 
endgenerate 

//End Sparse Tkeep check

// synthesis translate_on

endmodule

`default_nettype wire



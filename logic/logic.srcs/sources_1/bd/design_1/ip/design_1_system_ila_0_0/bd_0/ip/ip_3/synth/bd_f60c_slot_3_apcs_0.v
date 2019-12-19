// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
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
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:axis_protocol_checker:2.0
// IP Revision: 2

(* X_CORE_INFO = "axis_protocol_checker_v2_0_2_top,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "bd_f60c_slot_3_apcs_0,axis_protocol_checker_v2_0_2_top,{}" *)
(* CORE_GENERATION_INFO = "bd_f60c_slot_3_apcs_0,axis_protocol_checker_v2_0_2_top,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=axis_protocol_checker,x_ipVersion=2.0,x_ipCoreRevision=2,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_AXIS_TDATA_WIDTH=8,C_AXIS_TID_WIDTH=1,C_AXIS_TDEST_WIDTH=1,C_AXIS_TUSER_WIDTH=1,C_AXIS_SIGNAL_SET=0b00000000000000000000000000000011,C_PC_MAXWAITS=0,C_PC_MESSAGE_LEVEL=2,C_PC_HAS_SYSTEM_RESET=0,C_ENABLE_CONTROL=0,C_PC_STATUS_WIDTH=32,C_ENABLE_MARK_DEBUG=1}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module bd_f60c_slot_3_apcs_0 (
  aclk,
  aresetn,
  pc_axis_tvalid,
  pc_axis_tready,
  pc_axis_tdata,
  pc_asserted,
  pc_status
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLKIF, ASSOCIATED_BUSIF S_AXI:PC_AXIS, ASSOCIATED_RESET aresetn, FREQ_HZ 5e+07, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0, ASSOCIATED_CLKEN aclken" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLKIF CLK" *)
input wire aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RSTIF, POLARITY ACTIVE_LOW, INSERT_VIP 0, TYPE INTERCONNECT" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RSTIF RST" *)
input wire aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 PC_AXIS TVALID" *)
input wire pc_axis_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 PC_AXIS TREADY" *)
input wire pc_axis_tready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PC_AXIS, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 5e+07, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 PC_AXIS TDATA" *)
input wire [7 : 0] pc_axis_tdata;
output wire pc_asserted;
output wire [31 : 0] pc_status;

  axis_protocol_checker_v2_0_2_top #(
    .C_AXIS_TDATA_WIDTH(8),
    .C_AXIS_TID_WIDTH(1),
    .C_AXIS_TDEST_WIDTH(1),
    .C_AXIS_TUSER_WIDTH(1),
    .C_AXIS_SIGNAL_SET('B00000000000000000000000000000011),
    .C_PC_MAXWAITS(0),
    .C_PC_MESSAGE_LEVEL(2),
    .C_PC_HAS_SYSTEM_RESET(0),
    .C_ENABLE_CONTROL(0),
    .C_PC_STATUS_WIDTH(32),
    .C_ENABLE_MARK_DEBUG(1)
  ) inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .system_resetn(1'D1),
    .aclken(1'D1),
    .pc_axis_tvalid(pc_axis_tvalid),
    .pc_axis_tready(pc_axis_tready),
    .pc_axis_tdata(pc_axis_tdata),
    .pc_axis_tstrb(1'H1),
    .pc_axis_tkeep(1'H1),
    .pc_axis_tlast(1'D1),
    .pc_axis_tid(1'D0),
    .pc_axis_tdest(1'D0),
    .pc_axis_tuser(1'D0),
    .pc_asserted(pc_asserted),
    .pc_status(pc_status),
    .s_axi_araddr(10'D0),
    .s_axi_arvalid(1'D0),
    .s_axi_arready(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rvalid(),
    .s_axi_rready(1'D0)
  );
endmodule

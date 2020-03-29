// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
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


// IP VLNV: xilinx.com:user:adc_receiver_core:1.0
// IP Revision: 10

(* X_CORE_INFO = "adc_receiver_core_v1_0,Vivado 2019.2" *)
(* CHECK_LICENSE_TYPE = "design_1_adc_receiver_core_0_0,adc_receiver_core_v1_0,{}" *)
(* CORE_GENERATION_INFO = "design_1_adc_receiver_core_0_0,adc_receiver_core_v1_0,{x_ipProduct=Vivado 2019.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=adc_receiver_core,x_ipVersion=1.0,x_ipCoreRevision=10,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_adc_receiver_core_0_0 (
  adc_l1a_p,
  adc_l1a_n,
  adc_l1b_p,
  adc_l1b_n,
  adc_l2a_p,
  adc_l2a_n,
  adc_l2b_p,
  adc_l2b_n,
  adc_l3a_p,
  adc_l3a_n,
  adc_l3b_p,
  adc_l3b_n,
  adc_l4a_p,
  adc_l4a_n,
  adc_l4b_p,
  adc_l4b_n,
  adc_lclk_p,
  adc_lclk_n,
  adc_fclk_p,
  adc_fclk_n,
  g_rst,
  adc_bus,
  adc_data_clk,
  clk_master,
  bitslip_locked,
  train_l1a,
  train_l1b,
  train_l2a,
  train_l2b,
  train_l3a,
  train_l3b,
  train_l4a,
  train_l4b,
  delay_load,
  train_done_load,
  clk_idelay_refclk,
  idelay_rdy
);

input wire adc_l1a_p;
input wire adc_l1a_n;
input wire adc_l1b_p;
input wire adc_l1b_n;
input wire adc_l2a_p;
input wire adc_l2a_n;
input wire adc_l2b_p;
input wire adc_l2b_n;
input wire adc_l3a_p;
input wire adc_l3a_n;
input wire adc_l3b_p;
input wire adc_l3b_n;
input wire adc_l4a_p;
input wire adc_l4a_n;
input wire adc_l4b_p;
input wire adc_l4b_n;
input wire adc_lclk_p;
input wire adc_lclk_n;
input wire adc_fclk_p;
input wire adc_fclk_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME g_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 g_rst RST" *)
input wire g_rst;
output wire [63 : 0] adc_bus;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_data_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_adc_receiver_core_0_0_adc_data_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc_data_clk CLK" *)
output wire adc_data_clk;
input wire clk_master;
output wire bitslip_locked;
input wire [5 : 0] train_l1a;
input wire [5 : 0] train_l1b;
input wire [5 : 0] train_l2a;
input wire [5 : 0] train_l2b;
input wire [5 : 0] train_l3a;
input wire [5 : 0] train_l3b;
input wire [5 : 0] train_l4a;
input wire [5 : 0] train_l4b;
input wire delay_load;
output wire train_done_load;
input wire clk_idelay_refclk;
output wire idelay_rdy;

  adc_receiver_core_v1_0 inst (
    .adc_l1a_p(adc_l1a_p),
    .adc_l1a_n(adc_l1a_n),
    .adc_l1b_p(adc_l1b_p),
    .adc_l1b_n(adc_l1b_n),
    .adc_l2a_p(adc_l2a_p),
    .adc_l2a_n(adc_l2a_n),
    .adc_l2b_p(adc_l2b_p),
    .adc_l2b_n(adc_l2b_n),
    .adc_l3a_p(adc_l3a_p),
    .adc_l3a_n(adc_l3a_n),
    .adc_l3b_p(adc_l3b_p),
    .adc_l3b_n(adc_l3b_n),
    .adc_l4a_p(adc_l4a_p),
    .adc_l4a_n(adc_l4a_n),
    .adc_l4b_p(adc_l4b_p),
    .adc_l4b_n(adc_l4b_n),
    .adc_lclk_p(adc_lclk_p),
    .adc_lclk_n(adc_lclk_n),
    .adc_fclk_p(adc_fclk_p),
    .adc_fclk_n(adc_fclk_n),
    .g_rst(g_rst),
    .adc_bus(adc_bus),
    .adc_data_clk(adc_data_clk),
    .clk_master(clk_master),
    .bitslip_locked(bitslip_locked),
    .train_l1a(train_l1a),
    .train_l1b(train_l1b),
    .train_l2a(train_l2a),
    .train_l2b(train_l2b),
    .train_l3a(train_l3a),
    .train_l3b(train_l3b),
    .train_l4a(train_l4a),
    .train_l4b(train_l4b),
    .delay_load(delay_load),
    .train_done_load(train_done_load),
    .clk_idelay_refclk(clk_idelay_refclk),
    .idelay_rdy(idelay_rdy)
  );
endmodule

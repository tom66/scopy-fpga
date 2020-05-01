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


// IP VLNV: xilinx.com:user:PL_debug_LED_controller:1.0
// IP Revision: 3

(* X_CORE_INFO = "PL_debug_LED_controller_v1_0,Vivado 2019.2" *)
(* CHECK_LICENSE_TYPE = "design_1_PL_debug_LED_control_0_1,PL_debug_LED_controller_v1_0,{}" *)
(* CORE_GENERATION_INFO = "design_1_PL_debug_LED_control_0_1,PL_debug_LED_controller_v1_0,{x_ipProduct=Vivado 2019.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=PL_debug_LED_controller,x_ipVersion=1.0,x_ipCoreRevision=3,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,LED_BYTE_CHANNEL=1}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_PL_debug_LED_control_0_1 (
  spi_csn,
  spi_clk,
  acq_done,
  acq_run,
  trig_sig,
  axi_clk,
  axi_resetn,
  R_led_ctrl,
  led_out
);

input wire spi_csn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME spi_clk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 spi_clk CLK" *)
input wire spi_clk;
input wire acq_done;
input wire acq_run;
input wire trig_sig;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_clk, ASSOCIATED_RESET axi_resetn, FREQ_HZ 177777771, PHASE 0.000, CLK_DOMAIN design_1_zynq_ps_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axi_clk CLK" *)
input wire axi_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axi_resetn RST" *)
input wire axi_resetn;
input wire [31 : 0] R_led_ctrl;
output wire led_out;

  PL_debug_LED_controller_v1_0 #(
    .LED_BYTE_CHANNEL(1)
  ) inst (
    .spi_csn(spi_csn),
    .spi_clk(spi_clk),
    .acq_done(acq_done),
    .acq_run(acq_run),
    .trig_sig(trig_sig),
    .axi_clk(axi_clk),
    .axi_resetn(axi_resetn),
    .R_led_ctrl(R_led_ctrl),
    .led_out(led_out)
  );
endmodule

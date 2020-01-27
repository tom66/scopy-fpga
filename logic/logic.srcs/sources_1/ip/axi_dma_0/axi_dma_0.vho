-- (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:axi_dma:7.1
-- IP Revision: 21

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT axi_dma_0
  PORT (
    s_axi_lite_aclk : IN STD_LOGIC;
    m_axi_s2mm_aclk : IN STD_LOGIC;
    axi_resetn : IN STD_LOGIC;
    s_axi_lite_awvalid : IN STD_LOGIC;
    s_axi_lite_awready : OUT STD_LOGIC;
    s_axi_lite_awaddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    s_axi_lite_wvalid : IN STD_LOGIC;
    s_axi_lite_wready : OUT STD_LOGIC;
    s_axi_lite_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_lite_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_lite_bvalid : OUT STD_LOGIC;
    s_axi_lite_bready : IN STD_LOGIC;
    s_axi_lite_arvalid : IN STD_LOGIC;
    s_axi_lite_arready : OUT STD_LOGIC;
    s_axi_lite_araddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    s_axi_lite_rvalid : OUT STD_LOGIC;
    s_axi_lite_rready : IN STD_LOGIC;
    s_axi_lite_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_lite_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_s2mm_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_s2mm_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_s2mm_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_s2mm_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_s2mm_awvalid : OUT STD_LOGIC;
    m_axi_s2mm_awready : IN STD_LOGIC;
    m_axi_s2mm_wdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axi_s2mm_wstrb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_s2mm_wlast : OUT STD_LOGIC;
    m_axi_s2mm_wvalid : OUT STD_LOGIC;
    m_axi_s2mm_wready : IN STD_LOGIC;
    m_axi_s2mm_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_s2mm_bvalid : IN STD_LOGIC;
    m_axi_s2mm_bready : OUT STD_LOGIC;
    s2mm_prmry_reset_out_n : OUT STD_LOGIC;
    s_axis_s2mm_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_s2mm_tkeep : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axis_s2mm_tvalid : IN STD_LOGIC;
    s_axis_s2mm_tready : OUT STD_LOGIC;
    s_axis_s2mm_tlast : IN STD_LOGIC;
    s2mm_introut : OUT STD_LOGIC;
    axi_dma_tstvec : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : axi_dma_0
  PORT MAP (
    s_axi_lite_aclk => s_axi_lite_aclk,
    m_axi_s2mm_aclk => m_axi_s2mm_aclk,
    axi_resetn => axi_resetn,
    s_axi_lite_awvalid => s_axi_lite_awvalid,
    s_axi_lite_awready => s_axi_lite_awready,
    s_axi_lite_awaddr => s_axi_lite_awaddr,
    s_axi_lite_wvalid => s_axi_lite_wvalid,
    s_axi_lite_wready => s_axi_lite_wready,
    s_axi_lite_wdata => s_axi_lite_wdata,
    s_axi_lite_bresp => s_axi_lite_bresp,
    s_axi_lite_bvalid => s_axi_lite_bvalid,
    s_axi_lite_bready => s_axi_lite_bready,
    s_axi_lite_arvalid => s_axi_lite_arvalid,
    s_axi_lite_arready => s_axi_lite_arready,
    s_axi_lite_araddr => s_axi_lite_araddr,
    s_axi_lite_rvalid => s_axi_lite_rvalid,
    s_axi_lite_rready => s_axi_lite_rready,
    s_axi_lite_rdata => s_axi_lite_rdata,
    s_axi_lite_rresp => s_axi_lite_rresp,
    m_axi_s2mm_awaddr => m_axi_s2mm_awaddr,
    m_axi_s2mm_awlen => m_axi_s2mm_awlen,
    m_axi_s2mm_awsize => m_axi_s2mm_awsize,
    m_axi_s2mm_awburst => m_axi_s2mm_awburst,
    m_axi_s2mm_awprot => m_axi_s2mm_awprot,
    m_axi_s2mm_awcache => m_axi_s2mm_awcache,
    m_axi_s2mm_awvalid => m_axi_s2mm_awvalid,
    m_axi_s2mm_awready => m_axi_s2mm_awready,
    m_axi_s2mm_wdata => m_axi_s2mm_wdata,
    m_axi_s2mm_wstrb => m_axi_s2mm_wstrb,
    m_axi_s2mm_wlast => m_axi_s2mm_wlast,
    m_axi_s2mm_wvalid => m_axi_s2mm_wvalid,
    m_axi_s2mm_wready => m_axi_s2mm_wready,
    m_axi_s2mm_bresp => m_axi_s2mm_bresp,
    m_axi_s2mm_bvalid => m_axi_s2mm_bvalid,
    m_axi_s2mm_bready => m_axi_s2mm_bready,
    s2mm_prmry_reset_out_n => s2mm_prmry_reset_out_n,
    s_axis_s2mm_tdata => s_axis_s2mm_tdata,
    s_axis_s2mm_tkeep => s_axis_s2mm_tkeep,
    s_axis_s2mm_tvalid => s_axis_s2mm_tvalid,
    s_axis_s2mm_tready => s_axis_s2mm_tready,
    s_axis_s2mm_tlast => s_axis_s2mm_tlast,
    s2mm_introut => s2mm_introut,
    axi_dma_tstvec => axi_dma_tstvec
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file axi_dma_0.vhd when simulating
-- the core, axi_dma_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.


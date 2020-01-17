-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Sun Jan 12 18:07:37 2020
-- Host        : TomsDesktop running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/logic/logic.srcs/sources_1/bd/design_1/ip/design_1_adc_test_streamer_0_0/design_1_adc_test_streamer_0_0_stub.vhdl
-- Design      : design_1_adc_test_streamer_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z014sclg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_adc_test_streamer_0_0 is
  Port ( 
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m00_axis_tstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m00_axis_tlast : out STD_LOGIC;
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    adc_bus : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m00_axis_aclk : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC
  );

end design_1_adc_test_streamer_0_0;

architecture stub of design_1_adc_test_streamer_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "m00_axis_tdata[63:0],m00_axis_tstrb[7:0],m00_axis_tlast,m00_axis_tvalid,m00_axis_tready,adc_bus[63:0],m00_axis_aclk,m00_axis_aresetn";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "adc_test_streamer_v2_0,Vivado 2018.3";
begin
end;

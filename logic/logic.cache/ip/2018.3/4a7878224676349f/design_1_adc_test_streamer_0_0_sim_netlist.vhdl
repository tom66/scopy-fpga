-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Dec 20 00:42:15 2019
-- Host        : TomsDesktop running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_adc_test_streamer_0_0_sim_netlist.vhdl
-- Design      : design_1_adc_test_streamer_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z014sclg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0_M00_AXIS is
  port (
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axis_tlast : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0_M00_AXIS;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0_M00_AXIS is
  signal \FSM_sequential_mst_exec_state[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_mst_exec_state[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_mst_exec_state[1]_i_2_n_0\ : STD_LOGIC;
  signal axis_tlast : STD_LOGIC;
  signal axis_tlast_delay_i_2_n_0 : STD_LOGIC;
  signal axis_tlast_delay_i_3_n_0 : STD_LOGIC;
  signal axis_tvalid : STD_LOGIC;
  signal count : STD_LOGIC;
  signal \count[2]_i_1_n_0\ : STD_LOGIC;
  signal \count_reg__0\ : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal endless : STD_LOGIC;
  signal \endless[0]_i_3_n_0\ : STD_LOGIC;
  signal endless_reg : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \endless_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_1\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_2\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_3\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_4\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_5\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_6\ : STD_LOGIC;
  signal \endless_reg[0]_i_2_n_7\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_0\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[16]_i_1_n_7\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_0\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[20]_i_1_n_7\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_0\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[24]_i_1_n_7\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[28]_i_1_n_7\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \endless_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal mst_exec_state : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal p_0_in : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal \read_pointer[0]_i_1_n_0\ : STD_LOGIC;
  signal \read_pointer[0]_i_3_n_0\ : STD_LOGIC;
  signal read_pointer_reg : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal \read_pointer_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_1\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_2\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_3\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_4\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_5\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_6\ : STD_LOGIC;
  signal \read_pointer_reg[0]_i_2_n_7\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \read_pointer_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \read_pointer_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal \stream_data_out[31]_i_1_n_0\ : STD_LOGIC;
  signal tx_done_i_1_n_0 : STD_LOGIC;
  signal tx_done_i_2_n_0 : STD_LOGIC;
  signal tx_done_i_3_n_0 : STD_LOGIC;
  signal tx_done_i_4_n_0 : STD_LOGIC;
  signal tx_done_i_5_n_0 : STD_LOGIC;
  signal tx_done_reg_n_0 : STD_LOGIC;
  signal tx_en : STD_LOGIC;
  signal \NLW_endless_reg[28]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_read_pointer_reg[8]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_sequential_mst_exec_state[0]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \FSM_sequential_mst_exec_state[1]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \FSM_sequential_mst_exec_state[1]_i_2\ : label is "soft_lutpair1";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_sequential_mst_exec_state_reg[0]\ : label is "INIT_COUNTER:01,SEND_STREAM:10,IDLE:00";
  attribute FSM_ENCODED_STATES of \FSM_sequential_mst_exec_state_reg[1]\ : label is "INIT_COUNTER:01,SEND_STREAM:10,IDLE:00";
  attribute SOFT_HLUTNM of axis_tvalid_delay_i_1 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \count[0]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \count[1]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \count[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \count[3]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \count[4]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of tx_done_i_5 : label is "soft_lutpair0";
begin
\FSM_sequential_mst_exec_state[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"C7"
    )
        port map (
      I0 => \FSM_sequential_mst_exec_state[1]_i_2_n_0\,
      I1 => mst_exec_state(0),
      I2 => mst_exec_state(1),
      O => \FSM_sequential_mst_exec_state[0]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F3A0"
    )
        port map (
      I0 => \FSM_sequential_mst_exec_state[1]_i_2_n_0\,
      I1 => tx_done_reg_n_0,
      I2 => mst_exec_state(0),
      I3 => mst_exec_state(1),
      O => \FSM_sequential_mst_exec_state[1]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state[1]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => \count_reg__0\(3),
      I1 => \count_reg__0\(1),
      I2 => \count_reg__0\(0),
      I3 => \count_reg__0\(4),
      I4 => \count_reg__0\(2),
      O => \FSM_sequential_mst_exec_state[1]_i_2_n_0\
    );
\FSM_sequential_mst_exec_state_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => '1',
      D => \FSM_sequential_mst_exec_state[0]_i_1_n_0\,
      Q => mst_exec_state(0),
      R => \stream_data_out[31]_i_1_n_0\
    );
\FSM_sequential_mst_exec_state_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => '1',
      D => \FSM_sequential_mst_exec_state[1]_i_1_n_0\,
      Q => mst_exec_state(1),
      R => \stream_data_out[31]_i_1_n_0\
    );
axis_tlast_delay_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => axis_tlast_delay_i_2_n_0,
      I1 => axis_tlast_delay_i_3_n_0,
      O => axis_tlast
    );
axis_tlast_delay_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4000000000000000"
    )
        port map (
      I0 => read_pointer_reg(11),
      I1 => read_pointer_reg(9),
      I2 => read_pointer_reg(10),
      I3 => read_pointer_reg(8),
      I4 => read_pointer_reg(6),
      I5 => read_pointer_reg(7),
      O => axis_tlast_delay_i_2_n_0
    );
axis_tlast_delay_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => read_pointer_reg(0),
      I1 => read_pointer_reg(1),
      I2 => read_pointer_reg(2),
      I3 => read_pointer_reg(3),
      I4 => read_pointer_reg(4),
      I5 => read_pointer_reg(5),
      O => axis_tlast_delay_i_3_n_0
    );
axis_tlast_delay_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => '1',
      D => axis_tlast,
      Q => m00_axis_tlast,
      R => \stream_data_out[31]_i_1_n_0\
    );
axis_tvalid_delay_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => mst_exec_state(0),
      I1 => mst_exec_state(1),
      I2 => read_pointer_reg(11),
      O => axis_tvalid
    );
axis_tvalid_delay_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => '1',
      D => axis_tvalid,
      Q => m00_axis_tvalid,
      R => \stream_data_out[31]_i_1_n_0\
    );
\count[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \count_reg__0\(0),
      O => p_0_in(0)
    );
\count[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \count_reg__0\(0),
      I1 => \count_reg__0\(1),
      O => p_0_in(1)
    );
\count[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \count_reg__0\(0),
      I1 => \count_reg__0\(1),
      I2 => \count_reg__0\(2),
      O => \count[2]_i_1_n_0\
    );
\count[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => \count_reg__0\(1),
      I1 => \count_reg__0\(0),
      I2 => \count_reg__0\(2),
      I3 => \count_reg__0\(3),
      O => p_0_in(3)
    );
\count[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => mst_exec_state(1),
      I1 => mst_exec_state(0),
      I2 => \FSM_sequential_mst_exec_state[1]_i_2_n_0\,
      O => count
    );
\count[4]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => \count_reg__0\(2),
      I1 => \count_reg__0\(0),
      I2 => \count_reg__0\(1),
      I3 => \count_reg__0\(3),
      I4 => \count_reg__0\(4),
      O => p_0_in(4)
    );
\count_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => count,
      D => p_0_in(0),
      Q => \count_reg__0\(0),
      R => \stream_data_out[31]_i_1_n_0\
    );
\count_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => count,
      D => p_0_in(1),
      Q => \count_reg__0\(1),
      R => \stream_data_out[31]_i_1_n_0\
    );
\count_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => count,
      D => \count[2]_i_1_n_0\,
      Q => \count_reg__0\(2),
      R => \stream_data_out[31]_i_1_n_0\
    );
\count_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => count,
      D => p_0_in(3),
      Q => \count_reg__0\(3),
      R => \stream_data_out[31]_i_1_n_0\
    );
\count_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => count,
      D => p_0_in(4),
      Q => \count_reg__0\(4),
      R => \stream_data_out[31]_i_1_n_0\
    );
\endless[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00200000"
    )
        port map (
      I0 => m00_axis_aresetn,
      I1 => mst_exec_state(0),
      I2 => mst_exec_state(1),
      I3 => read_pointer_reg(11),
      I4 => m00_axis_tready,
      O => endless
    );
\endless[0]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => endless_reg(0),
      O => \endless[0]_i_3_n_0\
    );
\endless_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[0]_i_2_n_7\,
      Q => endless_reg(0),
      R => '0'
    );
\endless_reg[0]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \endless_reg[0]_i_2_n_0\,
      CO(2) => \endless_reg[0]_i_2_n_1\,
      CO(1) => \endless_reg[0]_i_2_n_2\,
      CO(0) => \endless_reg[0]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \endless_reg[0]_i_2_n_4\,
      O(2) => \endless_reg[0]_i_2_n_5\,
      O(1) => \endless_reg[0]_i_2_n_6\,
      O(0) => \endless_reg[0]_i_2_n_7\,
      S(3 downto 1) => endless_reg(3 downto 1),
      S(0) => \endless[0]_i_3_n_0\
    );
\endless_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[8]_i_1_n_5\,
      Q => endless_reg(10),
      R => '0'
    );
\endless_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[8]_i_1_n_4\,
      Q => endless_reg(11),
      R => '0'
    );
\endless_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[12]_i_1_n_7\,
      Q => endless_reg(12),
      R => '0'
    );
\endless_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[8]_i_1_n_0\,
      CO(3) => \endless_reg[12]_i_1_n_0\,
      CO(2) => \endless_reg[12]_i_1_n_1\,
      CO(1) => \endless_reg[12]_i_1_n_2\,
      CO(0) => \endless_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[12]_i_1_n_4\,
      O(2) => \endless_reg[12]_i_1_n_5\,
      O(1) => \endless_reg[12]_i_1_n_6\,
      O(0) => \endless_reg[12]_i_1_n_7\,
      S(3 downto 0) => endless_reg(15 downto 12)
    );
\endless_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[12]_i_1_n_6\,
      Q => endless_reg(13),
      R => '0'
    );
\endless_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[12]_i_1_n_5\,
      Q => endless_reg(14),
      R => '0'
    );
\endless_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[12]_i_1_n_4\,
      Q => endless_reg(15),
      R => '0'
    );
\endless_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[16]_i_1_n_7\,
      Q => endless_reg(16),
      R => '0'
    );
\endless_reg[16]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[12]_i_1_n_0\,
      CO(3) => \endless_reg[16]_i_1_n_0\,
      CO(2) => \endless_reg[16]_i_1_n_1\,
      CO(1) => \endless_reg[16]_i_1_n_2\,
      CO(0) => \endless_reg[16]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[16]_i_1_n_4\,
      O(2) => \endless_reg[16]_i_1_n_5\,
      O(1) => \endless_reg[16]_i_1_n_6\,
      O(0) => \endless_reg[16]_i_1_n_7\,
      S(3 downto 0) => endless_reg(19 downto 16)
    );
\endless_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[16]_i_1_n_6\,
      Q => endless_reg(17),
      R => '0'
    );
\endless_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[16]_i_1_n_5\,
      Q => endless_reg(18),
      R => '0'
    );
\endless_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[16]_i_1_n_4\,
      Q => endless_reg(19),
      R => '0'
    );
\endless_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[0]_i_2_n_6\,
      Q => endless_reg(1),
      R => '0'
    );
\endless_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[20]_i_1_n_7\,
      Q => endless_reg(20),
      R => '0'
    );
\endless_reg[20]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[16]_i_1_n_0\,
      CO(3) => \endless_reg[20]_i_1_n_0\,
      CO(2) => \endless_reg[20]_i_1_n_1\,
      CO(1) => \endless_reg[20]_i_1_n_2\,
      CO(0) => \endless_reg[20]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[20]_i_1_n_4\,
      O(2) => \endless_reg[20]_i_1_n_5\,
      O(1) => \endless_reg[20]_i_1_n_6\,
      O(0) => \endless_reg[20]_i_1_n_7\,
      S(3 downto 0) => endless_reg(23 downto 20)
    );
\endless_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[20]_i_1_n_6\,
      Q => endless_reg(21),
      R => '0'
    );
\endless_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[20]_i_1_n_5\,
      Q => endless_reg(22),
      R => '0'
    );
\endless_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[20]_i_1_n_4\,
      Q => endless_reg(23),
      R => '0'
    );
\endless_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[24]_i_1_n_7\,
      Q => endless_reg(24),
      R => '0'
    );
\endless_reg[24]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[20]_i_1_n_0\,
      CO(3) => \endless_reg[24]_i_1_n_0\,
      CO(2) => \endless_reg[24]_i_1_n_1\,
      CO(1) => \endless_reg[24]_i_1_n_2\,
      CO(0) => \endless_reg[24]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[24]_i_1_n_4\,
      O(2) => \endless_reg[24]_i_1_n_5\,
      O(1) => \endless_reg[24]_i_1_n_6\,
      O(0) => \endless_reg[24]_i_1_n_7\,
      S(3 downto 0) => endless_reg(27 downto 24)
    );
\endless_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[24]_i_1_n_6\,
      Q => endless_reg(25),
      R => '0'
    );
\endless_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[24]_i_1_n_5\,
      Q => endless_reg(26),
      R => '0'
    );
\endless_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[24]_i_1_n_4\,
      Q => endless_reg(27),
      R => '0'
    );
\endless_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[28]_i_1_n_7\,
      Q => endless_reg(28),
      R => '0'
    );
\endless_reg[28]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[24]_i_1_n_0\,
      CO(3) => \NLW_endless_reg[28]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \endless_reg[28]_i_1_n_1\,
      CO(1) => \endless_reg[28]_i_1_n_2\,
      CO(0) => \endless_reg[28]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[28]_i_1_n_4\,
      O(2) => \endless_reg[28]_i_1_n_5\,
      O(1) => \endless_reg[28]_i_1_n_6\,
      O(0) => \endless_reg[28]_i_1_n_7\,
      S(3 downto 0) => endless_reg(31 downto 28)
    );
\endless_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[28]_i_1_n_6\,
      Q => endless_reg(29),
      R => '0'
    );
\endless_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[0]_i_2_n_5\,
      Q => endless_reg(2),
      R => '0'
    );
\endless_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[28]_i_1_n_5\,
      Q => endless_reg(30),
      R => '0'
    );
\endless_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[28]_i_1_n_4\,
      Q => endless_reg(31),
      R => '0'
    );
\endless_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[0]_i_2_n_4\,
      Q => endless_reg(3),
      R => '0'
    );
\endless_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[4]_i_1_n_7\,
      Q => endless_reg(4),
      R => '0'
    );
\endless_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[0]_i_2_n_0\,
      CO(3) => \endless_reg[4]_i_1_n_0\,
      CO(2) => \endless_reg[4]_i_1_n_1\,
      CO(1) => \endless_reg[4]_i_1_n_2\,
      CO(0) => \endless_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[4]_i_1_n_4\,
      O(2) => \endless_reg[4]_i_1_n_5\,
      O(1) => \endless_reg[4]_i_1_n_6\,
      O(0) => \endless_reg[4]_i_1_n_7\,
      S(3 downto 0) => endless_reg(7 downto 4)
    );
\endless_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[4]_i_1_n_6\,
      Q => endless_reg(5),
      R => '0'
    );
\endless_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[4]_i_1_n_5\,
      Q => endless_reg(6),
      R => '0'
    );
\endless_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[4]_i_1_n_4\,
      Q => endless_reg(7),
      R => '0'
    );
\endless_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[8]_i_1_n_7\,
      Q => endless_reg(8),
      R => '0'
    );
\endless_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \endless_reg[4]_i_1_n_0\,
      CO(3) => \endless_reg[8]_i_1_n_0\,
      CO(2) => \endless_reg[8]_i_1_n_1\,
      CO(1) => \endless_reg[8]_i_1_n_2\,
      CO(0) => \endless_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \endless_reg[8]_i_1_n_4\,
      O(2) => \endless_reg[8]_i_1_n_5\,
      O(1) => \endless_reg[8]_i_1_n_6\,
      O(0) => \endless_reg[8]_i_1_n_7\,
      S(3 downto 0) => endless_reg(11 downto 8)
    );
\endless_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '1'
    )
        port map (
      C => m00_axis_aclk,
      CE => endless,
      D => \endless_reg[8]_i_1_n_6\,
      Q => endless_reg(9),
      R => '0'
    );
\read_pointer[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0040"
    )
        port map (
      I0 => mst_exec_state(0),
      I1 => mst_exec_state(1),
      I2 => m00_axis_tready,
      I3 => read_pointer_reg(11),
      O => \read_pointer[0]_i_1_n_0\
    );
\read_pointer[0]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => read_pointer_reg(0),
      O => \read_pointer[0]_i_3_n_0\
    );
\read_pointer_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[0]_i_2_n_7\,
      Q => read_pointer_reg(0),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[0]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \read_pointer_reg[0]_i_2_n_0\,
      CO(2) => \read_pointer_reg[0]_i_2_n_1\,
      CO(1) => \read_pointer_reg[0]_i_2_n_2\,
      CO(0) => \read_pointer_reg[0]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \read_pointer_reg[0]_i_2_n_4\,
      O(2) => \read_pointer_reg[0]_i_2_n_5\,
      O(1) => \read_pointer_reg[0]_i_2_n_6\,
      O(0) => \read_pointer_reg[0]_i_2_n_7\,
      S(3 downto 1) => read_pointer_reg(3 downto 1),
      S(0) => \read_pointer[0]_i_3_n_0\
    );
\read_pointer_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[8]_i_1_n_5\,
      Q => read_pointer_reg(10),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[8]_i_1_n_4\,
      Q => read_pointer_reg(11),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[0]_i_2_n_6\,
      Q => read_pointer_reg(1),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[0]_i_2_n_5\,
      Q => read_pointer_reg(2),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[0]_i_2_n_4\,
      Q => read_pointer_reg(3),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[4]_i_1_n_7\,
      Q => read_pointer_reg(4),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \read_pointer_reg[0]_i_2_n_0\,
      CO(3) => \read_pointer_reg[4]_i_1_n_0\,
      CO(2) => \read_pointer_reg[4]_i_1_n_1\,
      CO(1) => \read_pointer_reg[4]_i_1_n_2\,
      CO(0) => \read_pointer_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \read_pointer_reg[4]_i_1_n_4\,
      O(2) => \read_pointer_reg[4]_i_1_n_5\,
      O(1) => \read_pointer_reg[4]_i_1_n_6\,
      O(0) => \read_pointer_reg[4]_i_1_n_7\,
      S(3 downto 0) => read_pointer_reg(7 downto 4)
    );
\read_pointer_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[4]_i_1_n_6\,
      Q => read_pointer_reg(5),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[4]_i_1_n_5\,
      Q => read_pointer_reg(6),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[4]_i_1_n_4\,
      Q => read_pointer_reg(7),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[8]_i_1_n_7\,
      Q => read_pointer_reg(8),
      R => \stream_data_out[31]_i_1_n_0\
    );
\read_pointer_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \read_pointer_reg[4]_i_1_n_0\,
      CO(3) => \NLW_read_pointer_reg[8]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \read_pointer_reg[8]_i_1_n_1\,
      CO(1) => \read_pointer_reg[8]_i_1_n_2\,
      CO(0) => \read_pointer_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \read_pointer_reg[8]_i_1_n_4\,
      O(2) => \read_pointer_reg[8]_i_1_n_5\,
      O(1) => \read_pointer_reg[8]_i_1_n_6\,
      O(0) => \read_pointer_reg[8]_i_1_n_7\,
      S(3 downto 0) => read_pointer_reg(11 downto 8)
    );
\read_pointer_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => \read_pointer[0]_i_1_n_0\,
      D => \read_pointer_reg[8]_i_1_n_6\,
      Q => read_pointer_reg(9),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out[31]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => m00_axis_aresetn,
      O => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out[31]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0020"
    )
        port map (
      I0 => m00_axis_tready,
      I1 => read_pointer_reg(11),
      I2 => mst_exec_state(1),
      I3 => mst_exec_state(0),
      O => tx_en
    );
\stream_data_out_reg[0]\: unisim.vcomponents.FDSE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(0),
      Q => m00_axis_tdata(0),
      S => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(10),
      Q => m00_axis_tdata(10),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(11),
      Q => m00_axis_tdata(11),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(12),
      Q => m00_axis_tdata(12),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(13),
      Q => m00_axis_tdata(13),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(14),
      Q => m00_axis_tdata(14),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(15),
      Q => m00_axis_tdata(15),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(16),
      Q => m00_axis_tdata(16),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(17),
      Q => m00_axis_tdata(17),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(18),
      Q => m00_axis_tdata(18),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(19),
      Q => m00_axis_tdata(19),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(1),
      Q => m00_axis_tdata(1),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(20),
      Q => m00_axis_tdata(20),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(21),
      Q => m00_axis_tdata(21),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(22),
      Q => m00_axis_tdata(22),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(23),
      Q => m00_axis_tdata(23),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(24),
      Q => m00_axis_tdata(24),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(25),
      Q => m00_axis_tdata(25),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(26),
      Q => m00_axis_tdata(26),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(27),
      Q => m00_axis_tdata(27),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(28),
      Q => m00_axis_tdata(28),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(29),
      Q => m00_axis_tdata(29),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(2),
      Q => m00_axis_tdata(2),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(30),
      Q => m00_axis_tdata(30),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(31),
      Q => m00_axis_tdata(31),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(3),
      Q => m00_axis_tdata(3),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(4),
      Q => m00_axis_tdata(4),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(5),
      Q => m00_axis_tdata(5),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(6),
      Q => m00_axis_tdata(6),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(7),
      Q => m00_axis_tdata(7),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(8),
      Q => m00_axis_tdata(8),
      R => \stream_data_out[31]_i_1_n_0\
    );
\stream_data_out_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => tx_en,
      D => endless_reg(9),
      Q => m00_axis_tdata(9),
      R => \stream_data_out[31]_i_1_n_0\
    );
tx_done_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000AAAAAAAE"
    )
        port map (
      I0 => tx_done_reg_n_0,
      I1 => read_pointer_reg(11),
      I2 => tx_done_i_2_n_0,
      I3 => tx_done_i_3_n_0,
      I4 => tx_done_i_4_n_0,
      I5 => tx_done_i_5_n_0,
      O => tx_done_i_1_n_0
    );
tx_done_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => read_pointer_reg(6),
      I1 => read_pointer_reg(7),
      I2 => read_pointer_reg(4),
      I3 => read_pointer_reg(5),
      O => tx_done_i_2_n_0
    );
tx_done_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFEF"
    )
        port map (
      I0 => read_pointer_reg(2),
      I1 => read_pointer_reg(3),
      I2 => read_pointer_reg(11),
      I3 => read_pointer_reg(1),
      O => tx_done_i_3_n_0
    );
tx_done_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => read_pointer_reg(0),
      I1 => read_pointer_reg(10),
      I2 => read_pointer_reg(8),
      I3 => read_pointer_reg(9),
      O => tx_done_i_4_n_0
    );
tx_done_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0040FFFF"
    )
        port map (
      I0 => read_pointer_reg(11),
      I1 => m00_axis_tready,
      I2 => mst_exec_state(1),
      I3 => mst_exec_state(0),
      I4 => m00_axis_aresetn,
      O => tx_done_i_5_n_0
    );
tx_done_reg: unisim.vcomponents.FDRE
     port map (
      C => m00_axis_aclk,
      CE => '1',
      D => tx_done_i_1_n_0,
      Q => tx_done_reg_n_0,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0 is
  port (
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axis_tlast : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0 is
begin
adc_test_streamer_v2_0_M00_AXIS_inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0_M00_AXIS
     port map (
      m00_axis_aclk => m00_axis_aclk,
      m00_axis_aresetn => m00_axis_aresetn,
      m00_axis_tdata(31 downto 0) => m00_axis_tdata(31 downto 0),
      m00_axis_tlast => m00_axis_tlast,
      m00_axis_tready => m00_axis_tready,
      m00_axis_tvalid => m00_axis_tvalid
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axis_tstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axis_tlast : out STD_LOGIC;
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_adc_test_streamer_0_0,adc_test_streamer_v2_0,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "adc_test_streamer_v2_0,Vivado 2018.3";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  signal \<const1>\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of m00_axis_aclk : signal is "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of m00_axis_aclk : signal is "XIL_INTERFACENAME M00_AXIS_CLK, ASSOCIATED_BUSIF M00_AXIS, ASSOCIATED_RESET m00_axis_aresetn, FREQ_HZ 5e+07, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m00_axis_aresetn : signal is "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST";
  attribute X_INTERFACE_PARAMETER of m00_axis_aresetn : signal is "XIL_INTERFACENAME M00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m00_axis_tlast : signal is "xilinx.com:interface:axis:1.0 M00_AXIS TLAST";
  attribute X_INTERFACE_INFO of m00_axis_tready : signal is "xilinx.com:interface:axis:1.0 M00_AXIS TREADY";
  attribute X_INTERFACE_PARAMETER of m00_axis_tready : signal is "XIL_INTERFACENAME M00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 5e+07, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m00_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 M00_AXIS TVALID";
  attribute X_INTERFACE_INFO of m00_axis_tdata : signal is "xilinx.com:interface:axis:1.0 M00_AXIS TDATA";
  attribute X_INTERFACE_INFO of m00_axis_tstrb : signal is "xilinx.com:interface:axis:1.0 M00_AXIS TSTRB";
begin
  m00_axis_tstrb(3) <= \<const1>\;
  m00_axis_tstrb(2) <= \<const1>\;
  m00_axis_tstrb(1) <= \<const1>\;
  m00_axis_tstrb(0) <= \<const1>\;
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_adc_test_streamer_v2_0
     port map (
      m00_axis_aclk => m00_axis_aclk,
      m00_axis_aresetn => m00_axis_aresetn,
      m00_axis_tdata(31 downto 0) => m00_axis_tdata(31 downto 0),
      m00_axis_tlast => m00_axis_tlast,
      m00_axis_tready => m00_axis_tready,
      m00_axis_tvalid => m00_axis_tvalid
    );
end STRUCTURE;

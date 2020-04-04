/*
 * trigger.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 25 Mar 2020
 *      Author: Tom
 */

#ifndef SRC_TRIGGER_H_
#define SRC_TRIGGER_H_

#include <stdint.h>

#define TRIG_ADCSRC1						0
#define TRIG_ADCSRC2						1
#define TRIG_ADCSRC3						2
#define TRIG_ADCSRC4						3

#define TRIG_COMP_A							0
#define TRIG_COMP_B							1

#define TRIG_COMP_POL_NORMAL				0
#define TRIG_COMP_POL_INVERT				1

#define TRIGRES_OK							0
#define TRIGRES_PARAM_FAIL					-3
#define TRIGRES_NOT_IMPLEMENTED				-7

#define TRIG_EDGE_NEVER						0
#define TRIG_EDGE_FALLING					1
#define TRIG_EDGE_RISING					2
#define TRIG_EDGE_BOTH						3
#define TRIG_EDGE_NONE						4

#define TRIG_LVL_REG_LO_SHIFT				4
#define TRIG_LVL_REG_HI_SHIFT				20

#define TRIG_LVL_CH_ENABLE					0x00000001
#define TRIG_LVL_CH_POLARITY				0x00000002

// TODO: Register renamed from TRIG_CTRL to TRIG_CTRL_A ??
#define TRIG_CTRL_GLOBAL_ENABLE				0x00000001
#define TRIG_CTRL_LOAD						0x00000002
#define TRIG_CTRL_COMPARATOR_RESET			0x00000004
#define TRIG_CTRL_TRIGGER_RESET				0x00000008
#define TRIG_CTRL_FORCE_TRIGGER				0x00000010
#define TRIG_CTRL_CLEAR_TRIGD				0x00000020
#define TRIG_CTRL_GENERAL_MASK				0x00000040
#define TRIG_CTRL_TRIGGER_ARM				0x00000080
#define TRIG_CTRL_FILTSUM_A					0x00000100
#define TRIG_CTRL_FILTSUM_B					0x00000200
#define TRIG_CTRL_FILTSUM_C					0x00000400
#define TRIG_CTRL_FILTSUM_D					0x00000800
#define TRIG_CTRL_FILTMUX_MASK				0x0000f000
#define TRIG_CTRL_FILTMUX_FILTSUM_MASK		0x0000ff00
#define TRIG_CTRL_HOLDOFF_ENABLE			0x00010000
#define TRIG_CTRL_EXT_SEL_NORMAL			0x00000000
#define TRIG_CTRL_EXT_SEL_AC				0x00100000
#define TRIG_CTRL_EXT_SEL_EXT				0x00200000
#define TRIG_CTRL_EXT_SEL_BITFIELD			0x00300000
#define TRIG_CTRL_NA_NORMAL_MODE			0x00400000
#define TRIG_CTRL_NA_AUTO_MODE				0x00800000
#define TRIG_CTRL_EDGEA_NONE				0x00000000
#define TRIG_CTRL_EDGEA_RISING				0x01000000
#define TRIG_CTRL_EDGEA_FALLING				0x02000000
#define TRIG_CTRL_EDGEA_BOTH				0x03000000
#define TRIG_CTRL_EDGEA_BITFIELD			0x03000000
#define TRIG_CTRL_EDGEB_NONE				0x00000000
#define TRIG_CTRL_EDGEB_RISING				0x04000000
#define TRIG_CTRL_EDGEB_FALLING				0x08000000
#define TRIG_CTRL_EDGEB_BOTH				0x0c000000
#define TRIG_CTRL_EDGEB_BITFIELD			0x0c000000
#define TRIG_CTRL_TRIG_MODE_NEVER			0x00000000
#define TRIG_CTRL_TRIG_MODE_ALWAYS			0x10000000
#define TRIG_CTRL_TRIG_MODE_EDGE			0x20000000
#define TRIG_CTRL_TRIG_MODE_BITFIELD		0xf0000000

#define TRIG_CTRL_MASK_ALL					0xffffffff

#define TRIG_STATE_A_TRIGD					0x00000001
#define TRIG_STATE_A_AUTO_TRIGD				0x00000002
#define TRIG_STATE_A_AUTO_TRIG_REPD			0x00000004
#define TRIG_STATE_A_ARMED_SW				0x00000008
#define TRIG_STATE_A_ARMED_TRUE				0x00000010
#define TRIG_STATE_A_HOLDOFF_ACTIVE			0x00000020
#define TRIG_STATE_A_ACQ_WAIT_HOLDOFF		0x00000040
#define TRIG_STATE_A_INT_ARM				0x00000080
#define TRIG_STATE_A_DBG_AU_STATE_MASK		0x00000e00
#define TRIG_STATE_A_DBG_AU_STATE_SHIFT		9
#define TRIG_STATE_A_DBG_TRIG_STATE_MASK	0x0000f000
#define TRIG_STATE_A_DBG_TRIG_STATE_SHIFT	12

#define TRIG_LVL_MAX_PREC					2047
#define TRIG_LVL_MAX_8B						255

#define HOLDOFF_NS_PER_COUNT				8
#define HOLDOFF_NS_MINIMUM					32											// Min ~8ns
#define HOLDOFF_NS_MAXIMUM					((0xfffffffc) * HOLDOFF_NS_PER_COUNT)		// Max ~34.35s

void trig_init();
int trig_zero_levels();
int trig_write_levels(int comp_group, unsigned int chan_idx, uint8_t demux_mode, int comp_pol, uint16_t trig_lvl_high, uint16_t trig_lvl_low);
int trig_configure_edge(unsigned int chan_idx, uint16_t trig_lvl, uint16_t trig_hyst, int edge_type);
int trig_configure_always();
int trig_configure_holdoff(uint64_t holdoff_time_ns);
void trig_dump_state();
void trig_force();
void trig_arm();
void trig_disarm();
int trig_has_trigd();

#endif /* SRC_TRIGGER_H_ */

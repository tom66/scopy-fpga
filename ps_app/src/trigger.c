/*
 * trigger.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 25 Mar 2020
 *      Author: Tom
 */

#include "trigger.h"
#include "acquire.h"
#include "fabric_config.h"

/*
 * This file controls the trigger engine and the register space on the PL to
 * configure a trigger.  A trigger is necessary for a triggered acquisition to
 * complete; if one is not configured, no acquisition is possible.
 *
 * It is currently possible to configure an EDGE or ALWAYS trigger, and a trigger
 * can also be FORCEd by calling the relevant function.
 */

/*
 * Initialise the trigger engine and reset the state on the PL.
 */
void trig_init()
{
	// Default configuration.  Drive reset then clear reset bits.
	fabcfg_write(FAB_CFG_TRIG_CONFIG_A, 	TRIG_CTRL_TRIGGER_RESET | TRIG_CTRL_COMPARATOR_RESET | TRIG_CTRL_EXT_SEL_NORMAL | TRIG_CTRL_NA_NORMAL_MODE | \
											TRIG_CTRL_EDGEA_NONE | TRIG_CTRL_EDGEB_NONE | TRIG_CTRL_TRIG_MODE_NEVER);

	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, 	TRIG_CTRL_TRIGGER_RESET | TRIG_CTRL_COMPARATOR_RESET);

	// All levels start at zero, enables all disabled.
	trig_zero_levels();

	// XXX: Change the below loads into functions to load 31-bit timer registers

	// Load holdoff of zero.  Drive load flag.
	fabcfg_write(FAB_CFG_TRIG_HOLDOFF,  	0x00000001);
	fabcfg_write(FAB_CFG_TRIG_HOLDOFF,  	0x00000000);

	// Reset auto timer.  In future these will be loaded with auto timer values (which could be adjusted by the user).
	fabcfg_write(FAB_CFG_TRIG_AUTO_TIMERS, 	0x00000001);
	fabcfg_write(FAB_CFG_TRIG_AUTO_TIMERS,  0x00000000);

	// Load both delay registers to zero
	fabcfg_write(FAB_CFG_TRIG_DELAY_REG0, 	0x00000001);
	fabcfg_write(FAB_CFG_TRIG_DELAY_REG0,   0x00000000);
	fabcfg_write(FAB_CFG_TRIG_DELAY_REG1, 	0x00000001);
	fabcfg_write(FAB_CFG_TRIG_DELAY_REG1,   0x00000000);

	// Load holdoff with lowest holdoff possible
	trig_configure_holdoff(0);

	d_printf(D_INFO, "trigger: defaults loaded");
	trig_dump_state();
}

/*
 * Zero trigger levels and disable all trigger comparator channels.
 */
int trig_zero_levels()
{
	fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL1, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL2, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL3, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL4, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL5, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL6, 0x00000000);
	fabcfg_write(FAB_CFG_TRIG_LEVEL7, 0x00000000);

	return TRIGRES_OK;
}

/*
 * Write trigger levels for a given channel, comparator group and demux
 * mode to the fabric.
 */
int trig_write_levels(int comp_group, unsigned int chan_idx, uint8_t demux_mode, int comp_pol, uint16_t trig_lvl_high, uint16_t trig_lvl_low)
{
	uint32_t reg_base;
	uint32_t reg_write;

	if(comp_group == TRIG_COMP_A) {
		reg_base = FAB_CFG_TRIG_LEVEL_A_BASE;
	} else if(comp_group == TRIG_COMP_B) {
		reg_base = FAB_CFG_TRIG_LEVEL_B_BASE;
	} else {
		return TRIGRES_PARAM_FAIL;
	}

	/*
	 * Compute the data that will be written to all of the registers that are relevant.
	 *
	 * The level high and low registers are packed along with the polarity and enable.
	 */
	if(trig_lvl_low > trig_lvl_high) {
		return TRIGRES_PARAM_FAIL;
	}

	if(demux_mode & (ADCDEMUX_12BIT | ADCDEMUX_14BIT)) {
		if(trig_lvl_high > TRIG_LVL_MAX_PREC) {
			trig_lvl_high = TRIG_LVL_MAX_PREC;
		}

		if(trig_lvl_low > TRIG_LVL_MAX_PREC) {
			trig_lvl_low = TRIG_LVL_MAX_PREC;
		}
	} else {
		if(trig_lvl_high > TRIG_LVL_MAX_8B) {
			trig_lvl_high = TRIG_LVL_MAX_8B;
		}

		if(trig_lvl_low > TRIG_LVL_MAX_8B) {
			trig_lvl_low = TRIG_LVL_MAX_8B;
		}
	}

	reg_write = (trig_lvl_low << TRIG_LVL_REG_LO_SHIFT) | (trig_lvl_high << TRIG_LVL_REG_HI_SHIFT) | TRIG_LVL_CH_ENABLE;

	if(comp_pol == TRIG_COMP_POL_NORMAL) {
		reg_write |= TRIG_LVL_CH_POLARITY;
	} else if(comp_pol != TRIG_COMP_POL_INVERT) {
		return TRIGRES_PARAM_FAIL;
	}

	//d_printf(D_INFO, "trigger: reg_write: 0x%08x", reg_write);

	/*
	 * Depending on the demux mode, the chan_idx has different behaviours.
	 *
	 * In 1 ch mode, chan_idx is ignored (it should be zero) and all level registers are written
	 * In 2 ch mode, chan_idx of 0 writes to levels 0A and 2A or 0B and 2B (reflecting the ADC data arrangement);
	 *               chan_idx of 1 writes to levels 1A and 3A or 1B and 3B.
	 * In 4 ch mode, chan_idx selects the sole level word that is written.
	 *
	 * Other registers are left unchanged.
	 */
	if(demux_mode & ADCDEMUX_1CH) {
		if(chan_idx == 0) {
			fabcfg_write(reg_base + 0x00, reg_write);
			fabcfg_write(reg_base + 0x04, reg_write);
			fabcfg_write(reg_base + 0x08, reg_write);
			fabcfg_write(reg_base + 0x0c, reg_write);
		} else {
			return TRIGRES_PARAM_FAIL;
		}
	} else if(demux_mode & ADCDEMUX_2CH) {
		if(chan_idx == 0 || chan_idx == 1) {
			reg_base += chan_idx * 4;
		} else {
			return TRIGRES_PARAM_FAIL;
		}

		fabcfg_write(reg_base + 0x00, reg_write);
		fabcfg_write(reg_base + 0x08, reg_write);
	} else if(demux_mode & ADCDEMUX_4CH) {
		if(chan_idx <= 3) {
			reg_base += chan_idx * 4;
		} else {
			return TRIGRES_PARAM_FAIL;
		}

		fabcfg_write(reg_base, reg_write);
	} else {
		return TRIGRES_NOT_IMPLEMENTED;
	}

	return TRIGRES_OK;
}

/*
 * Configure the trigger as an always-trigger.  The existing trigger configuration
 * is cleared.
 */
int trig_configure_always()
{
	// Clear all prior trigger settings
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_MASK_ALL);

	// Reset the trigger, then remove the reset and re-arm it
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_TRIGGER_RESET | TRIG_CTRL_COMPARATOR_RESET | TRIG_CTRL_TRIG_MODE_ALWAYS);
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_TRIGGER_RESET | TRIG_CTRL_COMPARATOR_RESET);
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_GLOBAL_ENABLE | TRIG_CTRL_TRIGGER_ARM);

	return TRIGRES_OK;
}

/*
 * Configure the trigger as an edge-trigger.  The existing trigger configuration
 * is cleared; if a normal/auto mode or filter is required, this will need to be
 * set again after the configuration is loaded.
 */
int trig_configure_edge(unsigned int chan_idx, uint16_t trig_lvl, uint16_t trig_hyst, int edge_type)
{
	uint16_t trig_lo, trig_hi;
	int res;

	if(!(edge_type == TRIG_EDGE_FALLING || edge_type == TRIG_EDGE_RISING || edge_type == TRIG_EDGE_BOTH)) {
		return TRIGRES_PARAM_FAIL;
	}

	if((trig_hyst * 2) > trig_lvl) {
		return TRIGRES_PARAM_FAIL;
	}

	if(chan_idx >= 4) {
		return TRIGRES_PARAM_FAIL;
	}

	trig_lo = trig_lvl - (trig_hyst / 2);
	trig_hi = trig_lvl + (trig_hyst / 2);

	// Disable interrupts while writing state
	asm("cpsid I");

	// Clear and disable all trigger comparators.
	trig_zero_levels();

	// Switch to edge trigger, resetting the trigger engine.
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_MASK_ALL);
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_TRIGGER_RESET | TRIG_CTRL_COMPARATOR_RESET | TRIG_CTRL_TRIG_MODE_EDGE);

	// Set the appropriate edge mode.
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_EDGEA_BITFIELD | TRIG_CTRL_EDGEB_BITFIELD);

	if(edge_type == TRIG_EDGE_FALLING) {
		fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_EDGEA_FALLING);
	} else if(edge_type == TRIG_EDGE_RISING) {
		fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_EDGEA_RISING);
	} else if(edge_type == TRIG_EDGE_BOTH) {
		fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_EDGEA_BOTH);
	}

	// Write the levels for COMP_A (COMP_B is unused) and enable the trigger channels.
	res = trig_write_levels(TRIG_COMP_A, chan_idx, g_acq_state.demux_reg, TRIG_COMP_POL_NORMAL, trig_hi, trig_lo);

	// Remove the resets, enable the trigger engine.
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_TRIGGER_RESET | TRIG_CTRL_COMPARATOR_RESET);
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_GLOBAL_ENABLE | TRIG_CTRL_TRIGGER_ARM);

	// Enable interrupts again
	asm("cpsie I");

	// Check if level write succeeded
	if(res != TRIGRES_OK) {
		return res;
	}

	return TRIGRES_OK;
}

/*
 * Configure the holdoff.  Holdoff time in nanoseconds should be provided,
 * a minimum of HOLDOFF_NS_MINIMUM and maximum of HOLDOFF_NS_MAXIMUM.  Out of
 * range values are clipped to either limit.
 *
 * A holdoff value of zero disables holdoff completely.
 */
int trig_configure_holdoff(uint64_t holdoff_time_ns)
{
	uint32_t holdoff_reg;

	if(holdoff_time_ns == 0) {
		fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_HOLDOFF_ENABLE);
		fabcfg_write(FAB_CFG_TRIG_HOLDOFF, 0x00000000);
		return TRIGRES_OK;
	}

	if(holdoff_time_ns < HOLDOFF_NS_MINIMUM) {
		holdoff_time_ns = HOLDOFF_NS_MINIMUM;
	}

	if(holdoff_time_ns > HOLDOFF_NS_MAXIMUM) {
		holdoff_time_ns = HOLDOFF_NS_MAXIMUM;
	}

	holdoff_reg = holdoff_time_ns / HOLDOFF_NS_PER_COUNT;
	fabcfg_write(FAB_CFG_TRIG_HOLDOFF, holdoff_reg);
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_HOLDOFF_ENABLE);

	return TRIGRES_OK;
}

/*
 * Dump the state of the trigger engine.
 */
void trig_dump_state()
{
	uint32_t state_a;
	int i;

	d_printf(D_INFO, "");

	d_printf(D_INFO, "** Trigger State (Fabric) **");
	d_printf(D_INFO, "");
	d_printf(D_INFO, "trig_config_a      = 0x%08x", fabcfg_read(FAB_CFG_TRIG_CONFIG_A));

	for(i = 0; i < 8; i++) {
		d_printf(D_INFO, "trig_level%d        = 0x%08x", i, fabcfg_read(FAB_CFG_TRIG_LEVEL0 + (i * 4)));
	}

	d_printf(D_INFO, "trig_holdoff       = 0x%08x", fabcfg_read(FAB_CFG_TRIG_HOLDOFF));
	d_printf(D_INFO, "trig_auto_timers   = 0x%08x", fabcfg_read(FAB_CFG_TRIG_AUTO_TIMERS));
	d_printf(D_INFO, "trig_delay_reg0    = 0x%08x", fabcfg_read(FAB_CFG_TRIG_DELAY_REG0));
	d_printf(D_INFO, "trig_delay_reg1    = 0x%08x", fabcfg_read(FAB_CFG_TRIG_DELAY_REG1));

	state_a = fabcfg_read(FAB_CFG_TRIG_STATE_A);

	d_printf(D_INFO, "trig_state_a       = 0x%08x [%c%c%c%c%c%c%c%c] [auto:%d] [trig:%d]",
														 state_a, \
														(state_a & TRIG_STATE_A_TRIGD) 				? 'T' : ' ', \
														(state_a & TRIG_STATE_A_AUTO_TRIGD) 		? 'A' : ' ', \
														(state_a & TRIG_STATE_A_AUTO_TRIG_REPD) 	? 'a' : ' ', \
														(state_a & TRIG_STATE_A_ARMED_SW) 			? 's' : ' ', \
														(state_a & TRIG_STATE_A_ARMED_TRUE) 		? 'r' : ' ', \
														(state_a & TRIG_STATE_A_HOLDOFF_ACTIVE)		? 'H' : ' ', \
														(state_a & TRIG_STATE_A_ACQ_WAIT_HOLDOFF) 	? 'W' : ' ', \
														(state_a & TRIG_STATE_A_INT_ARM) 			? 'I' : ' ', \
														(state_a & TRIG_STATE_A_DBG_AU_STATE_MASK) >> TRIG_STATE_A_DBG_AU_STATE_SHIFT, \
														(state_a & TRIG_STATE_A_DBG_TRIG_STATE_MASK) >> TRIG_STATE_A_DBG_TRIG_STATE_SHIFT);

	d_printf(D_INFO, "trig_holdoff_debug = 0x%08x", fabcfg_read(FAB_CFG_TRIG_HOLDOFF_DEBUG));

	d_printf(D_INFO, "");

	//fabcfg_dump_state();
}

/*
 * Read the TRIG'D state from the trigger engine and clear the TRIG'D flag if set.
 * Auto trigger status also returned.
 *
 * Returns one of the following results:
 *   - TRIG_STATUS_TRIGD
 *   - TRIG_STATUS_AUTO
 *   - TRIG_STATUS_NONE
 */
int trig_has_trigd()
{
	int res = TRIG_STATUS_NONE;
	uint32_t state;

	state = fabcfg_read(FAB_CFG_TRIG_STATE_A);

	// Possible complication: what to do if we get a TRIG'D & AUTO event in same window?
	if(state & TRIG_STATE_A_TRIGD) {
		res = TRIG_STATUS_TRIGD;
	} else if(state & (TRIG_STATE_A_AUTO_TRIGD | TRIG_STATE_A_AUTO_TRIG_REPD)) {
		res = TRIG_STATUS_AUTO;
	}

	return res;
}

/*
 * Arm the trigger.
 */
void trig_arm()
{
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_TRIGGER_ARM);
}

/*
 * Disarm the trigger.
 */
void trig_disarm()
{
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_TRIGGER_ARM);
}

/*
 * Force the trigger.  Trigger should be armed.
 */
void trig_force()
{
	fabcfg_set(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_FORCE_TRIGGER);
	fabcfg_clear(FAB_CFG_TRIG_CONFIG_A, TRIG_CTRL_FORCE_TRIGGER);
}

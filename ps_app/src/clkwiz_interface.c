/*
 * clkwiz_interface.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 29 Feb 2020 (ooh, leap year)
 *      Author: Tom
 */

#include "clkwiz_interface.h"
#include "hal.h"

#include <math.h>

/*
 * Handles command and control of a ClkWiz via the XClkWiz API.  Enables
 * direct write of synthesiser values to change output frequencies.
 */

/*
 * Initialise a new ClkWiz interface structure.  `ifc' must point to a
 * an empty `struct clkwiz_interface_t`. For reasons unknown to me,
 * the refclk frequency stored in the ClkWiz is invalid, so an external
 * refclk must be specified as `refclk_freq`.
 */
void clkwiz_init(struct clkwiz_interface_t *ifc, uint32_t device_id, float refclk_freq)
{
	int i;
	XClk_Wiz_Config *clkcfg = XClk_Wiz_LookupConfig(device_id);

	D_ASSERT(clkcfg != NULL);
	D_ASSERT(refclk_freq > 1.0f && refclk_freq < 800.0f);  // Basic sanity check on refclk

	ifc->wiz_cfg = clkcfg;
	ifc->refclk_freq = refclk_freq;

	XClk_Wiz_CfgInitialize(&ifc->wiz, ifc->wiz_cfg, ifc->wiz_cfg->BaseAddr);

	d_printf(D_INFO, "clkwiz: initialised configuration");
}

/*
 * Change the first pair of ClkWiz frequencies for MIPI.  This works on other
 * ClkWizards but is primarily intended for the MIPI bus clocks.
 *
 * @param		new_freq		Requested frequency in MHz
 */
void clkwiz_change_mipi_freq(struct clkwiz_interface_t *ifc, float new_freq)
{
	int div, fb_mult, fb_frac;
	int best_fb_mult = 0, best_fb_frac = 0;
	float fbout_freq = 800.0f, best_fbout_freq = 0.0f;
	float freq = 0.0f, best_error = 1e10f, error = 0.0f, best_freq = 0;
	int solved = 0, solver_iters = 0;
	uint32_t ccfg_0, clkout_div;

	D_ASSERT(new_freq > 0.0f && new_freq < 800.0f);

	// Compute the closest divider assuming an 800MHz FBOUT.
	// Above 600MHz divider is forced to 1.
	if(new_freq >= 600) {
	 	div = 1;
	} else {
		for(div = 1; div < 106; div++) {
			freq = fbout_freq / div;
			//d_printf(D_INFO, "ReqFreq=%2.2f MHz, Freq=%2.2f MHz, div=%d", new_freq, freq, div);

			if(freq <= new_freq) {
				//d_printf(D_INFO, "Divider found");
				break;
			}
		}
	}

	/*
	 * Tune FBOUT to create an I and Q reference clock.
	 *
	 * We essentially tune FBOUT so that we can use an integer divider for the output clock frequencies.
	 *
	 * This gets us pretty close to supporting all frequencies in the range of 0-800MHz with minimal error,
	 * though the search algorithm could be substantially improved.
	 */
	for(fb_mult = 0; fb_mult < 8; fb_mult++) {
		for(fb_frac = 0; fb_frac < 1000; fb_frac++) {
			fbout_freq = ifc->refclk_freq * (fb_mult + (fb_frac / 1000.0f));

			// Skip invalid frequencies.
			if(fbout_freq < FBOUT_MIN_FREQ || fbout_freq > FBOUT_MAX_FREQ) {
				continue;
			}

			freq = fbout_freq / div;
			error = fabs(new_freq - freq);
			solver_iters++;

			if(error < best_error) {
				best_error = error;
				best_freq = freq;
				best_fb_mult = fb_mult;
				best_fb_frac = fb_frac;
				best_fbout_freq = fbout_freq;

				// If < 10Hz error, end
				if(best_error < 1e-5) {
					solved = 1;
					break;
				}
			}
		}
	}

	d_printf(D_INFO, "Mult=%4d, Frac=%4d, fbout_freq=%7.2f MHz, mipi_freq=%7.2f MHz, target=%7.2f MHz, best_error=%6d Hz, iters=%d, solved=%c", \
			best_fb_mult, best_fb_frac, best_fbout_freq, best_freq, new_freq, (int)(best_error * 1e6), solver_iters, (solved) ? 'Y' : 'N');

	// Write the settings to the registers and commit the clock change.
	ccfg_0 = 0x04000001 | ((best_fb_mult & 0xff) << 8) | ((best_fb_frac & 0x3ff) << 16);
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x200, ccfg_0);
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x204, 0);

	clkout_div = (div & 0xff);  // Only support integer division as that is common to all channels
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x208, clkout_div);
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x20c, 0);
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x210, 50000);	// 50% duty
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x214, clkout_div);
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x218, 0);
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x21c, 50000);	// 50% duty

	clkwiz_commit(ifc);
	//clkwiz_dump_state(ifc);
}

/*
 * Dump the ClkWiz state.
 */
void clkwiz_dump_state(struct clkwiz_interface_t *ifc)
{
	int i;
	int clkfbout_frac_en, clk_frac_en;
	uint32_t base_addr = 0x208;
	uint32_t reg_divfrac, reg_phase, reg_duty;
	uint32_t ccfg_0, clkfbout_phase, clkfbout_mult, clkfbout_frac;
	uint32_t clk_div, clk_frac;
	uint8_t clk_divide;
	float fbout_freq, clk_freq;

	// I don't know if these register offsets are in another .h file somewhere, but I couldn't find them
	// For now, all manually entered.
	ccfg_0 = XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, 0x200);
	clkfbout_phase = XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, 0x204);

	clk_divide       =   (ccfg_0 & 0x000000ff);
	clkfbout_mult    =   (ccfg_0 & 0x0000ff00) >> 8;
	clkfbout_frac    =   (ccfg_0 & 0x03ff0000) >> 16;
	clkfbout_frac_en = !!(ccfg_0 & (1 << 26));

	fbout_freq = ifc->refclk_freq * (clkfbout_mult + (clkfbout_frac / 1000.0f));

	d_printf(D_INFO, "** ClkWiz debug dump for ifc @ 0x%08x **", ifc);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Register base:          0x%08x", ifc->wiz_cfg->BaseAddr);
	d_printf(D_INFO, "Configured refclk freq: %2.5f MHz", ifc->refclk_freq);
	d_printf(D_INFO, "CLKCFG0 register:       0x%08x", ccfg_0);
	d_printf(D_INFO, "CLKFBOUT register:      0x%08x", clkfbout_phase);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Overall divide:         %d", clk_divide);
	d_printf(D_INFO, "CLKFBOUT multiplier:    %2.5f (MULT=%d, FRAC=%d, FRAC_EN=%d)", \
			clkfbout_mult + (clkfbout_frac / 1000.0f), clkfbout_mult, clkfbout_frac, clkfbout_frac_en);
	d_printf(D_INFO, "FBOUT frequency:        %2.5f MHz", fbout_freq);
	d_printf(D_INFO, "");

	for(i = 1; i < CLKWIZ_MAX_CLOCKS; i++) {
		reg_divfrac = XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, base_addr);
		reg_phase   = XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, base_addr + 4);
		reg_duty    = XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, base_addr + 8);

		clk_div     =   (reg_divfrac & 0x000000ff);
		clk_frac    =   (reg_divfrac & 0x0003ff00);
		clk_frac_en = !!(reg_divfrac & 0x00040000);

		// Fractional divide only supported for ClkOut1
		if(i > 1) {
			clk_frac = 0;
		}

		clk_freq    = (fbout_freq / (clk_div + (clk_frac / 1000.0f))) / clk_divide;

		d_printf(D_INFO, "Clock #%d: BaseAddr=0x%04x DivFrac=0x%08x Phase=0x%08x Duty=0x%08x Int=%4d Frac=%4d Div=%2.5f FracEn=%d", \
				i, base_addr, reg_divfrac, reg_phase, reg_duty, clk_div, clk_frac, clk_div + (clk_frac / 1000.0f), clk_frac_en);
		d_printf(D_INFO, "          OutputFreq=%2.5f MHz, OutputDuty=%2.3f%%, OutputPhase=%2.2f deg", \
				clk_freq, reg_duty / 1000.0f, reg_phase / 1000.0f);
		d_printf(D_INFO, "");

		base_addr += 12;

		//d_printf(D_INFO, "Clock #%d: Divide=%08d, Frac=%03d, FracEn=%d, Phase=%08d, Duty=%3.3f, ComputedFrequency=%8.2f)", i);
	}

	d_printf(D_INFO, "");
}

/*
 * Commit any changes to the dynamic reconfiguration registers to the CLKWIZ output.
 * Wait for LOCK indicating that the clock change has been accepted and stabilised.
 */
void clkwiz_commit(struct clkwiz_interface_t *ifc)
{
	int timeout = 100000;

	// Check that MMCM is locked already
	if(!(XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, 0x04) & 1)) {
		d_printf(D_ERROR, "MMCM not locked. Unable to change clock frequency.");
	}

	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x25c, 0x03);	// Load and SEN set
	asm("nop");
	XClk_Wiz_WriteReg(ifc->wiz_cfg->BaseAddr, 0x25c, 0x00);	// Load and SEN cleared

	// Wait for re-lock
	while(!(XClk_Wiz_ReadReg(ifc->wiz_cfg->BaseAddr, 0x04) & 1) && (timeout-- > 0)) ;

	if(timeout == 0) {
		d_printf(D_ERROR, "Timeout waiting for MMCM to lock onto new configuration.");
	}
}

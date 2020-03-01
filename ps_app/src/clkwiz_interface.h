/*
 * clkwiz_interface.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 29 Feb 2020 (ooh, leap year)
 *      Author: Tom
 */

#ifndef SRC_CLKWIZ_INTERFACE_H_
#define SRC_CLKWIZ_INTERFACE_H_

#include "xclk_wiz.h"

#define CLKWIZ_MAX_CLOCKS			7

#define FBOUT_MIN_FREQ				600
#define FBOUT_MAX_FREQ				1200

struct clkwiz_interface_t {
	XClk_Wiz_Config *wiz_cfg;
	XClk_Wiz wiz;
	float refclk_freq;
};

void clkwiz_init(struct clkwiz_interface_t *ifc, uint32_t device_id, float refclk_freq);
void clkwiz_change_mipi_freq(struct clkwiz_interface_t *ifc, float new_freq);
void clkwiz_dump_state(struct clkwiz_interface_t *ifc);
void clkwiz_commit(struct clkwiz_interface_t *ifc);

#endif // SRC_CLKWIZ_INTERFACE_H_

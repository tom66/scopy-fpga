/*
 * main.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: ?
 *      Author: Tom
 */

/*
 * Main entry point
 */

#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>

#include "hal.h"
#include "acquire.h"
#include "spi.h"
#include "mipi_csi.h"
#include "system_control.h"

//#define ACQ_HACKS_TEST

//uint8_t src_buffer[16384] __attribute__((aligned(32)));
//uint8_t dest_buffer[16384] __attribute__((aligned(32)));

int main()
{
	int res, i = 0;

	Xil_DCacheDisable();

	hal_init();
	acq_init();
	spi_init();
	mipi_csi_init();
	sysctrl_init();

#ifdef ACQ_HACKS_TEST
	acq_hacks_init();
	acq_hacks_run();
#endif

	// Run system control main loop;  we never leave that function.
	sysctrl_main_loop();

    cleanup_platform();
}

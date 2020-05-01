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

#if 0
	trig_configure_always();
	acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 8192, 8192, 384);

	while(1) {
		acq_rewind();
		res = acq_start(ACQ_START_FIFO_RESET);

		bogo_delay(100000);

		acq_stop();
		acq_debug_dump();
	}
#endif

	//acq_hacks_run();

	// Run system control main loop;  we never leave that function.
	sysctrl_main_loop();

	/*
	d_printf(D_INFO, "Press key to start...");
	d_waitkey();

	acq_hacks_init();
	acq_hacks_run();
	*/

    cleanup_platform();
}

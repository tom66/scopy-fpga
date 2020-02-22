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
#include "mipi_csi.h"

uint32_t csi_buffer[16384];

int main()
{
	int res, i = 0;

	Xil_DCacheDisable();

	hal_init();
	acq_init();
	mcsi_init();

	// acq_free_all_alloc();
	res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 131072, 50);

	if(res != ACQRES_OK) {
		d_printf(D_ERROR, "acq_prepare_triggered error: %d", res);
		exit(-1);
	}

	res = acq_start();

	if(res != ACQRES_OK) {
		d_printf(D_ERROR, "acq_start error: %d", res);
		exit(-1);
	}

	// Wait for acq to be done
	d_printf(D_INFO, "waiting for acq...");
	while(!acq_is_done()) ;

	acq_debug_dump();

	mcsi_setup_multi_transfer_by_id(2, 40);
	mcsi_start();

	while(1) {
		mcsi_tick();
		bogo_delay(10000);

		i++;
		if(i > 200) {
			exit(-1);
		}
	}

    cleanup_platform();
}

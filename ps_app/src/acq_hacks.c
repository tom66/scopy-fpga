/*
 * acq_hacks.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 2 Mar 2020
 *      Author: Tom
 */

#include "hal.h"
#include "acquire.h"
#include "mipi_csi_hacks.h"

extern uint8_t norway_512x512_grey[];

/*
 * Acquistion hacks.  Ties together the acquisition engine and CSI transmitter
 * for some initial testing.  Not intended for final project.
 */
uint8_t buffer[262144] __attribute__((aligned(8)));

void acq_hacks_init()
{
}

void acq_hacks_run()
{
	int res, i, j, n_waves, line = 0;
	int test_tx = 100, bytes;
	float microsec;

	n_waves = 2;

	csi_hack_init();

	memset(buffer, 0, 32);

	for(i = 0; i < (sizeof(buffer) - 32); i++) {
		buffer[i + 30] = norway_512x512_grey[i - 2];
	}

	// slow MIPI clock for diagnostics
	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, 450 /*177.7777777*/);

	while(1) {
		/*
		d_printf(D_ERROR, "starting to free acq...");

		// Setup the acquisition
		acq_free_all_alloc();

		d_printf(D_ERROR, "starting to prepare acq...");

		// 16k sampct, 128k bytes (128k samples)
		res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 16384, n_waves);

		if(res != ACQRES_OK) {
			d_printf(D_ERROR, "acq_prepare_triggered error: %d", res);
			exit(-1);
		}

		// Start the acquisition
		d_printf(D_INFO, "starting acquisition...");
		res = acq_start();

		if(res != ACQRES_OK) {
			d_printf(D_ERROR, "acq_start error: %d", res);
			exit(-1);
		}

		// Wait for acq to be done
		d_printf(D_INFO, "waiting for acq...");
		while(!acq_is_done()) ;

		//acq_debug_dump_wave(0);

		d_printf(D_INFO, "press key to stream to Pi...");
		//d_waitkey();
		*/

		//d_printf(D_INFO, "acq is done... starting CSI xfer");

		//d_printf(D_INFO, "Start sending %d packets", test_tx);

		bytes = 0;
		d_start_timing(2);

		//for(i = 0; i < 1 /*n_waves*/; i++) {
		for(i = 0; i < 100; i++) {
			csi_hack_start_frame(15);

			//Xil_DCacheInvalidateRange(buffer, sizeof(buffer));
			//dsb();

			//acq_copy_slow_mipi(i, (uint8_t*)buffer);

			for(j = 0; j < 8; j++) {
				//Xil_DCacheFlushRange(buffer, sizeof(buffer));
				//dsb();

				csi_hack_send_line_data(buffer + (j * 32768), 32768);
				bytes += 32768;
			}

			csi_hack_stop_frame();
		}

		d_stop_timing(2);
		microsec = d_read_timing_us(2);

		d_printf(D_INFO, "Done sending %d packets (%d KB) -- took %.4f microseconds", test_tx, microsec, bytes / 1024);
		d_printf(D_INFO, "Transfer rate: %.4f MB/s", bytes / microsec);
	}
}

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

	n_waves = 1;

	csi_hack_init();

	memset(buffer, 0, 32);

	for(i = 0; i < (sizeof(buffer) - 32); i++) {
		buffer[i + 30] = norway_512x512_grey[i];
	}

	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, 450);

	while(1) {
		d_printf(D_ERROR, "starting to free acq...");

		// Setup the acquisition
		acq_free_all_alloc();

		d_printf(D_ERROR, "starting to prepare acq...");

		// 32k sampct, 256k bytes (256k samples)
		//res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 32768, n_waves);

		// 2k sampct, 8k bytes (8k samples)
		res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 1024, n_waves);

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

		//d_printf(D_INFO, "press key to stream to Pi...");
		//d_waitkey();

		bytes = 0;
		microsec = 0;

		for(i = 0; i < n_waves; i++) {
			Xil_DCacheInvalidateRange(buffer, sizeof(buffer));
			dsb();

			acq_copy_slow_mipi(i, (uint8_t*)buffer);

			d_start_timing(2);
			csi_hack_start_frame(15);

			for(j = 0; j < 8; j++) {
				Xil_DCacheFlushRange(buffer, sizeof(buffer));
				dsb();

				csi_hack_send_line_data(buffer + (j * 32768), 32768);
				bytes += 32768;
			}

			csi_hack_stop_frame();

			d_stop_timing(2);
			microsec += d_read_timing_us(2);
		}


		d_printf(D_INFO, "Done sending %d waves (%d KB) -- took %.4f microseconds", n_waves, bytes / 1024, microsec);
		d_printf(D_INFO, "Transfer rate: %.4f MB/s", bytes / microsec);
	}
}

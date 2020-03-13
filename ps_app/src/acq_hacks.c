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

/*
 * Acquistion hacks.  Ties together the acquisition engine and CSI transmitter
 * for some initial testing.  Not intended for final project.
 */
uint8_t buffer[131072];

void acq_hacks_init()
{
}

void acq_hacks_run()
{
	int res, i, j, n_waves;

	n_waves = 2;

	csi_hack_init();

	// slow MIPI clock for diagnostics
	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, 200);

	while(1) {
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
		d_waitkey();

		d_printf(D_ERROR, "acq is done... starting CSI xfer");

		for(i = 0; i < n_waves; i++) {
			// transfer in 4 blocks, 128KB total.  Each frame is a new waveform, though there
			// is no strict framing requirement
			d_printf(D_ERROR, "iter()");
			csi_hack_start_frame(15);
			d_printf(D_ERROR, "done: csi_hack_start_frame");

			acq_copy_slow_mipi(i, (uint8_t*)buffer);
			for(i = 0; i < sizeof(buffer); i++) {
				buffer[i] = i & 0xff;
				//buffer[i] = 0xf0;
			}

			d_printf(D_ERROR, "done: acq_copy_slow_mipi");

			for(j = 0; j < 4; j++) {
				csi_hack_send_line_data(buffer + (j * 32768), 32768);
				d_printf(D_ERROR, "done: csi_hack_send_line_data");
			}

			csi_hack_stop_frame();
			d_printf(D_ERROR, "done: csi_hack_stop_frame");

			d_printf(D_ERROR, "sent %d waves", i);
		}

		d_printf(D_ERROR, "done sending n_waves=%d", n_waves);
	}
}

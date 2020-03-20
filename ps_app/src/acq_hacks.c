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

// #define PRETTY_DEBUG

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
	int res, i, j, n_waves, line = 0, wave_size_bytes, wave_size_counts;
	int test_tx = 100, bytes;
	int iter = 0;
	float microsec;

	wave_size_bytes = 16384;
	wave_size_counts = wave_size_bytes / 8;
	n_waves = 16;

	csi_hack_init();
	memset(buffer, 0, 32);

	/*
	for(i = 0; i < (sizeof(buffer) - 32); i++) {
		buffer[i + 30] = norway_512x512_grey[i];
	}
	*/

	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, 450);

#ifdef PRETTY_DEBUG
	d_printf(D_RAW, "\033[2J");
#endif

	while(1) {
#ifdef PRETTY_DEBUG
		if(iter > 10) {
			d_printf(D_RAW, "\033[2J");
			iter = 0;
		}
#endif

		//d_printf(D_WARN, "Iteration");

		// Setup the acquisition
		acq_free_all_alloc();

		// 32k sampct, 256k bytes (256k samples)
		//res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 32768, n_waves);

		// possible to go as low as 1k sampcount, 8k bytes.
		res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, wave_size_counts, n_waves);

		if(res != ACQRES_OK) {
			d_printf(D_ERROR, "acq_prepare_triggered error: %d", res);
			exit(-1);
		}

		// Start the acquisition
		d_start_timing(4);
		res = acq_start();

		if(res != ACQRES_OK) {
			d_printf(D_ERROR, "acq_start error: %d", res);
			exit(-1);
		}

		// Wait for acq to be done
		while(!acq_is_done()) {
#ifdef PRETTY_DEBUG
			d_printf(D_RAW, "\033[;H");
			acq_debug_dump();
#endif
		}

		d_stop_timing(4);
		microsec = d_read_timing_us(4);

		d_printf(D_INFO, "Acquiring %d waves took %.4f microseconds", n_waves, microsec);

		Xil_DCacheInvalidateRange(buffer, sizeof(buffer));
		dsb();

		d_start_timing(3);

		for(i = 0; i < n_waves; i++) {
			acq_copy_slow_mipi(i, (uint8_t*)(buffer + (wave_size_bytes * i)));
		}

		d_stop_timing(3);
		microsec = d_read_timing_us(3);

		d_printf(D_INFO, "Preparing %d waves took %.4f microseconds", n_waves, microsec);

		bytes = 0;
		microsec = 0;

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

		d_printf(D_INFO, "Done sending %d waves (%d KB) -- took %.4f microseconds", n_waves, bytes / 1024, microsec);
		d_printf(D_INFO, "Transfer rate: %.4f MB/s", bytes / microsec);

		iter++;
	}
}

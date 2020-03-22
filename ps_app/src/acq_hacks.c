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
#include "fabric_config.h"

extern uint8_t norway_512x512_grey[];

#define N_WAVES			128
#define N_WAVESIZE		8192
#define LINE_SIZE		4096
#define BUFFER_SIZE		(N_WAVES * N_WAVESIZE)
#define N_CSI_LINES		(BUFFER_SIZE / LINE_SIZE)

#define PRETTY_DEBUG

/*
 * Acquistion hacks.  Ties together the acquisition engine and CSI transmitter
 * for some initial testing.  Not intended for final project.
 */
uint8_t buffer[BUFFER_SIZE] __attribute__((aligned(8)));

void acq_hacks_init()
{
}

void acq_hacks_run()
{
	int res, i, j, n_waves, line = 0, wave_size_bytes, wave_size_counts;
	int test_tx = 100, bytes;
	int iter = 0;
	float microsec, last_frame_time = 1e6;

	wave_size_bytes = N_WAVESIZE;
	wave_size_counts = wave_size_bytes / 8;
	n_waves = N_WAVES;

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

		//d_printf(D_WARN, "Press key");
		//d_waitkey();

		//d_printf(D_WARN, "Iteration");

		// Setup the acquisition
		d_start_timing(5);
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

		//d_printf(D_INFO, "Acquiring %d waves took %.4f microseconds", n_waves, microsec);

		Xil_DCacheInvalidateRange(buffer, sizeof(buffer));
		dsb();

		d_start_timing(3);

		for(i = 0; i < n_waves; i++) {
			acq_copy_slow_mipi(i, (uint8_t*)(buffer + (wave_size_bytes * i)));
		}

		Xil_DCacheFlushRange(buffer, sizeof(buffer));
		dsb();

		d_stop_timing(3);
		//microsec = d_read_timing_us(3);
		//d_printf(D_INFO, "Preparing %d waves took %.4f microseconds", n_waves, microsec);

		bytes = 0;
		microsec = 0;

		fabcfg_write(FAB_CFG_CSI_LINE_BYTE_COUNT, LINE_SIZE - 2);

		d_start_timing(2);
		csi_hack_start_frame(N_CSI_LINES - 1);

		//for(j = 0; j < 8; j++) {
		csi_hack_send_line_data(buffer, BUFFER_SIZE);
		bytes += BUFFER_SIZE;
		//}

		/*
		csi_hack_start_frame(15);

		for(j = 0; j < 16; j++) {
			Xil_DCacheFlushRange(buffer, sizeof(buffer));
			dsb();

			csi_hack_send_line_data(buffer + (j * 32768), 32768);
			bytes += 32768;
		}
		*/

		csi_hack_stop_frame();

		d_stop_timing(2);
		microsec += d_read_timing_us(2);

		//d_printf(D_INFO, "Done sending %d waves (%d KB) -- took %.4f microseconds", n_waves, bytes / 1024, microsec);
		d_printf(D_INFO, "%.4f MB/s (%.4f fps)", bytes / microsec, 1e6 / last_frame_time);

		//bogo_delay(10000);

		d_stop_timing(5);
		last_frame_time = d_read_timing_us(5);

		iter++;
	}
}

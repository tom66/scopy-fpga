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
#include "trigger.h"

extern uint8_t norway_512x512_grey[];

#define N_WAVES			500
#define N_WAVESIZE		1152
#define LINE_SIZE		4096
#define BUFFER_SIZE		(N_WAVES * N_WAVESIZE)
#define N_CSI_LINES		(BUFFER_SIZE / LINE_SIZE)

#define PRETTY_DEBUG

/*
 * Acquistion hacks.  Ties together the acquisition engine and CSI transmitter
 * for some initial testing.  Not intended for final project.
 */
uint8_t buffer[BUFFER_SIZE] __attribute__((aligned(32)));

void acq_hacks_init()
{
}

void acq_hacks_run()
{
	int res, i, j, n_waves, line = 0, wave_size_bytes, wave_size_counts;
	int test_tx = 100, bytes;
	int iter = 0;
	int acqd_waves = 0;
	float microsec, last_frame_time = 1e6, wave_time = 0, wave_raw_time = 0;
	int trig_level = 0x80;
	int trig_hyst = 0x04;
	int trig_edge = TRIG_EDGE_RISING;
	int64_t trig_holdoff = 0;
	int no_key;

	wave_size_bytes = N_WAVESIZE;
	wave_size_counts = wave_size_bytes / 8;
	n_waves = N_WAVES;

	csi_hack_init();
	memset(buffer, 0, 32);

	/*
	while(1) {
		fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555555);
		fabcfg_write(FAB_CFG_TRIG_LEVEL1, 0x55555555);
		fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x00000000);
		fabcfg_write(FAB_CFG_TRIG_LEVEL1, 0x00000000);
	}
	*/

	/*
	for(i = 0; i < (sizeof(buffer) - 32); i++) {
		buffer[i + 30] = norway_512x512_grey[i];
	}
	*/

	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, 450);

	d_printf(D_WARN, "starting acquisition engine...");
	acq_free_all_alloc();

	// possible to go as low as 1k sampcount, 8k bytes.
	res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, wave_size_counts, n_waves);

	if(res != ACQRES_OK) {
		d_printf(D_ERROR, "acq_prepare_triggered error: %d", res);
		exit(-1);
	}

	d_printf(D_WARN, "starting trigger engine...");
	trig_init();

	// Setup the trigger
	res = trig_configure_edge(TRIG_ADCSRC1, trig_level, trig_hyst, trig_edge);
	d_printf(D_WARN, "trigger=%i", res);
	trig_dump_state();

	//trig_configure_always();
	//trig_configure_holdoff(trig_holdoff);

	d_printf(D_WARN, "starting acquisition hacks...");

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

		// Start overall timer
		d_start_timing(7);

		// Start the acquisition
		d_start_timing(5);
		d_start_timing(4);
		acq_dealloc_rewind();

		res = acq_start(ACQ_START_FIFO_RESET);

		if(res != ACQRES_OK) {
			d_printf(D_ERROR, "acq_start error: %d", res);
			exit(-1);
		}

		// Wait for acq to be done
		do {
#ifdef PRETTY_DEBUG
			d_printf(D_RAW, "\033[;H");
			acq_debug_dump();
#endif

			//outbyte('X');

			/*
			// Check key input, if any
			no_key = 0;

			switch(toupper(d_getkey())) {
				case 'T': trig_level += 1; break;
				case 'G': trig_level -= 1; break;
				case 'E': trig_edge = TRIG_EDGE_BOTH; break;
				case 'R': trig_edge = TRIG_EDGE_RISING; break;
				case 'F': trig_edge = TRIG_EDGE_FALLING; break;
				case 'Y': trig_hyst += 1; break;
				case 'H': trig_hyst -= 1; break;
				case 'O': trig_holdoff += 1000L; break;  // Add 1us holdoff
				case 'P': trig_holdoff -= 1000L; break;  // Remove 1ums holdoff
				default : no_key = 1; break;
			}

			if(trig_level > 255) {
				trig_level = 255;
			} else if(trig_level < 0) {
				trig_level = 0;
			}

			if(trig_hyst > 63) {
				trig_hyst = 63;
			} else if(trig_hyst < 0) {
				trig_hyst = 0;
			}

			if(trig_holdoff < 0L) {
				trig_holdoff = 0L;
			}

			if(trig_holdoff > 30000000000L) {
				trig_holdoff = 30000000000L;
			}

			if(!no_key) {
				trig_configure_edge(TRIG_ADCSRC1, trig_level, trig_hyst, trig_edge);
				//trig_configure_always();
				trig_configure_holdoff(trig_holdoff);
				d_printf(D_INFO, "level:0x%02x, hyst:0x%02x, edge:0x%02x, hold:0x%08x (%d us)", \
						(uint8_t)trig_level, (uint8_t)trig_hyst, (uint8_t)trig_edge, fabcfg_read(FAB_CFG_TRIG_HOLDOFF), \
						(int32_t)(trig_holdoff / 1000L));
				//trig_dump_state();
			}
			*/
		} while(!acq_is_done());

		d_stop_timing(4);

		wave_raw_time = d_read_timing_us(4);
		microsec = wave_raw_time;

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
		d_stop_timing(7);

		wave_time = d_read_timing_us(7);
		microsec += d_read_timing_us(2);
		acqd_waves += g_acq_state.num_acq_made;

		//d_printf(D_INFO, "Done sending %d waves (%d KB) -- took %.4f microseconds", n_waves, bytes / 1024, microsec);
		d_printf(D_INFO, "%.4f MB/s (%.4f fps, %d stalls, %d waves, %.1f waves/sec (%.1f waves/sec raw), %.4f%% stall rate)", \
				bytes / microsec, 1e6 / last_frame_time, (uint32_t)g_acq_state.stats.num_fifo_stall_total, acqd_waves, \
				(g_acq_state.num_acq_made * 1e6) / wave_time, (g_acq_state.num_acq_made * 1e6) / wave_raw_time, \
				((float)(g_acq_state.stats.num_fifo_stall_total) / acqd_waves) * 100);

		//bogo_delay(10000);

		d_stop_timing(5);
		last_frame_time = d_read_timing_us(5);

		iter++;
	}
}

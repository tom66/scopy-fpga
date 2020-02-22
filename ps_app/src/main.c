/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * main entry point for hacky Scopy tests
 */

#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>

#include "hal.h"
#include "acquire.h"

uint32_t csi_buffer[16384];

int main()
{
	uint32_t patt;
	int res, i, j, w;

	Xil_DCacheDisable();

	hal_init();
	acq_init();

#if 0
	while(1) {
		gpio_led_write(0, 1);
		d_start_timing(0);

		for(i = 0; i < 1000000; i++) {
			emio_fast_write(ACQ_EMIO_AXI_RUN, 1);
			emio_fast_write(ACQ_EMIO_AXI_RUN, 0);
			emio_fast_write(ACQ_EMIO_AXI_RUN, 1);
			emio_fast_write(ACQ_EMIO_AXI_RUN, 0);
		}

		d_stop_timing(0);
		gpio_led_write(0, 0);
		d_dump_timing("EMIO fast test II", 0);
	}

	d_start_timing(0);

	for(i = 0; i < 100000; i++) {
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);
	}

	d_stop_timing(0);
	d_dump_timing("Xilinx GPIO test", 0);
#endif

	//d_printf(D_INFO, "0x%08x", g_hal.xgpio_ps.GpioConfig.BaseAddr);

	//res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 192, 100);
#if 0
	res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 8192, 300);
	d_printf(D_INFO, "acq_prepare_triggered = %d", res);
	acq_debug_dump();
#endif
	//acq_debug_dump_wavedata();

	d_printf(D_WARN, "Press key to start");
	d_waitkey();

	d_printf(D_WARN, "Press key again");
	d_waitkey();

	//d_printf(D_WARN, "Press key again");
	//d_waitkey();

#if 0
	d_printf(D_INFO, "Starting acquisition");
	res = acq_start();

	d_printf(D_INFO, "acq_start = %d", res);
#endif

	//bogo_delay(1000000);
	//acq_debug_dump();

	/*
	d_printf(D_INFO, "Waiting...");

	while(!acq_is_done()) {
		//d_printf(D_RAW, "\r\n\r\n\033[2J\033[0m\r\n");
		//acq_debug_dump();
		bogo_delay(1000000);
	}
	*/

#if 0
	d_printf(D_RAW, "\r\n\r\n\033[2J\033[0m\r\n");

	while(1) {
		d_printf(D_RAW, "\r\n\r\n\033[1;1H\033[0m\r\n");
		acq_debug_dump();
		bogo_delay(100000);
	}
#endif

#if 0
	d_start_timing(2);
	for(i = 0; i < 1000; i++) {
		acq_append_next_alloc();
	}
	d_stop_timing(2);
	d_dump_timing("1000 alloc", 2);

	acq_debug_dump();
#endif

#if 0
	while(!acq_is_done()) {
		acq_debug_dump();
		bogo_delay(100000);
		//d_printf(D_WARN, "Waiting acq");
	}
#endif

	/*
	while(1) {
		asm("wfe");
	}*/

	while(1) {
		//d_printf(D_RAW, "\r\n\r\n\033[2J\033[0m\r\n");

		acq_free_all_alloc();
		res = acq_prepare_triggered(ACQ_MODE_8BIT | ACQ_MODE_1CH, 0, 8192, 50);
		//d_printf(D_INFO, "acq_prepare_triggered = %d", res);
		res = acq_start();
		//d_printf(D_INFO, "acq_start = %d", res);

		while(!acq_is_done()) ;

		//acq_debug_dump();
		acq_copy_slow_mipi(49, (uint32_t *)&csi_buffer);
		d_printf(D_INFO, "raw_samples=%llu", g_acq_state.stats.num_samples_raw);
	}

#if 0
	for(i = (8192 - 200); i < (8192 + 200); i++) {
		d_printf(D_INFO, "%8d: 0x%08x", i * 4, csi_buffer[i]);
	}
#endif

	patt = csi_buffer[0];

	for(i = 1; i < 16384; i++) {
		if((csi_buffer[i] - patt) != 0x04040404) {
			d_printf(D_ERROR, "%8d: 0x%08x (actual: 0x%08x)", i * 4, csi_buffer[i] - patt, csi_buffer[i]);
		} else if((csi_buffer[i] - patt) != 0x03030304) {
			d_printf(D_INFO,  "%8d: 0x%08x (actual: 0x%08x)", i * 4, csi_buffer[i] - patt, csi_buffer[i]);
		} else {
			d_printf(D_WARN,  "%8d: 0x%08x (actual: 0x%08x) ????", i * 4, csi_buffer[i] - patt, csi_buffer[i]);
		}
		patt = csi_buffer[i];
	}

	d_printf(D_WARN, "All done");

	while(1) ;

#if 0
	w = 0;

	while(1) {
		acq_debug_dump();
		acq_debug_dump_wave(w);

		w++;

		d_printf(D_WARN, "Press key for next wave (%d)", w);
		d_waitkey();
	}
#endif

    cleanup_platform();
}

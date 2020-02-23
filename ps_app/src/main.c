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
#include "dma_gearbox.h"

uint8_t src_buffer[16384] __attribute__((aligned(32)));
uint8_t dest_buffer[16384] __attribute__((aligned(32)));

int main()
{
	int res, i = 0;

	Xil_DCacheDisable();

	hal_init();
	acq_init();
	//mcsi_init();
	dma_gearbox_init();

	// acq_free_all_alloc();
#if 0
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
#endif

#if 0
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
#endif

	for(i = 0; i < 1024; i++) {
		src_buffer[i] = i + 0x80;
	}

	d_printf(D_INFO, "SrcAddr=%08x", src_buffer);
	d_printf(D_INFO, "DstAddr=%08x", dest_buffer);

	dma_gearbox_setup_copy(ADCDEMUX_8BIT | ADCDEMUX_1CH, 0, src_buffer, src_buffer + 1024, dest_buffer);
	dma_gearbox_execute();

	//while(dma_gearbox_is_done()) ;

	bogo_delay(100000);

	Xil_DCacheInvalidateRange((UINTPTR)&dest_buffer, sizeof(dest_buffer));
	dmb();

	d_printf(D_RAW, "\r\n** Source buffer **\r\n");
	d_printf(D_RAW, "0x%08x: ", 0);

	for(i = 0; i < 1024; i++) {
		d_printf(D_RAW, "%02x ", src_buffer[i]);

		if(((i + 1) & 31) == 0) {
			d_printf(D_RAW, "\r\n0x%08x: ", i);
		}
	}

	d_printf(D_RAW, "\r\n** Dest buffer **\r\n");
	d_printf(D_RAW, "0x%08x: ", 0);

	for(i = 0; i < 1024; i++) {
		d_printf(D_RAW, "%02x ", dest_buffer[i]);

		if(((i + 1) & 31) == 0) {
			d_printf(D_RAW, "\r\n0x%08x: ", i);
		}
	}

    cleanup_platform();
}

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
#include "mipi_csi.h"
#include "mipi_csi_hw.h"
#include "fabric_config.h"
#include "trigger.h"

void acq_hacks_init()
{
	d_printf(D_ERROR, "Start test");

	acq_prepare_triggered(ACQ_MODE_1CH | ACQ_MODE_8BIT, 12000, 12000, 99);
	trig_configure_edge(TRIG_ADCSRC1, 0x7f, 0x10, TRIG_EDGE_RISING);
	acq_start(1);

	bogo_delay(10000);

	dma_bd_debug_dump(g_mipi_csi_state.bd_ring);

	d_printf(D_ERROR, "Done test");
}

void acq_hacks_run()
{
	int i;

#if 0
	while(1) {
		d_printf(D_ERROR, "Press key to iterate");
		d_waitkey();

		d_printf(D_ERROR, "Iteration");

		acq_stop();
		acq_rewind();

		d_printf(D_ERROR, "got %d waves", acq_get_nwaves_done());

		mipi_csi_queue_all_waves();
		//acq_swap();
		//acq_start(1);
		mipi_csi_unpop_and_start_all();

		//d_printf(D_ERROR, "Running CSI");

		for(i = 0; i < 10; i++) {
			mipi_csi_tick();
		}

		acq_start(1);
		bogo_delay(10000);

		d_printf(D_ERROR, "Done");
	}
#endif
}

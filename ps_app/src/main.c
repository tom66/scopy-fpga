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

//uint8_t src_buffer[16384] __attribute__((aligned(32)));
//uint8_t dest_buffer[16384] __attribute__((aligned(32)));

int main()
{
	int res, i = 0;

	Xil_DCacheDisable();

	hal_init();
	acq_init();

	acq_hacks_init();
	acq_hacks_run();

    cleanup_platform();
}

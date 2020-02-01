/*
 * acquire.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 1 Feb 2020
 *      Author: Tom
 */

/*
 * Acquistion control engine.  This handles all oscilloscope acquisition functions
 * including memory buffer allocation, PL interface, AXI bus DMA and trigger setup.
 */

#include <stdint.h>
#include <stdbool.h>
#include <errno.h>

#include "acquire.h"
#include "fabric_config.h"

struct acq_state_t g_acq_state;

/*
 * Initialise the acquisitions engine.  Sets up default values in the structs.
 */
void acq_init()
{
	g_acq_state.state = ACQSTATE_UNINIT;
	g_acq_state.acq_first = NULL;
	g_acq_state.acq_current = NULL;
}

/*
 * Get the next allocation buffer, malloc'ing the required memory as required.
 * If this fails (e.g. no memory) a POSIX error is returned and values in `next`
 * are left unchanged; otherwise zero is returned.
 */
int acq_get_next_alloc(struct acq_buffer_t *next)
{
	struct acq_buffer_t work;

	/*
	 * Attempt to allocate the buffer, but make it ACQ_BUFFER_ALIGN bytes too big; this will
	 * allow us to shift the starting pointer if it isn't aligned as we desire.
	 */
	work.buff_real = malloc(g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN);

	if(work.buff_real == NULL) {
		return ACQERR_MALLOC_FAIL;
	}

	if((((uint32_t) work.buff_real) & ACQ_BUFFER_ALIGN_AMOD) != 0) {
		//work.
	}
}

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

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>

#include "hal.h"
#include "acquire.h"
#include "fabric_config.h"

struct acq_state_t g_acq_state;

/*
 * Interrupt handler for the DMA RX interrupt.
 */
void _acq_irq_rx_handler(void *cb)
{

}

/*
 * Initialise the acquisitions engine.  Sets up default values in the structs.
 */
void acq_init()
{
	int error;

	g_acq_state.state = ACQSTATE_UNINIT;
	g_acq_state.state = ACQSTATE_UNINIT;
	g_acq_state.acq_first = NULL;
	g_acq_state.acq_current = NULL;

	/*
	 * Setup the DMA engine.  Fail terribly if this can't be done.
	 */
	g_acq_state.dma_config = XAxiDma_LookupConfig(ACQ_DMA_ENGINE);
	error = XAxiDma_CfgInitialize(&g_acq_state.dma, g_acq_state.dma_config);

	if(error != XST_SUCCESS) {
		d_printf(D_ERR, "acquire: fatal: unable to initialise DMA engine! (error=%d)", error);
		exit(-1);
	}

	XScuGic_SetPriorityTriggerType(&g_hal.xscu_gic, ACQ_DMA_IRQ_RX, ACQ_DMA_IRQ_RX_PRIORITY, ACQ_DMA_IRQ_RX_TRIGGER);

	error = XScuGic_Connect(&g_hal.xscu_gic, ACQ_DMA_IRQ_RX, \
				(Xil_InterruptHandler)_acq_irq_rx_handler, XAxiDma_GetRxRing(&g_acq_state.dma));

	if(error != XST_SUCCESS) {
		d_printf(D_ERR, "acquire: fatal: unable to initialise DMA-IRQ engine! (error=%d)", error);
		exit(-1);
	}

	XScuGic_Enable(&g_hal.xscu_gic, ACQ_DMA_IRQ_RX);
}

/*
 * Get the next allocation buffer, malloc'ing the required memory as required.
 *
 * If this fails (e.g. no memory) ACQRES_MALLOC_FAIL is returned and values in `next`
 * are left unchanged; otherwise ACQRES_OK is returned.
 */
int acq_get_next_alloc(struct acq_buffer_t *next)
{
	uint32_t *ptr;

	/*
	 * Attempt to allocate the acquisiton buffer, but make it ACQ_BUFFER_ALIGN bytes too big; this will
	 * allow us to shift the starting pointer if it isn't aligned as we desire.
	 */
	ptr = malloc(g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN);

	if(ptr == NULL) {
		d_printf(D_ERR, "acquire: failed to allocate %d bytes for allocbuffer", g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN);
		return ACQRES_MALLOC_FAIL;
	}

	if((((uint32_t) work.buff_real) & ACQ_BUFFER_ALIGN_AMOD) != 0) {
		next->buff_acq = (uint32_t *)((((uint32_t) work.buff_real) + ACQ_BUFFER_ALIGN) & ACQ_BUFFER_ALIGN_AMOD);
	} else {
		next->buff_acq = ptr;
	}

	next->next = NULL;
	next->trigger_at = 0;
	next->idx = 0;
	next->buff_alloc = ptr;

	return ACQRES_OK;
}

/*
 * Append a new acquisition buffer to the linked list and set the current pointer to reference
 * this acquisition pointer.
 */
int acq_append_next_alloc()
{
	struct acq_buffer_t next;
	int res;

	res = acq_get_next_alloc(&next);
	if(res != ACQRES_OK) {
		return res;
	}

	/*
	 * Set current acquisition next pointer to this structure, increase the index
	 * to be one higher than the last index then move the current pointer to reference
	 * this structure.
	 */
	g_acq_state.acq_current->next = &next;
	g_acq_state.acq_current->next->idx = g_acq_state.acq_current->idx + 1;
	g_acq_state.acq_current = &next;

	return ACQRES_OK;
}

/*
 * Free all acquisition buffers safely.
 */
void acq_free_all_alloc()
{
	struct acq_buffer_t *next = g_acq_state.acq_first;
	struct acq_buffer_t *next_next;

	/*
	 * Iterate through the list of allocations starting at the first allocation,
	 * copy the next pointer, free the current allocation and repeat until we reach
	 * a NULL next pointer.
	 */
	while(next != NULL) {
		next_next = next->next;

		// Free the buffer *and* the acquisition structure
		free(next->buff_alloc);
		free(next);

		next = next_next;
	}

	g_acq_state.acq_first = NULL;
	g_acq_state.acq_current = NULL;
}

/*
 * Prepare a new triggered acquisition: allocate the first buffer, set up the state machine
 * and configure the fabric.
 *
 * @param	mode_flags		Mode flags of type ACQ_MODE used to configure the sampling engine.
 *
 * @param	bias_point		This parameter is a positive, negative or zero value:
 * 								- If positive, it is taken as the number of pre-trigger samples (e.g. 1/2 pre-trigger)
 * 								- If negative, it is taken as the number of post-trigger samples (e.g. 1/2 post-trigger)
 * 								- If zero, it configures the pre and post to be equal (1/2 post and 1/2 pre)
 *
 * 							For example: if configured with a bias point of +256 and a total_size of
 *
 * 							Note that the minimum pre- and post- trigger sizes must be obeyed, and they must be
 * 							appropriately aligned for the sample bit depth.
 *
 * @param	total_sz		Total acquisition size (number of samples to acquire)
 *
 * @param	num_acq			Total acquisition count (number of acquisitions to complete)
 */
int acq_prepare_triggered(uint32_t mode_flags, int32_t bias_point, uint32_t total_sz, uint32_t num_acq)
{
	uint32_t pre_sz, post_sz;
	uint32_t total_acq_sz;
	uint32_t demux;

	int error = 0, res;
	struct acq_buffer_t *first_parent;

	if(num_acq == 0 || total_sz == 0) {
		return ACQRES_PARAM_FAIL;
	}

	// Must have at least one of 8-bit, 12-bit or 14-bit set
	if(!(mode_flags & (ACQ_MODE_8BIT | ACQ_MODE_12BIT | ACQ_MODE_14BIT))) {
		return ACQRES_PARAM_FAIL;
	}

	// Must have at least one of 1ch, 2ch or 4ch set
	if(!(mode_flags & (ACQ_MODE_1CH | ACQ_MODE_2CH | ACQ_MODE_4CH))) {
		return ACQRES_PARAM_FAIL;
	}

	/*
	 * Compute the pre and post trigger buffer sizes, and verify that everything is
	 * lined up nicely along the required sample boundaries.
	 */
	if(bias_point == 0) {
		pre_sz = total_sz / 2;
		post_sz = total_sz / 2;
	} else if(bias_point < 0) {
		pre_sz = -bias_point;
		post_sz = total_sz - pre_sz;
	} else if(bias_point > 0) {
		post_sz = bias_point;
		pre_sz = total_sz - post_sz;
	}

	if(mode_flags & ACQ_MODE_8BIT) {
		if(post_sz & ACQ_SAMPLES_ALIGN_8B_AMOD)
			error = 1;

		if(pre_sz & ACQ_SAMPLES_ALIGN_8B_AMOD)
			error = 1;
	}

	if(mode_flags & (ACQ_MODE_12BIT | ACQ_MODE_14BIT)) {
		if(post_sz & ACQ_SAMPLES_ALIGN_PR_AMOD)
			error = 1;

		if(pre_sz & ACQ_SAMPLES_ALIGN_PR_AMOD)
			error = 1;
	}

	if(pre_sz < ACQ_MIN_PREPOST_SIZE || post_sz < ACQ_MIN_PREPOST_SIZE) {
		error = 1;
	}

	if(error) {
		d_printf(D_ERR, "acquire: pre or post buffers not aligned to required sample boundary (pre=%d post=%d total_sz=%d)", pre_sz, post_sz, total_sz);
		return ACQRES_ALIGN_FAIL;
	}

	/*
	 * Ensure that the total acquisition size doesn't exceed the available memory.  If
	 * that's OK, then free any existing buffers and create the first buffer.
	 */
	total_acq_sz = total_sz * num_acq;

	if(total_acq_sz > ACQ_TOTAL_MEMORY_AVAIL) {
		return ACQRES_TOTAL_MALLOC_FAIL;
	}

	g_acq_state.state = ACQSTATE_UNINIT;
	acq_free_all_alloc();

	first = malloc(sizeof(struct acq_buffer_t));

	if(first == NULL) {
		d_printf(D_ERR, "acquire: unable to allocate %d bytes for first entry in acquisition", sizeof(struct acq_buffer_t));
		return ACQRES_MALLOC_FAIL;
	}

	error = acq_get_next_alloc(&first);
	if(error != ACQRES_OK) {
		d_printf(D_ERR, "acquire: unable to get allocation for first buffer");
		return error;
	}

	g_acq_state.acq_first = first;
	g_acq_state.pre_buffsz = pre_sz;
	g_acq_state.post_buffsz = post_sz;
	g_acq_state.total_buffsz = total_sz;
	g_acq_state.num_acq = num_acq;
	g_acq_state.acq_mode_flags = acq_mode_flags | ACQ_MODE_TRIGGERED;
	g_acq_state.state = ACQSTATE_STOPPED;
	g_acq_state.sub_state = ACQSUBST_NONE;

	/*
	 * Initialise the fabric configuration.
	 */
	fabcfg_write(FAB_CFG_ACQ_SIZE, pre_sz);  // Acquisition initially starts at pre-trigger size;  trigger interrupt sets up post-trigger.

	if(acq_mode_flags & ACQ_MODE_8BIT) {
		demux |= ADCDEMUX_8BIT;
	} else if(acq_mode_flags & ACQ_MODE_12BIT) {
		demux |= ADCDEMUX_12BIT;
	} else if(acq_mode_flags & ACQ_MODE_14BIT) {
		demux |= ADCDEMUX_14BIT;
	}

	if(acq_mode_flags & ACQ_MODE_1CH) {
		demux |= ADCDEMUX_1CH;
	} else if(acq_mode_flags & ACQ_MODE_2CH) {
		demux |= ADCDEMUX_2CH;
	} else if(acq_mode_flags & ACQ_MODE_4CH) {
		demux |= ADCDEMUX_4CH;
	}

	fabcfg_write(FAB_CFG_ACQ_DEMUX_MODE, demux);

	/*
	 * Setup the interrupts and initialise, but do not start, the first AXIDMA
	 * transaction.
	 */

}

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

const char *acq_state_to_str[] = {
	"ACQSTATE_UNINIT", "ACQSTATE_STOPPED", "ACQSTATE_PREP", "ACQSTATE_WAIT_TRIG", "ACQSTATE_RUNNING", "ACQSTATE_DONE"
};

const char *acq_substate_to_str[] = {
	"ACQSUBST_NONE", "ACQSUBST_PRE_TRIG_FILL", "ACQSUBST_PRE_TRIG_WAIT", "ACQSUBST_POST_TRIG", "ACQSUBST_DONE_WAVE", "ACQSUBST_DONE_ALL"
};

// This block is in OCM to ensure fast access during DMA acquisition/interrupts.
struct acq_state_t g_acq_state; // __attribute__((section(".force_ocm")));

uint32_t test_buffsz = 768;

uint32_t test_sizes[1000];
uint32_t test_sizeptr = 0;

/*
 * Interrupt handler for the DMA RX interrupt.  Private.
 */
void _acq_irq_rx_handler(void *callback)
{
	XAxiDma_BdRing *bd_ring = (XAxiDma_BdRing *) callback;
	uint32_t status;
	int error;
	int i;

	//d_printf(D_WARN, "_acq_irq_rx_handler");
	g_acq_state.stats.num_irqs++;

	// Get status and ACK the interrupt.
	status = XAxiDma_BdRingGetIrq(bd_ring);
	XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_BdRingAckIrq(bd_ring, status);

	//d_printf(D_INFO, "L:%08x", XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_BUFFLEN_OFFSET));

	if(test_sizeptr < 1000) {
		test_sizes[test_sizeptr++] = XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_BUFFLEN_OFFSET);
	} else {
		d_printf(D_INFO, "** OVERFLOW of SUCCESS **");

		for(i = 0; i < test_sizeptr; i++) {
			d_printf(D_INFO, "L%4d:%08x(%d)", i, test_sizes[i], test_sizes[i]);
		}

		d_printf(D_INFO, "** eof error **");
		while(1) ;
	}

	/*
	 * Check for a DMA Error.  Error conditions force an increase of the error
	 * statistic counter and a reset of the state machine and DMA.
	 */
#if 1
	if(status & XAXIDMA_IRQ_ERROR_MASK) {
		//d_printf(D_WARN, "XAXIDMA_IRQ_ERROR_MASK");

		//d_printf(D_ERROR, "acquire: IRQ reports error (rxSR:0x%08x,txSR:0x%08x) during transfer (TLAST likely not asserted)", \
		//		XAxiDma_ReadReg(g_acq_state.dma.RegBase, XAXIDMA_SR_OFFSET + XAXIDMA_RX_OFFSET),
		//		XAxiDma_ReadReg(g_acq_state.dma.RegBase, XAXIDMA_SR_OFFSET + XAXIDMA_TX_OFFSET));
		for(i = 0; i < test_sizeptr; i++) {
			d_printf(D_INFO, "L%4d:%08x(%d)", i, test_sizes[i], test_sizes[i]);
		}

		d_printf(D_INFO, "** eof error **");
		test_sizeptr = 0;

		_acq_irq_error_dma();

		//return;
	}
#endif

	/*
	 * Check for IOC complete.  When an IOC event occurs it has occurred for one
	 * of three reasons:
	 *  - We have reached the number of words requested and no trigger has occurred
	 *    (when pre-triggering)
	 *  - We have received a trigger and we should start the post-trigger phase.
	 *  - We have finished the post-trigger phase.
	 *
	 * Note: we must deal with this quickly.  We have 512 word deep FIFO (~4K samples)
	 * which means we must start the new transaction within 4us (~2,700 CPU cycles)
	 * to avoid any sample loss.
	 */
	//d_printf(D_WARN, "%08x", status);

	if(status & XAXIDMA_IRQ_IOC_MASK) {
		//d_printf(D_WARN, "XAXIDMA_IRQ_IOC_MASK");

		switch(g_acq_state.sub_state) {
			// PRE_TRIG_FILL:  Fill up the buffer first, before accepting triggers.
			case ACQSUBST_PRE_TRIG_FILL:
				// Stop the AXI bus momentarily (TVALID will go low, TLAST will go high)
				XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);

				// Start the next transfer.
				error = XAxiDma_SimpleTransfer(&g_acq_state.dma, (uint32_t)g_acq_state.acq_current->buff_acq, \
						test_buffsz /*g_acq_state.pre_buffsz*/, XAXIDMA_DEVICE_TO_DMA);

				if(error != XST_SUCCESS) {
					_acq_irq_error_dma();
					d_printf(D_ERROR, "acquire: unable to start transfer in IRQ, error %d", error);
					return;
				}

				g_acq_state.sub_state = ACQSUBST_PRE_TRIG_WAIT;
				g_acq_state.state = ACQSTATE_WAIT_TRIG;

				// Demask triggers; start AXI bus transactions again.
				XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_MASK, 0);
				XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);

				// Statistics
				g_acq_state.stats.num_acq_total++;
				g_acq_state.stats.num_pre_total++;
				g_acq_state.stats.num_pre_fill_total++;
				break;

			case ACQSUBST_PRE_TRIG_WAIT:
				/*
				 * If a trigger has occurred (ACQ_EMIO_HAVE_TRIGGER is high) then jump address to the
				 * post-trigger buffer; if not, then go back to the start.
				 */
				if(XGpioPs_ReadPin(&g_hal.xgpio_ps, ACQ_EMIO_HAVE_TRIG)) {
					// Stop the AXI bus momentarily (TVALID will go low)
					XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);

					// Tell the PL that we want to use the 'B' channel acquisition depth now.
					XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_DEPTH_MUX, 1);

					// XXX: DMA transfers are in BYTE SIZES, so convert pointer to an integer before
					// adding the pre buffer offset.
					error = XAxiDma_SimpleTransfer(&g_acq_state.dma, \
							((uint32_t)g_acq_state.acq_current->buff_acq) + g_acq_state.pre_buffsz, \
							test_buffsz /*g_acq_state.post_buffsz*/, XAXIDMA_DEVICE_TO_DMA);

					if(error != XST_SUCCESS) {
						_acq_irq_error_dma();
						d_printf(D_ERROR, "acquire: unable to start transfer in IRQ, error %d", error);
						return;
					}

					// Start the AXI bus again (TVALID will go low)
					XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);

					/*
					 * We can relax a bit here. The transfer is now running, so record the address
					 * that the trigger occurred at from the fabric.
					 */
					fabcfg_commit();
					g_acq_state.acq_current->trigger_at = fabcfg_read(FAB_CFG_ACQ_TRIGGER_PTR);
					g_acq_state.sub_state = ACQSUBST_POST_TRIG;
					g_acq_state.stats.num_samples += g_acq_state.acq_current->trigger_at;
				} else {
					// No trigger. So just re-arm the pre-trigger, starting from the beginning of
					// the acquisition buffer.
					XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);
					error = XAxiDma_SimpleTransfer(&g_acq_state.dma, (uint32_t)g_acq_state.acq_current->buff_acq, \
							test_buffsz /*g_acq_state.pre_buffsz*/, XAXIDMA_DEVICE_TO_DMA);

					if(error != XST_SUCCESS) {
						_acq_irq_error_dma();
						d_printf(D_ERROR, "acquire: unable to start transfer in IRQ, error %d", error);
						return;
					}

					XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);
				}

				// Statistics
				g_acq_state.stats.num_acq_total++;
				g_acq_state.stats.num_pre_total++;
				break;

			case ACQSUBST_POST_TRIG:
				/*
				 * Trigger done.  Move to the next waveform, allocating the next buffer and
				 * re-arming the trigger.
				 *
				 * Any hold-off is controlled by the trigger engine.
				 */
				g_acq_state.sub_state = ACQSUBST_DONE_WAVE;
				g_acq_state.state = ACQSTATE_RUNNING;

				// If DONE signal not present at end of acquisition, then there is a fault.
				if(!XGpioPs_ReadPin(&g_hal.xgpio_ps, ACQ_EMIO_DONE)) {
					d_printf(D_ERROR, "acquire: PL reports not done, but DMA complete!");
					_acq_irq_error_dma();
					return;
				}

				XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_MASK, 1);  	// Triggers masked
				XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_RUN, 0);  		// Acquisition idled
				XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);		// AXI bus activity paused

				// Allocate the next buffer if we haven't filled the total waveform count.
				g_acq_state.num_acq_made++;
				if(g_acq_state.num_acq_made == g_acq_state.num_acq_request) {
					g_acq_state.sub_state = ACQSUBST_DONE_ALL;
					g_acq_state.state = ACQSTATE_STOPPED;
				} else {
					acq_append_next_alloc();
					error = acq_start();

					if(error != ACQRES_OK) {
						d_printf(D_ERROR, "acquire: unable to start next transfer, error %d", error);
						_acq_irq_error_dma();
						return;
					}
				}
				break;
		}
	}

}

/*
 * Handler for DMA error conditions in IRQs.
 */
void _acq_irq_error_dma()
{
	g_acq_state.stats.num_err_total++;
	g_acq_state.state = ACQSTATE_UNINIT;
	g_acq_state.sub_state = ACQSUBST_NONE;
	//XAxiDma_Reset(&g_acq_state.dma);
	return;
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
		d_printf(D_ERROR, "acquire: fatal: unable to initialise DMA engine! (error=%d)", error);
		exit(-1);
	}

	d_printf(D_INFO, "acquire: DMA initialised");

	d_printf(D_INFO, "acquire: Waiting for DMA reset to complete");

	XAxiDma_Reset(&g_acq_state.dma);
	while(!XAxiDma_ResetIsDone(&g_acq_state.dma)) ;

	d_printf(D_INFO, "acquire: DMA reset OK");

	/*
	 * Setup the SCUGIC interrupt controller.  Fail terribly if this can't be done.
	 */
	XScuGic_SetPriorityTriggerType(&g_hal.xscu_gic, ACQ_DMA_IRQ_RX, ACQ_DMA_IRQ_RX_PRIORITY, ACQ_DMA_IRQ_RX_TRIGGER);

	error = XScuGic_Connect(&g_hal.xscu_gic, ACQ_DMA_IRQ_RX, \
				(Xil_InterruptHandler)_acq_irq_rx_handler, XAxiDma_GetRxRing(&g_acq_state.dma));

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "acquire: fatal: unable to initialise DMA-IRQ engine! (error=%d)", error);
		exit(-1);
	}

	XScuGic_Enable(&g_hal.xscu_gic, ACQ_DMA_IRQ_RX);

	d_printf(D_INFO, "acquire: SCUGIC configured");

	/*
	 * Setup the required EMIOs between the PS and PL.
	 *
	 *   - ACQ_EMIO_RUN:			Signal to PL to indicate acquisition should run
	 *   - ACQ_EMIO_ABORT:			Signal to PL to stop acquisition (send TLAST)
	 *   - ACQ_EMIO_DONE:			Signal to PS to indicate acquisition is done (TLAST sent)
	 *   - ACQ_EMIO_TRIG_MASK:		Signal to PL to ignore trigger and only generate TLAST after #sample count is reached
	 *   - ACQ_EMIO_FIFO_RESET:		Signal to PL to reset FIFO contents
	 *   - ACQ_EMIO_HAVE_TRIG:		Signal to PS to indicate a trigger was received and this was cause of TLAST generation
	 *   - ACQ_EMIO_TRIG_RESET:		Signal to PL to reset and rearm trigger
	 *   - ACQ_EMIO_DEPTH_MUX:		Signal to PL to indicate which acq. counter to use ('A' = 0, 'B' = 1)
	 *   - ACQ_EMIO_AXI_RUN:		Signal to PL that is AND'ed to create read_en for mux (from AXI TREADY and !empty);
	 *   							this is useful to pause AXI data generation until all parameters are configured.
	 *   - ACQ_EMIO_ADC_VALID:		Signal to PL, currently ignored, that will control write_en of FIFO, pausing data
	 *   							reception into FIFO until acquisition is ready (e.g. if ADC not yet initialised.)
	 */
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_RUN, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_RUN, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_ABORT, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_ABORT, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_MASK, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_MASK, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_RESET, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_RESET, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_RESET, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_RESET, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_DEPTH_MUX, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_DEPTH_MUX, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, ACQ_EMIO_ADC_VALID, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_ADC_VALID, 1);

	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_DONE, 0);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_HAVE_TRIG, 0);

	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_RUN, 0);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_DONE, 0);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_MASK, 1);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_RESET, 0);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_RESET, 0);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_DEPTH_MUX, 0);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);
	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_ADC_VALID, 0);

	d_printf(D_INFO, "acquire: engine initialised");
}

/*
 * Get the next allocation buffer, malloc'ing the required memory as required.
 *
 * If this fails (e.g. no memory) ACQRES_MALLOC_FAIL is returned and values in `next`
 * are left unchanged; otherwise ACQRES_OK is returned.
 */
int acq_get_next_alloc(struct acq_buffer_t *next)
{
	struct acq_buffer_t work;

	/*
	 * Attempt to allocate the acquisition buffer, but make it ACQ_BUFFER_ALIGN bytes too big; this will
	 * allow us to shift the starting pointer if it isn't aligned as we require.
	 *
	 * TODO: Consider using _alloc_aligned.
	 */
	work.buff_alloc = malloc(g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN);

	if(work.buff_alloc == NULL) {
		d_printf(D_ERROR, "acquire: failed to allocate %d bytes for allocbuffer", g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN);
		g_acq_state.stats.num_alloc_err_total++;
		return ACQRES_MALLOC_FAIL;
	}

	if((((uint32_t) work.buff_alloc) & ACQ_BUFFER_ALIGN_AMOD) != 0) {
		next->buff_acq = (uint32_t *)((((uint32_t) work.buff_alloc) + ACQ_BUFFER_ALIGN) & ~(ACQ_BUFFER_ALIGN_AMOD));
	} else {
		next->buff_acq = work.buff_alloc;
	}

	d_printf(D_EXINFO, "acquire: next->buff_acq = 0x%08x, work.buff_alloc [malloc] = 0x%08x", next->buff_acq, work.buff_alloc);

	next->trigger_at = 0;
	next->idx = 0;
	next->buff_alloc = work.buff_alloc;
	next->next = NULL;

	g_acq_state.stats.num_alloc_total++;

	return ACQRES_OK;
}

/*
 * Append a new acquisition buffer to the linked list and set the current pointer to reference
 * this acquisition pointer.
 */
int acq_append_next_alloc()
{
	struct acq_buffer_t *next;
	int res;

	next = malloc(sizeof(struct acq_buffer_t));

	/*
	 * Allocate the struct that stores the buffer info first.  This is
	 * just a few bytes, but could fail if we are near the memory limit.
	 */
	if(next == 0) {
		d_printf(D_ERROR, "acquire: failed to allocate %d bytes for alloc structure", sizeof(struct acq_buffer_t));
		g_acq_state.stats.num_alloc_err_total++;
		return ACQRES_MALLOC_FAIL;
	}

	/*
	 * Then allocate the next buffer to be chained onto the list.
	 */
	res = acq_get_next_alloc(next);
	if(res != ACQRES_OK) {
		return res;
	}

	/*
	 * Set current acquisition next pointer to this structure, increase the index
	 * to be one higher than the last index then move the current pointer to reference
	 * this structure.
	 */
	g_acq_state.acq_current->next = next;
	g_acq_state.acq_current->next->idx = g_acq_state.acq_current->idx + 1;
	g_acq_state.acq_current = next;
	g_acq_state.stats.num_alloc_total++;

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
	struct acq_buffer_t *first;
	uint32_t pre_sz, post_sz, pre_sampct, post_sampct;
	uint32_t total_acq_sz;
	uint32_t align_mask;
	uint32_t demux;
	int error = 0;

	// How can we acquire an empty buffer of no waveforms?
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

	// Must not have "CONTINUOUS" or "TRIGGERED" set
	if(mode_flags & (ACQ_MODE_TRIGGERED | ACQ_MODE_CONTINUOUS)) {
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

	error = 0;

	if(mode_flags & ACQ_MODE_8BIT) {
		align_mask = ACQ_SAMPLES_ALIGN_8B_AMOD;

		if(post_sz & ACQ_SAMPLES_ALIGN_8B_AMOD) {
			error = 1;
		}

		if(pre_sz & ACQ_SAMPLES_ALIGN_8B_AMOD) {
			error = 1;
		}
	}

	if(mode_flags & (ACQ_MODE_12BIT | ACQ_MODE_14BIT)) {
		align_mask = ACQ_SAMPLES_ALIGN_PR_AMOD;

		if(post_sz & ACQ_SAMPLES_ALIGN_PR_AMOD) {
			error = 1;
		}

		if(pre_sz & ACQ_SAMPLES_ALIGN_PR_AMOD) {
			error = 1;
		}
	}

	if(pre_sz < ACQ_MIN_PREPOST_SIZE || post_sz < ACQ_MIN_PREPOST_SIZE) {
		error = 1;
	}

	if(error) {
		d_printf(D_ERROR, "acquire: pre or post buffers not aligned to required sample boundary or too small (pre=%d post=%d total_sz=%d req_align_mask=0x%08x test=0x%08x)", \
				pre_sz, post_sz, total_sz, align_mask, post_sz & ACQ_SAMPLES_ALIGN_8B_AMOD);
		return ACQRES_ALIGN_FAIL;
	}

	// Scale total_sz and pre/post sizes, if appropriate
	if(mode_flags & (ACQ_MODE_12BIT | ACQ_MODE_14BIT)) {
		// 4 samples per readout (64-bit)
		total_sz *= 4;
		pre_sampct = pre_sz;
		post_sampct = post_sz;
		post_sz *= 4;
		pre_sz *= 4;
	} else if(mode_flags & (ACQ_MODE_8BIT)) {
		// 8 samples per readout (64-bit)
		total_sz *= 8;
		pre_sampct = pre_sz;
		post_sampct = post_sz;
		post_sz *= 8;
		pre_sz *= 8;
	}

	/*
	 * Ensure that the total acquisition size doesn't exceed the available memory.  If
	 * that's OK, then free any existing buffers and create the first buffer.  Include an
	 * allocation penalty.
	 */
	total_acq_sz = (total_sz + ACQ_BUFFER_ALIGN) * num_acq;

	if(total_acq_sz > ACQ_TOTAL_MEMORY_AVAIL) {
		return ACQRES_TOTAL_MALLOC_FAIL;
	}

	g_acq_state.state = ACQSTATE_UNINIT;
	acq_free_all_alloc();

	first = malloc(sizeof(struct acq_buffer_t));

	if(first == NULL) {
		d_printf(D_ERROR, "acquire: unable to allocate %d bytes for first entry in acquisition", sizeof(struct acq_buffer_t));
		return ACQRES_MALLOC_FAIL;
	}

	error = acq_get_next_alloc(first);
	if(error != ACQRES_OK) {
		d_printf(D_ERROR, "acquire: unable to get allocation for first buffer");
		return error;
	}

	g_acq_state.acq_first = first;
	g_acq_state.acq_current = first;
	g_acq_state.pre_buffsz = pre_sz;
	g_acq_state.post_buffsz = post_sz;
	g_acq_state.pre_sampct = pre_sampct;
	g_acq_state.post_sampct = post_sampct;
	g_acq_state.total_buffsz = total_sz;
	g_acq_state.num_acq_request = num_acq;
	g_acq_state.num_acq_made = 0;
	g_acq_state.acq_mode_flags = mode_flags | ACQ_MODE_TRIGGERED;
	g_acq_state.state = ACQSTATE_STOPPED;
	g_acq_state.sub_state = ACQSUBST_NONE;

	/*
	 * Initialise the fabric configuration.
	 * Sample counters are off by 1 due to fabric design, so offset them here.
	 */
	fabcfg_write(FAB_CFG_ACQ_SIZE_A, g_acq_state.pre_sampct - 1);
	fabcfg_write(FAB_CFG_ACQ_SIZE_B, g_acq_state.post_sampct - 1);
	demux = 0;

	if(mode_flags & ACQ_MODE_8BIT) {
		demux |= ADCDEMUX_8BIT;
	} else if(mode_flags & ACQ_MODE_12BIT) {
		demux |= ADCDEMUX_12BIT;
	} else if(mode_flags & ACQ_MODE_14BIT) {
		demux |= ADCDEMUX_14BIT;
	}

	if(mode_flags & ACQ_MODE_1CH) {
		demux |= ADCDEMUX_1CH;
	} else if(mode_flags & ACQ_MODE_2CH) {
		demux |= ADCDEMUX_2CH;
	} else if(mode_flags & ACQ_MODE_4CH) {
		demux |= ADCDEMUX_4CH;
	}

	g_acq_state.demux_reg = demux;
	fabcfg_write(FAB_CFG_ACQ_DEMUX_MODE, demux);
	fabcfg_commit();

	return ACQRES_OK;
}

/*
 * Returns TRUE if the requested acquisition is complete.
 */
bool acq_is_done()
{
	return (g_acq_state.state == ACQSTATE_DONE);
}

/*
 * Start the acquisition engine.
 *
 * @return	ACQRES_NOT_INITIALISED if the transfer has not yet been initialised;
 * 			ACQRES_NOT_STOPPED if acquisition is currently running (must stop before starting);
 * 			ACQRES_NOT_IMPLEMENTED if the mode is not presently supported;
 * 			ACQRES_DMA_FAIL if DMA task could not be started;
 * 			ACQRES_SUCCESS if stop signal sent.
 */
int acq_start()
{
	int error;

	if(g_acq_state.state == ACQSTATE_UNINIT) {
		return ACQRES_NOT_INITIALISED;
	}

	if(!(g_acq_state.state == ACQSTATE_STOPPED || g_acq_state.state == ACQSTATE_DONE)) {
		return ACQRES_NOT_STOPPED;
	}

	if(g_acq_state.acq_mode_flags & ACQ_MODE_TRIGGERED) {
		// Disable the interrupt then re-enable it, to reset it.
		// TODO: Determine if this is strictly necessary!
		//XAxiDma_IntrDisable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
		//XAxiDma_IntrEnable(&g_acq_state.dma, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);
		//XAxiDma_IntrEnable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
		//XAxiDma_IntrDisable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
		XAxiDma_IntrEnable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

		// Set delay and coalesce to minimum values
		//XAxiDma_WriteReg(&g_acq_state.dma.RegBase, XAXIDMA_CR_OFFSET, \
				(XAxiDma_ReadReg(&g_acq_state.dma.RegBase, XAXIDMA_CR_OFFSET) | (0x0001 << XAXIDMA_COALESCE_SHIFT)));

		//XAxiDma_IntrDisable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
		//XAxiDma_IntrEnable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

		/*
		 * We must invalidate the cache line before starting the transfer.  This
		 * invalidation restricts us to 32-byte aligned pages.  Then we can start
		 * the AXI transfer.
		 */
		d_printf(D_WARN, "XAxiDmaBusy=%d", XAxiDma_Busy(&g_acq_state.dma, XAXIDMA_DEVICE_TO_DMA));
		d_printf(D_WARN, "SR_TX_Reg=0x%08x", XAxiDma_ReadReg(g_acq_state.dma.RegBase, XAXIDMA_SR_OFFSET));
		d_printf(D_WARN, "SR_RX_Reg=0x%08x", XAxiDma_ReadReg(g_acq_state.dma.RegBase, XAXIDMA_SR_OFFSET + XAXIDMA_RX_OFFSET));
		d_printf(D_WARN, "CR_TX_Reg=0x%08x", XAxiDma_ReadReg(g_acq_state.dma.RegBase, XAXIDMA_CR_OFFSET));
		d_printf(D_WARN, "CR_RX_Reg=0x%08x", XAxiDma_ReadReg(g_acq_state.dma.RegBase, XAXIDMA_CR_OFFSET + XAXIDMA_RX_OFFSET));

		Xil_DCacheInvalidateRange((INTPTR)g_acq_state.acq_current->buff_acq, g_acq_state.total_buffsz);
		error = XAxiDma_SimpleTransfer(&g_acq_state.dma, (uint32_t)g_acq_state.acq_current->buff_acq, \
				test_buffsz /*g_acq_state.pre_buffsz*/, XAXIDMA_DEVICE_TO_DMA);

		if(error != XST_SUCCESS) {
			d_printf(D_ERROR, "acquire: unable to start transfer, error %d", error);
			return ACQRES_DMA_FAIL;
		}

		d_printf(D_EXINFO, "align:            0x%08x", g_acq_state.dma.TxBdRing.DataWidth);
		d_printf(D_EXINFO, "length:           0x%08x", g_acq_state.pre_buffsz);
		d_printf(D_EXINFO, "max_length:       0x%08x", g_acq_state.dma.TxBdRing.MaxTransferLen);
		d_printf(D_EXINFO, "current_buff_acq: 0x%08x", (INTPTR)g_acq_state.acq_current->buff_acq);
		d_printf(D_EXINFO, "total_buffsz:     0x%08x", g_acq_state.total_buffsz);

		// Set the state machine
		g_acq_state.state = ACQSTATE_PREP;
		g_acq_state.sub_state = ACQSUBST_PRE_TRIG_FILL;

		// Start on 'A' mux: pre-trigger
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_DEPTH_MUX, 0);

		// Drive FIFO reset signal, just long to ensure a reset of the FIFO occurs.
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_RESET, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_RESET, 0);

		// Send the EMIO signal to start the acquisition, with trigger masked.  Then we wait for an IRQ.
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_ABORT, 0);
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_RUN, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_TRIG_MASK, 1);
		//XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 1);		// AXI bus activity enabled

		emio_fast_write(ACQ_EMIO_AXI_RUN, 1);

		return ACQRES_OK;
	} else {
		return ACQRES_NOT_IMPLEMENTED;
	}
}

/*
 * Send a force-stop command to the fabric.  The acquisition will stop
 * very shortly after this command is sent, but do note that this is not a
 * real-time task and so the actual stop time of the acquisition is not guaranteed.
 *
 * @return	ACQRES_DMA_FAIL if DMA task could not be stopped;
 * 			ACQRES_SUCCESS if stop signal sent.
 */
int acq_force_stop()
{
	int error;

	error = XAxiDma_Pause(&g_acq_state.dma);

	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_AXI_RUN, 0);		// AXI bus activity stopped

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "acquire: unable to start transfer, error %d", error);
		return ACQRES_DMA_FAIL;
	}

	XGpioPs_WritePin(&g_hal.xgpio_ps, ACQ_EMIO_ABORT, 1);
	g_acq_state.state = ACQSTATE_STOPPED;

	return ACQRES_OK;
}

/*
 * Dump state of acquire engine for debugging purposes.
 */
void acq_debug_dump()
{
	void *sp = NULL;

	d_printf(D_INFO, "** Acquisition State (g_acq_state: 0x%08x) **", &g_acq_state);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "I think the stack is at 0x%08x or thereabouts", (void*)&sp);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "acq_mode_flags        = 0x%08x", g_acq_state.acq_mode_flags);
	d_printf(D_INFO, "state                 = %d [%s]", g_acq_state.state, acq_state_to_str[g_acq_state.state]);
	d_printf(D_INFO, "sub_state             = %d [%s]", g_acq_state.sub_state, acq_substate_to_str[g_acq_state.sub_state]);
	d_printf(D_INFO, "acq_current           = 0x%08x", g_acq_state.acq_current);
	d_printf(D_INFO, "acq_first             = 0x%08x", g_acq_state.acq_first);
	d_printf(D_INFO, "dma                   = 0x%08x", g_acq_state.dma);
	d_printf(D_INFO, "dma_config            = 0x%08x", g_acq_state.dma_config);
	d_printf(D_INFO, "demux_reg             = 0x%02x", g_acq_state.demux_reg);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "pre_buffsz            = %d bytes (0x%08x)", g_acq_state.pre_buffsz, g_acq_state.pre_buffsz);
	d_printf(D_INFO, "post_buffsz           = %d bytes (0x%08x)", g_acq_state.post_buffsz, g_acq_state.post_buffsz);
	d_printf(D_INFO, "total_buffsz          = %d bytes (0x%08x)", g_acq_state.total_buffsz, g_acq_state.total_buffsz);
	d_printf(D_INFO, "pre_sampct            = %d wavepoints", g_acq_state.pre_sampct);
	d_printf(D_INFO, "post_sampct           = %d wavepoints", g_acq_state.post_sampct);
	d_printf(D_INFO, "num_acq_request       = %d waves", g_acq_state.num_acq_request);
	d_printf(D_INFO, "num_acq_made          = %d waves", g_acq_state.num_acq_made);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "s.num_acq_total       = %d", g_acq_state.stats.num_acq_total);
	d_printf(D_INFO, "s.num_alloc_err_total = %d", g_acq_state.stats.num_alloc_err_total);
	d_printf(D_INFO, "s.num_alloc_total     = %d", g_acq_state.stats.num_alloc_total);
	d_printf(D_INFO, "s.num_err_total       = %d", g_acq_state.stats.num_err_total);
	d_printf(D_INFO, "s.num_post_total      = %d", g_acq_state.stats.num_post_total);
	d_printf(D_INFO, "s.num_pre_total       = %d", g_acq_state.stats.num_pre_total);
	d_printf(D_INFO, "s.num_pre_fill_total  = %d", g_acq_state.stats.num_pre_fill_total);
	d_printf(D_INFO, "s.num_samples         = %d", g_acq_state.stats.num_samples);
	d_printf(D_INFO, "s.num_irqs            = %d", g_acq_state.stats.num_irqs);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "** End **");
}

/*
 * Dump contents of buffer in active acquisition.
 *
 * @param	prepost		0 = pre, 1 = post
 */
void acq_debug_dump_wavedata()
{
	uint32_t sz;
	uint32_t i;

	if(g_acq_state.sub_state == ACQSUBST_PRE_TRIG_FILL || g_acq_state.sub_state == ACQSUBST_PRE_TRIG_WAIT) {
		sz = g_acq_state.pre_buffsz;
		d_printf(D_INFO, "** Waveform Data (Pre-Trigger) -- %d bytes **", g_acq_state.pre_buffsz);
	} else {
		sz = g_acq_state.post_buffsz;
		d_printf(D_INFO, "** Waveform Data (Post-Trigger) -- %d bytes **", g_acq_state.pre_buffsz);
	}

	sz /= 4;

	for(i = 0; i <= sz; i += 2) {
		d_printf(D_INFO, "0x%08x: 0x%08x 0x%08x", i * 4, *(g_acq_state.acq_current->buff_acq + i), *(g_acq_state.acq_current->buff_acq + i + 1));
	}

	d_printf(D_INFO, "** End of Waveform Data **");
}

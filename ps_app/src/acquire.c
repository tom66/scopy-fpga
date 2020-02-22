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
#include <math.h>
#include <errno.h>
#include <malloc.h>

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

uint32_t test_sizes[1000];
uint32_t test_sizeptr = 0;

/*
 * Interrupt handler for the DMA RX interrupt.  Private.
 */
void _acq_irq_rx_handler(void *callback)
{
	XAxiDma_BdRing *bd_ring = (XAxiDma_BdRing *) callback;
	uint32_t status, addr;
	int error;
	int i;

	//d_printf(D_WARN, "_acq_irq_rx_handler");
	g_acq_state.stats.num_irqs++;

	// Get status and ACK the interrupt.
	status = XAxiDma_BdRingGetIrq(bd_ring);
	XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_BdRingAckIrq(bd_ring, status);

	//d_printf(D_INFO, "L:%08x", XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_BUFFLEN_OFFSET));

#if 0
	if(test_sizeptr < 1000) {
		test_sizes[test_sizeptr++] = XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_BUFFLEN_OFFSET);
	} else {
		d_printf(D_INFO, "** OVERFLOW of SUCCESS **");

		for(i = 0; i < test_sizeptr; i++) {
			d_printf(D_INFO, "L%4d:%08x(%d)", i, test_sizes[i], test_sizes[i]);
		}

		test_sizeptr = 0;
	}
#endif

	/*
	 * Check for a DMA Error.  Error conditions force an increase of the error
	 * statistic counter and a reset of the state machine and DMA.
	 */
	if(status & XAXIDMA_IRQ_ERROR_MASK) {
		_acq_irq_error_dma();
		return;
	}

	/*
	 * Check for IOC complete.  When an IOC event occurs it has occurred for one
	 * of three reasons:
	 *  - We have reached the number of words requested and no trigger has occurred
	 *    (when pre-triggering)
	 *  - We have received a trigger and we should start the post-trigger phase.
	 *  - We have finished the post-trigger phase.
	 *
	 * Note: we must deal with this quickly.  We have 2048 word deep FIFO (~16K samples)
	 * which means we must start the new transaction within 16us (~10,800 CPU cycles)
	 * to avoid any sample loss.  Realistically, the faster the interrupt, the faster
	 * the waveform rate of the instrument and the smaller a sample buffer that
	 * can be used.
	 */
	if(status & XAXIDMA_IRQ_IOC_MASK) {
		switch(g_acq_state.sub_state) {
			// PRE_TRIG_FILL:  Fill up the buffer first, before accepting triggers.
			case ACQSUBST_PRE_TRIG_FILL:
				// Force depth 'A'
				emio_fast_write(ACQ_EMIO_DEPTH_MUX, 0);

				// Stop the AXI bus momentarily (TVALID will go low, TLAST will go high)
				emio_fast_write(ACQ_EMIO_AXI_RUN, 0);

				// Start the next transfer.
				error = XAxiDma_SimpleTransfer(&g_acq_state.dma, (uint32_t)g_acq_state.acq_current->buff_acq, \
						g_acq_state.pre_buffsz, XAXIDMA_DEVICE_TO_DMA);

				if(error != XST_SUCCESS) {
					_acq_irq_error_dma();
					d_printf(D_ERROR, "acquire: unable to start transfer in IRQ, error %d", error);
					return;
				}

				/*
				 * If the FIFO is full, don't allow us to exit this state.  Instead, send a reset pulse
				 * to the FIFO and revert back to PRE_TRIG_FILL.
				 */
				if(emio_fast_read(ACQ_EMIO_FIFO_OVERRUN)) {
					_acq_reset_PL_fifo();
					g_acq_state.sub_state = ACQSUBST_PRE_TRIG_FILL;
					g_acq_state.state = ACQSTATE_PREP;
					g_acq_state.stats.num_fifo_full++;
				} else {
					g_acq_state.sub_state = ACQSUBST_PRE_TRIG_WAIT;
					g_acq_state.state = ACQSTATE_WAIT_TRIG;
				}

				// Demask triggers; start AXI bus transactions again.
				emio_fast_write(ACQ_EMIO_TRIG_MASK, 0);
				emio_fast_write(ACQ_EMIO_AXI_RUN, 1);

				// Statistics
				g_acq_state.stats.num_samples += g_acq_state.pre_buffsz;
				g_acq_state.stats.num_samples_raw += g_acq_state.pre_buffsz;
				g_acq_state.stats.num_acq_total++;
				g_acq_state.stats.num_pre_total++;
				g_acq_state.stats.num_pre_fill_total++;
				break;

			case ACQSUBST_PRE_TRIG_WAIT:
				/*
				 * If a trigger has occurred (ACQ_EMIO_HAVE_TRIGGER is high) then jump address to the
				 * post-trigger buffer; if not, then go back to the start.
				 */
				if(emio_fast_read(ACQ_EMIO_HAVE_TRIG)) {
					// Tell the PL that we want to use the 'B' channel acquisition depth now.
					emio_fast_write(ACQ_EMIO_DEPTH_MUX, 1);

					// Stop the AXI bus momentarily (TVALID will go low)
					emio_fast_write(ACQ_EMIO_AXI_RUN, 0);

					// Start the fabric sync process (background task)
					fabcfg_fastcfg_start();

					/*
					 * If the FIFO is full, capture the data but set the discard flag.
					 */
					if(emio_fast_read(ACQ_EMIO_FIFO_OVERRUN)) {
						g_acq_state.acq_current->flags |= ACQBUF_FLAG_PKT_OVERRUN;
						g_acq_state.stats.num_fifo_full++;
					}

					/*
					 * Compute the address of the next DMA transfer and set it up.
					 */
					addr = ((uint32_t)g_acq_state.acq_current->buff_acq) + g_acq_state.pre_buffsz;

					error = XAxiDma_SimpleTransfer(&g_acq_state.dma, addr, \
							g_acq_state.post_buffsz, XAXIDMA_DEVICE_TO_DMA);

					if(error != XST_SUCCESS) {
						_acq_irq_error_dma();
						d_printf(D_ERROR, "acquire: unable to start transfer in IRQ, error %d", error);
						return;
					}

					/*
					 * The transfer is now running, so record the address that the trigger occurred at
					 * from the fabric.
					 */
					fabcfg_fastcfg_wait();
					g_acq_state.acq_current->trigger_at = fabcfg_read(FAB_CFG_ACQ_TRIGGER_PTR);

					// Start the AXI bus again
					emio_fast_write(ACQ_EMIO_AXI_RUN, 1);

					g_acq_state.sub_state = ACQSUBST_POST_TRIG;
					g_acq_state.stats.num_samples_raw += g_acq_state.acq_current->trigger_at;
					g_acq_state.stats.num_samples += g_acq_state.acq_current->trigger_at;
				} else {
					// No trigger. So just re-arm the pre-trigger, starting from the beginning of
					// the acquisition buffer.
					emio_fast_write(ACQ_EMIO_AXI_RUN, 0);
					_acq_wait_for_ndone();

					// If the FIFO is full, capture the data but set the discard flag.
					// XXX: Since there's no trigger consider a FIFO reset instead?
					if(emio_fast_read(ACQ_EMIO_FIFO_OVERRUN)) {
						_acq_reset_PL_fifo();
						g_acq_state.acq_current->flags |= ACQBUF_FLAG_PKT_OVERRUN;
						g_acq_state.stats.num_fifo_full++;
					}

					error = XAxiDma_SimpleTransfer(&g_acq_state.dma, g_acq_state.acq_current->buff_acq, \
							g_acq_state.pre_buffsz, XAXIDMA_DEVICE_TO_DMA);

					if(error != XST_SUCCESS) {
						_acq_irq_error_dma();
						d_printf(D_ERROR, "acquire: unable to start transfer in IRQ, error %d", error);
						return;
					}

					// Reset the trigger
					_acq_reset_trigger();

					emio_fast_write(ACQ_EMIO_AXI_RUN, 1);
					g_acq_state.stats.num_samples_raw += g_acq_state.pre_buffsz;
				}

				// Statistics
				g_acq_state.stats.num_acq_total++;
				g_acq_state.stats.num_pre_total++;
				break;

			case ACQSUBST_POST_TRIG:
				/*
				 * Acquisition done.  Move to the next waveform and re-arm the trigger.
				 *
				 * Any hold-off is controlled by the trigger engine.
				 */
				// If DONE signal not present at end of acquisition, then there is a fault.
				if(!emio_fast_read(ACQ_EMIO_DONE)) {
					d_printf(D_ERROR, "acquire: PL reports not done, but DMA complete!");
					_acq_irq_error_dma();
					return;
				}

				emio_fast_write(ACQ_EMIO_TRIG_MASK, 1);
				emio_fast_write(ACQ_EMIO_RUN, 0);
				emio_fast_write(ACQ_EMIO_AXI_RUN, 0);

				g_acq_state.sub_state = ACQSUBST_DONE_WAVE;
				g_acq_state.state = ACQSTATE_RUNNING;

				g_acq_state.stats.num_samples_raw += g_acq_state.post_buffsz;
				g_acq_state.acq_current->flags |= ACQBUF_FLAG_PKT_DONE;

				/*
				 * If the OVERRUN flag was set, then this waveform should be discarded as it is not valid.  The
				 * acquisition restarts on the same wave.
				 */
				if(g_acq_state.acq_current->flags & ACQBUF_FLAG_PKT_OVERRUN) {
					//d_printf(D_ERROR, "acquire: packet overrun at done");
					g_acq_state.stats.num_fifo_pkt_dscd++;

					// Start a new transfer, but without allocating a new buffer or increasing the waveform count
					_acq_reset_PL_fifo();
					error = acq_start();

					if(error != ACQRES_OK) {
						d_printf(D_ERROR, "acquire: unable to reset current transfer, error %d", error);
						_acq_irq_error_dma();
						return;
					}
				} else {
					// Move to the next buffer if we haven't filled the total waveform count.
					g_acq_state.num_acq_made++;
					g_acq_state.stats.num_samples += g_acq_state.post_buffsz;

					if(g_acq_state.num_acq_made == g_acq_state.num_acq_request) {
						g_acq_state.sub_state = ACQSUBST_DONE_ALL;
						g_acq_state.state = ACQSTATE_DONE;
					} else {
						if(g_acq_state.acq_current->next != NULL) {
							g_acq_state.acq_current = g_acq_state.acq_current->next;
							error = acq_start();

							if(error != ACQRES_OK) {
								d_printf(D_ERROR, "acquire: unable to start next transfer, error %d", error);
								_acq_irq_error_dma();
								return;
							}
						} else {
							d_printf(D_ERROR, "acquire: NULL deref trying to move to next wavebuffer; something's wrong!");
						}
					}
				}

				g_acq_state.stats.num_post_total++;
				break;
		}
	}

	// d_printf(D_INFO, "irq_end (%d)", g_acq_state.sub_state);
}

/*
 * Handler for DMA error conditions in IRQs.
 */
void _acq_irq_error_dma()
{
	g_acq_state.stats.num_err_total++;
	g_acq_state.state = ACQSTATE_UNINIT;
	g_acq_state.sub_state = ACQSUBST_NONE;
	XAxiDma_Reset(&g_acq_state.dma);
	return;
}

/*
 * Force a reset of the PL FIFO.  Internal function - do not call outside of acquire engine.
 */
void _acq_reset_PL_fifo()
{
	volatile int i;

	/*
	 * The reset signal is sampled on the AXI clock (160MHz).  As a result it is necessary to
	 * drive the reset pulse for some cycles to ensure that the reset is received and the state
	 * machine is in the correct state
	 */
	emio_fast_write(ACQ_EMIO_FIFO_RESET, 1);

	for(i = 0; i < 20; i++) {
		asm __volatile__("nop");
	}

	emio_fast_write(ACQ_EMIO_FIFO_RESET, 0);

	// Test the FIFO full signal; wait for it to deassert before handing control back over
	while(XGpioPs_ReadPin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_OVERRUN)) ;
}

/*
 * Send a trigger reset signal to re-arm the trigger.  This only rearms the trigger on the
 * acquire engine.  It doesn't rearm any actual trigger sources; if those need rearming, you
 * need to send the required signals there, too!
 */
void _acq_reset_trigger()
{
	volatile int i;

	/*
	 * The reset signal is sampled on the ADC clock (125MHz).  As a result it is necessary to
	 * drive the reset pulse for some cycles to ensure that the reset is received and the state
	 * machine is in the correct state
	 */
	emio_fast_write(ACQ_EMIO_TRIG_RESET, 1);

	for(i = 0; i < 10; i++) {
		asm __volatile__("nop");
	}

	emio_fast_write(ACQ_EMIO_TRIG_RESET, 0);
}


/*
 * Blocks until the DONE signal is deasserted.
 */
void _acq_wait_for_ndone()
{
	while(emio_fast_read(ACQ_EMIO_DONE)) ;
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
	g_acq_state.last_debug_timer = 0;

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
	 *   - ACQ_EMIO_FIFO_OVERRUN:	Signal to PS to indicate that acquisition has overrun the FIFO and a FIFO reset is
	 *   							required.
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
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, ACQ_EMIO_FIFO_OVERRUN, 0);

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
	uint32_t *work;
	uint32_t buf_sz;

#if 0
	uint32_t buf_sz = g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN;

	/*
	 * Attempt to allocate the acquisition buffer, but make it ACQ_BUFFER_ALIGN bytes too big; this will
	 * allow us to shift the starting pointer if it isn't aligned as we require.
	 *
	 * TODO: Consider using _alloc_aligned.
	 */
	work = calloc(1, buf_sz);  // Change to malloc later for performance reasons

	if(work == NULL) {
		d_printf(D_ERROR, "acquire: failed to allocate %d bytes for allocbuffer", buf_sz);
		g_acq_state.stats.num_alloc_err_total++;
		return ACQRES_MALLOC_FAIL;
	}

	if((((uint32_t) work) & ACQ_BUFFER_ALIGN_AMOD) != 0) {
		next->buff_acq = (uint32_t *)((((uint32_t) work) + ACQ_BUFFER_ALIGN) & ~(ACQ_BUFFER_ALIGN_AMOD));
	} else {
		next->buff_acq = work;
	}
#endif

	buf_sz = (g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN) & ~(ACQ_BUFFER_ALIGN_AMOD);
	//d_printf(D_ERROR, "buf_sz: req:%d actual:%d (align_error: %d)", g_acq_state.total_buffsz, buf_sz, g_acq_state.total_buffsz % ACQ_BUFFER_ALIGN);

	work = memalign(ACQ_BUFFER_ALIGN, buf_sz);

	if(work == NULL) {
		d_printf(D_ERROR, "acquire: failed to allocate %d bytes for allocbuffer", buf_sz);
		g_acq_state.stats.num_alloc_err_total++;
		return ACQRES_MALLOC_FAIL;
	}

	next->idx = 0;
	next->trigger_at = 0;
	next->flags = ACQBUF_FLAG_ALLOC;
	next->next = NULL;

	// both blocks allocated aligned, so both pointers are identical.  TODO: once tested buff_alloc
	// may be removed entirely.
	next->buff_alloc = work;
	next->buff_acq = work;

	//d_printf(D_EXINFO, "acquire: next = 0x%08x, next->buff_acq = 0x%08x, work.buff_alloc [malloc] = 0x%08x", next, next->buff_acq, work);

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

	// ?
	next->next = NULL;
	next->flags = ACQBUF_FLAG_ALLOC;
	next->trigger_at = 0;

	/*
	 * Then allocate the next buffer to be chained onto the list.
	 */
	res = acq_get_next_alloc(next);
	if(res != ACQRES_OK) {
		d_printf(D_ERROR, "acq_append_next_alloc: acq_get_next_alloc failed: %d", res);
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
 * 								- If positive, it is taken as the number of pre-trigger samples
 * 								- If negative, it is taken as the number of post-trigger samples
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
	uint32_t pre_sz = 0, post_sz = 0, pre_sampct = 0, post_sampct = 0;
	uint32_t total_acq_sz;
	uint32_t align_mask;
	uint32_t demux;
	int i, error = 0;

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

	g_acq_state.pre_buffsz = pre_sz;
	g_acq_state.post_buffsz = post_sz;
	g_acq_state.pre_sampct = pre_sampct;
	g_acq_state.post_sampct = post_sampct;
	g_acq_state.total_buffsz = total_sz;

	/*
	 * Ensure that the total acquisition size doesn't exceed the available memory.  If
	 * that's OK, then free any existing buffers and allocate the memory blocks.  Include an
	 * allocation penalty in our size calculation.
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

	/*
	 * Allocate all subsequent blocks on start up.  We can't allocate these in the IRQ. Then set
	 * the current pointer back to the first so that we start acquiring from that wave buffer.
	 *
	 * If at any point this fails, bail out and free memory.
	 */
	for(i = 0; i < num_acq; i++) {
		// d_printf(D_EXINFO, "acq_current: 0x%08x", g_acq_state.acq_current);

		error = acq_append_next_alloc();
		if(error != ACQRES_OK) {
			d_printf(D_ERROR, "acquire: error %d while allocating buffer #%d, aborting allocation", error, i);
			acq_free_all_alloc();
			return error;
		}
	}

	g_acq_state.acq_current = g_acq_state.acq_first;
	g_acq_state.num_acq_request = num_acq;
	g_acq_state.num_acq_made = 0;
	g_acq_state.acq_mode_flags = mode_flags | ACQ_MODE_TRIGGERED;
	g_acq_state.state = ACQSTATE_STOPPED;
	g_acq_state.sub_state = ACQSUBST_NONE;

	/*
	 * Initialise the fabric configuration.
	 *
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

	//d_printf(D_ERROR, "acquire: starts");

	if(g_acq_state.state == ACQSTATE_UNINIT) {
		return ACQRES_NOT_INITIALISED;
	}

#if 0
	if(!(g_acq_state.state == ACQSTATE_STOPPED || g_acq_state.state == ACQSTATE_DONE)) {
		return ACQRES_NOT_STOPPED;
	}
#endif

	if(g_acq_state.acq_mode_flags & ACQ_MODE_TRIGGERED) {
		XAxiDma_IntrEnable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

		Xil_DCacheFlushRange((INTPTR)g_acq_state.acq_current->buff_acq, g_acq_state.total_buffsz);
		dsb();

		error = XAxiDma_SimpleTransfer(&g_acq_state.dma, (uint32_t)g_acq_state.acq_current->buff_acq, \
				g_acq_state.pre_buffsz, XAXIDMA_DEVICE_TO_DMA);

		if(error != XST_SUCCESS) {
			d_printf(D_ERROR, "acquire: unable to start transfer, error %d", error);
			return ACQRES_DMA_FAIL;
		}

		// Set the state machine
		g_acq_state.state = ACQSTATE_PREP;
		g_acq_state.sub_state = ACQSUBST_PRE_TRIG_FILL;

		// Start on 'A' mux: pre-trigger
		emio_fast_write(ACQ_EMIO_DEPTH_MUX, 0);

		// Empty the FIFO
		_acq_reset_PL_fifo();

		// Reset the trigger before starting acquisition.
		_acq_reset_trigger();

		// Send the EMIO signal to start the acquisition, with trigger masked.  Then we wait for an IRQ.
		emio_fast_write(ACQ_EMIO_ABORT, 0);
		emio_fast_write(ACQ_EMIO_RUN, 1);
		emio_fast_write(ACQ_EMIO_TRIG_MASK, 1);
		emio_fast_write(ACQ_EMIO_AXI_RUN, 1);

		return ACQRES_OK;
	} else {
		return ACQRES_NOT_IMPLEMENTED;
	}
}

/*
 * Returns TRUE if the requested acquisition is complete.
 */
bool acq_is_done()
{
	return (g_acq_state.state == ACQSTATE_DONE);
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
	void *sp = NULL;  // approximately the stack
	uint64_t timer_value, time_delta, acq_delta;
	uint64_t sample_delta;
	uint32_t msb, lsb;
	float time_delta_us, acq_rate = NAN, sample_rate = NAN;

	// Calculate acquisition rate if last debug timer is set
	if(g_acq_state.last_debug_timer != 0) {
		// Compute time delta
		d_read_global_timer(&lsb, &msb);
		timer_value = (((uint64_t)msb) << 32) | lsb;
		time_delta = timer_value - g_acq_state.last_debug_timer;
		time_delta_us = time_delta * XSCUTIMER_TICKS_TO_US;

		// Compute acq delta; ensure it is positive
		acq_delta = g_acq_state.stats.num_acq_total - g_acq_state.stat_last.num_acq_total;
		if(acq_delta > 0) {
			if(time_delta_us > 0) {
				acq_rate = ((float)acq_delta / time_delta_us) * 1e6;
			}
		}

		// Compute data rate; ensure it is positive
		sample_delta = g_acq_state.stats.num_samples_raw - g_acq_state.stat_last.num_samples_raw;
		if(sample_delta > 0) {
			if(time_delta_us > 0) {
				sample_rate = ((float)sample_delta / time_delta_us) * 1e3;
			}
		}
	}

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
	d_printf(D_INFO, "pre_sampct            = %d wavewords", g_acq_state.pre_sampct);
	d_printf(D_INFO, "post_sampct           = %d wavewords", g_acq_state.post_sampct);
	d_printf(D_INFO, "num_acq_request       = %d waves", g_acq_state.num_acq_request);
	d_printf(D_INFO, "num_acq_made          = %d waves", g_acq_state.num_acq_made);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "acq_current->flags    = 0x%04x", g_acq_state.acq_current->flags);
	d_printf(D_INFO, "acq_current->trig_at  = %d (0x%08x)", g_acq_state.acq_current->trigger_at, g_acq_state.acq_current->trigger_at);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "s.num_acq_total       = %llu", g_acq_state.stats.num_acq_total);
	d_printf(D_INFO, "s.num_alloc_err_total = %llu", g_acq_state.stats.num_alloc_err_total);
	d_printf(D_INFO, "s.num_alloc_total     = %llu", g_acq_state.stats.num_alloc_total);
	d_printf(D_INFO, "s.num_err_total       = %llu", g_acq_state.stats.num_err_total);
	d_printf(D_INFO, "s.num_post_total      = %llu", g_acq_state.stats.num_post_total);
	d_printf(D_INFO, "s.num_pre_total       = %llu", g_acq_state.stats.num_pre_total);
	d_printf(D_INFO, "s.num_pre_fill_total  = %llu", g_acq_state.stats.num_pre_fill_total);
	d_printf(D_INFO, "s.num_samples         = %llu", g_acq_state.stats.num_samples);
	d_printf(D_INFO, "s.num_samples_raw     = %llu", g_acq_state.stats.num_samples_raw);
	d_printf(D_INFO, "s.num_irqs            = %llu", g_acq_state.stats.num_irqs);
	d_printf(D_INFO, "s.num_fifo_full       = %llu", g_acq_state.stats.num_fifo_full);
	d_printf(D_INFO, "s.num_fifo_pkt_dscd   = %llu", g_acq_state.stats.num_fifo_pkt_dscd);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Approx acq. rate      = %d acq/s     ", (int)acq_rate);
	d_printf(D_INFO, "Approx sample rate    = %d Ksa/s     ", (int)sample_rate);
	d_printf(D_INFO, "Debug delta           = %d us     ", (int)time_delta_us);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "** End **");

	// Save last state...
	g_acq_state.stat_last = g_acq_state.stats;
	g_acq_state.last_debug_timer = timer_value;
}

/*
 * Dump raw contents of buffer in active acquisition.
 */
void acq_debug_dump_waveraw()
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

/*
 * Explore the linked list to find a waveform by an index and copy a pointer
 * to the passed parameter `buff`.
 *
 * @param	index	Index of wave
 * @param	buff	Pointer to a pointer for the acq_buffer_t struct
 *
 * @return	ACQRES_OK if waveform found (trigger state disregarded)
 * 			ACQRES_WAVE_NOT_FOUND if... well... the waveform wasn't found
 */
int acq_get_ll_pointer(int index, struct acq_buffer_t **buff)
{
	struct acq_buffer_t *wave = g_acq_state.acq_first;

	while(wave != NULL) {
		//d_printf(D_EXINFO, "explore: 0x%08x (%d) (buff_acq:0x%08x, trigger_at:0x%08x %d)", \
				wave, wave->idx, wave->buff_acq, wave->trigger_at, wave->trigger_at);

		if(wave->idx == index)
			break;

		wave = wave->next;
	}

	if(wave == NULL) {
		d_printf(D_ERROR, "Unable to find waveindex %d", index);
		return ACQRES_WAVE_NOT_FOUND;
	}

	*buff = wave;
	return ACQRES_OK;
}

/*
 * Dump information from a wave N.
 *
 * @param	index	Index of wave to dump. Function will explore LL to find the waveform.
 */
void acq_debug_dump_wave(int index)
{
	struct acq_buffer_t *wave;
	uint32_t addr, addr_start, addr_end, offs, sz, start, end, end_post;
	uint32_t *addr2;
	uint32_t *deref;
	int first, i;

	if(acq_get_ll_pointer(index, &wave) != ACQRES_OK) {
		d_printf(D_ERROR, "Unable to dump for waveindex %d: couldn't find wave", index);
		return;
	}

	// d_printf(D_ERROR, "Pointer: 0x%08x", wave);

	// Dump info about this wave
	d_printf(D_INFO, "");
	d_printf(D_INFO, "** Waveinfo for index %d **", index);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "buff_acq address      = 0x%08x", wave->buff_acq);
	d_printf(D_INFO, "buff_alloc address    = 0x%08x", wave->buff_alloc);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "idx                   = %d", wave->idx);
	d_printf(D_INFO, "flags                 = 0x%04x", wave->flags);
	d_printf(D_INFO, "trigger_at            = 0x%08x", wave->trigger_at);
	d_printf(D_INFO, "trigger_at(div8)      = 0x%08x (%d)", wave->trigger_at >> 3, wave->trigger_at >> 3);
	d_printf(D_INFO, "trigger_at(div16)     = 0x%08x (%d)", wave->trigger_at >> 4, wave->trigger_at >> 4);
	d_printf(D_INFO, "");

	// If waveform is completed with trigger then display it
	if(!(wave->trigger_at & TRIGGER_INVALID_MASK) && (wave->flags & ACQBUF_FLAG_PKT_DONE)) {
		/*
		 * To play back the waveform:
		 *   - Invalidate the DCache for this line (do NOT flush line back to DDR3)
		 *   - Start at pre-trigger address + 1
		 *   - Copy words out until end of pre-buffer
		 *   - Jump to start of pre-buffer
		 *   - Copy words out until pre-trigger address
		 *   - Jump to start of post-buffer (end of pre-buffer)
		 *   - Copy words out until end of post-buffer
		 *
		 * The 3 LSBs of the trigger_at value give the first word index that
		 * generated the trigger event.  These are discarded (for now).
		 *
		 * The trigger_at value is given in 8-byte word counts; it must be scaled
		 * by two to get the address.
		 */
		Xil_DCacheInvalidateRange((INTPTR)wave->buff_acq, g_acq_state.total_buffsz);
		dmb();
		//Xil_L2CacheFlushRange((INTPTR)wave->buff_acq, g_acq_state.total_buffsz);
		//bogo_delay(1000000);

		//offs = wave->trigger_at >> 3;
		addr_start = wave->buff_acq; // + (wave->trigger_at * 8);
		//addr_end = &wave->buff_acq + g_acq_state.pre_buffsz;

		//addr2 = wave->buff_acq + (wave->trigger_at / 2);
		start = (((wave->trigger_at >> 3) + 1) * 2);
		end = g_acq_state.pre_sampct * 2;
		//addr_start = wave->buff_acq[(wave->trigger_at >> 3)];
		//addr_end = wave->buff_acq + (g_acq_state.pre_sampct * 2);

		d_printf(D_INFO, "sz=%d, start=%d, end_post=%d", end, start, end_post);

		for(i = start; i < end; i += 2) {
			d_printf(D_RAW, "\033[96m%8d 0x%08x 0x%08x\033[0m\r\n", i, wave->buff_acq[i], wave->buff_acq[i + 1]);
		}

		for(i = 0; i < start; i += 2) {
			d_printf(D_RAW, "\033[95m%8d 0x%08x 0x%08x\033[0m\r\n", i, wave->buff_acq[i], wave->buff_acq[i + 1]);
		}

		start = g_acq_state.pre_sampct * 2;
		end = (g_acq_state.pre_sampct + g_acq_state.post_sampct) * 2;

		for(i = start; i < end; i += 2) {
			d_printf(D_RAW, "\033[97m%8d 0x%08x 0x%08x\033[0m\r\n", i, wave->buff_acq[i], wave->buff_acq[i + 1]);
		}
	} else {
		d_printf(D_ERROR, "Trigger invalid for waveindex %d or wave not done", index);
	}

	d_printf(D_INFO, "");
}

/*
 * Copy waveform data to a buffer for MIPI transmission.  The copy process is inefficient
 * and slow, requiring processor intervention, and this should only be used for test/demonstration.
 *
 * @param	index	Index of wave to dump. Function will explore LL to find the waveform.
 * @param	buffer	Buffer to place assembled waveform.  The buffer must be at least as large as the
 * 					total_buffsz parameter or buffer overflow could occur.
 */
int acq_copy_slow_mipi(int index, uint32_t *buffer)
{
	struct acq_buffer_t *wave;
	uint32_t start, end;
	int res;

	// Find the LL pointer to this waveindex
	res = acq_get_ll_pointer(index, &wave);

	if(res != ACQRES_OK) {
		d_printf(D_ERROR, "Unable to dump for waveindex %d: couldn't find wave", index);
		return res;
	}

	d_printf(D_EXINFO, "acq: trigger_at=0x%08x (sample:%d)", wave->trigger_at, wave->trigger_at >> 3);

	// If waveform is completed with trigger then copy it
	if(!(wave->trigger_at & TRIGGER_INVALID_MASK) && (wave->flags & ACQBUF_FLAG_PKT_DONE)) {
		Xil_DCacheInvalidateRange((INTPTR)wave->buff_acq, g_acq_state.total_buffsz);
		dmb();

		start = (((wave->trigger_at >> 3) + 1) * 2);
		end = g_acq_state.pre_sampct * 2;

		d_printf(D_INFO, "X. pointer: 0x%08x", wave->buff_acq);

		d_printf(D_INFO, "0. pointer: 0x%08x, start: %6d, bytes: %6d, end: %6d", wave->buff_acq + start, start * 4, (end - start) * 4, ((start * 4) + ((end - start) * 4)));

		memcpy(buffer, wave->buff_acq + start, (end - start) * 4);
		buffer += (end - start);

		d_printf(D_INFO, "1. pointer: 0x%08x, start: %6d, bytes: %6d, end: %6d", wave->buff_acq, 0, start * 4, start * 4);

		memcpy(buffer, wave->buff_acq, start * 4);
		buffer += start;

		start = g_acq_state.pre_sampct * 2;
		end = (g_acq_state.pre_sampct + g_acq_state.post_sampct) * 2;

		d_printf(D_INFO, "2. pointer: 0x%08x, start: %6d, bytes: %6d, end: %6d", wave->buff_acq + start, start * 4, (end - start) * 4, ((start * 4) + ((end - start) * 4)));

		memcpy(buffer, wave->buff_acq + start, (end - start) * 4);
		buffer += start;
	} else {
		return ACQRES_WAVE_NOT_READY;
	}
}

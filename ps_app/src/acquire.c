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
 * including memory buffer allocation, PL interface and AXI bus DMA.  It does not handle
 * triggers but interfaces with the trigger block as necessary.
 */

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <errno.h>
#include <malloc.h>

#include "hal.h"
#include "acquire.h"
#include "trigger.h"
#include "fabric_config.h"

const char *acq_state_to_str[] = {
	"ACQSTATE_UNINIT", "ACQSTATE_STOPPED", "ACQSTATE_PREP", "ACQSTATE_WAIT_TRIG", "ACQSTATE_RUNNING", "ACQSTATE_DONE", "ACQSTATE_ERROR"
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
	uint32_t irq_status, addr;
	volatile uint32_t acq_status_a;
	int error, irq_ackd = 0, dma_sent = 0;
	int i;

	// Get status. IRQ will be ack'd after next DMA xfer is started.
	irq_status = XAxiDma_BdRingGetIrq(bd_ring);

	/*
	 * Check for a DMA Error.  Error conditions force an increase of the error
	 * statistic counter and the interrupt gets acknowledged.
	 */
	if(irq_status & XAXIDMA_IRQ_ERROR_MASK) {
		//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0xe0e0e0e0);
		//_acq_irq_error_dma(0);
		//d_printf(D_ERROR, "IRQError");
		XAxiDma_BdRingAckIrq(bd_ring, XAXIDMA_IRQ_ERROR_MASK);
		XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
		//return; // XXX: Should handle other interrupts - this probably should go
	}

	/*
	 * Check for IOC complete.  When an IOC event occurs it has occurred for one
	 * of four reasons:
	 *  - We have filled our pre-trigger window.
	 *  - We have reached the number of words requested and no trigger has occurred
	 *    (when pre-triggering)
	 *  - We have received a trigger and we should start the post-trigger phase.
	 *  - We have finished the post-trigger phase.
	 */
	if(irq_status & XAXIDMA_IRQ_IOC_MASK) {
		switch(g_acq_state.sub_state) {
			// PRE_TRIG_FILL:  Fill up the buffer first, before accepting triggers.
			case ACQSUBST_PRE_TRIG_FILL:
				// Force depth 'A', stop the AXI bus momentarily (TVALID will go low, TLAST will go high)
				_acq_clear_ctrl_a(ACQ_CTRL_A_DEPTH_MUX | ACQ_CTRL_A_AXI_RUN | ACQ_CTRL_A_POST_TRIG_MODE);

				/*
				 * Start the next transfer.
				 * If the acquisition is to be aborted, then don't resume it.
				 */
				if(g_acq_state.acq_early_abort) {
					//d_printf(D_RAW, "ej");
					g_acq_state.acq_early_abort = 0;
					g_acq_state.acq_abort_done = 1;
					//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555501);
					_acq_clear_ctrl_a(ACQ_CTRL_A_END_EARLY);
					//_acq_irq_error_dma(999);
					g_acq_state.sub_state = ACQSUBST_NONE;
					dma_sent = 0;
				} else {
					_acq_fast_dma_start(g_acq_state.acq_current->buff_acq, g_acq_state.pre_buffsz);
					dma_sent = 1;
				}

				// Acknowledge IRQ, as promised
				XAxiDma_BdRingAckIrq(bd_ring, irq_status);
				XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
				irq_ackd = 1;

				if(dma_sent) {
					/*
					 * If the FIFO is full, don't allow us to exit this state.  Instead, send a reset pulse
					 * to the FIFO and revert back to PRE_TRIG_FILL.  This only applies if the SHORT_WITH_RESET
					 * flag isn't set.
					 */
					if(!(g_acq_state.acq_mode_flags & ACQ_MODE_SHORT_WITH_RESET)) {
						if(fabcfg_test(FAB_CFG_ACQ_STATUS_A, ACQ_STATUS_A_DATA_LOSS)) {
							_acq_reset_PL_fifo();
							g_acq_state.sub_state = ACQSUBST_PRE_TRIG_FILL;
							g_acq_state.state = ACQSTATE_PREP;
							g_acq_state.stats.num_fifo_full++;
						} else {
							g_acq_state.sub_state = ACQSUBST_PRE_TRIG_WAIT;
							g_acq_state.state = ACQSTATE_WAIT_TRIG;
						}
					} else {
						g_acq_state.sub_state = ACQSUBST_PRE_TRIG_WAIT;
						g_acq_state.state = ACQSTATE_WAIT_TRIG;
					}

					// Demask triggers; start AXI bus transactions again.
					_acq_clear_and_set_ctrl_a(ACQ_CTRL_A_TRIG_MASK | ACQ_CTRL_A_FIFO_RESET, ACQ_CTRL_A_AXI_RUN);
				}

				// Statistics
				g_acq_state.stats.num_samples += g_acq_state.pre_buffsz;
				g_acq_state.stats.num_samples_raw += g_acq_state.pre_buffsz;
				g_acq_state.stats.num_acq_total++;
				g_acq_state.stats.num_pre_total++;
				g_acq_state.stats.num_pre_fill_total++;
				break;

			case ACQSUBST_PRE_TRIG_WAIT:
				/*
				 * If a trigger has occurred (flag HAVE_TRIG is high) then jump address to the
				 * post-trigger buffer; if not, then go back to the start.
				 */
				acq_status_a = fabcfg_read(FAB_CFG_ACQ_STATUS_A);

				if(acq_status_a & ACQ_STATUS_A_HAVE_TRIG) {
					/*
					 * Tell the PL that we want to use the 'B' channel acquisition depth now.
					 * Stop the AXI bus momentarily (TVALID will go low)
					 */
					_acq_clear_and_set_ctrl_a(ACQ_CTRL_A_AXI_RUN, ACQ_CTRL_A_DEPTH_MUX);

					/*
					 * If the FIFO is full (DATA_LOSS flag set), capture the data but set the discard flag.
					 * XXX: This should be reworked.  We should be able to go back to the start and
					 * recover rather than completing this acquisition needlessly.
					 */
					if(COND_UNLIKELY(acq_status_a & ACQ_STATUS_A_DATA_LOSS)) {
						g_acq_state.acq_current->flags |= ACQBUF_FLAG_PKT_OVERRUN;
						g_acq_state.stats.num_fifo_full++;
					}

					// Acknowledge IRQ, as promised
					XAxiDma_BdRingAckIrq(bd_ring, irq_status);
					XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
					irq_ackd = 1;

					/*
					 * Compute the address of the next DMA transfer and set it up.
					 * If the acquisition is to be aborted, then don't start another DMA.
					 */
					if(COND_UNLIKELY(g_acq_state.acq_early_abort)) {
						//d_printf(D_RAW, "ek");
						g_acq_state.acq_early_abort = 0;
						g_acq_state.acq_abort_done = 1;
						_acq_clear_ctrl_a(ACQ_CTRL_A_END_EARLY);
						//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555502);
						g_acq_state.sub_state = ACQSUBST_NONE;
						dma_sent = 0;
					} else {
						addr = ((uint32_t)g_acq_state.acq_current->buff_acq) + g_acq_state.pre_buffsz;
						_acq_fast_dma_start((uint32_t*)addr, g_acq_state.post_buffsz);
						dma_sent = 1;
					}

					/*
					 * The transfer is now running, so record the address that the trigger occurred at
					 * from the fabric.
					 *
					 * XXX: Do we need to do this on abort?
					 */
					g_acq_state.acq_current->trigger_at = fabcfg_read(FAB_CFG_ACQ_TRIGGER_PTR);

					/*
					 * Start the AXI bus again with triggers masked as we are no longer interested in triggers
					 *
				 	 * POST_TRIG_MODE flag is set to indicate that we can generate a post-trigger done flag at the
				 	 * end of this acquisition, to trigger hold-off and other hardware blocks.
				 	 */
					if(dma_sent) {
						_acq_set_ctrl_a(ACQ_CTRL_A_TRIG_MASK | ACQ_CTRL_A_AXI_RUN | ACQ_CTRL_A_POST_TRIG_MODE);
						g_acq_state.sub_state = ACQSUBST_POST_TRIG;
					}

					g_acq_state.stats.num_samples_raw += g_acq_state.acq_current->trigger_at;
					g_acq_state.stats.num_samples += g_acq_state.acq_current->trigger_at;
				} else {
					/*
					 * No trigger. So just re-arm the pre-trigger, starting from the beginning of
					 * the acquisition buffer.
					 */
					_acq_clear_ctrl_a(ACQ_CTRL_A_AXI_RUN);

					// If the FIFO is full, capture the data but set the discard flag.
					if(COND_UNLIKELY(acq_status_a & ACQ_STATUS_A_DATA_LOSS)) {
						_acq_reset_PL_fifo();
						g_acq_state.acq_current->flags |= ACQBUF_FLAG_PKT_OVERRUN;
						g_acq_state.stats.num_fifo_full++;
					}

					/*
					 * Set the next DMA transfer up with pointer at the start of the current buffer.
					 * If the acquisition is to be aborted, then don't start another DMA.
					 */
					if(COND_UNLIKELY(g_acq_state.acq_early_abort)) {
						//d_printf(D_RAW, "eo");
						g_acq_state.acq_early_abort = 0;
						g_acq_state.acq_abort_done = 1;
						_acq_clear_ctrl_a(ACQ_CTRL_A_END_EARLY);
						//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555503);
						g_acq_state.sub_state = ACQSUBST_NONE;
						dma_sent = 0;
					} else {
						_acq_fast_dma_start(g_acq_state.acq_current->buff_acq, g_acq_state.pre_buffsz);
						dma_sent = 1;
					}

					// Acknowledge IRQ, as promised
					XAxiDma_BdRingAckIrq(bd_ring, irq_status);
					XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
					irq_ackd = 1;

					// Start the next pre-trigger acquisition...
					if(dma_sent) {
						_acq_set_ctrl_a(ACQ_CTRL_A_AXI_RUN);
					}

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
				if(!g_acq_state.acq_early_abort && !fabcfg_test(FAB_CFG_ACQ_STATUS_A, ACQ_STATUS_A_DONE)) {
					d_printf(D_ERROR, "acquire: PL reports not done, but DMA complete! (0x%08x)", fabcfg_read(FAB_CFG_ACQ_STATUS_A));
					_acq_irq_error_dma(4);
					return;
				}

				_acq_clear_and_set_ctrl_a(ACQ_CTRL_A_RUN | ACQ_CTRL_A_AXI_RUN | ACQ_CTRL_A_POST_TRIG_MODE, ACQ_CTRL_A_TRIG_MASK);

				g_acq_state.sub_state = ACQSUBST_DONE_WAVE;
				g_acq_state.state = ACQSTATE_RUNNING;

				g_acq_state.stats.num_samples_raw += g_acq_state.post_buffsz;
				g_acq_state.acq_current->flags |= ACQBUF_FLAG_PKT_DONE;

				/*
				 * If the OVERRUN flag was set, then this waveform should be discarded as it is not valid.  The
				 * acquisition restarts on the same wave.
				 */
				if(g_acq_state.acq_current->flags & ACQBUF_FLAG_PKT_OVERRUN) {
					g_acq_state.stats.num_fifo_pkt_dscd++;

					/*
					 * Start a new transfer, but without allocating a new buffer or increasing the waveform count.
					 * Don't start the transfer if we're trying to abort.
					 */
					if(COND_UNLIKELY(g_acq_state.acq_early_abort)) {
						//d_printf(D_RAW, "ep");
						g_acq_state.acq_early_abort = 0;
						g_acq_state.acq_abort_done = 1;
						_acq_clear_ctrl_a(ACQ_CTRL_A_END_EARLY);
						//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555504);
						g_acq_state.sub_state = ACQSUBST_NONE;
					} else {
						error = acq_start(ACQ_START_FIFO_RESET);

						if(error != ACQRES_OK) {
							d_printf(D_ERROR, "acquire: unable to reset current transfer, error %d", error);
							_acq_irq_error_dma(5);
							return;
						}
					}
				} else {
					// Move to the next buffer if we haven't filled the total waveform count.
					g_acq_state.num_acq_made++;
					g_acq_state.stats.num_samples += g_acq_state.post_buffsz;

					// XXX: Changed this to a >= which fixes a null deref error, but this really shouldn't be
					// necessary.  Need to see what could cause num_acq_made to exceed num_acq_request.
					if(g_acq_state.num_acq_made >= g_acq_state.num_acq_request) {
						g_acq_state.sub_state = ACQSUBST_DONE_ALL;
						g_acq_state.state = ACQSTATE_DONE;
					} else {
						if(g_acq_state.acq_current->next != NULL) {
							// Don't start next acquisition if we're in abort
							if(g_acq_state.acq_early_abort) {
								g_acq_state.acq_early_abort = 0;
								g_acq_state.acq_abort_done = 1;
								//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555505);
								_acq_clear_ctrl_a(ACQ_CTRL_A_END_EARLY);
								g_acq_state.sub_state = ACQSUBST_NONE;
							} else {
								g_acq_state.acq_current = g_acq_state.acq_current->next;
								//d_printf(D_INFO, "cur:%08x nxt:%08x", g_acq_state.acq_current, g_acq_state.acq_current->next);
								//outbyte('x');
								error = acq_start(ACQ_START_FIFO_RESET);

								if(error != ACQRES_OK) {
									d_printf(D_ERROR, "acquire: unable to start next transfer, error %d", error);
									_acq_irq_error_dma(6);
									return;
								}
							}
						} else {
							d_printf(D_ERROR, "acquire: NULL deref trying to move to next wavebuffer; something's wrong! (%d acq made, %d requested)", \
									g_acq_state.num_acq_made, g_acq_state.num_acq_request);
							acq_debug_dump();
						}
					}
				}

				g_acq_state.stats.num_post_total++;
				break;

			case ACQSUBST_NONE:
				d_printf(D_RAW, "IRQ_none!");
				break;
		}
	}

	// If IRQ not acknowledged above (default case or post trigger) do it now.
	if(!irq_ackd) {
		XAxiDma_BdRingAckIrq(bd_ring, irq_status);
		XAxiDma_IntrAckIrq(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	}

#if 0
	// Free to do this AXI-hogging stuff at the -end- of setting up our DMA transfers, etc., while
	// they are busy doing that...
	g_acq_state.stats.num_irqs++;
	g_acq_state.dbg_isr_acq_ctrl_a = fabcfg_read(FAB_CFG_ACQ_CTRL_A);
	g_acq_state.dbg_isr_acq_status_a = fabcfg_read(FAB_CFG_ACQ_STATUS_A);
	g_acq_state.dbg_isr_acq_status_b = fabcfg_read(FAB_CFG_ACQ_STATUS_B);
	g_acq_state.dbg_isr_acq_trig_ptr = fabcfg_read(FAB_CFG_ACQ_TRIGGER_PTR);
#endif
}

/*
 * Interrupt handler for the FIFO Stall condition.
 *
 * In some cases, the state machine can stall because the FIFO overflowed during a
 * trigger event.  If this should occur, the state machine will be reset to recover,
 * and the current acquisition will be reset and restarted (discarding the last waveform.)
 *
 * This interrupt generally only fires on very fast acquisitions where the interrupt
 * storm does not get correctly managed.  There is probably a better way to solve this
 * problem...
 *
 * @param	Argument passed from SCUGIC.  Not used.
 */
void _acq_irq_fifo_gen_rst(void *none)
{
	volatile uint32_t stat_a, stat_b;
	int i;

	//d_printf(D_ERROR, "acquire: FIFO stall, recovering");

#if 0
	/*
	 * Don't attempt recovery if we're in an abort state.
	 */
	if(g_acq_state.acq_early_abort) {
		d_printf(D_WARN, "NotRecover");
		return;
	}
#endif

	if(fabcfg_test(FAB_CFG_ACQ_STATUS_A, ACQ_STATUS_A_RG_FIFO_STALL)) {
		_acq_clear_and_set_ctrl_a(ACQ_CTRL_A_RUN | ACQ_CTRL_A_AXI_RUN, ACQ_CTRL_A_FIFO_RESET /*| ACQ_CTRL_A_TRIG_RST*/ | ACQ_CTRL_A_ABORT);

		// Wait until both FIFO level readouts report 0x0000
		while(((fabcfg_read_no_dsb(FAB_CFG_ACQ_STATUS_A) & ACQ_STATUS_A_FIFO_MASK) != 0) && \
			  ((fabcfg_read_no_dsb(FAB_CFG_ACQ_STATUS_B) & ACQ_STATUS_B_FIFO_MASK) != 0)) ;

		_acq_clear_ctrl_a(ACQ_CTRL_A_FIFO_RESET  /*| ACQ_CTRL_A_TRIG_RST*/ | ACQ_CTRL_A_ABORT);

		// Reset the current acquisition and try again.  Set a tracking flag for diagnostics/debug.
		g_acq_state.acq_current->flags |= ACQBUF_FLAG_NOTE_FIFOSTALL;
		g_acq_state.acq_current->trigger_at = 0;
		g_acq_state.state = ACQSTATE_WAIT_TRIG; // TODO: maybe need another state here
		g_acq_state.sub_state = ACQSUBST_PRE_TRIG_FILL; // TODO: maybe need another state here

		XAxiDma_Reset(&g_acq_state.dma);
		while(!XAxiDma_ResetIsDone(&g_acq_state.dma));
		XAxiDma_IntrEnable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

		if(_acq_core_dma_start(g_acq_state.acq_current->buff_acq, g_acq_state.pre_buffsz) != ACQRES_OK) {
			d_printf(D_ERROR, "acquire: FIFO stall not recovered");
			return;
		}

		stat_a = fabcfg_read(FAB_CFG_ACQ_STATUS_A);
		stat_b = fabcfg_read(FAB_CFG_ACQ_STATUS_B);

		// Start on 'A' mux: pre-trigger, triggers masked
		_acq_clear_and_set_ctrl_a(ACQ_CTRL_A_DEPTH_MUX | ACQ_CTRL_A_POST_TRIG_MODE, ACQ_CTRL_A_DATA_VALID | ACQ_CTRL_A_RUN | ACQ_CTRL_A_TRIG_MASK | ACQ_CTRL_A_AXI_RUN);

		//d_printf(D_ERROR, "acquire: FIFO stall recovery (0x%08x, 0x%08x)", stat_a, stat_b);

		//stat_a = fabcfg_read(FAB_CFG_ACQ_STATUS_A);
		//stat_b = fabcfg_read(FAB_CFG_ACQ_STATUS_B);

		//d_printf(D_ERROR, "acquire: FIFO stall recovery (0x%08x, 0x%08x)", stat_a, stat_b);
		//acq_debug_dump();
		g_acq_state.stats.num_fifo_stall_total++;
	} else {
		d_printf(D_ERROR, "acquire: FIFO stall interrupt without FIFO stall signal!");
	}
}

/*
 * Handler for DMA error conditions in IRQs.
 */
void _acq_irq_error_dma(int cause_index)
{
	d_printf(D_ERROR, "acquire: _acq_irq_error_dma error (%d), DMASR=0x%08x, BuffLen=0x%08x", cause_index, \
			XAxiDma_ReadReg(g_acq_state.dma.RxBdRing[0].ChanBase, XAXIDMA_SR_OFFSET), \
			XAxiDma_ReadReg(g_acq_state.dma.RxBdRing[0].ChanBase, XAXIDMA_BUFFLEN_OFFSET));

	_acq_set_ctrl_a(ACQ_CTRL_A_TRIG_RST);

	//fabcfg_write(FAB_CFG_TRIG_LEVEL0, 0x55555500 | (cause_index & 0xff));

	g_acq_state.stats.num_err_total++;
	g_acq_state.state = ACQSTATE_ERROR;
	g_acq_state.sub_state = ACQSUBST_NONE;
	XAxiDma_Reset(&g_acq_state.dma);

	return;
}

/*
 * Force a reset of the PL FIFO.  Internal function - do not call outside of acquire engine.
 */
void _acq_reset_PL_fifo()
{
	_acq_set_ctrl_a(ACQ_CTRL_A_FIFO_RESET);
	_acq_clear_ctrl_a(ACQ_CTRL_A_FIFO_RESET);

	// Test the FIFO full signal; wait for it to deassert before handing control back over
	// XXX: Fix this, it was completely wrong 3 months ago and likely is still borken yet I did not notice...
	//while(fabcfg_test(FAB_CFG_ACQ_CTRL_A, ACQ_CTRL_A_FIFO_RESET)) ;
}

/*
 * Send a trigger reset signal to re-arm the trigger.  This only rearms the trigger on the
 * acquire engine.  It doesn't rearm any actual trigger sources; if those need rearming, you
 * need to send the required signals there, too!
 */
void _acq_reset_trigger()
{
	volatile int i;

	_acq_set_ctrl_a(ACQ_CTRL_A_TRIG_RST);
	_acq_clear_ctrl_a(ACQ_CTRL_A_TRIG_RST);
}

/*
 * Blocks until the DONE signal is deasserted.
 */
void _acq_wait_for_ndone()
{
	while(fabcfg_test(FAB_CFG_ACQ_STATUS_A, ACQ_STATUS_A_DONE)) ;
	//while(emio_fast_read(ACQ_EMIO_DONE)) ;
}

/*
 * Fast acquisition DMA setup, for use in IRQs.  Does not check for
 * error conditions.
 *
 * Below partially based on Xilinx xaxidma.c.
 */
void _acq_fast_dma_start(uint32_t *buff_ptr, uint32_t buff_sz)
{
	XAxiDma_WriteReg(g_acq_state.dma.RxBdRing[0].ChanBase, XAXIDMA_DESTADDR_OFFSET, buff_ptr);

	// We track the DMACR state in memory and can apply a quick change without a RMW operation
	g_acq_state.dmacr_state |= XAXIDMA_CR_RUNSTOP_MASK;
	XAxiDma_WriteReg(g_acq_state.dma.RxBdRing[0].ChanBase, XAXIDMA_CR_OFFSET, g_acq_state.dmacr_state);

	// transaction started by writing to length register
	XAxiDma_WriteReg(g_acq_state.dma.RxBdRing[0].ChanBase, XAXIDMA_BUFFLEN_OFFSET, buff_sz);

	return ACQRES_OK;
}

/*
 * Core acquisition DMA setup.  Sets up DMA transfer only.  Logs CR register for
 * fast write function.
 *
 * @return	ACQRES_DMA_FAIL if DMA task could not be started;
 * 			ACQRES_OK if DMA task started successfully.
 */
int _acq_core_dma_start(uint32_t *buff_ptr, uint32_t buff_sz)
{
	int error;

	error = XAxiDma_SimpleTransfer(&g_acq_state.dma, (uint32_t)buff_ptr, buff_sz, XAXIDMA_DEVICE_TO_DMA);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "acquire: unable to start DMA core, error %d", error);
		return ACQRES_DMA_FAIL;
	}

	g_acq_state.dmacr_state = XAxiDma_ReadReg(g_acq_state.dma.RxBdRing[0].ChanBase, XAXIDMA_CR_OFFSET);

	//d_printf(D_WARN, "c=%d", buff_sz);

	return ACQRES_OK;
}

/*
 * Initialise the acquisitions engine.  Sets up default values in the structs.
 */
void acq_init()
{
	int i, error;

	g_acq_state.state = ACQSTATE_UNINIT;
	g_acq_state.sub_state = ACQSUBST_NONE;  // needed?
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

	d_printf(D_INFO, "acquire: DMA initialised @ 0x%08x", g_acq_state.dma_config->BaseAddr);

	XAxiDma_Reset(&g_acq_state.dma);
	while(!XAxiDma_ResetIsDone(&g_acq_state.dma)) ;

	d_printf(D_INFO, "acquire: DMA reset OK");

	/*
	 * Setup the SCUGIC interrupt controller for the DMA transfer.
	 */
	XScuGic_SetPriorityTriggerType(&g_hal.xscu_gic, ACQ_DMA_RX_IRQ, ACQ_DMA_RX_IRQ_PRIO, ACQ_DMA_RX_IRQ_TRIG);

	error = XScuGic_Connect(&g_hal.xscu_gic, ACQ_DMA_RX_IRQ, \
				(Xil_InterruptHandler)_acq_irq_rx_handler, XAxiDma_GetRxRing(&g_acq_state.dma));

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "acquire: fatal: unable to initialise DMA-IRQ engine! (error=%d)", error);
		exit(-1);
	}

	d_printf(D_INFO, "acquire: SCUGIC connected for DMA IRQ");

	/*
	 * Setup the SCUGIC interrupt controller for the FIFO stall interrupt.
	 */
	XScuGic_SetPriorityTriggerType(&g_hal.xscu_gic, ACQ_FIFO_STALL_IRQ, ACQ_FIFO_STALL_IRQ_PRIO, \
			ACQ_FIFO_STALL_IRQ_TRIG);

	error = XScuGic_Connect(&g_hal.xscu_gic, ACQ_FIFO_STALL_IRQ, \
				(Xil_InterruptHandler)_acq_irq_fifo_gen_rst, NULL);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "acquire: fatal: unable to initialise FIFO stall IRQ! (error=%d)", error);
		exit(-1);
	}

	d_printf(D_INFO, "acquire: SCUGIC connected for FIFO stall IRQ");

	/*
	 * Enable the SCUGIC.
	 */
	XScuGic_Enable(&g_hal.xscu_gic, ACQ_DMA_RX_IRQ);
	XScuGic_Enable(&g_hal.xscu_gic, ACQ_FIFO_STALL_IRQ);
	d_printf(D_INFO, "acquire: SCUGIC configured");

	/*
	 * Set all line training data to zero and write it to the acquisition engine.
	 */
	for(i = 0; i < 8; i++) {
		g_acq_state.line_train[i] = 0;
	}

	acq_write_training();
}

/*
 * Write training data to the acquisition engine.
 */
void acq_write_training()
{
	int i;
	uint32_t train_regA = 0, train_regB = 0;

	d_printf(D_INFO, "acquire: start loading train values");

	// 5 LSBs from each line train value are stored into A and B registers
	for(i = 0; i < 4; i++) {
		train_regA |= (g_acq_state.line_train[i + 0] & 31) << (3 + (8 * i));
	}

	for(i = 0; i < 4; i++) {
		train_regB |= (g_acq_state.line_train[i + 4] & 31) << (3 + (8 * i));
	}

	fabcfg_write(FAB_CFG_ACQ_TRAIN_A, train_regA | ACQ_TRAIN_A_LOAD);
	fabcfg_write(FAB_CFG_ACQ_TRAIN_B, train_regB);

	// Verify "DL" bit is clear
	while(fabcfg_test(FAB_CFG_ACQ_STATUS_C, ACQ_STATUS_C_DELAY_LOADED)) ;

	// Clear train_load flag
	fabcfg_clear(FAB_CFG_ACQ_TRAIN_A, ACQ_TRAIN_A_LOAD);

	// XXX: Finish this... this hangs here, it shouldn't!
#if 0
	// Wait for "DL" bit to be set
	while(!fabcfg_test(FAB_CFG_ACQ_STATUS_C, ACQ_STATUS_C_DELAY_LOADED)) {
		//outbyte('C');
	}
#endif

	d_printf(D_INFO, "acquire: training values loaded");
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

	buf_sz = (g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN) & ~(ACQ_BUFFER_ALIGN_AMOD);
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

	// Currently these values are the same for every transfer but we might support variable size waveform
	// acquisition in the future
	next->pre_sz = g_acq_state.pre_buffsz;
	next->post_sz = g_acq_state.post_buffsz;

	// Both blocks allocated aligned, so both pointers are identical.  TODO: once tested buff_alloc
	// may be removed entirely.
	next->buff_alloc = work;
	next->buff_acq = work;

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
	if(next == NULL) {
		d_printf(D_ERROR, "acquire: failed to allocate %d bytes for alloc structure", sizeof(struct acq_buffer_t));
		g_acq_state.stats.num_alloc_err_total++;
		return ACQRES_MALLOC_FAIL;
	}

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
	//d_printf(D_INFO, "AppNext cur:%08x cur->next:%08x next:%08x", g_acq_state.acq_current, g_acq_state.acq_current->next, next);
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

	//d_printf(D_INFO, "Start FreeAllAlloc");

	// Disable interrupts while we process this as we're altering the linked list
	GLOBAL_IRQ_DISABLE();

	/*
	 * Iterate through the list of allocations starting at the first allocation,
	 * copy the next pointer, free the current allocation and repeat until we reach
	 * a NULL next pointer.
	 */
	while(next != NULL) {
		//d_printf(D_INFO, "FA n:%08x b:%08x idx:%d nn:%08x fl:%04x", next, next->buff_alloc, next->idx, next->next, next->flags);

		next_next = next->next;

		// Free the buffer *and* the acquisition structure
		free(next->buff_alloc);
		free(next);

		next = next_next;
	}

	g_acq_state.acq_first = NULL;
	g_acq_state.acq_current = NULL;

	GLOBAL_IRQ_ENABLE();

	//d_printf(D_INFO, "Done FreeAllAlloc");
}

/*
 * Rewind the acquisition pointer to the start and mark all buffers as free.
 * The buffers will contain stale data after this, but are made available for reuse.
 *
 * This function cannot be used if the allocation size has changed.  Buffers must
 * be freed and reallocated using `acq_free_all_alloc` and `acq_prepare_triggered`.
 */
void acq_rewind()
{
	struct acq_buffer_t *next = g_acq_state.acq_first;

	//d_printf(D_INFO, "Start Rewind");

	// Disable interrupts while we process this as we're altering the linked list
	GLOBAL_IRQ_DISABLE();

	//d_printf(D_INFO, "f:%08x c:%08x", g_acq_state.acq_first, g_acq_state.acq_current);

	/*
	 * Iterate through the list of allocations starting at the first allocation,
	 * clearing the flags and trigger position.
	 */
	while(next != NULL) {
		//d_printf(D_INFO, "RW %08x %d %08x %04x", next, next->idx, next->next, next->flags);

		next->flags = ACQBUF_FLAG_ALLOC;
		next->trigger_at = 0;

		next = next->next;
	}

	g_acq_state.acq_current = g_acq_state.acq_first;
	g_acq_state.num_acq_made = 0; // Reset wave counter

	GLOBAL_IRQ_ENABLE();

	//d_printf(D_INFO, "Done Rewind");
}

/*
 * Prepare a new triggered acquisition: allocate the buffers, set up the state machine
 * and configure the fabric.
 *
 * @param	mode_flags		Mode flags of type ACQ_MODE used to configure the sampling engine.
 * @param	pre_sz			Pre trigger buffer size (samples)
 * @param	post_sz			Post trigger buffer size (samples)
 * @param	num_acq			Total acquisition count (number of acquisitions to complete)
 */
int acq_prepare_triggered(uint32_t mode_flags, uint32_t pre_sz, uint32_t post_sz, uint32_t num_acq)
{
	struct acq_buffer_t *first;
	uint32_t pre_sampct = 0, post_sampct = 0;
	uint32_t total_acq_sz;
	uint32_t align_mask;
	uint32_t demux;
	int i, error;

	// How can we acquire an empty buffer of no waveforms?
	if(COND_UNLIKELY(num_acq == 0 || pre_sz == 0 || post_sz == 0)) {
		d_printf(D_ERROR, "acquire: zero buffer/zero wavecount");
		return ACQRES_PARAM_FAIL;
	}

	// Must have at least one of 8-bit, 12-bit or 14-bit set
	if(COND_UNLIKELY(!(mode_flags & (ACQ_MODE_8BIT | ACQ_MODE_12BIT | ACQ_MODE_14BIT)))) {
		d_printf(D_ERROR, "acquire: bit-depth not provided");
		return ACQRES_PARAM_FAIL;
	}

	// Must have at least one of 1ch, 2ch or 4ch set
	if(COND_UNLIKELY(!(mode_flags & (ACQ_MODE_1CH | ACQ_MODE_2CH | ACQ_MODE_4CH)))) {
		d_printf(D_ERROR, "acquire: channel mode not provided");
		return ACQRES_PARAM_FAIL;
	}

	// Must not have "CONTINUOUS" or "TRIGGERED" set
	if(COND_UNLIKELY(mode_flags & (ACQ_MODE_TRIGGERED | ACQ_MODE_CONTINUOUS))) {
		d_printf(D_ERROR, "acquire: triggered or continuous flag set (both bits must be clear)");
		return ACQRES_PARAM_FAIL;
	}

	error = 0;

	if(mode_flags & ACQ_MODE_8BIT) {
		align_mask = ACQ_SAMPLES_ALIGN_8B_AMOD;
		pre_sampct = pre_sz / ACQ_SAMPLES_ALIGN_8B;
		post_sampct = post_sz / ACQ_SAMPLES_ALIGN_8B;
		error |= (post_sz & align_mask) | (pre_sz & align_mask);
	} else if(mode_flags & (ACQ_MODE_12BIT | ACQ_MODE_14BIT)) {
		align_mask = ACQ_SAMPLES_ALIGN_PR_AMOD;
		pre_sampct = pre_sz / ACQ_SAMPLES_ALIGN_PR;
		post_sampct = post_sz / ACQ_SAMPLES_ALIGN_PR;
		error |= (post_sz & align_mask) | (pre_sz & align_mask);
	}

	if(COND_UNLIKELY(pre_sz < ACQ_MIN_PREPOST_SIZE || post_sz < ACQ_MIN_PREPOST_SIZE)) {
		error |= 1;
	}

	if(COND_UNLIKELY(error)) {
		d_printf(D_ERROR, "acquire: pre or post buffers not aligned to required sample boundary or too small (pre=%d post=%d req_align_mask=0x%08x)", \
				pre_sz, post_sz, align_mask);
		return ACQRES_ALIGN_FAIL;
	}

#if 0
	// Scale total_sz and pre/post sizes, if appropriate
	if(mode_flags & (ACQ_MODE_12BIT | ACQ_MODE_14BIT)) {
		// 4 samples per data word (64-bit)
		pre_sampct = pre_sz;
		post_sampct = post_sz;
		//post_sz *= 4;
		//pre_sz *= 4;
	} else if(mode_flags & (ACQ_MODE_8BIT)) {
		// 8 samples per per data word (64-bit)
		pre_sampct = pre_sz;
		post_sampct = post_sz;
		//post_sz *= 8;
		//pre_sz *= 8;
	}
#endif

	g_acq_state.pre_buffsz = pre_sz;
	g_acq_state.post_buffsz = post_sz;
	g_acq_state.pre_sampct = pre_sampct;
	g_acq_state.post_sampct = post_sampct;
	g_acq_state.total_buffsz = pre_sz + post_sz;

	// If the acquisition is small, set a flag indicating this which will trigger a FIFO reset mode
	// to maximise performance
	if(g_acq_state.total_buffsz <= ACQ_SHORT_THRESHOLD) {
		mode_flags |= ACQ_MODE_SHORT_WITH_RESET;
	}

	/*
	 * Ensure that the total acquisition size doesn't exceed the available memory.  If
	 * that's OK, then free any existing buffers and allocate the memory blocks.  Include an
	 * allocation penalty in our size calculation.
	 */
	total_acq_sz = (g_acq_state.total_buffsz + ACQ_BUFFER_ALIGN) * num_acq;

	if(total_acq_sz > ACQ_TOTAL_MEMORY_AVAIL) {
		return ACQRES_TOTAL_MALLOC_FAIL;
	}

	g_acq_state.state = ACQSTATE_UNINIT;
	d_printf(D_INFO, "FreeALL");
	acq_free_all_alloc();
	d_printf(D_INFO, "FreeDone");

	first = malloc(sizeof(struct acq_buffer_t));

	if(first == NULL) {
		d_printf(D_ERROR, "acquire: unable to allocate %d bytes for first entry in acquisition", sizeof(struct acq_buffer_t));
		return ACQRES_MALLOC_FAIL;
	}

	error = acq_get_next_alloc(first);
	if(error != ACQRES_OK) {
		d_printf(D_ERROR, "acquire: unable to get allocation for first buffer: error %d", error);
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
	//fabcfg_write(FAB_CFG_ACQ_DEMUX_MODE, demux);

	return ACQRES_OK;
}

/*
 * Start the acquisition engine.  Resets the wave count and starts acquiring from wave#0.
 *
 * @param	reset_fifo		If set, the acquisition FIFO will be cleared, ensuring no old samples remain
 * 							This is the recommended behaviour.  Only clear this if performance is critical,
 * 							and you can be sure the FIFO does not contain stale data.
 *
 * @return	ACQRES_NOT_INITIALISED if the acquisition has not yet been initialised;
 * 			ACQRES_NOT_STOPPED if acquisition is currently running (must stop before starting);
 * 			ACQRES_NOT_IMPLEMENTED if the mode is not presently supported;
 * 			ACQRES_DMA_FAIL if DMA task could not be started;
 * 			ACQRES_OK if acquisition task started successfully.
 */
int acq_start(int reset_fifo)
{
	int error;

	//d_printf(D_INFO, "acquire: starts");

	if(COND_UNLIKELY(g_acq_state.state == ACQSTATE_UNINIT)) {
		d_printf(D_ERROR, "ACQSTATE_UNINIT");
		return ACQRES_NOT_INITIALISED;
	}

#if 0
	if(!(g_acq_state.state == ACQSTATE_STOPPED || g_acq_state.state == ACQSTATE_DONE)) {
		return ACQRES_NOT_STOPPED;
	}
#endif

	if(g_acq_state.acq_mode_flags & ACQ_MODE_TRIGGERED) {
		XAxiDma_Reset(&g_acq_state.dma);
		XAxiDma_IntrEnable(&g_acq_state.dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

		Xil_DCacheFlushRange((INTPTR)g_acq_state.acq_current->buff_acq, g_acq_state.total_buffsz);
		dsb();

		//d_printf(D_INFO, "acquire: %d bytes", g_acq_state.pre_buffsz);
		error = _acq_core_dma_start((uint32_t)g_acq_state.acq_current->buff_acq, g_acq_state.pre_buffsz);

		if(error != XST_SUCCESS) {
			d_printf(D_ERROR, "acquire: unable to start DMA, error %d", error);
			return ACQRES_DMA_FAIL;
		}

		// Ensure we clear the overrun flag as this is a new packet.  If this is not cleared
		// we cannot recover from overrun.
		g_acq_state.acq_current->flags &= ~ACQBUF_FLAG_PKT_OVERRUN;

		// Set the state machine
		g_acq_state.acq_early_abort = 0;
		g_acq_state.state = ACQSTATE_PREP;
		g_acq_state.sub_state = ACQSUBST_PRE_TRIG_FILL;

		// Start on 'A' mux: pre-trigger
		_acq_clear_ctrl_a(ACQ_CTRL_A_DEPTH_MUX | ACQ_CTRL_A_ABORT | ACQ_CTRL_A_END_EARLY | ACQ_CTRL_A_POST_TRIG_MODE);

		if(reset_fifo == ACQ_START_FIFO_RESET) {
			_acq_reset_PL_fifo();
		}

		// Reset the trigger before starting acquisition.
		//_acq_reset_trigger();

		// Start the transaction: initially with triggers masked and not in POST_TRIG mode
		_acq_set_ctrl_a(ACQ_CTRL_A_DATA_VALID | ACQ_CTRL_A_RUN | ACQ_CTRL_A_TRIG_MASK | ACQ_CTRL_A_AXI_RUN);

		return ACQRES_OK;
	} else {
		d_printf(D_ERROR, "acquire: mode unsupported (0x%08x)", g_acq_state.acq_mode_flags);
		return ACQRES_NOT_IMPLEMENTED;
	}
}

/*
 * Stop the acquisition engine.  This works by sending a signal to the software on
 * the acquisition side (setting a flag) and sending a pulse to the fabric which
 * causes an early abort of any acquisition in progress.
 *
 * @return	ACQRES_NOT_RUNNING if the acquisition is already stopped;
 * 			ACQRES_OK if stop signal sent.
 */
int acq_stop()
{
	if(g_acq_state.state == ACQSTATE_STOPPED) {
		d_printf(D_ERROR, "acquire: acquisition already stopped");
		return ACQRES_NOT_RUNNING;
	}

	GLOBAL_IRQ_DISABLE();
	g_acq_state.acq_abort_done = 0;
	g_acq_state.acq_early_abort = 1;
	_acq_set_ctrl_a(ACQ_CTRL_A_END_EARLY);
	GLOBAL_IRQ_ENABLE();

	return ACQRES_OK;
}

/*
 * Returns TRUE and clears internal acknowledge state if an acquisition has been
 * successfully aborted.  Normally acquisition aborts happen quickly so this
 * function should return TRUE more or less immediately.  The edge case is
 * present if a hold off is programmed, because that hold off needs to be stopped
 * first.
 */
bool acq_abort_done()
{
	if(g_acq_state.acq_abort_done) {
		g_acq_state.acq_abort_done = 0;
		return 1;
	}

	return 0;
}

/*
 * Returns TRUE if the requested acquisition is complete.
 */
bool acq_is_done()
{
	return (g_acq_state.state == ACQSTATE_DONE);
}

/*
 * Generate an acquisition status response.
 */
void acq_make_status(struct acq_status_resp_t *status_resp)
{
	int trig_res;

	status_resp->flags = 0;
	status_resp->waves_done = g_acq_state.num_acq_made;

	if(g_acq_state.state == ACQSTATE_UNINIT || g_acq_state.state == ACQSTATE_STOPPED || g_acq_state.state == ACQSTATE_DONE) {
		status_resp->flags |= ACQSTA_STOPPED;
	}

	if(g_acq_state.state == ACQSTATE_DONE) {
		status_resp->flags |= ACQSTA_DONE;
	}

	if(g_acq_state.num_acq_made == g_acq_state.num_acq_request && g_acq_state.num_acq_request > 0) {
		status_resp->flags |= ACQSTA_ALL_REQUESTED;
	}

	trig_res = trig_has_trigd();

	if(trig_res == TRIG_STATUS_TRIGD) {
		status_resp->flags |= ACQSTA_TRIGD_NORMAL;
	} else if(trig_res == TRIG_STATUS_AUTO) {
		status_resp->flags |= ACQSTA_TRIGD_AUTO;
	}
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

	d_printf(D_INFO, "** Acquisition State (g_acq_state: 0x%08x) **   ", &g_acq_state);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "I think the stack is at 0x%08x or thereabouts   ", (void*)&sp);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "acq_mode_flags        = 0x%08x                  ", g_acq_state.acq_mode_flags);
	d_printf(D_INFO, "state                 = %d [%s]                 ", g_acq_state.state, acq_state_to_str[g_acq_state.state]);
	d_printf(D_INFO, "sub_state             = %d [%s]                 ", g_acq_state.sub_state, acq_substate_to_str[g_acq_state.sub_state]);
	d_printf(D_INFO, "acq_current           = 0x%08x                  ", g_acq_state.acq_current);
	d_printf(D_INFO, "acq_first             = 0x%08x                  ", g_acq_state.acq_first);
	d_printf(D_INFO, "dma                   = 0x%08x                  ", g_acq_state.dma);
	d_printf(D_INFO, "dma_config            = 0x%08x                  ", g_acq_state.dma_config);
	d_printf(D_INFO, "demux_reg             = 0x%02x                  ", g_acq_state.demux_reg);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "R_acq_ctrl_a          = 0x%08x (last_isr:0x%08x)", fabcfg_read(FAB_CFG_ACQ_CTRL_A), g_acq_state.dbg_isr_acq_ctrl_a);
	d_printf(D_INFO, "R_acq_status_a        = 0x%08x (last_isr:0x%08x)", fabcfg_read(FAB_CFG_ACQ_STATUS_A), g_acq_state.dbg_isr_acq_status_a);
	d_printf(D_INFO, "R_acq_status_b        = 0x%08x (last_isr:0x%08x)", fabcfg_read(FAB_CFG_ACQ_STATUS_B), g_acq_state.dbg_isr_acq_status_b);
	d_printf(D_INFO, "R_acq_trigger_ptr     = 0x%08x (last_isr:0x%08x)", fabcfg_read(FAB_CFG_ACQ_TRIGGER_PTR), g_acq_state.dbg_isr_acq_trig_ptr);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "pre_buffsz            = %7d bytes (0x%08x)      ", g_acq_state.pre_buffsz, g_acq_state.pre_buffsz);
	d_printf(D_INFO, "post_buffsz           = %7d bytes (0x%08x)      ", g_acq_state.post_buffsz, g_acq_state.post_buffsz);
	d_printf(D_INFO, "total_buffsz          = %7d bytes (0x%08x)      ", g_acq_state.total_buffsz, g_acq_state.total_buffsz);
	d_printf(D_INFO, "pre_sampct            = %7d wavewords           ", g_acq_state.pre_sampct);
	d_printf(D_INFO, "post_sampct           = %7d wavewords           ", g_acq_state.post_sampct);
	d_printf(D_INFO, "num_acq_request       = %7d waves               ", g_acq_state.num_acq_request);
	d_printf(D_INFO, "num_acq_made          = %7d waves               ", g_acq_state.num_acq_made);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "acq_current->flags    = 0x%04x                  ", g_acq_state.acq_current->flags);
	d_printf(D_INFO, "acq_current->trig_at  = %d (0x%08x)             ", g_acq_state.acq_current->trigger_at, g_acq_state.acq_current->trigger_at);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "s.num_acq_total       = %llu                    ", g_acq_state.stats.num_acq_total);
	d_printf(D_INFO, "s.num_alloc_err_total = %llu                    ", g_acq_state.stats.num_alloc_err_total);
	d_printf(D_INFO, "s.num_alloc_total     = %llu                    ", g_acq_state.stats.num_alloc_total);
	d_printf(D_INFO, "s.num_err_total       = %llu                    ", g_acq_state.stats.num_err_total);
	d_printf(D_INFO, "s.num_post_total      = %llu                    ", g_acq_state.stats.num_post_total);
	d_printf(D_INFO, "s.num_pre_total       = %llu                    ", g_acq_state.stats.num_pre_total);
	d_printf(D_INFO, "s.num_pre_fill_total  = %llu                    ", g_acq_state.stats.num_pre_fill_total);
	d_printf(D_INFO, "s.num_samples         = %llu                    ", g_acq_state.stats.num_samples);
	d_printf(D_INFO, "s.num_samples_raw     = %llu                    ", g_acq_state.stats.num_samples_raw);
	d_printf(D_INFO, "s.num_irqs            = %llu                    ", g_acq_state.stats.num_irqs);
	d_printf(D_INFO, "s.num_fifo_full       = %llu                    ", g_acq_state.stats.num_fifo_full);
	d_printf(D_INFO, "s.num_fifo_pkt_dscd   = %llu                    ", g_acq_state.stats.num_fifo_pkt_dscd);
	d_printf(D_INFO, "s.num_fifo_stall_tot  = %llu                    ", g_acq_state.stats.num_fifo_stall_total);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "Approx acq. rate      = %d acq/s                ", (int)acq_rate);
	d_printf(D_INFO, "Approx sample rate    = %d Ksa/s                ", (int)sample_rate);
	d_printf(D_INFO, "Debug delta           = %d us                   ", (int)time_delta_us);
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "** End **                                       ");
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "                                                ");
	d_printf(D_INFO, "                                                ");

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
 * Pass a reference to the next entry in a linked list, checking for the end
 * of the list.
 *
 * @param	buff	Current waveform pointer
 * @param	next	Pointer to result for next waveform pointer; set to NULL if no next exists
 */
int acq_next_ll_pointer(struct acq_buffer_t *this, struct acq_buffer_t **next)
{
	D_ASSERT(this != NULL && next != NULL);

	if(this->next != NULL) {
		*next = this->next;
		return ACQRES_OK;
	}

	*next = NULL;
	return ACQRES_END_OF_WAVE_LL;
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

	//d_printf(D_INFO, "acq: trigger_at=0x%08x (sample:%d, sub_index:%d)", wave->trigger_at, wave->trigger_at >> 3, wave->trigger_at & 0x07);

	// If waveform is completed with trigger then copy it
	if(!(wave->trigger_at & TRIGGER_INVALID_MASK) && (wave->flags & ACQBUF_FLAG_PKT_DONE)) {
		Xil_DCacheInvalidateRange((INTPTR)wave->buff_acq, g_acq_state.total_buffsz);
		dmb();

		start = (((wave->trigger_at >> 3) + 1) * 2);
		end = g_acq_state.pre_sampct * 2;

		d_printf(D_EXINFO, "X. pointer: 0x%08x", wave->buff_acq);

		d_printf(D_EXINFO, "0. pointer: 0x%08x, start: %6d, bytes: %6d, end: %6d", wave->buff_acq + start, start * 4, (end - start) * 4, ((start * 4) + ((end - start) * 4)));

		memcpy(buffer, wave->buff_acq + start, (end - start) * 4);
		buffer += (end - start);

		d_printf(D_EXINFO, "1. pointer: 0x%08x, start: %6d, bytes: %6d, end: %6d", wave->buff_acq, 0, start * 4, start * 4);

		memcpy(buffer, wave->buff_acq, start * 4);
		buffer += start;

		start = g_acq_state.pre_sampct * 2;
		end = (g_acq_state.pre_sampct + g_acq_state.post_sampct) * 2;

		d_printf(D_EXINFO, "2. pointer: 0x%08x, start: %6d, bytes: %6d, end: %6d", wave->buff_acq + start, start * 4, (end - start) * 4, ((start * 4) + ((end - start) * 4)));

		memcpy(buffer, wave->buff_acq + start, (end - start) * 4);
		buffer += start;
	} else {
		return ACQRES_WAVE_NOT_READY;
	}
}

/*
 * Return the pointers to be used to copy a given waveform.  These
 * pointers will be used to do DMA copies to the MIPI peripherals,
 * or for other tasks.
 *
 * @param	wave	Pointer to the waveform struct to provide pointers for
 * @param	buff	Pointer to an addr_helper struct
 *
 * @return	ACQRES_OK if successful, ACQRES_WAVE_NOT_READY if waveform not
 * 			ready for pointer calculation (e.g. unfilled.)
 */
void acq_dma_address_helper(struct acq_buffer_t *wave, struct acq_dma_addr_t *addr_helper)
{
	uint32_t start, end;

	D_ASSERT(wave != NULL);
	D_ASSERT(addr_helper != NULL);

	if((wave->trigger_at & TRIGGER_INVALID_MASK) || !(wave->flags & ACQBUF_FLAG_PKT_DONE)) {
		return ACQRES_WAVE_NOT_READY;
	}

	//start = ACQ_TRIGGER_AT_TO_32PTR(wave->trigger_at);
	//end = ACQ_64SAMPCT_TO_32PTR(wave->pre_sz);

	start = ACQ_TRIGGER_AT_TO_BYPTR(wave->trigger_at);
	end = wave->pre_sz;

	addr_helper->pre_upper_start = wave->buff_acq + start;
	addr_helper->pre_upper_end = addr_helper->pre_upper_start + end - start;

	addr_helper->pre_lower_start = wave->buff_acq;
	addr_helper->pre_lower_end = addr_helper->pre_lower_start + start;

	addr_helper->post_start = wave->buff_acq + end;
	addr_helper->post_end = addr_helper->post_start + wave->post_sz;

	return ACQRES_OK;
}

/*
 * Helper function to get the size of the present waveform configuration,
 * used by external callers.
 *
 * If the acquisition has not been initialised, this function might return
 * garbage or invalid values.
 *
 * @param	region		bitmask of type ACQ_REGION_x
 */
unsigned int acq_get_wave_size_bytes(int region)
{
	unsigned int size = 0;

	if(region & ACQ_REGION_PRE)
		size += g_acq_state.pre_buffsz;

	if(region & ACQ_REGION_POST)
		size += g_acq_state.post_buffsz;

	return size;
}

/*
 * Get the waveform bit depth.  Returns 8, 12, or 14.
 */
int acq_get_wave_bit_depth()
{
	int res = 0;

	if(g_acq_state.acq_mode_flags & ACQ_MODE_8BIT)
		res = 8;

	if(g_acq_state.acq_mode_flags & ACQ_MODE_12BIT)
		res = 12;

	if(g_acq_state.acq_mode_flags & ACQ_MODE_14BIT)
		res = 14;

	return res;
}

/*
 * Get the packed waveform bit depth.  Returns 8 or 16.
 */
int acq_get_wave_bit_packed_depth()
{
	int res = 0;

	if(g_acq_state.acq_mode_flags & ACQ_MODE_8BIT)
		res = 8;

	if(g_acq_state.acq_mode_flags & (ACQ_MODE_12BIT | ACQ_MODE_14BIT))
		res = 16;

	return res;
}

/*
 * mipi_csi.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: ?
 *      Author: Tom
 */

/*
 * Control for the PL fabric MIPI CSI transmitter, used to move large blocks
 * of data into the CM3.
 *
 * Transfers are copied from acquistion memory in DDR3 into a 64K BRAM block
 * on the FPGA.  Transfers are copied into the low and high addresses alternately
 * with the CSI peripheral transmitting data from the alternate section as
 * it becomes available.
 *
 * This module only handles the copy of data to the CSI buffer.  The CSI buffer
 * may be post-processed by a DSP core, with its own latencies.  The software
 * does not currently implement support for this DSP core.  The CSI buffer will
 * also need to be demuxed for multi channel operations.
 */

#include "mipi_csi.h"
#include "acquire.h"
#include "hal.h"

struct mcsi_state_t g_mcsi_state;

/*
 * Initialise the MCSI controller.  It is not permitted to call this function more than once.
 */
void mcsi_init()
{
	g_mcsi_state.state = MCSI_STATE_IDLE;
	g_mcsi_state.flags = MCSI_FLAG_USE_MEMCPY;
	g_mcsi_state.mipi_line_size = 2048;
}

/*
 * Setup a simple transfer of a single waveindex by the waveindex ID.  If the ID is not
 * found an error is returned and the transfer is not started.
 */
int mcsi_setup_transfer_by_id(uint32_t wave_id)
{
	struct acq_buffer_t *wave;

	d_assert(g_mcsi_state.state == MCSI_STATE_IDLE) ;

	res = acq_get_ll_pointer(wave_id, &wave);

	if(res != ACQRES_OK) {
		return MCSI_RES_WAVE_ERROR;
	}

	d_assert(wave != NULL) ;

	// n.b. IRQs should be disabled here to avoid interrupt contention of global resource
	g_mcsi_state.wave = buffer;
	g_mcsi_state.wave_start = buffer;
	g_mcsi_state.wave_end = buffer;
	g_mcsi_state.flags |= MCSI_FLAG_TX_SINGLE;
	g_mcsi_state.flags &= ~MCSI_FLAG_TX_MULTI;
}

/*
 * Setup a multi transfer of a range of waveindex.  wave_start MUST be less than
 * wave_end.
 */
void mcsi_setup_multi_transfer_by_id(uint32_t wave_start, uint32_t wave_end)
{
	struct acq_buffer_t *b_start, *b_end;

	d_assert(g_mcsi_state.state == MCSI_STATE_IDLE) ;
	d_assert(wave_start < wave_end) ;

	res = acq_get_ll_pointer(wave_start, &b_start);

	if(res != ACQRES_OK) {
		return MCSI_RES_WAVE_ERROR;
	}

	res = acq_get_ll_pointer(wave_end, &b_end);

	if(res != ACQRES_OK) {
		return MCSI_RES_WAVE_ERROR;
	}

	d_assert(b_start->idx < b_end->idx) ;
	d_assert(wave_start != NULL) ;
	d_assert(wave_end != NULL) ;

	// n.b. IRQs should be disabled here to avoid interrupt contention of global resource
	g_mcsi_state.wave = b_start;
	g_mcsi_state.wave_start = b_start;
	g_mcsi_state.wave_end = b_end;
	g_mcsi_state.flags |= MCSI_FLAG_TX_MULTI;
	g_mcsi_state.flags &= ~MCSI_FLAG_TX_SINGLE;
}

/*
 * Start the requested transfer.
 */
void mcsi_start()
{
	d_assert(g_mcsi_state.state == MCSI_STATE_IDLE) ;

	g_mcsi_state.state = MCSI_STATE_RUN;
}

/*
 * Tick processor.  This checks the state of transfers and executes a new transfer if required.
 *
 * This should be run in the application infinite loop.
 */
void mcsi_tick()
{
	uint32_t tot_sz;
	uint32_t bram_addr;

	/*
	 * While we are testing without DMA, packets are just transferred using memcpy,
	 * which blocks the tick while it executes.
	 */
	switch(g_mcsi_state.state) {
		case MCSI_STATE_RUN:
			if(g_mcsi_state.flags & MCSI_FLAG_USE_MEMCPY) {
				/*
				 * Transfer data into either the 'A' buffer or the 'B' buffer.  If the transfer is too big for
				 * one operation, it is broken up into multiple separate transfers.  We start at the 'A' buffer
				 * and at the beginning of the first waveform.
				 */
				tot_sz = g_mcsi_state.wave->pre_sz + g_mcsi_state.wave->post_sz;
				if(tot_sz > MCSI_MAX_BUFFER_BRAM_SIZE) {
					g_mcsi_state.flags |= MCSI_FLAG_OUTPUT_MULTI;
				} else {
					g_mcsi_state.flags &= ~MCSI_FLAG_OUTPUT_MULTI;
				}

				g_mcsi_state.buffer_id = 0;
				g_mcsi_state.cur_wave_offset = 0;
				g_mcsi_state.state = MCSI_STATE_TRANSFER_MEMCPY;
			} else {
				d_printf(D_ERROR, "Not implemented - DMA xfer");
			}
			break;

		case MCSI_STATE_TRANSFER_MEMCPY:
			// Transfer up to MCSI_MAX_BUFFER_BRAM_SIZE per waveform.  If the waveform is larger than this
			// it needs to be broken up into these sized transfers.
			bram_addr = MCSI_BRAM_BASE + (MCSI_BRAM_BASE_1_OFFSET * g_mcsi_state.buffer_id);
			tot_sz = g_mcsi_state.wave->pre_sz + g_mcsi_state.wave->post_sz;

			_mcsi_tx_memcpy(g_mcsi_state.wave, g_mcsi_state.cur_wave_offset, g_mcsi_state.bram_addr, MCSI_MAX_BUFFER_BRAM_SIZE);
			g_mcsi_state.cur_wave_offset += MCSI_MAX_BUFFER_BRAM_SIZE;

			if(g_mcsi_state.cur_wave_offset > tot_sz) {
				// Next waveform or end
				if(g_mcsi_state.wave == g_mcsi_state.wave_end) {
					// Advance to waiting for CSI to complete, but set flag indicating we're done
					g_mcsi_state.flags |= MCSI_FLAG_TX_ALL_DONE;
					g_mcsi_state.state = MCSI_STATE_WAITING_CSI;
				} else {
					d_assert(g_mcsi_state.wave->next != NULL) ;
					g_mcsi_state.wave = g_mcsi_state.wave->next;
					g_mcsi_state.state = MCSI_STATE_WAITING_CSI;
				}
			}
			break;

		case MCSI_STATE_WAITING_CSI:
			// pretend CSI tx happens immediately
			g_mcsi_state.buffer_id = 1 - g_mcsi_state.buffer_id;
			g_mcsi_state.cur_wave_offset = 0;
			g_mcsi_state.state = MCSI_STATE_TRANSFER_MEMCPY;
			break;
	}

	d_printf(D_INFO, "mcsi_tick: state=%d, buffer_id=%d", g_mcsi_state.state, g_mcsi_state.buffer_id);
}

/*
 * Internal helper function for memcpy transfer method.
 */
void _mcsi_tx_memcpy(struct acq_buffer_t *buf, uint32_t offset_src, uint32_t bram_des, uint32_t bytes_max)
{
	d_printf(D_INFO, "_mcsi_tx_memcpy: tx_offset=0x%08x (%d), bram_des=0x%08x, bytes_max=%d", \
			offset_src, offset_src, bram_des, bytes_max);
}

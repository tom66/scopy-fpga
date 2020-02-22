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
	int res;
	struct acq_buffer_t *wave;

	D_ASSERT(g_mcsi_state.state == MCSI_STATE_IDLE) ;

	res = acq_get_ll_pointer(wave_id, &wave);

	if(res != ACQRES_OK) {
		return MCSI_RES_WAVE_ERROR;
	}

	D_ASSERT(wave != NULL) ;

	// n.b. IRQs should be disabled here to avoid interrupt contention of global resource
	g_mcsi_state.wave = wave;
	g_mcsi_state.wave_start = wave;
	g_mcsi_state.wave_end = wave;
	g_mcsi_state.flags |= MCSI_FLAG_TX_SINGLE;
	g_mcsi_state.flags &= ~MCSI_FLAG_TX_MULTI;
}

/*
 * Setup a multi transfer of a range of waveindex.  wave_start MUST be less than
 * wave_end.  If an ID is not found an error is returned and the transfer is not
 * started.
 */
int mcsi_setup_multi_transfer_by_id(uint32_t wave_start, uint32_t wave_end)
{
	int res;
	struct acq_buffer_t *w_start, *w_end;

	D_ASSERT(g_mcsi_state.state == MCSI_STATE_IDLE);
	D_ASSERT(wave_start < wave_end);

	res = acq_get_ll_pointer(wave_start, &w_start);

	if(res != ACQRES_OK) {
		return MCSI_RES_WAVE_ERROR;
	}

	res = acq_get_ll_pointer(wave_end, &w_end);

	if(res != ACQRES_OK) {
		return MCSI_RES_WAVE_ERROR;
	}

	D_ASSERT(w_start->idx < w_end->idx);
	D_ASSERT(w_start != NULL);
	D_ASSERT(w_end != NULL);

	// n.b. IRQs should be disabled here to avoid interrupt contention of global resource
	g_mcsi_state.wave = w_start;
	g_mcsi_state.wave_start = w_start;
	g_mcsi_state.wave_end = w_end;
	g_mcsi_state.flags |= MCSI_FLAG_TX_MULTI;
	g_mcsi_state.flags &= ~MCSI_FLAG_TX_SINGLE;
}

/*
 * Start the requested transfer.
 */
void mcsi_start()
{
	D_ASSERT(g_mcsi_state.state == MCSI_STATE_IDLE) ;

	g_mcsi_state.state = MCSI_STATE_RUN;
}

/*
 * Tick processor.  This checks the state of transfers and executes a new transfer if required.
 *
 * This should be run in the application infinite loop.
 */
void mcsi_tick()
{
	uint32_t tot_sz, tx_sz;
	uint32_t bram_addr;

	/*
	 * While we are testing without DMA, packets are just transferred using memcpy,
	 * which blocks the tick while it executes.
	 */
	switch(g_mcsi_state.state) {
		case MCSI_STATE_IDLE:
			break;

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
				g_mcsi_state.bram_addr = MCSI_BRAM_BASE;
				g_mcsi_state.bram_offs = 0;
				g_mcsi_state.state = MCSI_STATE_TRANSFER_MEMCPY;
			} else {
				d_printf(D_ERROR, "Not implemented - DMA xfer");
			}
			break;

		case MCSI_STATE_TRANSFER_MEMCPY:
			// Transfer up to MCSI_MAX_BUFFER_BRAM_SIZE per waveform.  If the waveform is larger than this
			// it needs to be broken up into smaller size transfers.
			D_ASSERT(g_mcsi_state.buffer_id == 0 || g_mcsi_state.buffer_id == 1) ;
			tot_sz = g_mcsi_state.wave->pre_sz + g_mcsi_state.wave->post_sz;
			tx_sz = MIN(tot_sz, MCSI_MAX_BUFFER_BRAM_SIZE);

			d_printf(D_INFO, "mcsi_tick: tx_sz=%d, tot_sz=%d", tx_sz, tot_sz);

			_mcsi_tx_memcpy(g_mcsi_state.wave, g_mcsi_state.cur_wave_offset, g_mcsi_state.bram_addr, tx_sz);
			g_mcsi_state.cur_wave_offset += tx_sz;
			g_mcsi_state.bram_addr += tx_sz;
			g_mcsi_state.bram_offs += tx_sz;

			if(g_mcsi_state.bram_offs >= MCSI_MAX_BUFFER_BRAM_SIZE) {
				if(g_mcsi_state.buffer_id == 0) {
					g_mcsi_state.flags |= MCSI_FLAG_BUF_A_VALID;
				} else if(g_mcsi_state.buffer_id == 1) {
					g_mcsi_state.flags |= MCSI_FLAG_BUF_B_VALID;
				}

				g_mcsi_state.buffer_id = 0; // 1 - g_mcsi_state.buffer_id;
				g_mcsi_state.bram_addr = MCSI_BRAM_BASE + (MCSI_MAX_BUFFER_BRAM_SIZE * g_mcsi_state.buffer_id);
			}

			if(g_mcsi_state.cur_wave_offset >= tot_sz) {
				// Next waveform or end
				if(g_mcsi_state.wave == g_mcsi_state.wave_end) {
					// Advance to waiting for CSI to complete, but set flag indicating we're done
					g_mcsi_state.flags |= MCSI_FLAG_TX_ALL_DONE;
					g_mcsi_state.state = MCSI_STATE_WAITING_CSI;
				} else {
					D_ASSERT(g_mcsi_state.wave->next != NULL) ;
					g_mcsi_state.wave = g_mcsi_state.wave->next;
					g_mcsi_state.state = MCSI_STATE_WAITING_CSI;
				}
			}
			break;

		case MCSI_STATE_WAITING_CSI:
			// pretend CSI tx happens immediately: normally we would wait here for CSI peripheral to signal us;
			// but do it in a re-entrant manner, so the rest of this block does not execute if nDONE.
			// ...

			// We need to check and see if the buffer is full before sending a CSI request.  If it's
			// not full then we should fall back to continuing the TX.

			// If the transfer is done then return to the IDLE state.
			if(g_mcsi_state.flags & MCSI_FLAG_TX_ALL_DONE) {
				g_mcsi_state.state = MCSI_STATE_IDLE;
			} else {
				g_mcsi_state.cur_wave_offset = 0;

				if(g_mcsi_state.flags & MCSI_FLAG_USE_MEMCPY) {
					g_mcsi_state.state = MCSI_STATE_TRANSFER_MEMCPY;
				} else {
					d_printf(D_ERROR, "Not implemented - DMA xfer");
				}
			}
			break;
	}

	d_printf(D_INFO, "mcsi_tick: state=%d, buffer_id=%d, wave->idx=%d", \
			g_mcsi_state.state, g_mcsi_state.buffer_id, g_mcsi_state.wave->idx);
}

/*
 * Internal helper function for memcpy transfer method.
 */
void _mcsi_tx_memcpy(struct acq_buffer_t *wave, uint32_t offset_src, uint32_t bram_des, uint32_t bytes_max)
{
	uint32_t start, end, length;
	uint32_t *bram_ptr = (uint32_t *)bram_des;

	d_printf(D_INFO, "_mcsi_tx_memcpy: tx_offset=0x%08x (%d), bram_des=0x%08x, bytes_max=%d", \
			offset_src, offset_src, bram_des, bytes_max);

	if(!(wave->trigger_at & TRIGGER_INVALID_MASK) && (wave->flags & ACQBUF_FLAG_PKT_DONE)) {
		Xil_DCacheInvalidateRange((INTPTR)wave->buff_acq, wave->pre_sz + wave->post_sz);
		dmb();

		start = (((wave->trigger_at >> 3) + 1) * 2);
		end = g_acq_state.pre_sampct * 2; // change this to wave->pre_sz in some way ??
		length = (end - start) * 4;

		// Use our bounded memcpy to do the transfer; ending operations if out of bounds
		if(_mcsi_tx_memcpy_assist_bounded(bram_ptr, wave->buff_acq + start, length, MCSI_BRAM_END) != MCSI_RES_OK)
			return;

		bram_ptr += (end - start);
		length = start * 4;

		if(_mcsi_tx_memcpy_assist_bounded(bram_ptr, wave->buff_acq, start * 4, MCSI_BRAM_END) != MCSI_RES_OK)
			return;

		bram_ptr += start;

		// XXX: FIXME: HORRIBLE HACK:  BRAM is too small.  Omit last 8 bytes from post-trigger.
		start = g_acq_state.pre_sampct * 2;
		end = ((g_acq_state.pre_sampct + g_acq_state.post_sampct) * 2) - 8;  // change this to wave->pre/post_sz in some way ??

		if(_mcsi_tx_memcpy_assist_bounded(bram_ptr, wave->buff_acq + start, (end - start) * 4, MCSI_BRAM_END) != MCSI_RES_OK)
			return;

		d_printf(D_INFO, "done copy");
	}
}

/*
 * Bounded memcopy.  Will not overflow defined range and will return a state signal
 * if an overflow would occur with a non-bounded copy.
 */
int _mcsi_tx_memcpy_assist_bounded(void *base, void *src, size_t length, uint32_t addr_limit)
{
	int res = MCSI_RES_OK;
	uint32_t end = (uint32_t)base + length;

	d_printf(D_INFO, "_mcsi_tx_memcpy_assist_bounded: base=0x%08x, src=0x%08x, end=0x%08x, length=0x%08x (%d), addr_limit=0x%08x", \
			base, src, end, length, length, addr_limit);

	if(end >= addr_limit) {
		end = addr_limit;
		length = end - (uint32_t)base;
		res = MCSI_RES_MEMCPY_BOUND;

		d_printf(D_INFO, "_mcsi_tx_memcpy_assist_bounded: clip end address to 0x%08x", end);
	}

	memcpy(base, src, length);

	return res;
}



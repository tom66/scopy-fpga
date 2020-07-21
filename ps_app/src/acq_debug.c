/*
 * acq_debug.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 19 Jul 2020
 *      Author: Tom
 */

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <errno.h>
#include <malloc.h>

#include "acquire.h"
#include "acq_debug.h"
#include "hal.h"

const char *acq_state_to_str[] = {
	"ACQSTATE_UNINIT", "ACQSTATE_STOPPED", "ACQSTATE_PREP", "ACQSTATE_WAIT_TRIG", "ACQSTATE_RUNNING", "ACQSTATE_DONE", "ACQSTATE_ERROR"
};

const char *acq_substate_to_str[] = {
	"ACQSUBST_NONE", "ACQSUBST_PRE_TRIG_FILL", "ACQSUBST_PRE_TRIG_WAIT", "ACQSUBST_POST_TRIG", "ACQSUBST_DONE_WAVE", "ACQSUBST_DONE_ALL"
};

/*
 * To keep the acquisition file smaller and easier to read, most of the debug
 * routines are placed in this file.
 */

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
	d_printf(D_INFO, "acq_done_current      = 0x%08x                  ", g_acq_state.acq_done_current);
	d_printf(D_INFO, "acq_done_first        = 0x%08x                  ", g_acq_state.acq_done_first);
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
	d_printf(D_INFO, "num_acq_made_done     = %7d waves               ", g_acq_state.num_acq_made_done);
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
 * Dump the LL structure for debugging purposes.
 */
void acq_debug_ll_dump(struct acq_buffer_t *base, char *str)
{
	struct acq_buffer_t *wave = base;

	d_printf(D_INFO, "** Acquisition Linked List State for 0x%08x %s **", base, str);
	d_printf(D_INFO, "");

	while(wave != NULL) {
		d_printf(D_INFO, "info = 0x%08x, buffer = 0x%08x, next = 0x%08x, flags = 0x%04x, index = %8d", wave, wave->buff_acq, wave->next, wave->flags, wave->idx);
		wave = wave->next;
	}

	d_printf(D_INFO, "");
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
 * Dump information from a wave N.
 *
 * @param	index	Index of wave to dump. Function will explore LL to find the waveform.
 */
void acq_debug_dump_wave(int index, int list)
{
	struct acq_buffer_t *wave;

	D_ASSERT(list == ACQLIST_ACQ || list == ACQLIST_DONE);

	if(acq_get_ll_pointer(index, &wave, list) != ACQRES_OK) {
		d_printf(D_ERROR, "Unable to dump for waveindex %d: couldn't find wave", index);
		return;
	}

	acq_debug_dump_wave_pointer(wave);
}

/*
 * Dump a single word line, with trigger colouring.
 *
 * @param	index		index to print prior to word value
 * @param	wordptr		word pointer
 * @param	trig		trigger level (0x00 - 0xff)
 * @param	rf			rise = 'r', fall = 'f'
 * @param	pretrig		colour to use pre-trigger (ANSI escape seq.)
 * @param	posttrig	colour to use post-trigger (ANSI escape seq.)
 * @param	subpos		0-7 sub position, shades the relevant column
 * @param	mode		0 = colour according to intensity, 1 = colour according to pre/post trig colour
 */
void acq_debug_dump_wordline(int index, uint8_t *wordptr, uint8_t trig, char rf, uint8_t pretrig, uint8_t posttrig, uint8_t subpos, int mode)
{
	uint8_t byte;
	uint8_t col = 0, bgcol = 0;
	int r, g, b, i;

	rf = tolower(rf);
	D_ASSERT(rf == 'r' || rf == 'f');

	d_printf(D_RAW, "\033[%dm %6d  \033[0m", posttrig, index);

	for(i = 0; i < 8; i++) {
		byte = *wordptr++;

		if(i == subpos) {
			bgcol = 100;
		} else {
			bgcol = 40;
		}

		if(rf == 'r') {
			if(byte >= trig) {
				col = posttrig;
			} else {
				col = pretrig;
			}
		} else if(rf == 'f') {
			if(byte <= trig) {
				col = posttrig;
			} else {
				col = pretrig;
			}
		}

		if(mode == 0) {
			d_printf(D_RAW, "\033[%d;%d", col, bgcol);
		} else if(mode == 1) {
			r = 16 + ((224 * (int)byte) / 256);
			g = 16 + ((676 * (int)byte) / 256);

			if(r > 255) {
				r = 255;
			}

			if(g > 255) {
				g = 255;
			}

			b = r;

			d_printf(D_RAW, "\033[38;2;%d;%d;%d", r, g, b);
		}

		d_printf(D_RAW, "m%02x ", byte);
	}

	d_printf(D_RAW, "\033[0m\r\n");
}

/*
 * Dump information from a wave pointer.
 *
 * @param	wave		Pointer to the wave to dump.
 */
void acq_debug_dump_wave_pointer(struct acq_buffer_t *wave)
{
	uint32_t start, end;
	uint64_t word;
	int i;

	// Dump info about this wave
	d_printf(D_INFO, "");
	d_printf(D_INFO, "** Waveinfo for index %d **", wave->idx);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "buff_acq address      = 0x%08x", wave->buff_acq);
	d_printf(D_INFO, "buff_alloc address    = 0x%08x", wave->buff_alloc);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "idx                   = %d", wave->idx);
	d_printf(D_INFO, "flags                 = 0x%04x", wave->flags);
	d_printf(D_INFO, "trigger_at            = 0x%08x (%d) (subpos:%d)", wave->trigger_at, wave->trigger_at, wave->trigger_at & 0x07);
	d_printf(D_INFO, "trigger_at(div8)      = 0x%08x (%d)", wave->trigger_at >> 3, wave->trigger_at >> 3);
	d_printf(D_INFO, "trigger_at(div16)     = 0x%08x (%d)", wave->trigger_at >> 4, wave->trigger_at >> 4);
	d_printf(D_INFO, "");

	// If waveform is completed with trigger then display it
	if(!(wave->trigger_at & TRIGGER_INVALID_MASK)) {
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

		//addr_start = wave->buff_acq;

		start = (((wave->trigger_at >> 3) + 1) * 2);
		end = g_acq_state.pre_sampct * 2;

		//d_printf(D_INFO, "sz=%d, start=%d, end_post=%d", end, start, end_post);

		d_printf(D_RAW, " bytepos word\r\n");

		for(i = start; i < end; i += 2) {
			//d_printf(D_RAW, "\033[96m%8d 0x%08x 0x%08x\033[0m\r\n", i * 4, (wave->buff_acq[i]), (wave->buff_acq[i + 1]));
			acq_debug_dump_wordline(i * 4, (uint8_t*)(&wave->buff_acq[i]), 0x7f, 'r', 36, 96, wave->trigger_at & 0x07, 0);
		}

		for(i = 0; i < start; i += 2) {
			//d_printf(D_RAW, "\033[95m%8d 0x%08x 0x%08x\033[0m\r\n", i * 4, (wave->buff_acq[i]), (wave->buff_acq[i + 1]));
			acq_debug_dump_wordline(i * 4, (uint8_t*)(&wave->buff_acq[i]), 0x7f, 'r', 35, 95, wave->trigger_at & 0x07, 0);
		}

		start = g_acq_state.pre_sampct * 2;
		end = (g_acq_state.pre_sampct + g_acq_state.post_sampct) * 2;

		for(i = start; i < end; i += 2) {
			//d_printf(D_RAW, "\033[97m%8d 0x%08x 0x%08x\033[0m\r\n", i * 4, (wave->buff_acq[i]), (wave->buff_acq[i + 1]));
			acq_debug_dump_wordline(i * 4, (uint8_t*)(&wave->buff_acq[i]), 0x7f, 'r', 33, 93, wave->trigger_at & 0x07, 0);
		}
	} else {
		d_printf(D_ERROR, "Trigger invalid for waveindex %d or wave not done", wave->idx);
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
	res = acq_get_ll_pointer(index, &wave, ACQLIST_DONE);

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
 * @param	wave			Pointer to the waveform struct to provide pointers for
 * @param	addr_helper		Pointer to an addr_helper struct
 *
 * @return	ACQRES_OK if successful, ACQRES_WAVE_NOT_READY if waveform not
 * 			ready for pointer calculation (e.g. unfilled.)
 */
int acq_dma_address_helper(struct acq_buffer_t *wave, struct acq_dma_addr_t *addr_helper)
{
	uint32_t start, end;

	D_ASSERT(wave != NULL);
	D_ASSERT(addr_helper != NULL);

	//d_printf(D_INFO, "0x%08x 0x%02x", wave->trigger_at, wave->flags);

	if((wave->trigger_at & TRIGGER_INVALID_MASK) || !(wave->flags & ACQBUF_FLAG_READY_CSI)) {
		//d_printf(D_WARN, "wave_invalid trig=0x%08x flags=0x%04x idx=%d", wave->trigger_at, wave->flags, wave->idx);
		return ACQRES_WAVE_NOT_READY;
	}

	//start = ACQ_TRIGGER_AT_TO_32PTR(wave->trigger_at);
	//end = ACQ_64SAMPCT_TO_32PTR(wave->pre_sz);

	start = ACQ_TRIGGER_AT_TO_BYPTR(wave->trigger_at);
	end = wave->pre_sz;

	addr_helper->pre_upper_start = (uint32_t)wave->buff_acq + start;
	addr_helper->pre_upper_end = addr_helper->pre_upper_start + end - start;

	addr_helper->pre_lower_start = (uint32_t)wave->buff_acq;
	addr_helper->pre_lower_end = addr_helper->pre_lower_start + start;

	addr_helper->post_start = (uint32_t)wave->buff_acq + wave->pre_sz;
	addr_helper->post_end = addr_helper->post_start + wave->post_sz;

	addr_helper->wave_base = (uint32_t)wave->buff_acq;  // Alias for pre_lower_start but keeps the values distinct for future changes
	addr_helper->flags = ACQBUF_ALL_FLAGS;

	return ACQRES_OK;
}

/*
 * Dump debug info for the passed address helper and wave.
 *
 * @param	wave			Pointer to the waveform struct for the address helper
 * @param	addr_helper		Pointer to an addr_helper struct
 */
void acq_dma_address_helper_debug(struct acq_buffer_t *wave, struct acq_dma_addr_t *addr_helper)
{
	d_printf(D_RAW, "WaveBase = 0x%08x, Trigger = 0x%08x, PrLS = 0x%08x, PrLE = 0x%08x, PrUS = 0x%08x, PrUE = 0x%08x, PoS = 0x%08x, PoE = 0x%08x, WavIdx = %3d, N = 0x%08x\r\n", \
			wave->buff_acq, wave->trigger_at, \
			addr_helper->pre_lower_start, addr_helper->pre_lower_end, \
			addr_helper->pre_upper_start, addr_helper->pre_upper_end, \
			addr_helper->post_start, addr_helper->post_end,  wave->idx, wave->next);

	d_printf(D_RAW, "DeBASED:                                     PrLS = 0x%08x, PrLE = 0x%08x, PrUS = 0x%08x, PrUE = 0x%08x, PoS = 0x%08x, PoE = 0x%08x\r\n\r\n", \
			addr_helper->pre_lower_start - (uint32_t)wave->buff_acq, addr_helper->pre_lower_end - (uint32_t)wave->buff_acq, \
			addr_helper->pre_upper_start - (uint32_t)wave->buff_acq, addr_helper->pre_upper_end - (uint32_t)wave->buff_acq, \
			addr_helper->post_start - (uint32_t)wave->buff_acq, addr_helper->post_end - (uint32_t)wave->buff_acq);
}

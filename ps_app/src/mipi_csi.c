/*
 * mipi_csi.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 25 Apr 2020
 *      Author: Tom
 */

/*
 * Revised MIPI streaming core.  Handles the high speed transfer of data from
 * the Zynq PL memory domain or PS memory domain to the CM3.
 *
 * All data transfers happen in lines and frames.  Each frame is sized to be
 * large enough to be packed into a buffer on the CM3.  The buffers are guaranteed
 * to be transmitted in order and assembled correctly in order.
 *
 * If a transfer is larger than one frame, it is transmitted across multiple
 * frames.  Transfers shorter than the desired frame size are transmitted to the
 * nearest multiple line size; data beyond the frame is not defined.
 *
 * Transfers are controlled by the Scatter-Gather core on the Zynq FPGA.  The core
 * processes only one chain of BDs at any one time in this configuration.
 *
 * Once the current task is done, the next task is loaded. If there are no tasks
 * remaining, the core goes idle.
 */

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <errno.h>
#include <malloc.h>

#include "mipi_csi.h"
#include "mipi_csi_hw.h"

#include "system_control.h"
#include "acquire.h"
#include "acq_debug.h"
#include "hal.h"
#include "fabric_config.h"
#include "spi.h"
#include "dma_bd.h"
#include "queue.h" // Collections-C
#include "deque.h" // Collections-C

#include "xaxidma.h"
#include "xscugic.h"

struct mipi_csi_state_t g_mipi_csi_state;

int g_frame_ctr = 0;

/*
 * Initialise the MIPI CSI controller.  Sets up the queue and resets
 * fabric control variables to zero.  Initialises the DMA.
 */
void mipi_csi_init()
{
	int status;
	QueueConf q_conf;

	d_printf(D_INFO, "mipi_csi: initialising...");

	/*
	 * Set up the task queue.
	 */
	queue_conf_init(&q_conf);
	q_conf.capacity = MCSI_QUEUE_SIZE;

	status = queue_new_conf(&q_conf, &g_mipi_csi_state.item_queue) ;

	if(status != CC_OK) {
		d_printf(D_ERROR, "mipi_csi: error initialising queue: %d", status);
		return;
	}

	d_printf(D_INFO, "mipi_csi: queue initialised");

	/*
	 * Initialise the AXI DMA peripheral.
	 */
	g_mipi_csi_state.mipi_dma_config = XAxiDma_LookupConfig(XPAR_MIPI_DMA_DEVICE_ID);
	status = XAxiDma_CfgInitialize(&g_mipi_csi_state.mipi_dma, g_mipi_csi_state.mipi_dma_config);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: error initialising AXIDMA: %d", status);
		return;
	}

	status = XAxiDma_Selftest(&g_mipi_csi_state.mipi_dma);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: error during self test for AXIDMA: %d", status);
		return;
	}

	// Ensure scatter-gather is built into the peripheral
	D_ASSERT(XAxiDma_HasSg(&g_mipi_csi_state.mipi_dma));
	d_printf(D_INFO, "mipi_csi: DMA config: has_mm2s=%d, has_s2mm=%d", g_mipi_csi_state.mipi_dma.HasMm2S, g_mipi_csi_state.mipi_dma.HasS2Mm);
	d_printf(D_INFO, "mipi_csi: DMA initialisation done");

	XAxiDma_IntrDisable(&g_mipi_csi_state.mipi_dma, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(&g_mipi_csi_state.mipi_dma, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

	/*
	 * Prepare the peripheral with default settings and initial state machine position.
	 */
	g_mipi_csi_state.csi_bitclock = CSI_DEFAULT_BIT_CLOCK;
	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, g_mipi_csi_state.csi_bitclock);

	//g_mipi_csi_state.flags |= MCSI_FLAG_CLOCK_IDLE_MODE_1;
	g_mipi_csi_state.flags |= MCSI_FLAG_CLOCK_IDLE_MODE_2;
	g_mipi_csi_state.state = MCSI_ST_IDLE;
	g_mipi_csi_state.working = NULL;
	g_mipi_csi_state.csi_line_size = MCSI_DEFAULT_LINE_WIDTH;
	g_mipi_csi_state.csi_line_count = MCSI_DEFAULT_LINE_COUNT;
	mipi_csi_set_datatype_and_frame_wct(MCSI_DEFAULT_DATA_TYPE, MCSI_DEFAULT_WCT);

	/*
	 * Create the DMA BD ring which stores our allocation of BD entries (a replacement
	 * for the byzantine and buggy Xilinx library.)
	 */
	dma_bd_create_ring(&g_mipi_csi_state.bd_ring);

	/*
	 * Allocate the header block.  Must be in main RAM (not on stack) and 32-byte aligned.
	 */
	g_mipi_csi_state.header = memalign(32, sizeof(struct mipi_csi_wave_header_t));

	if(g_mipi_csi_state.header == NULL) {
		d_printf(D_ERROR, "mipi_csi: unable to allocate %d bytes for wave header", sizeof(struct mipi_csi_wave_header_t));
		return;
	}

	d_printf(D_ERROR, "mipi_csi: header block at 0x%08x", g_mipi_csi_state.header);
}

/*
 * Set the default datatype and frame wordcount to be used for future
 * queued elements.
 */
void mipi_csi_set_datatype_and_frame_wct(uint8_t data_type, uint16_t frame_wct)
{
	// Datatypes 0x00 ~ 0x03 reserved; all others fair game.  Datatype includes VC ID.
	if(COND_UNLIKELY(data_type >= 0x00 && data_type <= 0x03)) {
		d_printf(D_ERROR, "mipi_csi: attempt to use reserved datatype (0x00 ~ 0x03); ignoring request to change DT");
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		return;
	}

	g_mipi_csi_state.csi_data_type = data_type;
	g_mipi_csi_state.csi_frame_wct = frame_wct;

	d_printf(D_INFO, "mipi_csi: data_type=0x%02x, wct=0x%04x", data_type, frame_wct);
}

/*
 * Create a Scatter-Gather list for a given address range, which can be passed
 * to the AXIDMA module to stream arbitrary memory data.
 *
 * Portions based on dma_ex_sg_v2_1 (Xilinx)
 *
 * @param	addr_start		Start address.  Must be 32-bit aligned.
 * @param	addr_end		End address.  Must be 32-bit aligned, and greater or equal
 */
#if 0
int mipi_csi_generate_sg_list_for_buffer_range(uint32_t addr_start, uint32_t addr_end, struct mipi_csi_stream_queue_item_t *q_item)
{
	XAxiDma_BdRing *ring;
	XAxiDma_Bd *bd_ptr;
	XAxiDma_Bd *cur_bd_ptr;
	uint32_t *buff = (uint32_t*)addr_start;
	uint32_t xfer_size = 0, pk_size = 0;
	uint32_t bd_size;
	int32_t size, bd_entries;
	int i, status;
	bool sof, eof;

	d_start_timing(TMR_MIPI_SG_OVERALL);

	D_ASSERT((addr_start % 32) == 0);
	D_ASSERT((addr_end % 32) == 0);
	D_ASSERT(addr_end >= addr_start);

	size = addr_end - addr_start;
	q_item->ring = NULL;
	q_item->calculated_size = size;

	// Reset the DMA peripheral, terminating any existing transactions
	XAxiDma_Reset(&g_mipi_csi_state.mipi_dma);

	// Force a cache flush for the specified range
	//d_printf(D_INFO, "mipi_csi: cache flush 0x%08x size %d bytes", addr_start, addr_end - addr_start);
	Xil_DCacheFlushRange(addr_start, addr_end - addr_start);

	/*
	 * Free the old BD list, if it's present.  Then, attempt to create a new BD list,
	 * the size of which is equal to the number of MCSI_AXI_MAX_BD_SIZE chunks
	 * to be transmitted.
	 */
	if(g_mipi_csi_state.bd_area != NULL) {
		d_printf(D_INFO, "FreeBD=0x%08x I", g_mipi_csi_state.bd_area);
		free(g_mipi_csi_state.bd_area);
	}

	bd_entries = (size / MCSI_AXI_MAX_BD_SIZE);

	/*
	 * Account for off-by-one error (this won't be necessary after we move away from Xil stuff
	 * to pack the BD. [FIXME]
	 */
	bd_size = bd_entries * MCSI_AXI_MAX_BD_SIZE;
	if(bd_size < size) {
		bd_entries++;
	}

	g_mipi_csi_state.bd_area = (void *)memalign(XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries * XAXIDMA_BD_MINIMUM_ALIGNMENT);

	if(g_mipi_csi_state.bd_area == NULL) {
		d_printf(D_ERROR, "mipi_csi: fatal error allocating memory for DMA scatter-gather list!");
		exit(-1);
	}

	D_ASSERT(((uint32_t)g_mipi_csi_state.bd_area % XAXIDMA_BD_MINIMUM_ALIGNMENT) == 0);

	/*
	 * Attempt to set up the BDRing.  This function prints an error if things go
	 * wrong (and returns a failure code), so we just handle this condition with an assert.
	 */
	D_ASSERT(mipi_csi_setup_bdring_and_bd(g_mipi_csi_state.bd_area, bd_entries, &ring, &bd_ptr) == MCSI_RET_OK);

	/*
	 * Pack the entries into the BD. Each BD length must be less than 8MB, so large
	 * transfers are split up.
	 */
	cur_bd_ptr = bd_ptr;

	/*
	for(i = 0; i < bd_entries; i++) {
		pk_size = MIN(size, MCSI_AXI_MAX_BD_SIZE);
		sof = (i == 0);
		eof = (i == (bd_entries - 1));

		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, pk_size, (uint32_t*)buff, sof, eof);
		buff += MCSI_AXI_MAX_BD_SIZE;
		size -= pk_size;
		xfer_size += pk_size;
	}
	*/

	pk_size = addr_end - addr_start;
	_mipi_csi_axidma_add_bd_block(ring, bd_ptr, pk_size, (uint32_t*)buff, 1, 1);

	g_mipi_csi_state.transfer_size = pk_size;

	// Pass the BD to hardware for transmission
	//d_printf(D_INFO, "cur_bd=0x%08x stat=0x%08x", bd_ptr, XAxiDma_BdGetCtrl(bd_ptr));

	status = XAxiDma_BdRingToHw(ring, bd_entries, bd_ptr); // This function manages cache coherency for BDs
	if (status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error passing BD ring to hardware: %d", status);
		exit(-1);
	}

	d_stop_timing(TMR_MIPI_SG_OVERALL);

	q_item->ring = ring;
	return CSIRES_OK;
}
#endif

/*
 * Create a Scatter-Gather list for a given waveform range (MCSI_WAVE_ALL
 * not supported) which can be passed to the AXIDMA module to stream
 * waveform data.
 *
 * @param	wave_start		Starting wave index
 * @param	wave_end		Ending wave index - must be more than or equal to starting index
 *
 * @param	q_item			Item in queue for additional tag information
 */
int mipi_csi_generate_sg_list_for_waves(struct mipi_csi_stream_queue_item_t *q_item)
{
	static int iter = 0;
	int status, n_waves, i, n;
	// XAxiDma_Bd bd_template;
	struct acq_buffer_t *wave;
	struct acq_buffer_t *next;
	struct dma_bd_ring_t *ring = g_mipi_csi_state.bd_ring;
	struct acq_dma_addr_t addr_helper;
	uint32_t total_wave_sz, total_wave_bytes, expect_total_bytes, pad, line_pad;
	uint32_t working_ptr = 0;
	uint32_t trig_buffer_size = 0;
	uint32_t *trig_buffer_ptr;

	d_start_timing(TMR_MIPI_SG_OVERALL);

	D_ASSERT(q_item->config.wave_start <= q_item->config.wave_end);
	n_waves = (q_item->config.wave_end - q_item->config.wave_start);
	q_item->ring = NULL;
	q_item->calculated_size = 0;

	/*
	 * Get the first waveform.  This is also used to retrieve the size of the waveforms
	 * that is needed to compute the BD list size.
	 *
	 * Wave bounds checking is handled gracefully elsewhere, so this assert shouldn't
	 * be harmful.
	 */
	D_ASSERT(acq_get_ll_pointer_in_base(q_item->config.wave_start, &wave, q_item->wave_buffer_first) == ACQRES_OK);
	total_wave_sz = wave->pre_sz + wave->post_sz;
	expect_total_bytes = n_waves * total_wave_sz;

	/*
	 * Reset the BD list to the start so we can start adding entries.  Pack the
	 * entries into the BD, using the acquisition helper function to calculate
	 * the remapped addresses.  Large transfers are split up by the BD library.
	 */
	d_start_timing(TMR_MIPI_SG_BDFILL);
	dma_bd_rewind(ring);

	/*
	 * Allocate trigger buffer block.  4 bytes per trigger index.  TODO:  Don't
	 * reallocate this on each cycle.
	 */
	if(g_mipi_csi_state.trig_buffer_ptr != NULL) {
		free(g_mipi_csi_state.trig_buffer_ptr);
	}

	trig_buffer_size = 4 * acq_get_nwaves_request();
	trig_buffer_size += trig_buffer_size & 7; // Ensure trigger buffer size is 64-bit aligned

	g_mipi_csi_state.trig_buffer_ptr = (uint32_t*)memalign(32, trig_buffer_size);

	/*
	 * Generate and add header data.  Header is allocated in RAM; clear any prior header
	 * before writing this one.
	 *
	 * XXX: CRC not yet added. When CRC field added it will be necessary to move the cache
	 * flush to after the CRC is calculated.
	 */
	memset(g_mipi_csi_state.header, 0x00, sizeof(struct mipi_csi_wave_header_t));

	g_mipi_csi_state.header->magic_header = MCSI_MAGIC_HEADER_WAVES;
	g_mipi_csi_state.header->subpkt = 1;   // Always '1' for now
	g_mipi_csi_state.header->n_waves_done = acq_get_nwaves_done();
	g_mipi_csi_state.header->n_waves_request = acq_get_nwaves_request();
	g_mipi_csi_state.header->start_wave_index = q_item->config.wave_start;
	g_mipi_csi_state.header->end_wave_index = q_item->config.wave_end;
	g_mipi_csi_state.header->seq = q_item->config.seq;
	g_mipi_csi_state.header->wave_stride = total_wave_sz;  // For now, assume no pre-header for each waveform transferred
	g_mipi_csi_state.header->wave_length = total_wave_sz;

	// Hmm, should we look at doing this via scatter-gather to reduce the copies made?
	g_mipi_csi_state.header->health = g_sysctrl_health;
	g_mipi_csi_state.header->stats = g_mipi_csi_state.stats;

	dma_bd_add_large_sg_entry(g_mipi_csi_state.bd_ring, (uint32_t)g_mipi_csi_state.header, MCSI_HEADER_SIZE, 0, NULL);

	working_ptr += MCSI_HEADER_SIZE;
	total_wave_bytes = 0;

	/*
	 * As soon as we meet an invalid wave (non-acquired) we assume that the rest
	 * of the waveforms are duff, and so end the streamout of waveforms and pad
	 * the packet with zero bytes.
	 */
	g_mipi_csi_state.header->wavebuffer_ptr = working_ptr;
	trig_buffer_ptr = g_mipi_csi_state.trig_buffer_ptr;

	for(i = 0; i < n_waves; i++) {
		if(acq_dma_address_helper(wave, &addr_helper) != ACQRES_OK) {
			break;
		}

		/*
		if(i == 0) {
			acq_debug_dump_wave_pointer(wave);
		}
		*/

		// acq_dma_address_helper_debug(wave, addr_helper);
		// d_printf(D_RAW, "%08x\r\n", wave->trigger_at);

		dma_bd_add_large_sg_entry(g_mipi_csi_state.bd_ring, addr_helper.pre_upper_start, addr_helper.pre_upper_end - addr_helper.pre_upper_start, 0, NULL);
		dma_bd_add_large_sg_entry(g_mipi_csi_state.bd_ring, addr_helper.pre_lower_start, addr_helper.pre_lower_end - addr_helper.pre_lower_start, 0, NULL);
		dma_bd_add_large_sg_entry(g_mipi_csi_state.bd_ring, addr_helper.post_start, addr_helper.post_end - addr_helper.post_start, 0, NULL);

		// Add the trigger pointer
		*(trig_buffer_ptr + i) = (wave->trigger_at & 0x07) << 24;
		//d_printf(D_RAW, "%08x\r\n", *(trig_buffer_ptr + i));

		/*
		for(n = 0; n < 8; n++) {
			if(n == (wave->trigger_at & 0x07)) {
				d_printf(D_RAW, "\033[93m");
			}

			d_printf(D_RAW, "%02x\033[0m", *(uint8_t*)(addr_helper.pre_upper_end + n));
		}

		d_printf(D_RAW, " %08x\r\n", wave->trigger_at);
		*/

		total_wave_bytes += total_wave_sz;

		// End of list?
		if(acq_next_ll_pointer(wave, &next) != ACQRES_OK) {
			break;
		}

		wave = next;
	}

	d_printf(D_INFO, "ntot=%d I=%d", n_waves, i);

	/*
	 * Pad the wave buffer to the required length.
	 */
	pad = expect_total_bytes - total_wave_bytes;
	if(pad > 0) {
		dma_bd_add_zero_sg_entry(g_mipi_csi_state.bd_ring, pad, 0, NULL);
	}

	d_printf(D_INFO, "pad: %d", pad);
	working_ptr += total_wave_bytes + pad;

	/*
	 * Add the trigger buffer pointer.
	 */
	//d_printf(D_INFO, "add entry: 0x%08x size %d", g_mipi_csi_state.trig_buffer_ptr, trig_buffer_size);
	dma_bd_add_large_sg_entry(g_mipi_csi_state.bd_ring, (uint32_t)g_mipi_csi_state.trig_buffer_ptr, trig_buffer_size, 0, NULL);
	g_mipi_csi_state.header->tagbuffer_ptr = working_ptr;
	working_ptr += trig_buffer_size;

	//d_printf(D_INFO, "0x%08x 0x%08x", g_mipi_csi_state.header->wavebuffer_ptr, g_mipi_csi_state.header->tagbuffer_ptr);

	/*
	 * Pad data to meet one CSI line size.
	 */
	line_pad = (MCSI_DEFAULT_LINE_WIDTH - (working_ptr % MCSI_DEFAULT_LINE_WIDTH));
	if(line_pad > 0) {
		dma_bd_add_zero_sg_entry(g_mipi_csi_state.bd_ring, line_pad, 0, NULL);
		working_ptr += line_pad;
	}

	//d_printf(D_INFO, "tb:%d eb:%d pad:%d line_pad:%d", total_wave_bytes, expect_total_bytes, pad, line_pad);

	d_stop_timing(TMR_MIPI_SG_BDFILL);
	g_mipi_csi_state.stats.last_sg_bd_time_us = d_read_timing_us(TMR_MIPI_SG_BDFILL);

	/*
	 * Ensure the header is cache flushed, so that the DMA peripheral can read it correctly
	 * Ensure the tag buffer is cache flushed.
	 */
	Xil_DCacheFlushRange((INTPTR)g_mipi_csi_state.header, sizeof(struct mipi_csi_wave_header_t));
	Xil_DCacheFlushRange((INTPTR)g_mipi_csi_state.trig_buffer_ptr, trig_buffer_size);

	/*
	 * Pass the BD for transmission.  This function handles caching too.  We shouldn't
	 * try to change any data in memory at this point though, as the behaviour is undefined.
	 */
	status = dma_bd_start(&g_mipi_csi_state.mipi_dma, g_mipi_csi_state.bd_ring, BD_STFLAGS_TRANSMIT /* | BD_STFLAGS_DUMP_DEBUG */);
	q_item->calculated_size = dma_bd_get_total_block_size(g_mipi_csi_state.bd_ring);

	if (status != BD_RES_OK) {
		d_printf(D_ERROR, "mipi_csi: fatal error passing BD ring to hardware: %d", status);
		exit(-1);
	}

	//d_printf(D_INFO, "mipi_csi: list sent to DMA...");

	d_stop_timing(TMR_MIPI_SG_OVERALL);
	g_mipi_csi_state.stats.last_sg_total_time_us = d_read_timing_us(TMR_MIPI_SG_OVERALL);
	g_mipi_csi_state.stats.num_bds_created += dma_bd_get_total_bd_count(g_mipi_csi_state.bd_ring);

	//d_dump_malloc_info();

	return CSIRES_OK;
}

/*
 * Process an enqueued item and generate the required AXIDMA operations for it
 * to happen.
 */
void mipi_csi_process_queue_item(struct mipi_csi_stream_queue_item_t *q_item)
{
	uint32_t status;
	int send_packet = 0;

	D_ASSERT(q_item != NULL);
	g_mipi_csi_state.working = q_item;

	q_item->data_type = g_mipi_csi_state.csi_data_type;
	q_item->wct_header = g_mipi_csi_state.csi_frame_wct;

	switch(q_item->item_type) {
		/*
		case MCSI_TYPE_RAW_MEMORY:
			//d_printf(D_INFO, "MCSI_TYPE_RAW_MEMORY");
			if(mipi_csi_generate_sg_list_for_buffer_range(q_item->start_addr, q_item->end_addr, q_item) == CSIRES_OK) {
				send_packet = 1;
			}
			break;
		*/

		case MCSI_TYPE_WAVEFORM_RANGE:
			mipi_csi_send_fifo_reset();
			if(mipi_csi_generate_sg_list_for_waves(q_item) == CSIRES_OK) {
				send_packet = 1;
			}
			break;

		default:
			d_printf(D_INFO, "@ 0x%08x .. 0x%02x %d %d", q_item, q_item->item_type, q_item->config.wave_start, q_item->config.wave_end);
			D_ASSERT(0);
			return;
	}

	if(send_packet) {
		D_ASSERT(q_item->calculated_size > 0);

		g_mipi_csi_state.transfer_size = q_item->calculated_size;
		g_mipi_csi_state.transfer_rem = q_item->calculated_size;
		g_mipi_csi_state.state = MCSI_ST_WAIT_FOR_XFER;

		d_start_timing(TMR_MIPI_PERFORMANCE);
		mipi_csi_transfer_packet(q_item);

		GLOBAL_IRQ_DISABLE();
		g_mipi_csi_state.flags |= MCSI_FLAG_TRANSFER_RUNNING;
		g_mipi_csi_state.flags &= ~MCSI_FLAG_STOP_DONE;
		GLOBAL_IRQ_ENABLE();
	}
}

/*
 * Tick controller.  Should be run frequently to allow the controller to process all
 * queued requests promptly.
 */
void mipi_csi_tick()
{
	switch(g_mipi_csi_state.state) {
		case MCSI_ST_IDLE:
			/*
			 * Occasionally, trim the BD list of any unused entries.
			 */
#if 0
			time = systick_get_time_us_nonirq();
			if(COND_UNLIKELY((time - g_mipi_csi_state.last_bd_trim) > CSI_TRIM_RATE)) {
				d_printf(D_INFO, "Trim Start");
				dma_bd_trim(g_mipi_csi_state.bd_ring);
				d_printf(D_INFO, "Trim Stop");
				g_mipi_csi_state.last_bd_trim = time;
			}
#endif
			break;

		case MCSI_ST_WAIT_FOR_XFER:
			/*
			 * Check if the MIPI controller is done with our last transfer.  If it's not, then
			 * we don't do anything here.
			 */
			/*
			d_printf(D_INFO, "rem=%d status=0x%08x DMASR=0x%08x DMACR=0x%08x CDESC=0x%08x TDESC=0x%08x", \
					g_mipi_csi_state.transfer_rem, \
					fabcfg_read(FAB_CFG_CSI_STATUS_A), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SR_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CR_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_TDESC_OFFSET));
			*/

			/*
			if(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) == XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_TDESC_OFFSET)) {
				d_printf(D_WARN, "*** Done DMA Xfer, Dump State... ***");
				dma_bd_debug_dump(g_mipi_csi_state.bd_ring);
			}
			*/

			//dma_bd_debug_dump(g_mipi_csi_state.bd_ring);

			if(fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) {
				// Do we have any more data left?
				if(g_mipi_csi_state.transfer_rem > 0) {
					// Data remains.  Process that data. (Frame ends, then we start a new frame immediately.)
					mipi_csi_send_eof();
					mipi_csi_transfer_packet(g_mipi_csi_state.working);
				} else {
					// Log some performance parameters
					d_stop_timing(TMR_MIPI_PERFORMANCE);
					g_mipi_csi_state.stats.last_transfer_time_us = d_read_timing_us(TMR_MIPI_PERFORMANCE);
					g_mipi_csi_state.stats.last_transfer_perf_mbs = g_mipi_csi_state.transfer_size / (float)g_mipi_csi_state.stats.last_transfer_time_us;
					g_mipi_csi_state.stats.total_transfer_time_us += (int)g_mipi_csi_state.stats.last_transfer_time_us;

					//d_printf(D_INFO, "mipi_csi: %.4f MB/s (%d bytes in %.3f microsec)", \
							g_mipi_csi_state.stats.last_transfer_perf_mbs, g_mipi_csi_state.transfer_size, \
							g_mipi_csi_state.stats.last_transfer_time_us);

					//d_printf(D_INFO, "Total_time=%.4f, BD_time=%.4f", g_mipi_csi_state.stats.last_sg_total_time_us, g_mipi_csi_state.stats.last_sg_bd_time_us);

					// End frame and return to idle.
					mipi_csi_send_eof();
					g_mipi_csi_state.done = 1;
					g_mipi_csi_state.working = NULL;
					g_mipi_csi_state.state = MCSI_ST_IDLE;
					g_mipi_csi_state.flags &= ~MCSI_FLAG_TRANSFER_RUNNING;
				}
			} else {
				/*
				status = fabcfg_read(FAB_CFG_CSI_STATUS_A);

				d_printf(D_INFO, "Ndone %08x (RV:%d, RR:%d, SA:%d, mipi_state:%d, ctrl_state:%d, DMACR:%08x, DMASR:%08x, CDESC:%08x, TDESC:%08x, SGCTL:%08x)", \
						status, \
						!!(status & CSI_STATUS_A_DBG_RV), \
						!!(status & CSI_STATUS_A_DBG_RR), \
						!!(status & CSI_STATUS_A_DBG_SA), \
						(status & CSI_STATUS_A_DBG_MIPI_ST_MSK) >> CSI_STATUS_A_DBG_MIPI_ST_SFT, \
						(status & CSI_STATUS_A_DBG_CTRL_ST_MSK) >> CSI_STATUS_A_DBG_CTRL_ST_SFT, \
						XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CR_OFFSET), \
						XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SR_OFFSET), \
						XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET), \
						XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_TDESC_OFFSET), \
						XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SGCTL_OFFSET));
				*/
			}
			break;
	}
}

/*
 * Return a status report combining hardware (FPGA) and software state.
 */
void mipi_csi_get_status(struct mipi_csi_status_t *status)
{
	uint32_t stat_a_reg;

	GLOBAL_IRQ_DISABLE();

	status->flags = g_mipi_csi_state.flags;
	status->data_rem = g_mipi_csi_state.transfer_rem;
	status->queue_size = queue_size(g_mipi_csi_state.item_queue);

	stat_a_reg = fabcfg_read(FAB_CFG_CSI_STATUS_A);

	if(stat_a_reg & CSI_STATUS_A_DONE)
		status->flags |= MCSI_FLAG_SPECIAL_HW_DSTATE;

	if(stat_a_reg & CSI_STATUS_A_RUNNING)
		status->flags |= MCSI_FLAG_SPECIAL_HW_RSTATE;

	g_mipi_csi_state.flags &= ~MCSI_FLAG_ERROR_MASK;

	GLOBAL_IRQ_ENABLE();
}

/*
 * Return a size report.
 */
void mipi_csi_get_size_report(struct mipi_tx_size_resp_t *status)
{
	GLOBAL_IRQ_DISABLE();

	status->all_waves_size = acq_get_nwaves_done() * acq_get_wave_size_bytes(ACQ_REGION_ALL);
	status->trigger_data_size = acq_get_nwaves_done() * sizeof(struct acq_trigger_data_resp_t);

	// 1 bit per sample, calculate sample size.  May need to be corrected for multi channel modes.
	status->bitpack_size = status->all_waves_size / acq_get_wave_bit_packed_depth();

	GLOBAL_IRQ_ENABLE();
}

/*
 * Return if the done reg is set and clear that register - used to see that
 * another command can be executed/scheduled.
 */
int mcsi_get_task_done()
{
	int done = g_mipi_csi_state.done;

	g_mipi_csi_state.done = 0;

	return done;
}

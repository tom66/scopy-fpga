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
#include "acquire.h"
#include "hal.h"
#include "fabric_config.h"
#include "spi.h"
#include "queue.h" // Collections-C
#include "deque.h" // Collections-C

#include "xaxidma.h"
#include "xscugic.h"

struct mipi_csi_state_t g_mipi_csi_state;

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
	q_conf.capacity = CSISTRM_QUEUE_SIZE;

	D_ASSERT(queue_new_conf(&q_conf, &g_mipi_csi_state.item_queue) == CC_OK);

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
 * Allocate an item buffer and return the pointer.  Dies if calloc fails.
 */
struct mipi_csi_stream_queue_item_t *mipi_csi_alloc_item()
{
	struct mipi_csi_stream_queue_item_t *item;

	item = calloc(sizeof(struct mipi_csi_stream_queue_item_t), 1);

	if(item == NULL) {
		d_printf(D_ERROR, "mipi_csi: Unable to calloc %d bytes for queued item", sizeof(struct mipi_csi_stream_queue_item_t));
		return NULL;
	}

	item->item_type = CSISTRM_TYPE_ALLOC_UNDEF;
	g_mipi_csi_state.stats.items_alloc++;

	//d_printf(D_INFO, "ptr=0x%08x sz=%d", item, sizeof(struct mipi_csi_stream_queue_item_t));

	return item;
}

/*
 * Free an item buffer.
 */
void mipi_csi_free_item(struct mipi_csi_stream_queue_item_t *item)
{
	D_ASSERT(item != NULL);

	free(item->free_done);
	free(item);

	g_mipi_csi_state.stats.items_freed++;
}

/*
 * Queue a waveform range into the CSI task queue.
 *
 * @param	start_addr
 * @param	end_addr
 * @param	free_done		Buffer to free when done (or if an error occurs)
 */
void mipi_csi_queue_buffer(uint32_t start_addr, uint32_t end_addr, void *free_done)
{
	struct mipi_csi_stream_queue_item_t *item;

	if(start_addr > end_addr) {
		d_printf(D_ERROR, "mipi_csi: buffer range invalid, not queueing request");
		free(free_done);
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		return;
	}

	if((start_addr % 32) != 0 || (end_addr % 32) != 0) {
		d_printf(D_ERROR, "mipi_csi: buffer range misaligned (0x%08x 0x%08x, align 32), not queueing request", \
				start_addr, end_addr);
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		free(free_done);
		return;
	}

	item = mipi_csi_alloc_item();

	if(item == NULL) {
		d_printf(D_ERROR, "mipi_csi: failed in mipi_csi_alloc_item()");
		free(free_done);
		return;
	}

	item->data_type = g_mipi_csi_state.csi_data_type;
	item->wct_header = g_mipi_csi_state.csi_frame_wct;
	item->item_type = CSISTRM_TYPE_RAW_MEMORY;
	item->start_addr = start_addr;
	item->end_addr = end_addr;
	item->free_done = free_done;

	if(queue_enqueue(g_mipi_csi_state.item_queue, item) != CC_OK) {
		d_printf(D_ERROR, "mipi_csi: failed to enqueue item into task queue: no space?");
		mipi_csi_free_item(item);
	} else {
		g_mipi_csi_state.stats.items_queued++;
	}
}


/*
 * Queue a waveform range into the CSI task queue.
 */
void mipi_csi_queue_waverange(uint32_t start, uint32_t end)
{
	int i;
	struct mipi_csi_stream_queue_item_t *item;
	uint32_t nmax = acq_get_nwaves_done() - 1;

	if(start == CSISTRM_WAVE_ALL && end == CSISTRM_WAVE_ALL) {
		start = 0;
		end = nmax;
	}

	if(start > nmax || end > nmax) {
		d_printf(D_ERROR, "mipi_csi: wave range OoB; not queueing request");
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		return;
	}

	item = mipi_csi_alloc_item();
	item->data_type = g_mipi_csi_state.csi_data_type;
	item->wct_header = g_mipi_csi_state.csi_frame_wct;
	item->item_type = CSISTRM_TYPE_WAVEFORM_RANGE;
	item->start_addr = start;
	item->end_addr = end;
	item->free_done = NULL;

	//d_printf(D_INFO, "queue=0x%08x, item=0x%08x", g_mipi_csi_state.item_queue, item);
	D_ASSERT(queue_enqueue(g_mipi_csi_state.item_queue, item) == CC_OK);
	g_mipi_csi_state.stats.items_queued++;
}

/*
 * Queue all waveforms into the CSI task queue. Shorthand for calling
 * above with all FF values.
 */
void mipi_csi_queue_all_waves()
{
	mipi_csi_queue_waverange(CSISTRM_WAVE_ALL, CSISTRM_WAVE_ALL);
}

/*
 * Helper function to set up a BDRing and BD for an AXI scatter-gather transfer.
 *
 * @param	bd_area		Void pointer to the BD memory block
 * @param	bd_entries	Number of entries in the BdRing
 * @param	ring		Returned pointer to the BdRing
 * @param	bd_ptr		Returned head pointer of BdRing
 */
int mipi_csi_setup_bdring_and_bd(void *bd_area, int bd_entries, XAxiDma_BdRing **ring, XAxiDma_Bd **bd_ptr)
{
	int status;
	XAxiDma_Bd bd_template;

	/*
	 * Get the working BD ring; disable IRQs on it while we work on it.
	 * Then allocate the entries in the ring.
	 */
	*ring = XAxiDma_GetTxRing(&g_mipi_csi_state.mipi_dma);
	XAxiDma_BdRingIntDisable(*ring, XAXIDMA_IRQ_ALL_MASK);

	// I'm not 100% sure this is safe, but it fixes a memory leak
	if((*ring)->CyclicBd != NULL) {
		free((*ring)->CyclicBd);
	}

	// This function seems to eat 2ms with ~1100 entries to allocate: need to find a way to replace it
	status = XAxiDma_BdRingCreate(*ring, (int)bd_area, (int)bd_area, XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error creating BD ring: %d", status);
		return MCSI_RET_XAXIDMA_ERROR;
	}

	XAxiDma_BdClear(&bd_template);
	status = XAxiDma_BdRingClone(*ring, &bd_template);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error cloning BD ring: %d", status);
		return MCSI_RET_XAXIDMA_ERROR;
	}

	status = XAxiDma_BdRingAlloc(*ring, bd_entries, bd_ptr);
	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error allocating BD ring: %d", status);
		return MCSI_RET_XAXIDMA_ERROR;
	}

	return MCSI_RET_OK;
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
int mipi_csi_generate_sg_list_for_buffer_range(uint32_t addr_start, uint32_t addr_end, struct mipi_csi_stream_queue_item_t *q_item)
{
	XAxiDma_BdRing *ring;
	XAxiDma_Bd *bd_ptr;
	XAxiDma_Bd *cur_bd_ptr;
	uint32_t *buff = (uint32_t*)addr_start;
	uint32_t xfer_size = 0, pk_size = 0;
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
	 * the size of which is equal to the number of CSISTRM_AXI_MAX_BD_SIZE chunks
	 * to be transmitted.
	 */
	if(g_mipi_csi_state.bd_area != NULL) {
		d_printf(D_INFO, "FreeBD=0x%08x I", g_mipi_csi_state.bd_area);
		free(g_mipi_csi_state.bd_area);
	}

	bd_entries = (size / CSISTRM_AXI_MAX_BD_SIZE);
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
		pk_size = MIN(size, CSISTRM_AXI_MAX_BD_SIZE);
		sof = (i == 0);
		eof = (i == (bd_entries - 1));

		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, pk_size, (uint32_t*)buff, sof, eof);
		buff += CSISTRM_AXI_MAX_BD_SIZE;
		size -= pk_size;
		xfer_size += pk_size;
	}
	*/

	pk_size = addr_end - addr_start;
	_mipi_csi_axidma_add_bd_block(ring, bd_ptr, pk_size, (uint32_t*)buff, 1, 1);

	g_mipi_csi_state.transfer_size = pk_size;

	// Pass the BD to hardware for transmission
	status = XAxiDma_BdRingToHw(ring, bd_entries, bd_ptr); // This function manages cache coherency for BDs
	if (status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error passing BD ring to hardware: %d", status);
		exit(-1);
	}

	d_stop_timing(TMR_MIPI_SG_OVERALL);

	q_item->ring = ring;
	return CSIRES_OK;
}

/*
 * Create a Scatter-Gather list for a given waveform range (CSISTRM_WAVE_ALL
 * not supported) which can be passed to the AXIDMA module to stream
 * waveform data.
 *
 * Portions based on dma_ex_sg_v2_1 (Xilinx)
 *
 * @param	wave_start		Starting wave index
 * @param	wave_end		Ending wave index - must be more than or equal to starting index
 */
int mipi_csi_generate_sg_list_for_waves(uint32_t wave_start, uint32_t wave_end, struct mipi_csi_stream_queue_item_t *q_item)
{
	int status, n_waves, bd_entries, i;
	XAxiDma_BdRing *ring;
	XAxiDma_Bd *bd_ptr;
	XAxiDma_Bd *cur_bd_ptr;
	// XAxiDma_Bd bd_template;
	struct acq_buffer_t *wave;
	struct acq_buffer_t *next;
	struct acq_dma_addr_t addr_helper;
	uint32_t total_sz, extra_chunks, total_bytes;
	bool sof, eof;

	//d_printf(D_INFO, "waves: %d %d", wave_start, wave_end);

	d_start_timing(TMR_MIPI_SG_OVERALL);

	D_ASSERT(wave_start <= wave_end);
	n_waves = (wave_end - wave_start) + 1;
	q_item->ring = NULL;
	q_item->calculated_size = 0;

	// Reset the DMA peripheral, terminating any existing transactions
	XAxiDma_Reset(&g_mipi_csi_state.mipi_dma);

	/*
	 * Get the first waveform.  This is also used to retrieve the size of the waveforms
	 * that is needed to compute the BD list size.
	 *
	 * Wave bounds checking is handled gracefully elsewhere, so this assert shouldn't
	 * be harmful.
	 */
	D_ASSERT(acq_get_ll_pointer(wave_start, &wave, ACQLIST_DONE) == ACQRES_OK);
	total_sz = wave->pre_sz + wave->post_sz;
	extra_chunks  = wave->pre_sz / CSISTRM_AXI_MAX_BD_SIZE;
	extra_chunks += wave->post_sz / CSISTRM_AXI_MAX_BD_SIZE;
	total_bytes = total_sz * n_waves;

	//d_printf(D_INFO, "mipi_csi: wave_start=%d, wave_base=0x%08x", wave_start, wave);

	/*
	 * Free the old BD list, if it's present.  Then, attempt to create a new BD list.  The
	 * list is three times the number of waveforms, as we have two pre-trigger DMA copies
	 * and one post-trigger DMA copy, plus one to allow for worst-case alignment.
	 */
	if(g_mipi_csi_state.bd_area != NULL) {
		d_printf(D_INFO, "FreeBD=0x%08x I (waves)", g_mipi_csi_state.bd_area);
		free(g_mipi_csi_state.bd_area);
	}

	bd_entries = ((3 + extra_chunks) * n_waves);

	//d_printf(D_INFO, "mipi_csi: expected BD size: %d entries (%d total wave bytes, %d BD table bytes)", \
			bd_entries, total_bytes, bd_entries * XAXIDMA_BD_MINIMUM_ALIGNMENT);

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
	//d_printf(D_INFO, "bd_ptr=0x%08x", bd_ptr);

	/*
	 * Pack the entries into the BD, using the acquisition helper function to
	 * calculate the remapped addresses.  Each BD length must be less than 8MB,
	 * so large transfers are split up.
	 */
	cur_bd_ptr = bd_ptr;

	d_start_timing(TMR_MIPI_SG_BDFILL);

	for(i = 0; i < n_waves; i++) {
		sof = (i == 0);
		eof = (i == n_waves - 1);

		if(acq_dma_address_helper(wave, &addr_helper) != ACQRES_OK) {
			d_printf(D_WARN, "mipi_csi: early abort of CSI SG generation due to inconsistent wave buffer. " \
							 "Wave at 0x%08x (index %d) is not valid, but acquistion engine claims it has %d entries available.", \
							 wave, i, n_waves);
			return CSIRES_ERROR_WAVES;
		}

		//d_printf(D_INFO, "i = %4d, n_waves = %d, sof = %d, eof = %d, wave = 0x%08x, wave_flags = 0x%04x", i, n_waves, sof, eof, wave, wave->flags);

		/*
		d_printf(D_INFO, "WaveBase = 0x%08x, Trigger = 0x%08x, PrLS = 0x%08x, PrLE = 0x%08x, PrUS = 0x%08x, PrUE = 0x%08x, PoS = 0x%08x, PoE = 0x%08x", \
				wave->buff_acq, wave->trigger_at, \
				addr_helper.pre_lower_start, addr_helper.pre_lower_end, \
				addr_helper.pre_upper_start, addr_helper.pre_upper_end, \
				addr_helper.post_start, addr_helper.post_end);
		*/

		// Add the pre-upper section in 8MB chunks
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, \
				addr_helper.pre_upper_end - addr_helper.pre_upper_start, addr_helper.pre_upper_start, sof, 0);

		// Add the pre-lower section in 8MB chunks
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, \
				addr_helper.pre_lower_end - addr_helper.pre_lower_start, addr_helper.pre_lower_start, 0, 0);

		// Add the post section in 8MB chunks
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, \
				addr_helper.post_end - addr_helper.post_start, addr_helper.post_start, 0, eof);

		// End of list?
		if(acq_next_ll_pointer(wave, &next) != ACQRES_OK)
			break;
		wave = next;
	}

	d_stop_timing(TMR_MIPI_SG_BDFILL);
	g_mipi_csi_state.stats.last_sg_bd_time_us = d_read_timing_us(TMR_MIPI_SG_BDFILL);

	// Pass the BD to hardware for transmission
	status = XAxiDma_BdRingToHw(ring, bd_entries, bd_ptr); // This function manages cache coherency for BDs
	if (status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error passing BD ring to hardware: %d", status);
		exit(-1);
	}

	//d_printf(D_INFO, "mipi_csi: list sent to DMA...");

	q_item->calculated_size = n_waves * total_sz;
	q_item->ring = ring;

	d_stop_timing(TMR_MIPI_SG_OVERALL);
	g_mipi_csi_state.stats.last_sg_total_time_us = d_read_timing_us(TMR_MIPI_SG_OVERALL);

	return CSIRES_OK;
}

/*
 * Send a reset FIFO command, ensuring the FIFO starts off empty.
 */
void mipi_csi_send_fifo_reset()
{
	outbyte('R');

	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_RESET_FIFO);
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_RESET_FIFO);
}

/*
 * Send a start of frame signal and wait for the MIPI controller to transmit that
 * (should happen in less than 50 us.)
 */
void mipi_csi_send_sof()
{
	outbyte('S');

	/*
	 * If clock idle flag #2 is set, then we turn off fabric clock idling so that clock goes active
	 * for the whole transaction until EoF.  If clock idle flag #1 is set, then enable clock idling
	 * now (it might not be enabled on the fabric before) but don't turn it off at EoF.
	 */
	if(g_mipi_csi_state.flags & MCSI_FLAG_CLOCK_IDLE_MODE_2) {
		fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_CLOCK_SLEEP_ENABLE);
	} else if(g_mipi_csi_state.flags & MCSI_FLAG_CLOCK_IDLE_MODE_1) {
		fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_CLOCK_SLEEP_ENABLE);
	}

	// Ensure system is stopped first by sending a stop pulse.
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_STOP);
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_STOP | CSI_CTRL_A_START_LINES | CSI_CTRL_A_START_FRAME);

	fabcfg_write_masked(FAB_CFG_CSI_CTRL_C, g_mipi_csi_state.csi_frame_wct, CSI_CTRL_C_WCT_HEADER_MSK, CSI_CTRL_C_WCT_HEADER_SFT);

	// TODO: There is probably a better way to do this.
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_FRAME);
	//while( fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;  // wait for DONE to go LOW - ack of command
	bogo_delay(1);
	while(!fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;  // then wait for DONE to go HIGH - command done
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_FRAME);

	outbyte(',');
}

/*
 * Send an end of frame signal and wait for the MIPI controller to transmit that
 * (should happen in less than 50 us.)
 */
void mipi_csi_send_eof()
{
	outbyte('E');

	fabcfg_write_masked(FAB_CFG_CSI_CTRL_C, g_mipi_csi_state.csi_frame_wct, CSI_CTRL_C_WCT_HEADER_MSK, CSI_CTRL_C_WCT_HEADER_SFT);

	// TODO: There is probably a better way to do this.
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_LINES | CSI_CTRL_A_START_FRAME);
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_END_FRAME);
	bogo_delay(1);
	while(!fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;  //  wait for DONE to go HIGH - command done
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_END_FRAME);

	outbyte('.');

	/*
	 * If clock idle flag #2 is set, then we turn on fabric clock idling so that clock goes inactive
	 * until the next transaction
	 */
	if(g_mipi_csi_state.flags & MCSI_FLAG_CLOCK_IDLE_MODE_2) {
		fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_CLOCK_SLEEP_ENABLE);
	}
}

/*
 * Stop any running transcation.  To stop:
 *   - Check RUNNING is set, indicating core is processing data; if not this has no effect.
 *   - STOP signal is asserted
 *   - We wait for the core to respond by waiting for RUNNING to go low (may take up to one
 *     data line transmission.)
 */
void mipi_csi_stop()
{
	int timeout = CSI_TIMEOUT_STOP;

	// If not running don't bother stopping...
	if(!fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_RUNNING)) {
		return;
	}

	// Send STOP and test for RUNNING - time out eventually
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_INIT_SIGNALS);
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_STOP);

	while(fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_RUNNING) && timeout--) ;

	if(timeout == 0) {
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_STOP_TIMEOUT;
	} else {
		g_mipi_csi_state.flags |= MCSI_FLAG_STOP_DONE;
	}

	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_STOP);
}

/*
 * Send a packet via the CSI bus, up to MCSI_PACKET_MAX_SIZE bytes.  The transfer
 * should have already been set up in the AXI controller, otherwise this may
 * hang forever.
 *
 * This function initiates a transfer: it doesn't wait for the transfer to complete.
 * The user should check the DONE state to see when to send the next packet.
 */
void mipi_csi_transfer_packet(struct mipi_csi_stream_queue_item_t *q_item)
{
	uint32_t flags_a = 0;
	uint32_t lines = g_mipi_csi_state.csi_line_count;
	uint32_t size;

	outbyte('x');

	size = lines * g_mipi_csi_state.csi_line_size;

	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_LINES);

	/*
	 * Adjust the line count near the end of the packet.
	 *
	 * Packets are rounded to a multiple of the line size with remaining data replaced
	 * with undefined values.
	 */
	if(size > g_mipi_csi_state.transfer_rem) {
		size = g_mipi_csi_state.transfer_rem;
		lines = size / g_mipi_csi_state.csi_line_size;

		//d_printf(D_INFO, "mipi_csi: packet resize to %d lines", lines);
	}

	//d_printf(D_INFO, "mipi_csi: packet parameters: %d lines, %d line size, %d total size, %d bytes left", lines, g_mipi_csi_state.csi_line_size, size, g_mipi_csi_state.transfer_rem - size);

	/*
	 * Counts are off by one and two (bytes) respectively, as the core counts down
	 * and tests at zero.
	 *
	 * So for 256 lines, the line counter must be loaded with 255, and for 2048 lines,
	 * 2046 must be loaded into the counter. Additionally the line byte count *must* be
	 * even (odd values will may a core lockup as the counter never reaches zero,
	 * with the logic subtracting two on each 16-bit word xfer.)
	 *
	 * TODO: We could probably improve performance here by not writing these values on
	 * each iteration -- but this is a relatively light task compared to the DMA setup.
	 */
	D_ASSERT(INT_IS_EVEN(g_mipi_csi_state.csi_line_size)) ;

	fabcfg_write_masked(FAB_CFG_CSI_CTRL_A, g_mipi_csi_state.csi_line_size - 2, CSI_CTRL_A_LINE_BYTE_COUNT_MSK, CSI_CTRL_A_LINE_BYTE_COUNT_SFT);
	fabcfg_write_masked(FAB_CFG_CSI_CTRL_B, lines - 1, CSI_CTRL_B_LINE_COUNT_MSK, CSI_CTRL_B_LINE_COUNT_SFT);
	fabcfg_write_masked(FAB_CFG_CSI_CTRL_B, q_item->data_type, CSI_CTRL_B_DATA_TYPE_MSK, CSI_CTRL_B_DATA_TYPE_SFT);
	fabcfg_write_masked(FAB_CFG_CSI_CTRL_C, q_item->wct_header, CSI_CTRL_C_WCT_HEADER_MSK, CSI_CTRL_C_WCT_HEADER_SFT);

	// Send the frame start signal first, then send the start lines signal.
	mipi_csi_send_sof();
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_LINES);

	g_mipi_csi_state.transfer_rem -= size;
	g_mipi_csi_state.stats.data_xfer_bytes += size;

	//d_printf(D_INFO, "mipi_csi: packet parameters: %d bytes remain", g_mipi_csi_state.transfer_rem);
}

/*
 * Clear the queue of all working buffers, excluding any in progress.  The
 * transfer that is in progress will be removed once complete.  (The transfer
 * that is working is not on the queue.)
 */
void mipi_csi_clear_queue()
{
	struct mipi_csi_stream_queue_item_t *q_item;

	// Free/dealloc all entries then delete queue
	queue_poll(g_mipi_csi_state.item_queue, (void*)&q_item);

	while(q_item != NULL) {
		d_printf(D_INFO, "free_clear 0x%08x", q_item);
		free(q_item);
		queue_poll(g_mipi_csi_state.item_queue, (void*)&q_item);
	}
}

/*
 * Unpop the oldest item from the queue and start work on it, if possible.
 *
 * If there is a task running already, this has no effect and an error state is
 * set in the flags register.
 */
void mipi_csi_unpop_and_start()
{
	if(g_mipi_csi_state.working == NULL) {
		g_mipi_csi_state.unpop_and_start = 1;
	} else {
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_TRANSFER_BUSY;
	}
}

/*
 * Unpop ALL items from the queue and transmit them sequentially.
 */
void mipi_csi_unpop_and_start_all()
{
	if(!g_mipi_csi_state.unpop_and_start_all) {
		g_mipi_csi_state.unpop_and_start_all = 1;
		//d_printf(D_INFO, "unpop_and_start_all req");
	} else {
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_TRANSFER_BUSY;
		//d_printf(D_INFO, "unpop_and_start_all not possible");
	}
}

/*
 * Return a status report.
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
 * Process an enqueued item and generate the required AXIDMA operations for it
 * to happen.
 */
void mipi_csi_process_queue_item(struct mipi_csi_stream_queue_item_t *q_item)
{
	uint32_t status;
	int i, send_packet = 0;
	D_ASSERT(q_item != NULL);
	g_mipi_csi_state.working = q_item;

	//d_printf(D_INFO, "q_item=%08x, item_type=%d, q_size=%d", q_item, q_item->item_type, queue_size(g_mipi_csi_state.item_queue));

	switch(q_item->item_type) {
		case CSISTRM_TYPE_RAW_MEMORY:
			//d_printf(D_INFO, "CSISTRM_TYPE_RAW_MEMORY");
			if(mipi_csi_generate_sg_list_for_buffer_range(q_item->start_addr, q_item->end_addr, q_item) == CSIRES_OK) {
				send_packet = 1;
			}
			break;

		case CSISTRM_TYPE_WAVEFORM_RANGE:
			//d_printf(D_INFO, "CSISTRM_TYPE_WAVEFORM_RANGE");
			if(q_item->start_addr == CSISTRM_WAVE_ALL && q_item->end_addr == CSISTRM_WAVE_ALL) {
				if(acq_get_nwaves_done() > 0) {
					if(mipi_csi_generate_sg_list_for_waves(0, acq_get_nwaves_done() - 1, q_item) == CSIRES_OK) {
						send_packet = 1;
					}
				}
			} else {
				if(mipi_csi_generate_sg_list_for_waves(q_item->start_addr, q_item->end_addr, q_item) == CSIRES_OK) {
					send_packet = 1;
				}
			}
			break;
	}

	if(send_packet) {
		D_ASSERT(q_item->calculated_size > 0);
		g_mipi_csi_state.transfer_size = q_item->calculated_size;
		g_mipi_csi_state.transfer_rem = q_item->calculated_size;
		g_mipi_csi_state.state = MCSI_ST_WAIT_FOR_XFER;

		// Send first and possibly only packet
		//d_printf(D_INFO, "mipi_csi: starting packet transmission of %d bytes", g_mipi_csi_state.transfer_size);
		D_ASSERT(q_item->ring != NULL);

		/*
		status = fabcfg_read(FAB_CFG_CSI_STATUS_A);
		d_printf(D_INFO, "Ndone %08x (RV:%d, RR:%d, SA:%d, mipi_state:%d, ctrl_state:%d, DMACR:%08x, DMASR:%08x, CDESC:%08x, BD_NXTDST:%08x, BD_CTRLLEN:%08x, BD_STA:%08x, TDESC:%08x, SGCTL:%08x)", status, \
				!!(status & CSI_STATUS_A_DBG_RV), \
				!!(status & CSI_STATUS_A_DBG_RR), \
				!!(status & CSI_STATUS_A_DBG_SA), \
				(status & CSI_STATUS_A_DBG_MIPI_ST_MSK) >> CSI_STATUS_A_DBG_MIPI_ST_SFT, \
				(status & CSI_STATUS_A_DBG_CTRL_ST_MSK) >> CSI_STATUS_A_DBG_CTRL_ST_SFT, \
				XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CR_OFFSET), \
				XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SR_OFFSET), \
				XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET), \
				*(uint32_t*)(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) + XAXIDMA_BD_NDESC_OFFSET), \
				*(uint32_t*)(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) + XAXIDMA_BD_CTRL_LEN_OFFSET), \
				*(uint32_t*)(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) + XAXIDMA_BD_STS_OFFSET), \
				XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_TDESC_OFFSET), \
				XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SGCTL_OFFSET));
		*/

		d_start_timing(TMR_MIPI_PERFORMANCE);
		mipi_csi_send_fifo_reset();
		XAxiDma_BdRingStart(q_item->ring);
		mipi_csi_transfer_packet(q_item);

		/*
		for(i = 0; i < 200; i++) {
			status = fabcfg_read(FAB_CFG_CSI_STATUS_A);
			d_printf(D_INFO, "Ndone %08x (RV:%d, RR:%d, SA:%d, mipi_state:%d, ctrl_state:%d, DMACR:%08x, DMASR:%08x, CDESC:%08x, BD_NXTDST:%08x, BD_CTRLLEN:%08x, BD_STA:%08x, TDESC:%08x, SGCTL:%08x)", status, \
					!!(status & CSI_STATUS_A_DBG_RV), \
					!!(status & CSI_STATUS_A_DBG_RR), \
					!!(status & CSI_STATUS_A_DBG_SA), \
					(status & CSI_STATUS_A_DBG_MIPI_ST_MSK) >> CSI_STATUS_A_DBG_MIPI_ST_SFT, \
					(status & CSI_STATUS_A_DBG_CTRL_ST_MSK) >> CSI_STATUS_A_DBG_CTRL_ST_SFT, \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CR_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SR_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET), \
					*(uint32_t*)(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) + XAXIDMA_BD_NDESC_OFFSET), \
					*(uint32_t*)(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) + XAXIDMA_BD_CTRL_LEN_OFFSET), \
					*(uint32_t*)(XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_CDESC_OFFSET) + XAXIDMA_BD_STS_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_TDESC_OFFSET), \
					XAxiDma_ReadReg(g_mipi_csi_state.mipi_dma.RegBase, XAXIDMA_SGCTL_OFFSET));
		}

		d_printf(D_ERROR, "Hang here...");
		while(1) ;
		*/

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
	uint32_t status;
	struct mipi_csi_stream_queue_item_t *q_item;

	//d_printf(D_INFO, "mcst=%d", g_mipi_csi_state.state);

	/*
	status = fabcfg_read(FAB_CFG_CSI_STATUS_A);

	d_printf(D_INFO, "%08x (RV:%d, RR:%d, SA:%d, mipi_state:%d, ctrl_state:%d, DMACR:%08x, DMASR:%08x, CDESC:%08x, TDESC:%08x, SGCTL:%08x)", \
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

	/*
	d_printf(D_INFO, "ca:%08x cb:%08x cc:%08x sa:%08x dt:%02x", \
			fabcfg_read(FAB_CFG_CSI_CTRL_A),
			fabcfg_read(FAB_CFG_CSI_CTRL_B),
			fabcfg_read(FAB_CFG_CSI_CTRL_C),
			fabcfg_read(FAB_CFG_CSI_STATUS_A),
			g_mipi_csi_state.csi_data_type);
	*/

	switch(g_mipi_csi_state.state) {
		case MCSI_ST_IDLE:
			/*
			 * Unqueue the oldest command and see what we need to do with that command.  This
			 * may involve processing the command and setting up a DMA transfer.
			 *
			 * We only do this if we've received a command to unpop the command.
			 */
			if(g_mipi_csi_state.unpop_and_start || g_mipi_csi_state.unpop_and_start_all) {
				//d_printf(D_RAW, "qs%d u%d,%d\r\n", queue_size(g_mipi_csi_state.item_queue), \
						g_mipi_csi_state.unpop_and_start, g_mipi_csi_state.unpop_and_start_all);
				g_mipi_csi_state.unpop_and_start = 0;

				if(queue_size(g_mipi_csi_state.item_queue) > 0) {
					queue_poll(g_mipi_csi_state.item_queue, (void *)&q_item);
					mipi_csi_process_queue_item(q_item);
				} else {
					//d_printf(D_INFO, "mipi_csi: queue empty, unpop all ends");

					g_mipi_csi_state.flags |= MCSI_FLAG_QUEUE_EMPTY;
					g_mipi_csi_state.unpop_and_start_all = 0;
				}
			} else {
				//d_printf(D_RAW, "ZZZ Qs=%d\r\n", queue_size(g_mipi_csi_state.item_queue));
			}
			break;

		case MCSI_ST_WAIT_FOR_XFER:
			/*
			 * Check if the MIPI controller is done with our last transfer.  If it's not, then
			 * we don't do anything here.
			 */
			//d_printf(D_INFO, "rem=%d status=0x%08x", g_mipi_csi_state.transfer_rem, fabcfg_read(FAB_CFG_CSI_STATUS_A));

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
					mipi_csi_free_item(g_mipi_csi_state.working);
					D_ASSERT(g_mipi_csi_state.bd_area != NULL);
					//d_printf(D_INFO, "FreeBD=0x%08x II", g_mipi_csi_state.bd_area);
					free(g_mipi_csi_state.bd_area);
					g_mipi_csi_state.bd_area = NULL;
					g_mipi_csi_state.working = NULL;
					g_mipi_csi_state.state = MCSI_ST_IDLE;
					g_mipi_csi_state.flags &= ~MCSI_FLAG_TRANSFER_RUNNING;

					//malloc_stats();
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


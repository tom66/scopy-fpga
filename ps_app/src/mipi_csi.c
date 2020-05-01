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

	d_printf(D_INFO, "mipi_csi: queue done");

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

	d_printf(D_INFO, "mipi_csi: done");

	/*
	 * Prepare the peripheral with default settings and initial state machine position.
	 */
	g_mipi_csi_state.flags |= MCSI_FLAG_CLOCK_IDLE_MODE;
	g_mipi_csi_state.state = MCSI_ST_IDLE;
	g_mipi_csi_state.working = NULL;
	g_mipi_csi_state.csi_line_size = MCSI_DEFAULT_LINE_WIDTH;
	g_mipi_csi_state.csi_line_count = MCSI_DEFAULT_LINE_COUNT;
	mipi_csi_set_datatype_and_frame_wct(0x2a, 0x0000);  // RAW8, no WCT
}

/*
 * Set the default datatype and frame wordcount to be used for future
 * queued elements.
 */
void mipi_csi_set_datatype_and_frame_wct(uint8_t data_type, uint16_t frame_wct)
{
	// Datatypes (upper 6 bits) 0x00 ~ 0x03 reserved; all others fair game
	uint8_t mask_data_type = data_type & 0x3f;

	if(mask_data_type >= 0x00 && mask_data_type <= 0x03) {
		d_printf(D_ERROR, "mipi_csi: attempt to use reserved datatype (0x00 ~ 0x03); ignoring request to change DT");
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		return;
	}

	g_mipi_csi_state.csi_data_type = mask_data_type;
	g_mipi_csi_state.csi_frame_wct = frame_wct;
}

/*
 * Allocate an item buffer and return the pointer.  Dies if calloc fails.
 */
struct mipi_csi_stream_queue_item_t *mipi_csi_alloc_item()
{
	struct mipi_csi_stream_queue_item_t *item;

	item = calloc(sizeof(struct mipi_csi_stream_queue_item_t), 1);
	D_ASSERT(item != NULL);

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
	free(item);
	g_mipi_csi_state.stats.items_freed++;
}

/*
 * Process an enqueued item and generate the required AXIDMA operations for it
 * to happen.
 */
void mipi_csi_process_queue_item(struct mipi_csi_stream_queue_item_t *q_item)
{
	int send_packet = 0;
	D_ASSERT(q_item != NULL);
	g_mipi_csi_state.working = q_item;

	switch(q_item->item_type) {
		case CSISTRM_TYPE_RAW_MEMORY:
			mipi_csi_generate_sg_list_for_buffer_range(q_item->start_addr, q_item->end_addr);
			g_mipi_csi_state.state = MCSI_ST_WAIT_FOR_XFER;
			send_packet = 1;
			break;

		case CSISTRM_TYPE_WAVEFORM_RANGE:
			if(q_item->start_addr == CSISTRM_WAVE_ALL && q_item->end_addr == CSISTRM_WAVE_ALL) {
				mipi_csi_generate_sg_list_for_waves(0, acq_get_nwaves_done() - 1);
			} else {
				mipi_csi_generate_sg_list_for_waves(q_item->start_addr, q_item->end_addr);
			}

			g_mipi_csi_state.state = MCSI_ST_WAIT_FOR_XFER;
			send_packet = 1;
			break;
	}

	if(send_packet) {
		// Send first and possibly last packet
		mipi_csi_send_sof();
		mipi_csi_transfer_packet();
		mipi_csi_send_eof();

		GLOBAL_IRQ_DISABLE();
		g_mipi_csi_state.flags |= MCSI_FLAG_TRANSFER_RUNNING;
		g_mipi_csi_state.flags &= ~MCSI_FLAG_STOP_DONE;
		GLOBAL_IRQ_ENABLE();
	}
}

/*
 * Queue a waveform range into the CSI task queue.
 */
void mipi_csi_queue_buffer(uint32_t start_addr, uint32_t end_addr)
{
	struct mipi_csi_stream_queue_item_t *item;

	if(start_addr > end_addr) {
		d_printf(D_ERROR, "mipi_csi: buffer range invalid, not queueing request");
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		return;
	}

	if((start_addr % 4) != 0 || (end_addr % 4) != 0) {
		d_printf(D_ERROR, "mipi_csi: buffer range misaligned, not queueing request");
		g_mipi_csi_state.flags |= MCSI_FLAG_ERROR_PARAMETER;
		return;
	}

	item = mipi_csi_alloc_item();
	item->data_type = g_mipi_csi_state.csi_data_type;
	item->wct_header = g_mipi_csi_state.csi_frame_wct;
	item->item_type = CSISTRM_TYPE_WAVEFORM_RANGE;
	item->start_addr = start_addr;
	item->end_addr = end_addr;

	D_ASSERT(queue_enqueue(g_mipi_csi_state.item_queue, item) == CC_OK);
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

	//d_printf(D_INFO, "queue=0x%08x, item=0x%08x", g_mipi_csi_state.item_queue, item);
	D_ASSERT(queue_enqueue(g_mipi_csi_state.item_queue, item) == CC_OK);
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

	status = XAxiDma_BdRingCreate(*ring, (int)bd_area, (int)bd_area, XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error creating BD ring %d", status);
		return MCSI_RET_XAXIDMA_ERROR;
	}

	XAxiDma_BdClear(&bd_template);
	status = XAxiDma_BdRingClone(*ring, &bd_template);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error cloning BD ring %d", status);
		return MCSI_RET_XAXIDMA_ERROR;
	}

	status = XAxiDma_BdRingAlloc(*ring, bd_entries, &bd_ptr);
	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error allocating BD ring %d", status);
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
void mipi_csi_generate_sg_list_for_buffer_range(uint32_t addr_start, uint32_t addr_end)
{
	XAxiDma_BdRing *ring;
	XAxiDma_Bd *bd_ptr;
	XAxiDma_Bd *cur_bd_ptr;
	uint32_t *buff = (uint32_t)addr_start;
	uint32_t xfer_size = 0, pk_size = 0;
	int32_t size, bd_entries;
	int i, status;

	D_ASSERT((addr_start % 4) == 0);
	D_ASSERT((addr_end % 4) == 0);
	D_ASSERT(addr_end >= addr_start);

	size = addr_end - addr_start;

	/*
	 * Free the old BD list, if it's present.  Then, attempt to create a new BD list,
	 * the size of which is equal to the number of 8MB chunks to be transmitted.
	 */
	if(g_mipi_csi_state.bd_area != NULL) {
		free(g_mipi_csi_state.bd_area);
	}

	bd_entries = (size / CSISTRM_AXI_MAX_BD_SIZE) + 1;
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

	for(i = 0; i < bd_entries; i++) {
		pk_size = MIN(size, CSISTRM_AXI_MAX_BD_SIZE);
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, pk_size, (uint32_t*)buff, XAXIDMA_BD_CTRL_TXSOF_MASK);

		buff += CSISTRM_AXI_MAX_BD_SIZE;
		size -= pk_size;
		xfer_size += pk_size;
	}

	g_mipi_csi_state.transfer_size = pk_size;

	// Pass the BD to hardware for transmission
	status = XAxiDma_BdRingToHw(ring, bd_entries, bd_ptr); // This function manages cache coherency for BDs
	if (status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error passing BD ring to hardware %d", status);
		exit(-1);
	}
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
void mipi_csi_generate_sg_list_for_waves(uint32_t wave_start, uint32_t wave_end)
{
	int status, n_waves, bd_entries, i;
	XAxiDma_BdRing *ring;
	XAxiDma_Bd *bd_ptr;
	XAxiDma_Bd *cur_bd_ptr;
	XAxiDma_Bd bd_template;
	struct acq_buffer_t *wave;
	struct acq_buffer_t *next;
	struct acq_dma_addr_t addr_helper;
	uint32_t total_sz, extra_chunks;

	D_ASSERT(wave_start <= wave_end);
	n_waves = (wave_end - wave_start) + 1;

	/*
	 * Get the first waveform.  This is also used to retrieve the size of the waveforms
	 * that is needed to compute the BD list size.
	 *
	 * Wave bounds checking will be handled gracefully elsewhere, so this assert shouldn't
	 * be harmful.
	 */
	D_ASSERT(acq_get_ll_pointer(wave_start, &wave) == ACQRES_OK);
	total_sz = wave->pre_sz + wave->post_sz;
	extra_chunks  = wave->pre_sz / CSISTRM_AXI_MAX_BD_SIZE;
	extra_chunks += wave->post_sz / CSISTRM_AXI_MAX_BD_SIZE;

	/*
	 * Free the old BD list, if it's present.  Then, attempt to create a new BD list.  The
	 * list is three times the number of waveforms, as we have two pre-trigger DMA copies
	 * and one post-trigger DMA copy, plus one to allow for worst-case alignment.
	 */
	if(g_mipi_csi_state.bd_area != NULL) {
		free(g_mipi_csi_state.bd_area);
	}

	bd_entries = ((3 + extra_chunks) * n_waves) + 1;
	g_mipi_csi_state.bd_area = (void *)memalign(XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries * XAXIDMA_BD_MINIMUM_ALIGNMENT);

	if(g_mipi_csi_state.bd_area == NULL) {
		d_printf(D_ERROR, "mipi_csi: fatal error allocating memory for DMA scatter-gather list!");
		exit(-1);
	}

	D_ASSERT(((uint32_t)g_mipi_csi_state.bd_area % XAXIDMA_BD_MINIMUM_ALIGNMENT) == 0);

	/*
	 * Get the working BD ring; disable IRQs on it while we work on it.
	 * Then allocate the entries in the ring.
	 */
	ring = XAxiDma_GetTxRing(&g_mipi_csi_state.mipi_dma);
	XAxiDma_BdRingIntDisable(ring, XAXIDMA_IRQ_ALL_MASK);

	status = XAxiDma_BdRingCreate(ring, (int)g_mipi_csi_state.bd_area, (int)g_mipi_csi_state.bd_area, XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error creating BD ring %d", status);
		exit(-1);
	}

	XAxiDma_BdClear(&bd_template);
	status = XAxiDma_BdRingClone(ring, &bd_template);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error cloning BD ring %d", status);
		exit(-1);
	}

	status = XAxiDma_BdRingAlloc(ring, bd_entries, &bd_ptr);
	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error allocating BD ring %d", status);
		exit(-1);
	}

	/*
	 * Pack the entries into the BD, using the acquisition helper function to
	 * calculate the remapped addresses.  Each BD length must be less than 8MB,
	 * so large transfers are split up.
	 */
	cur_bd_ptr = bd_ptr;

	for(i = 0; i < n_waves; i++) {
		acq_dma_address_helper(wave, &addr_helper);

		// Add the pre-lower section in 8MB chunks
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, \
				addr_helper.pre_lower_end - addr_helper.pre_lower_start, addr_helper.pre_lower_start, XAXIDMA_BD_CTRL_TXSOF_MASK);

		// Add the pre-upper section in 8MB chunks
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, \
				addr_helper.pre_upper_end - addr_helper.pre_upper_start, addr_helper.pre_upper_start, XAXIDMA_BD_CTRL_TXSOF_MASK);

		// Add the post section in 8MB chunks
		cur_bd_ptr = _mipi_csi_axidma_add_bd_block(ring, cur_bd_ptr, \
				addr_helper.post_end - addr_helper.post_start, addr_helper.post_start, XAXIDMA_BD_CTRL_TXSOF_MASK);

		// End of list?
		if(acq_next_ll_pointer(wave, &next) != ACQRES_OK)
			break;
		wave = next;
	}

	g_mipi_csi_state.transfer_size = n_waves * total_sz;

	// Pass the BD to hardware for transmission
	status = XAxiDma_BdRingToHw(ring, bd_entries, bd_ptr); // This function manages cache coherency for BDs
	if (status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error passing BD ring to hardware %d", status);
		exit(-1);
	}
}

/*
 * Send a start of frame signal and wait for the MIPI controller to transmit that
 * (should happen in less than 50 us.)
 */
void mipi_csi_send_sof()
{
	// Ensure system is stopped first by sending a stop pulse.
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_STOP);
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_STOP);

	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_FRAME);
	while(!fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_FRAME);
}

/*
 * Send an end of frame signal and wait for the MIPI controller to transmit that
 * (should happen in less than 50 us.)
 */
void mipi_csi_send_eof()
{
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_END_FRAME);
	while(!fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_END_FRAME);
}

/*
 * Send a packet via the CSI bus, up to MCSI_PACKET_MAX_SIZE bytes.  The transfer
 * should have already been set up in the AXI controller, otherwise this may
 * hang forever.
 *
 * This function initiates a transfer: it doesn't wait for the transfer to complete.
 * The user should check the DONE state to see when to send the next packet.
 */
void mipi_csi_transfer_packet()
{
	uint32_t flags_a = 0;
	uint32_t lines = g_mipi_csi_state.csi_line_count;
	uint32_t size;

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
	}

	/*
	 * Counts are off by one and two (bytes) respectively, as the core counts down
	 * and tests at zero.
	 *
	 * So for 256 lines, the line counter must be loaded with 255, and for 2048 lines,
	 * 2046 must be loaded into the counter. Additionally the line byte count *must* be
	 * even (odd values will may a core lockup as the counter never reaches zero,
	 * with the logic subtracting two on each 16-bit word xfer.)
	 */
	D_ASSERT(INT_IS_EVEN(g_mipi_csi_state.csi_line_size)) ;

	if(g_mipi_csi_state.flags & MCSI_FLAG_CLOCK_IDLE_MODE) {
		flags_a |= CSI_CTRL_A_CLOCK_SLEEP_ENABLE;
	}

	fabcfg_write_masked(FAB_CFG_CSI_CTRL_B, lines - 1, CSI_CTRL_B_LINE_COUNT_MSK, CSI_CTRL_B_LINE_COUNT_SFT);
	fabcfg_set(FAB_CFG_CSI_CTRL_A, flags_a);
	fabcfg_write_masked(FAB_CFG_CSI_CTRL_A, g_mipi_csi_state.csi_line_size - 2, CSI_CTRL_A_LINE_BYTE_COUNT_MSK, CSI_CTRL_A_LINE_BYTE_COUNT_SFT);
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_LINES);

	g_mipi_csi_state.transfer_rem -= size;
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
	queue_poll(g_mipi_csi_state.item_queue, &q_item);

	while(q_item != NULL) {
		free(q_item);
		queue_poll(g_mipi_csi_state.item_queue, &q_item);
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
	g_mipi_csi_state.unpop_and_start_all = 1;
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
 * Tick controller.
 */
void mipi_csi_tick()
{
	struct mipi_csi_stream_queue_item_t q_item;

	return;

	switch(g_mipi_csi_state.state) {
		case MCSI_ST_IDLE:
			/*
			 * Unqueue the oldest command and see what we need to do with that command.  This
			 * may involve processing the command and setting up a DMA transfer.
			 *
			 * We only do this if we've received a command to unpop the command.
			 */
			if(g_mipi_csi_state.unpop_and_start || g_mipi_csi_state.unpop_and_start_all) {
				d_printf(D_RAW, "qs%d u%d,%d\r\n", queue_size(g_mipi_csi_state.item_queue), \
						g_mipi_csi_state.unpop_and_start, g_mipi_csi_state.unpop_and_start_all);
				g_mipi_csi_state.unpop_and_start = 0;

				if(queue_size(g_mipi_csi_state.item_queue) > 0) {
					queue_poll(g_mipi_csi_state.item_queue, (void *)&q_item);
					mipi_csi_process_queue_item(&q_item);
				} else {
					g_mipi_csi_state.flags |= MCSI_FLAG_QUEUE_EMPTY;
					g_mipi_csi_state.unpop_and_start_all = 0;
				}
			}
			break;

		case MCSI_ST_WAIT_FOR_XFER:
			/*
			 * Check if the MIPI controller is done with our last transfer.  If it's not, then
			 * we don't do anything here.
			 */
			if(fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) {
				// Do we have any more data left?
				if(g_mipi_csi_state.transfer_rem > 0) {
					// Data remains.  Process that data.
					mipi_csi_send_sof();
					mipi_csi_transfer_packet();
					mipi_csi_send_eof();
				} else {
					// We're done.  End the frame and go back to idle.  Cleanup and free buffers.
					mipi_csi_free_item(g_mipi_csi_state.working);
					D_ASSERT(g_mipi_csi_state.bd_area != NULL);
					free(g_mipi_csi_state.bd_area);
					free(g_mipi_csi_state.working);
					g_mipi_csi_state.bd_area = NULL;
					g_mipi_csi_state.working = NULL;
					g_mipi_csi_state.state = MCSI_ST_IDLE;

					g_mipi_csi_state.flags &= ~MCSI_FLAG_TRANSFER_RUNNING;
				}
			}
			break;
	}

}


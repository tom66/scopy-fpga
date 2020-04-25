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

#include "mipi_csi.h"
#include "acquire.h"
#include "hal.h"
#include "fabric_config.h"
#include "queue.h" // Collections-C

#include "xaxidma.h"
#include "xscugic.h"

struct mipi_csi_state_t g_mipi_csi_state;

/*
 * Initialise the MIPI CSI controller.  Sets up the queue and resets
 * fabric control variables to zero.  Initialises the DMA.
 */
void mipi_csi_init()
{
	QueueConf q_conf;
	q_conf.capacity = CSISTRM_QUEUE_SIZE;

	D_ASSERT(queue_new_conf(&q_conf, &g_mipi_csi_state.item_queue) == CC_OK);

	g_mipi_csi_state.flags |= MCSI_FLAG_CLOCK_IDLE_MODE;
	g_mipi_csi_state.state = MCSI_ST_IDLE;
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
 * Queue a waveform range into the CSI task queue.
 */
void mipi_csi_queue_waverange(uint32_t start, uint32_t stop, uint8_t data_type)
{
	struct mipi_csi_stream_queue_item_t *item;

	item = mipi_csi_alloc_item();

	item->data_type = data_type;
	item->item_type = CSISTRM_TYPE_WAVEFORM_RANGE;
	item->start_addr = start;

	queue_enqueue(g_mipi_csi_state.item_queue, item);
}

/*
 * Queue all waveforms into the CSI task queue.
 */
void mipi_csi_queue_all_waves(uint8_t data_type)
{
	mipi_csi_queue_waverange(CSISTRM_WAVE_ALL, CSISTRM_WAVE_ALL, data_type);
}

/*
 * Create a Scatter-Gather list for a given waveform range (CSISTRM_WAVE_ALL
 * not supported) which can be passed to the AXIDMA module to stream
 * waveform data.
 *
 * Portions based on dma_ex_sg_v2_1 (Xilinx)
 */
void mipi_csi_generate_sg_list_for_waves(uint32_t wave_start, uint32_t wave_end)
{
	int status, n_waves, bd_entries, i, chcnt, c;
	XAxiDma_BdRing *ring;
	XAxiDma_Bd *bd_ptr;
	XAxiDma_Bd *cur_bd_ptr;
	XAxiDma_Bd bd_template;
	struct acq_buffer_t *wave;
	struct acq_dma_addr_t addr_helper;
	uint32_t total_sz, extra_chunks, base, size;

	D_ASSERT(wave_start < wave_end);
	n_waves = (wave_end - wave_start) + 1;

	//XAxiDma_BdRing *ring;
	//XAxiDma_BdRingCreate;

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
	g_mipi_csi_state.bd_area = memalign(XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries * XAXIDMA_BD_MINIMUM_ALIGNMENT);

	if(g_mipi_csi_state.bd_area == NULL) {
		d_printf(D_ERROR, "mipi_csi: fatal error allocating memory for DMA scatter-gather list!");
		exit(-1);
	}

	D_ASSERT(((uint32_t)g_mipi_csi_state.bd_area % XAXIDMA_BD_MINIMUM_ALIGNMENT) == 0);

	status = XAxiDma_BdRingCreate(ring, (int)g_mipi_csi_state.bd_area, (int)g_mipi_csi_state.bd_area, XAXIDMA_BD_MINIMUM_ALIGNMENT, bd_entries);

	if(status != XST_SUCCESS) {
		d_printf(D_ERROR, "mipi_csi: fatal error creating BD ring %d", status);
		exit(-1);
	}

	/*
	 * Get the working BD ring; disable IRQs on it while we work on it.
	 * Then allocate the entries in the ring.
	 */
	ring = XAxiDma_GetTxRing(&g_mipi_csi_state.mipi_dma);
	XAxiDma_BdRingIntDisable(ring, XAXIDMA_IRQ_ALL_MASK);

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
	 * calculate the pre-trigger address.  Each BD length must be less than 8MB,
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
 * Tick controller.
 */
void mipi_csi_tick()
{
	switch(g_mipi_csi_state.state) {
		case MCSI_ST_IDLE:
			break;

		case MCSI_ST_WAIT_FOR_XFER:
			/*
			 * Check if the MIPI controller is done with our last transfer.  If it's not, then
			 * we don't do anything here.
			 */

			break;
	}

}


/*
 * mipi_csi.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 25 Apr 2020
 *      Author: Tom
 */

#ifndef SRC_MIPI_CSI_H_
#define SRC_MIPI_CSI_H_

#include <stdint.h>
#include "hal.h"

#include "queue.h" // Collections-C

#define CSISTRM_QUEUE_SIZE				50		// Max # of entries to support in the CSI queue.

#define CSISTRM_TYPE_UNDEF				0
#define CSISTRM_TYPE_ALLOC_UNDEF		1
#define CSISTRM_TYPE_RAW_MEMORY			2
#define CSISTRM_TYPE_WAVEFORM_RANGE		3
#define CSISTRM_TYPE_BITPACKED_WAVE		4

#define CSISTRM_WAVE_ALL				0xffffffff

#define CSISTRM_AXI_MAX_BD_SIZE			((1 << 23))

#define MCSI_FLAG_CLOCK_IDLE_MODE		0x00000001

#define MCSI_DEFAULT_LINE_WIDTH			2048
#define MCSI_DEFAULT_LINE_COUNT			256

#define MCSI_ST_IDLE					0
#define MCSI_ST_WAIT_FOR_XFER			1

struct mipi_csi_stream_queue_item_t {
	int index;
	uint8_t data_type;
	int item_type;

	uint32_t start_addr;	// Can be wave ID or pointer
	uint32_t end_addr;		// ^^^
};

struct mipi_csi_stats_t {
	uint32_t items_queued;
	uint32_t items_alloc;
	uint32_t items_freed;
	uint64_t data_xfer_bytes;
	uint64_t num_bds_created;
};

struct mipi_csi_state_t {
	Queue *item_queue;

	XAxiDma mipi_dma;
	XAxiDma_Config *mipi_dma_config;

	// State machine index
	int state;

	// Control flags of type MIPI_CSI_FLAG_x.
	uint32_t flags;

	// State of the transfer
	uint32_t transfer_size;
	uint32_t transfer_done;

	struct mipi_csi_stats_t stats;

	// Allocation of memory for BD Scatter-Gather list
	void *bd_area;
};

extern struct mipi_csi_state_t g_mipi_csi_state;

void mipi_csi_init();
struct mipi_csi_stream_queue_item_t *mipi_csi_alloc_item();
void mipi_csi_free_item(struct mipi_csi_stream_queue_item_t *item);
void mipi_csi_queue_waverange(uint32_t start, uint32_t stop, uint8_t data_type);
void mipi_csi_queue_all_waves(uint8_t data_type);
void mipi_csi_generate_sg_list_for_waves(uint32_t wave_start, uint32_t wave_end);
void mipi_csi_tick();

/*
 * Helper inline to add a BD entry, including address, length and control words, then
 * return the next BD pointer.
 */
inline XAxiDma_Bd *_mipi_csi_axidma_add_bd_entry(XAxiDma_BdRing *ring, XAxiDma_Bd *cur_bd, uint32_t buf_addr, uint32_t len, uint32_t ctrl)
{
	/*
	 * XXX: Consider replacing these with variants that do no bounds checking, if we can ensure
	 * that we never do misaligned or out of range transfers.
	 */
	D_ASSERT(XAxiDma_BdSetBufAddr(cur_bd, buf_addr) != XST_SUCCESS);
	D_ASSERT(XAxiDma_BdSetLength(cur_bd, len, ring->MaxTransferLen) != XST_SUCCESS);
	XAxiDma_BdSetCtrl(cur_bd, ctrl);

	return XAxiDma_BdRingNext(ring, cur_bd);
}

/*
 * Helper inline to pack 8MB sized BD entries (1 or more).  Returns next Bd pointer.
 */
inline XAxiDma_Bd* _mipi_csi_axidma_add_bd_block(XAxiDma_BdRing *ring, XAxiDma_Bd *cur_bd, uint32_t base, uint32_t size, uint32_t ctrl)
{
	int c, chcnt = size / CSISTRM_AXI_MAX_BD_SIZE;

	for(c = 0; c < chcnt; c++) {
		cur_bd = _mipi_csi_axidma_add_bd_entry(ring, cur_bd, base, MIN(size, CSISTRM_AXI_MAX_BD_SIZE), ctrl);
		base += CSISTRM_AXI_MAX_BD_SIZE;
		size -= CSISTRM_AXI_MAX_BD_SIZE;
	}

	g_mipi_csi_state.stats.num_bds_created += chcnt;
	return cur_bd;
}

#endif // SRC_MIPI_CSI_H_

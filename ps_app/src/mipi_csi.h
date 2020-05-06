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

#include "xaxidma.h"
#include "xscugic.h"

#define CSISTRM_QUEUE_SIZE				64		// Max # of entries to support in the CSI queue.  Must be power of two.

#define CSISTRM_TYPE_UNDEF				0
#define CSISTRM_TYPE_ALLOC_UNDEF		1
#define CSISTRM_TYPE_RAW_MEMORY			2
#define CSISTRM_TYPE_WAVEFORM_RANGE		3
#define CSISTRM_TYPE_BITPACKED_WAVE		4

#define CSISTRM_WAVE_ALL				0xffffffff

#define CSISTRM_AXI_MAX_BD_SIZE			((1 << 23))

#define MCSI_FLAG_ERROR_TRANSFER_BUSY	0x0002
#define MCSI_FLAG_ERROR_PARAMETER		0x0004
#define MCSI_FLAG_ERROR_STOP_TIMEOUT	0x0008
#define MCSI_FLAG_TRANSFER_RUNNING		0x0100
#define MCSI_FLAG_QUEUE_EMPTY			0x0200
#define MCSI_FLAG_STOP_DONE				0x0400
#define MCSI_FLAG_CLOCK_IDLE_MODE_2		0x4000		// Clock idles between EoF and next SoF
#define MCSI_FLAG_CLOCK_IDLE_MODE_1		0x8000		// Clock idles between each packet

// Special flags that indicate the state from the CSI peripheral of the DONE and RUN flags
#define MCSI_FLAG_SPECIAL_HW_DSTATE		0x4000
#define MCSI_FLAG_SPECIAL_HW_RSTATE		0x8000

#define MCSI_FLAG_ERROR_MASK			(MCSI_FLAG_ERROR_TRANSFER_BUSY | MCSI_FLAG_ERROR_PARAMETER | MCSI_FLAG_ERROR_STOP_TIMEOUT)

#define MCSI_DEFAULT_LINE_WIDTH			2048
#define MCSI_DEFAULT_LINE_COUNT			64
#define MCSI_PACKET_MAX_SIZE			(MCSI_DEFAULT_LINE_WIDTH * MCSI_DEFAULT_LINE_COUNT)

#define MCSI_DEFAULT_DATA_TYPE			0x2a
#define MCSI_DEFAULT_WCT				0x0000

#define MCSI_ST_IDLE					0
#define MCSI_ST_WAIT_FOR_XFER			1

#define MCSI_RET_OK						0
#define MCSI_RET_XAXIDMA_ERROR			-1

#define CSI_CTRL_A_START_LINES			0x00000001
#define CSI_CTRL_A_START_FRAME			0x00000002
#define CSI_CTRL_A_END_FRAME			0x00000004
#define CSI_CTRL_A_STOP					0x00000008
#define CSI_CTRL_A_SLEEP				0x00000010
#define CSI_CTRL_A_CLOCK_SLEEP_ENABLE	0x00000020
#define CSI_CTRL_A_RESET_FIFO			0x00000040
#define CSI_CTRL_A_RESET_PERIPHERAL		0x00000080
#define CSI_CTRL_A_LINE_BYTE_COUNT_MSK	0xffff0000
#define CSI_CTRL_A_LINE_BYTE_COUNT_SFT	16

#define CSI_CTRL_A_INIT_SIGNALS			(CSI_CTRL_A_START_LINES | CSI_CTRL_A_START_FRAME | CSI_CTRL_A_END_FRAME | CSI_CTRL_A_SLEEP)

#define CSI_CTRL_B_LINE_COUNT_MSK		0x0000ffff
#define CSI_CTRL_B_LINE_COUNT_SFT		0
#define CSI_CTRL_B_DATA_TYPE_MSK		0xff000000
#define CSI_CTRL_B_DATA_TYPE_SFT		24

#define CSI_CTRL_C_WCT_HEADER_MSK		0x0000ffff
#define CSI_CTRL_C_WCT_HEADER_SFT		0

#define CSI_STATUS_A_DONE				0x00000001
#define CSI_STATUS_A_CLKWIZ_LOCK		0x00000002
#define CSI_STATUS_A_RUNNING			0x00000004
#define CSI_STATUS_A_DBG_RV				0x00001000
#define CSI_STATUS_A_DBG_RR				0x00002000
#define CSI_STATUS_A_DBG_SA				0x00004000
#define CSI_STATUS_A_DBG_II				0x00008000
#define CSI_STATUS_A_DBG_IL				0x00010000
#define CSI_STATUS_A_DBG_IS				0x00020000
#define CSI_STATUS_A_DBG_DB				0x00040000
#define CSI_STATUS_A_DBG_DD				0x00080000
#define CSI_STATUS_A_DBG_CTRL_ST_MSK	0x03f00000
#define CSI_STATUS_A_DBG_CTRL_ST_SFT	20
#define CSI_STATUS_A_DBG_MIPI_ST_MSK	0xfc000000
#define CSI_STATUS_A_DBG_MIPI_ST_SFT	26

#define CSIRES_ERROR_WAVES				-1
#define CSIRES_OK						0

#define CSI_TIMEOUT_STOP				1000

#define CSI_DEFAULT_BIT_CLOCK			100			// Specified in MHz, FP values acceptable.  250MHz default, experimentation required to establish max bit clock

struct mipi_csi_stream_queue_item_t {
	int item_type;						// One of CSISTRM_TYPE_x values
	uint8_t data_type;					// Datatype to be passed to CSI FPGA core (becomes CSI datatype)
	uint16_t wct_header;				// Wordcount header to be passed to CSI FPGA core (becomes SOF/EOF wordcount field)
	uint32_t core_flags;				// Currently ignored, eventually due to be passed to the FPGA
	uint32_t start_addr;				// Can be wave ID or pointer
	uint32_t end_addr;					// Can be wave ID or pointer
	uint32_t calculated_size;			// Calculated size of any transfer in bytes, after the transfer has been processed and SG list packed
	XAxiDma_BdRing *ring;				// Pointer for this configured ring (filled after this entry is processed and all BD entries calculated)
};

struct mipi_csi_stats_t {
	uint32_t items_queued;				// Items queued in total
	uint32_t items_alloc;				// Items queued that memory has been allocated for
	uint32_t items_freed;				// Items freed in total (should closely match alloc)
	uint64_t data_xfer_bytes;			// Total bytes sent
	uint64_t num_bds_created;			// Total BD entries set up
	float last_transfer_time_us;		// Last transfer time in microseconds
	float last_transfer_perf_mbs;		// Last transfer rate in MB/s
	uint64_t total_transfer_time_us;	// Total transfer time in microseconds
	float last_sg_total_time_us;		// Total time to prepare the last scatter-gather list
	float last_sg_bd_time_us;			// Time to prepare the last scatter-gather BD list (the O(n) part of the equation)
};

struct mipi_csi_state_t {
	Queue *item_queue;
	XAxiDma mipi_dma;
	XAxiDma_Config *mipi_dma_config;

	// State machine
	int state;
	int unpop_and_start : 1;
	int unpop_and_start_all : 1;

	// Control/status flags of type MIPI_CSI_FLAG_x.
	uint16_t flags;

	// Working item from the queue.  NULL if no working item.
	struct mipi_csi_stream_queue_item_t *working;

	// State of the transfer
	uint32_t transfer_size;
	uint32_t transfer_rem;

	// Default CSI parameters
	uint16_t csi_line_size, csi_line_count, csi_frame_wct;
	uint8_t csi_data_type;

	struct mipi_csi_stats_t stats;

	// Allocation of memory for BD Scatter-Gather list
	void *bd_area;

	// Bitclock for CSI port in MHz.  Valid range approx 50 ~ 550MHz.
	float csi_bitclock;
};

/*
 * MIPI CSI status: returned back to Pi host.
 *
 * Do not modify this structure without considering the changes required on
 * the Pi side first!
 */
struct __attribute__ ((packed)) mipi_csi_status_t {
	uint16_t flags;
	uint32_t data_rem;
	uint16_t queue_size;
};

/*
 * MIPI transfer size response.  Returns byte size of an all-waves
 * transfer, a trigger data transfer and one bitpacked wave transfer.
 *
 * Do not modify this structure without considering the changes required on
 * the Pi side first!
 */
struct __attribute__ ((packed)) mipi_tx_size_resp_t {
	uint32_t all_waves_size;
	uint32_t trigger_data_size;
	uint32_t bitpack_size;
};

extern struct mipi_csi_state_t g_mipi_csi_state;

void mipi_csi_init();
struct mipi_csi_stream_queue_item_t *mipi_csi_alloc_item();
void mipi_csi_free_item(struct mipi_csi_stream_queue_item_t *item);
void mipi_csi_process_queue_item(struct mipi_csi_stream_queue_item_t *item);
void mipi_csi_queue_buffer(uint32_t start_addr, uint32_t end_addr);
void mipi_csi_queue_waverange(uint32_t start, uint32_t end);
void mipi_csi_queue_all_waves();
void mipi_csi_set_datatype_and_frame_wct(uint8_t data_type, uint16_t frame_wct);
int mipi_csi_setup_bdring_and_bd(void *bd_area, int bd_entries, XAxiDma_BdRing **ring, XAxiDma_Bd **bd_ptr);
int mipi_csi_generate_sg_list_for_buffer_range(uint32_t addr_start, uint32_t addr_end, struct mipi_csi_stream_queue_item_t *q_item);
int mipi_csi_generate_sg_list_for_waves(uint32_t wave_start, uint32_t wave_end, struct mipi_csi_stream_queue_item_t *q_item);
void mipi_csi_send_sof();
void mipi_csi_send_eof();
void mipi_csi_transfer_packet();
void mipi_csi_clear_queue();
void mipi_csi_unpop_and_start();
void mipi_csi_unpop_and_start_all();
void mipi_csi_stop();
void mipi_csi_get_status(struct mipi_csi_status_t *status);
void mipi_csi_get_size_report(struct mipi_tx_size_resp_t *status);
void mipi_csi_tick();

/*
 * Helper inline to add a BD entry, including address, length and control words, then
 * return the next BD pointer.
 */
inline XAxiDma_Bd *_mipi_csi_axidma_add_bd_entry(XAxiDma_BdRing *ring, XAxiDma_Bd *cur_bd, uint32_t buf_addr, uint32_t len, uint32_t ctrl)
{
	//d_printf(D_INFO, "ring:%08x, cur_bd:%08x, buf_addr:%08x, len:%d, ctrl:%08x", \
			ring, cur_bd, buf_addr, len, ctrl);

	/*
	 * XXX: Consider replacing these with variants that do no bounds checking, if we can ensure
	 * that we never do misaligned or out of range transfers.
	 */
	D_ASSERT(XAxiDma_BdSetBufAddr(cur_bd, buf_addr) == XST_SUCCESS);
	D_ASSERT(XAxiDma_BdSetLength(cur_bd, len, ring->MaxTransferLen) == XST_SUCCESS);
	XAxiDma_BdSetCtrl(cur_bd, ctrl);

	return XAxiDma_BdRingNext(ring, cur_bd);
}

/*
 * Helper inline to pack 8MB sized BD entries (1 or more).  Returns next Bd pointer.
 */
inline XAxiDma_Bd* _mipi_csi_axidma_add_bd_block(XAxiDma_BdRing *ring, XAxiDma_Bd *cur_bd, int size, uint32_t base, bool sof, bool eof)
{
	int c;
	int chcnt = (size / CSISTRM_AXI_MAX_BD_SIZE) + 1;
	uint32_t ctrl = 0;

	//d_printf(D_INFO, "size=%10d base=0x%08x curbd=0x%08x maxsize=%8d chcnt=%5d", size, base, cur_bd, CSISTRM_AXI_MAX_BD_SIZE, chcnt);

	for(c = 0; c < chcnt; c++) {
		/*
		 * Add SOF and EOF flags to actual first and last BD entries.
		 *
		 * SOF and EOF flags should be set per block according to the first and last block respectively
		 * this logic ensures the tags are appended to the *true* start/end block.
		 */
		if(eof && ((c + 1) == chcnt)) {
			ctrl |= XAXIDMA_BD_CTRL_TXEOF_MASK;
		}

		if(sof && (c == 0)) {
			ctrl |= XAXIDMA_BD_CTRL_TXSOF_MASK;
		}

		cur_bd = _mipi_csi_axidma_add_bd_entry(ring, cur_bd, base, MIN(size, CSISTRM_AXI_MAX_BD_SIZE), ctrl);
		base += CSISTRM_AXI_MAX_BD_SIZE;
		size -= CSISTRM_AXI_MAX_BD_SIZE;
	}

	g_mipi_csi_state.stats.num_bds_created += chcnt;
	return cur_bd;
}

#endif // SRC_MIPI_CSI_H_

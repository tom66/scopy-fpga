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
 * does not currently implement support for this DSP core.
 */

#ifndef SRC_MIPI_CSI_H_
#define SRC_MIPI_CSI_H_

#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>

#define MCSI_STATE_IDLE				0			// Nothing to do
#define MCSI_STATE_RUN				1			// Transfer running
#define MCSI_STATE_TRANSFER_MEMCPY	2			// Waiting for memcpy to be done
#define MCSI_STATE_TRANSFER_DMA		3			// Waiting for PL330 DMA to be done
#define MCSI_STATE_WAITING_CSI		4			// Waiting for CSI peripheral to be done

#define MCSI_FLAG_TX_SINGLE			0x00000001
#define MCSI_FLAG_TX_MULTI			0x00000002
#define MCSI_FLAG_TX_ALL_DONE		0x00000004
#define MCSI_FLAG_TX_ERROR			0x00000008
#define MCSI_FLAG_USE_DMA			0x00000010
#define MCSI_FLAG_USE_MEMCPY		0x00000020
#define MCSI_FLAG_OUTPUT_MULTI		0x00000040	// CSI transfer is happening in multiple operations
#define MCSI_FLAG_BUF_A_VALID		0x00000080
#define MCSI_FLAG_BUF_B_VALID		0x00000100

#define MCSI_MAX_TOTAL_BRAM_SIZE	65536		// Bytes
#define MCSI_MAX_BUFFER_BRAM_SIZE	32768		// Bytes
#define MCSI_LINE_SIZE				2048		// Bytes

#define MCSI_RES_OK					0
#define MCSI_RES_WAVE_ERROR			-1
#define MCSI_RES_MEMCPY_BOUND		-2

#define MCSI_BRAM_BASE				(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR)
#define MCSI_BRAM_BASE_1_OFFSET		(MCSI_MAX_BUFFER_BRAM_SIZE)
#define MCSI_BRAM_END				XPAR_AXI_BRAM_CTRL_1_S_AXI_HIGHADDR

struct mcsi_state_t {
	int state;
	uint32_t flags;

	/* Buffer in use (0, 1) */
	int buffer_id;
	uint32_t bram_addr;
	uint32_t bram_offs;

	/* Desired MIPI line size.  Should be a power of two. */
	uint32_t mipi_line_size;

	/* Waveform currently being transmitted, and packet in this waveform ID */
	struct acq_buffer_t *wave;
	uint32_t cur_wave_offset;

	/* Range of a multi-waveform request.  wave_start MUST precede wave_end in the LL. */
	struct acq_buffer_t *wave_start;
	struct acq_buffer_t *wave_end;
};

void mcsi_init();
int mcsi_setup_transfer_by_id(uint32_t wave_id);
int mcsi_setup_multi_transfer_by_id(uint32_t wave_start, uint32_t wave_end);
void mcsi_start();
void mcsi_tick();
void _mcsi_tx_memcpy(struct acq_buffer_t *buf, uint32_t offset_src, uint32_t bram_des, uint32_t bytes_max);
int _mcsi_tx_memcpy_assist_bounded(void *base, void *src, size_t length, uint32_t addr_limit);

#endif // SRC_MIPI_CSI_H_

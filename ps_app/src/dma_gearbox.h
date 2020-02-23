/*
 * dma_gearbox.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 22 Feb 2020
 *      Author: Tom
 */

#ifndef SRC_DMA_GEARBOX_H_
#define SRC_DMA_GEARBOX_H_

#include <stdint.h>

#include "xdmaps.h"

#define DMA_GBOX_8B_MODE			0
#define DMA_GBOX_12B14B_MODE		1

#define DMA_GBOX_RES_OK				0

#define DMA_GBOX_CHANNEL			0		// Use channel 0

#define DMA_DEVICE_ID 				XPAR_XDMAPS_1_DEVICE_ID

struct dma_gearbox_state_t {
	/* DMA Configuration & Base Struct */
	XDmaPs_Config *dmaps_cfg;
	XDmaPs dmaps_inst;
	XDmaPs_Cmd dmaps_cmd;

	/* Running?  Ready?  */
	int running;
	int ready;

	/* Configuration for the DMA */
	uint32_t start_addr_word;		// Starting word address (aligned to 8 byte boundary)
	uint32_t end_addr_word;			// Ending word address (aligned to 8 byte boundary)
	unsigned int word_offset;		// Starting offset in word (1 ~ 8)
	unsigned int src_increment;		// 1 ~ 4; must be even for precision modes
	unsigned int data_size;			// 1 or 2

	/* Destination base address */
	uint32_t base_dest_addr;
};

int dma_gearbox_setup_copy(uint8_t demux_mode, unsigned int start_index, uint32_t start_addr, uint32_t end_addr, uint32_t base_dest_addr);
void dma_gearbox_execute();
int dma_gearbox_is_done();

#endif // SRC_DMA_GEARBOX_H_

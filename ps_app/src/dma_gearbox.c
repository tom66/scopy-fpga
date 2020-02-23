/*
 * dma_gearbox.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 22 Feb 2020
 *      Author: Tom
 */

/*
 * This module controls the PL330 DMA on the ARM.  The PL330 DMA is a complex, programmable
 * DMA engine which is used to perform DDR to BRAM copies.  The engine is also capable of
 * demultiplexing data when configured correctly.
 *
 * Briefly:  Demultiplexing involves decoding the channel data and selecting the appropriate
 * data words from the data stream.
 *
 * In 1 channel mode, the demultiplexing engine does not run.  Direct copies from the DDR3
 * to the BRAM (or other system memory) are executed.
 *
 * In 2 channel mode, the DMA selects every other byte from the data stream.  The starting
 * byte can be any index in the word (0-7).
 *
 * In 4 channel mode, the DMA selects every fourth byte from the data stream.  The starting
 * byte can be again any index in the word (0-7).
 *
 * In precision modes (2 bytes per data word), the DMA selects two bytes from the data stream.
 * Offsets must be multiples of 2.  Otherwise, the behaviour is identical.
 */

#include "dma_gearbox.h"
#include "acquire.h"
#include "hal.h"

#include "xdmaps.h"

struct dma_gearbox_state_t g_dma_gbox;

/*
 * Initialise data structures.
 */
void dma_gearbox_init()
{
	int res;

	g_dma_gbox.running = 0;
	g_dma_gbox.ready = 0;
	g_dma_gbox.dmaps_cfg = XDmaPs_LookupConfig(DMA_DEVICE_ID);

	if(g_dma_gbox.dmaps_cfg == NULL) {
		d_printf(D_ERROR, "dma_gearbox: XDmaPs failed to initialise (g_dma_gbox.dmaps_cfg == NULL)");
		exit(-1);
	}

	res = XDmaPs_CfgInitialize(&g_dma_gbox.dmaps_inst, g_dma_gbox.dmaps_cfg, g_dma_gbox.dmaps_cfg->BaseAddress);

	if(res != XST_SUCCESS) {
		d_printf(D_ERROR, "dma_gearbox: XDmaPs failed to initialise (XDmaPs_CfgInitialize returned %d)", res);
		exit(-1);
	}

	d_printf(D_INFO, "dma_gearbox: XDmaPs ready");
}

/*
 * Setup a DMA gearbox operation.  It doesn't start until the execute instruction is sent.
 */
int dma_gearbox_setup_copy(uint8_t demux_mode, unsigned int start_index, uint32_t start_addr, uint32_t end_addr, uint32_t base_dest_addr)
{
	uint32_t length;

	// Future:  These should just return error codes instead of throwing assertions
	D_ASSERT(g_dma_gbox.running == 0) ;
	D_ASSERT((start_addr & 0x03) == 0) ;
	D_ASSERT((end_addr & 0x03) == 0) ;
	D_ASSERT(start_addr < end_addr) ;
	D_ASSERT(demux_mode & (ADCDEMUX_1CH | ADCDEMUX_2CH | ADCDEMUX_4CH)) ;
	D_ASSERT(demux_mode & (ADCDEMUX_8BIT | ADCDEMUX_12BIT | ADCDEMUX_14BIT)) ;
	D_ASSERT(start_index >= 0 && start_index <= 7) ;

	/*
	 * For 8-bit modes, determine offset based on start_index alone.
	 *
	 * For 12-bit and 14-bit modes, determine offset based on start index but mask the LSB as
	 * that would produce an unaligned read.
	 */
	if(demux_mode & ADCDEMUX_8BIT) {
		if(demux_mode & ADCDEMUX_1CH) {
			g_dma_gbox.src_increment = 1;
		} else if(demux_mode & ADCDEMUX_2CH) {
			g_dma_gbox.src_increment = 2;
		} else if(demux_mode & ADCDEMUX_4CH) {
			g_dma_gbox.src_increment = 4;
		}

		g_dma_gbox.word_offset = start_index;
		g_dma_gbox.data_size = 1;
	} else if(demux_mode & (ADCDEMUX_12BIT | ADCDEMUX_14BIT)) {
		if(demux_mode & ADCDEMUX_1CH) {
			g_dma_gbox.src_increment = 2;
		} else if(demux_mode & ADCDEMUX_2CH) {
			g_dma_gbox.src_increment = 4;
		} else if(demux_mode & ADCDEMUX_4CH) {
			g_dma_gbox.src_increment = 8;  // may not be permitted as exceeds 32-bit boundary
		}

		g_dma_gbox.word_offset = start_index & 0x06;
		g_dma_gbox.data_size = 2;
	}

	g_dma_gbox.base_dest_addr = base_dest_addr;
	g_dma_gbox.start_addr_word = start_addr;
	g_dma_gbox.end_addr_word = end_addr;

	length = (g_dma_gbox.end_addr_word - g_dma_gbox.start_addr_word) / g_dma_gbox.data_size;

	/*
	 * Program the DMA controller but don't start the transfer.
	 */
	g_dma_gbox.dmaps_cmd.ChanCtrl.EndianSwapSize = 0;
	g_dma_gbox.dmaps_cmd.ChanCtrl.SrcCacheCtrl = 0;
	g_dma_gbox.dmaps_cmd.ChanCtrl.SrcBurstSize = g_dma_gbox.src_increment;
	g_dma_gbox.dmaps_cmd.ChanCtrl.SrcBurstLen = g_dma_gbox.src_increment;
	g_dma_gbox.dmaps_cmd.ChanCtrl.SrcInc = g_dma_gbox.src_increment;
	g_dma_gbox.dmaps_cmd.ChanCtrl.DstCacheCtrl = 0;
	g_dma_gbox.dmaps_cmd.ChanCtrl.DstBurstSize = 1;
	g_dma_gbox.dmaps_cmd.ChanCtrl.DstBurstLen = 1;
	g_dma_gbox.dmaps_cmd.ChanCtrl.DstInc = 1;
	g_dma_gbox.dmaps_cmd.BD.SrcAddr = start_addr + g_dma_gbox.word_offset;
	g_dma_gbox.dmaps_cmd.BD.DstAddr = g_dma_gbox.base_dest_addr;
	g_dma_gbox.dmaps_cmd.BD.Length = length;

	g_dma_gbox.ready = 1;

	d_printf(D_INFO, "** dma_gearbox_setup_copy **");
	d_printf(D_INFO, "");
	d_printf(D_INFO, "SrcInc  = %d", g_dma_gbox.dmaps_cmd.ChanCtrl.SrcInc);
	d_printf(D_INFO, "SrcAddr = 0x%08x", g_dma_gbox.dmaps_cmd.BD.SrcAddr);
	d_printf(D_INFO, "DstAddr = 0x%08x", g_dma_gbox.base_dest_addr);
	d_printf(D_INFO, "Length  = 0x%08x (%d)", g_dma_gbox.dmaps_cmd.BD.Length, g_dma_gbox.dmaps_cmd.BD.Length);
	d_printf(D_INFO, "");

	return DMA_GBOX_RES_OK;
}

/*
 * Start the initialised transfer.  If the transfer is not initialised, an assertion
 * is thrown.
 */
void dma_gearbox_execute()
{
	D_ASSERT(g_dma_gbox.ready == 1) ;
	XDmaPs_Start(&g_dma_gbox.dmaps_inst, DMA_GBOX_CHANNEL, &g_dma_gbox.dmaps_cmd, 0);
	XDmaPs_Print_DmaProg(&g_dma_gbox.dmaps_cmd);
}

/*
 * Reports whether the DMAPS is done with the requested operation.
 */
int dma_gearbox_is_done()
{
	return !XDmaPs_IsActive(&g_dma_gbox.dmaps_inst, DMA_GBOX_CHANNEL);
}


/*
 * mipi_csi_hw.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 12 June 2020
 *      Author: Tom
 */

/*
 * Hardware interfcace for revised MIPI streaming core.
 */

#include "mipi_csi_hw.h"
#include "mipi_csi.h"

/*
 * Send a reset FIFO command, ensuring the FIFO starts off empty.
 */
void mipi_csi_send_fifo_reset()
{
	//outbyte('R');

	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_RESET_FIFO);
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_RESET_FIFO);
}

/*
 * Send a start of frame signal and wait for the MIPI controller to transmit that
 * (should happen in less than 50 us.)
 */
void mipi_csi_send_sof()
{
	//outbyte('S');

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

	//outbyte(',');
}

/*
 * Send an end of frame signal and wait for the MIPI controller to transmit that
 * (should happen in less than 50 us.)
 */
void mipi_csi_send_eof()
{
	//outbyte('E');

	fabcfg_write_masked(FAB_CFG_CSI_CTRL_C, g_mipi_csi_state.csi_frame_wct, CSI_CTRL_C_WCT_HEADER_MSK, CSI_CTRL_C_WCT_HEADER_SFT);

	// TODO: There is probably a better way to do this.
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_START_LINES | CSI_CTRL_A_START_FRAME);
	fabcfg_set(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_END_FRAME);
	bogo_delay(1);
	while(!fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;  //  wait for DONE to go HIGH - command done
	fabcfg_clear(FAB_CFG_CSI_CTRL_A, CSI_CTRL_A_END_FRAME);

	//outbyte('.');

	//d_printf(D_RAW, "[f%d]", g_frame_ctr++);

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
 * Send a padding packet (N empty frames with no lines.)
 */
void mipi_csi_pack_padding(int frames)
{
	fabcfg_write_masked(FAB_CFG_CSI_CTRL_B, 0, CSI_CTRL_B_LINE_COUNT_MSK, CSI_CTRL_B_LINE_COUNT_SFT);

	// Send the frame start signal first, then send the start lines signal.
	while(frames--) {
		//outbyte('0' + frames);
		mipi_csi_send_sof();
		//while(fabcfg_test(FAB_CFG_CSI_STATUS_A, CSI_STATUS_A_DONE)) ;
		mipi_csi_send_eof();
	}
}

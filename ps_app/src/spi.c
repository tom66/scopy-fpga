/*
 * spi.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 3 Apr 2020
 *      Author: Tom
 */

#include <stdint.h>

// Deque data structure
#include "Collections-C/src/include/deque.h"

#include "xspips.h"

#include "hal.h"
#include "spi.h"
#include "spi_commands.h"
#include "fabric_config.h"
#include "version_tag.h"

struct spi_state_t g_spi_state;
struct spi_command_lut_t g_spi_command_lut[SPI_COMMAND_TOTAL_COUNT];

struct spi_version_resp_t version_resp;

/*
 * Initialise the SPI controller.
 *
 * This must be called after the fabric configurator is loaded.
 */
void spi_init()
{
	char b0, b1, b2;
	int i, error;

	/*
	 * Initialise the SPI peripheral.
	 */
	g_spi_state.spi_config = XSpiPs_LookupConfig(SPI_DEVICE_ID);
	if(g_spi_state.spi_config == NULL) {
		d_printf(D_ERROR, "spi: configuration lookup returns NULL");
		exit(-1);
	}

	error = XSpiPs_CfgInitialize(&g_spi_state.spi, g_spi_state.spi_config, g_spi_state.spi_config->BaseAddress);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "spi: unable to initialise SPI peripheral: error %d", error);
		exit(-1);
	}

	/*
	 * Perform a self-test on the hardware.
	 */
	error = XSpiPs_SelfTest(&g_spi_state.spi);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "spi: selftest failed: error %d", error);
		exit(-1);
	}

	/*
	 * SPI starts as slave.  Configure clock polarity.
	 */
	error = XSpiPs_SetOptions(&g_spi_state.spi, XSPIPS_CR_CPHA_MASK | XSPIPS_CR_CPOL_MASK);

	if (error != XST_SUCCESS) {
		d_printf(D_ERROR, "spi: unable to configure options: error %d", error);
		exit(-1);
	}

	XSpiPs_SetRXWatermark(&g_spi_state.spi, SPI_SHORTEST_MESSAGE); 		 // Interrupt when we have at least 2 bytes (SPI_SHORTEST_MESSAGE) available
	XSpiPs_SetTXWatermark(&g_spi_state.spi, SPI_TX_OVERWATER_DEFAULT);

	/*
	 * Connect interrupts to the SPI peripheral, then enable the peripheral.
	 */
	error = XScuGic_Connect(&g_hal.xscu_gic, XPAR_XSPIPS_0_INTR, (Xil_ExceptionHandler)spi_isr_handler, NULL);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "spi: unable to connect ScuGic: error %d", error);
		exit(-1);
	}

	REG_SET_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_IER_OFFSET, XSPIPS_IXR_RXNEMPTY_MASK);
	XSpiPs_Enable(&g_spi_state.spi);
	XScuGic_Enable(&g_hal.xscu_gic, XPAR_XSPIPS_0_INTR);

	d_printf(D_INFO, "spi: peripheral initialised @ 0x%08x", g_spi_state.spi_config->BaseAddress);

	/*
	 * Initialise the SPI LUTs and command state machine.
	 */
	spi_crc_lut_gen();
	spi_command_lut_gen();

	g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;

	/*
	 * Initialise the Deque for commands.  Prepare the allocation table.
	 */
	error = deque_new(&g_spi_state.command_dq);

	if(error != CC_OK) {
		d_printf(D_ERROR, "spi: unable to initialise deque: error %d", error);
		exit(-1);
	}

	for(i = 0; i < SPI_QUEUE_ALLOC_MAX; i++) {
		g_spi_state.cmd_alloc_table[i].alloc_idx = i;
		g_spi_state.cmd_alloc_table[i].cmd = 0;
		g_spi_state.cmd_alloc_table[i].nargs = 0;
	}

	/*
	 * Bitmask starts with all slots free (masks set to all ones), but since there
	 * is typically one less bit set in the last word, use our setter inline.
	 * GCC will probably optimise this to a few const writes.
	 */
	for(i = 0; i < SPI_QUEUE_ALLOC_MAX; i++) {
		spi_command_mark_slot_free(i);
	}

	/*
	 * Prepare the 'Version' response now.
	 */
	version_resp.bitstream_id = fabcfg_read(FAB_CFG_VERSION);
	version_resp.usraccess = fabcfg_read(FAB_CFG_USRACCESS);
	version_resp.ps_app_id = PS_APP_VERSION_INT;
	version_resp.build_timestamp = 0x00000000; // TBD

	d_printf(D_ERROR, "hanging at SPI processor");

	while(1) {
		spi_command_tick();
		bogo_delay(20000);
		//d_printf(D_INFO, "SR=0x%08x", XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET));
	}

	/*
	while(1) {
		if(XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET) & XSPIPS_IXR_RXNEMPTY_MASK) {
			b0 = XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_RXD_OFFSET);
			b1 = XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_RXD_OFFSET);
			b2 = XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_RXD_OFFSET);
			d_printf(D_INFO, "RXD=%02x%02x%02x", b0, b1, b2);
		}
	}
	*/
}

/*
 * Initialise the SPI CRC8 LUT.
 */
void spi_crc_lut_gen()
{
	int i, j, k;

	// Tom Hargreaves, 2020
	for(i = 0; i < 256; i++) {
		for(j = 0, k = i; j < 8; j++) {
			if((k <<= 1) & 0x100) {
				k ^= SPI_CRC8_POLY;
			}
		}
		g_spi_state.crc_table[i] = k;
	}
}


/*
 * Initialise the SPI command LUT.
 */
void spi_command_lut_gen()
{
	struct spi_command_def_t *spi_cmd;
	int i, added = 0;

	// Reset the LUT, setting valid fields to 0
	for(i = 0; i < SPI_COMMAND_TOTAL_COUNT; i++) {
		memset(g_spi_command_lut[i].short_name, 0, SPI_COMMAND_SHORT_NAME_MAX + 1);
		g_spi_command_lut[i].valid = 0;
	}

	/*
	 * For each entry until the end ID of 0xff, copy the data over from the const
	 * table and set the valid flag to 1
	 */
	for(i = 0; spi_command_defs[i].cmd_id != 0xff; i++) {
		spi_cmd = &spi_command_defs[i];

		strncpy(g_spi_command_lut[spi_cmd->cmd_id].short_name, spi_cmd->short_name, SPI_COMMAND_SHORT_NAME_MAX);
		g_spi_command_lut[spi_cmd->cmd_id].nargs = spi_cmd->nargs;
		g_spi_command_lut[spi_cmd->cmd_id].cmd_processor = spi_cmd->cmd_processor;
		g_spi_command_lut[spi_cmd->cmd_id].has_response = spi_cmd->has_response;
		g_spi_command_lut[spi_cmd->cmd_id].valid = 1;
		added++;
	}

	d_printf(D_INFO, "spi: %d LUT entries filled, %d free", added, SPI_COMMAND_TOTAL_COUNT - added);
}

/*
 * ISR context handler for SPI.  We do not use the XSpiPs interrupt
 * handler.
 */
void spi_isr_handler(void *unused)
{
	char byte;
	int sent_response = 0, tx_bytes = 0, sent_bytes = 0, slot_idx = 0;
	struct spi_command_alloc_t *slot;

	gpio_led_write(1, 1);

	/*
	 * What we do in this ISR is entirely dependent on the state we are in.
	 *
	 * States are:
	 *   - SPI_STATE_CMD_HEADER:       Reading header byte (advances immediately)
	 *   - SPI_STATE_ARGS:             Reading argument bytes (advances after # args are read)
	 *   - SPI_STATE_CHECKSUM:         Reading checksum byte (advances immediately)
	 *   - SPI_STATE_RESPONSE_WAIT:    If a command has a response, we clock 0xff out until the response is ready
	 *                                 then 0xcc followed by the response which can be freely clocked out.
	 *                                 We sit in this state until the response is generated.  Data clocked in must
	 *                                 be 0x00, or we exit this state.
	 *   - SPI_STATE_RESPONSE_SIZE:    Size header is clocked out (1-2 bytes).
	 *   - SPI_STATE_RESPONSE:         Data is clocked out.
	 *
	 * The state machine executes one iteration for each byte available.
	 *
	 * Error states can occur, which will revert the state machine back to the header
	 * processing stage.
	 */
	while(XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET) & XSPIPS_IXR_RXNEMPTY_MASK) {
		sent_response = 0;
		g_spi_state.stats.num_bytes_rxtx++;
		byte = XSpiPs_ReadReg(g_spi_state.spi_config->BaseAddress, XSPIPS_RXD_OFFSET);

		switch(g_spi_state.cmd_state) {
			case SPI_STATE_CMD_HEADER:
				/*
				 * Check to see if this byte is a valid command.  If it is, we advance to the
				 * next state with the argument count and command stored.
				 */
				if(g_spi_command_lut[byte].valid) {
					g_spi_state.cmd_id = byte;
					g_spi_state.has_response = g_spi_command_lut[byte].has_response;
					g_spi_state.cmd_argpop = g_spi_command_lut[byte].nargs;
					g_spi_state.cmd_argidx = 0;
					g_spi_state.crc = g_spi_state.crc_table[byte];
					memset(&g_spi_state.cmd_argdata, 0, SPI_COMMAND_MAX_ARGS);

					g_spi_state.stats.num_bytes_rx_valid++;
					g_spi_state.stats.num_command_ok++;

					// Zero arguments: no args pushed into the stack, so jump straight to checksum state
					if(g_spi_state.cmd_argpop == 0) {
						g_spi_state.cmd_state = SPI_STATE_CHECKSUM;
					} else {
						g_spi_state.cmd_state = SPI_STATE_ARGS;
					}
				} else {
					g_spi_state.stats.num_command_errors++;
				}
				break;

			case SPI_STATE_ARGS:
				/*
				 * Pop off the arguments until there are none left.
				 */
				g_spi_state.cmd_argdata[g_spi_state.cmd_argidx] = byte;
				g_spi_state.crc = g_spi_state.crc_table[g_spi_state.crc ^ byte];
				g_spi_state.cmd_argpop--;
				g_spi_state.cmd_argidx++;
				g_spi_state.stats.num_bytes_rx_valid++;

				if(g_spi_state.cmd_argpop == 0) {
					g_spi_state.cmd_state = SPI_STATE_CHECKSUM;
				}
				break;

			case SPI_STATE_CHECKSUM:
				g_spi_state.stats.num_bytes_rx_valid++;
				/*
				d_printf(D_INFO, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x (CRC:%02x)", \
						g_spi_state.cmd_id, \
						g_spi_state.cmd_argdata[0], \
						g_spi_state.cmd_argdata[1], \
						g_spi_state.cmd_argdata[2], \
						g_spi_state.cmd_argdata[3], \
						g_spi_state.cmd_argdata[4], \
						g_spi_state.cmd_argdata[5], \
						g_spi_state.cmd_argdata[6], \
						g_spi_state.cmd_argdata[7], \
						g_spi_state.cmd_argdata[8], \
						g_spi_state.cmd_argdata[9], \
						g_spi_state.cmd_argdata[10], \
						g_spi_state.cmd_argdata[11], \
						g_spi_state.cmd_argdata[12], \
						byte, g_spi_state.crc);
				*/

				if(g_spi_state.crc != byte) {
					gpio_led_write(0, 1);
				}

				if(g_spi_state.crc == byte) {
					/*
					 * Pack the command in the deque by finding a space for it.  If there's
					 * no free slot in the static allocation table, then throw away the command.
					 * If the deque is full, then throw away the command.
					 */
					slot_idx = spi_command_find_free_slot();

					if(slot_idx == -1) {
						g_spi_state.stats.num_command_lost_full_alloc++;
						g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
					} else {
						spi_command_mark_slot_occupied(slot_idx);
						slot = &g_spi_state.cmd_alloc_table[slot_idx];
						slot->cmd = g_spi_state.cmd_id;
						memcpy(slot->args, g_spi_state.cmd_argdata, SPI_COMMAND_MAX_ARGS);
						slot->nargs = g_spi_state.cmd_argidx;
						slot->resp_ready = 0;
						slot->crc_valid = g_spi_state.crc == byte;

						// XXX: This *might* do a malloc, if we add more items than the capacity of the deque.
						// But this shouldn't normally happen, as we only have SPI_QUEUE_ALLOC_MAX slots available,
						// in our static allocation buffer, one less than the size of the deque SPI_QUEUE_SIZE.
						if(deque_add_last(g_spi_state.command_dq, slot) != CC_OK) {
							g_spi_state.stats.num_command_lost_full_deque++;
							g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
							d_printf(D_ERROR, "Out of space for SPI commands");
						} else {
							g_spi_state.commands_queued++;
							g_spi_state.stats.num_command_accepted++;
							g_spi_state.last_cmd = slot;

							// If the command has a response go to the response handler state.
							if(g_spi_state.has_response) {
								g_spi_state.cmd_state = SPI_STATE_RESPONSE_WAIT;
							} else {
								g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
							}
						}
					}
				} else {
					// Invalid CRC.  Discard the packet after incrementing the relevant statistic.
					g_spi_state.stats.num_crc_errors++;
					g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;

					/*
					d_printf(D_ERROR, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x (CRC:%02x)", \
							g_spi_state.cmd_id, \
							g_spi_state.cmd_argdata[0], \
							g_spi_state.cmd_argdata[1], \
							g_spi_state.cmd_argdata[2], \
							g_spi_state.cmd_argdata[3], \
							g_spi_state.cmd_argdata[4], \
							g_spi_state.cmd_argdata[5], \
							g_spi_state.cmd_argdata[6], \
							g_spi_state.cmd_argdata[7], \
							g_spi_state.cmd_argdata[8], \
							g_spi_state.cmd_argdata[9], \
							g_spi_state.cmd_argdata[10], \
							g_spi_state.cmd_argdata[11], \
							g_spi_state.cmd_argdata[12], \
							byte, g_spi_state.crc);
					*/
				}
				break;

			case SPI_STATE_RESPONSE_WAIT:
				/*
				 * We hang out in this state until the most recent command is ready to
				 * return a response.  Commands that return a response are "blocking" - we
				 * cannot receive any other commands while they are waiting to be processed.
				 * But this is a fair trade-off given most commands do not need a response
				 * and it avoids having to handle returning the right data for the right command.
				 *
				 * We output 0xff while the command is not done with the data.  The Pi can
				 * continue to ping us with packets triggering frequent IRQs until we are ready.
				 * Packets must be 0x00 to stay in reception state.  If any other value is received,
				 * then the command receive will abort and we go to receive a new command instead.
				 *
				 * When the command is ready, we transmit 0xcc followed by the packet data.  The
				 * 0xcc byte is a frame boundary and is not part of the returned data packet.
				 */
				if(byte == 0x00) {
					if(g_spi_state.last_cmd->resp_ready) {
						spi_transmit(0xcc);
						sent_response = 1;
					} else {
						spi_transmit(0xff);
						sent_response = 1;
						g_spi_state.cmd_state = SPI_STATE_RESPONSE_SIZE;
					}
				} else {
					g_spi_state.stats.num_resp_aborts_byte_rec++;
					g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
				}
				break;

			case SPI_STATE_RESPONSE_SIZE:
				/*
				 * Size packet prefixes any returned data.  Size packet is 1 or 2 bytes.
				 *
				 * For transfers 1 ~ 127 bytes the size packet is 0x01 ~ 0x7f.
				 * For transfers 128 ~ 32640 bytes, the size packet is 0x80 ~ 0xff followed
				 * by another 8 bits (total of ~15 bits.)
				 */
				D_ASSERT(g_spi_state.last_cmd->resp_size <= SPI_RESPONSE_2BYTE_MAX) ;

				if(g_spi_state.last_cmd->resp_size <= SPI_RESPONSE_1BYTE_MAX) {
					// Pack one byte, then advance state machine.
					spi_transmit(g_spi_state.last_cmd->resp_size);
					sent_response = 1;
				} else if(g_spi_state.last_cmd->resp_size <= SPI_RESPONSE_2BYTE_MAX) {
					// Pack two bytes, then advance state machine -- it doesn't matter
					// if these aren't aligned to our IRQ, they will be transmitted eventually anyway.
					spi_transmit((g_spi_state.last_cmd->resp_size >> 8) + 0x80);
					spi_transmit(g_spi_state.last_cmd->resp_size & 0xff);
					sent_response = 1;
					g_spi_state.stats.num_bytes_rxtx++; // possibly off-by-one here, but it's just a statistic.
				}

				g_spi_state.resp_bytes = g_spi_state.last_cmd->resp_size;
				g_spi_state.resp_data_ptr = g_spi_state.last_cmd->resp_data;
				g_spi_state.cmd_state = SPI_STATE_RESPONSE;
				break;

			case SPI_STATE_RESPONSE:
				/*
				 * Pack up to SPI_RESPONSE_PACK_SIZE bytes at a time to reduce CPU load.
				 * We return to CMD_HEADER once all bytes have been sent.
				 */
				if(g_spi_state.resp_bytes > 0) {
					tx_bytes = MIN(g_spi_state.resp_bytes, SPI_RESPONSE_PACK_SIZE);
					sent_bytes = spi_transmit_packet_nonblock(g_spi_state.resp_data_ptr, tx_bytes);
					g_spi_state.resp_data_ptr += sent_bytes;
					g_spi_state.resp_bytes -= sent_bytes;
				}

				if(g_spi_state.resp_bytes == 0) {
					/*
					 * Wait until the TX buffer is empty then we are done.  To check if it is
					 * empty, we set the TXFIFO UW level to 1.
					 */
					XSpiPs_SetTXWatermark(&g_spi_state.spi, 1);

					if(!SPI_IS_TX_OVERWATER()) {
						XSpiPs_SetTXWatermark(&g_spi_state.spi, SPI_TX_OVERWATER_DEFAULT);
						g_spi_state.stats.num_resps++;
						g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
					}
				}

				/*
				 * Always set sent_response as we don't want garbage to get mixed in while we
				 * unpack the FIFO.
				 */
				sent_response = 1;
				break;
		}

		/*
		 * If no other byte is sent, then send 0x55 as an indication of ISR activity
		 * for debug purposes.
		 */
		if(!sent_response) {
			spi_transmit(0x55);
		}
	}

	gpio_led_write(1, 0);
	gpio_led_write(0, 0);
}

/*
 * Transmit a packet via the SPI port while TX FIFO is not overwater,
 * and fill it until it is FULL.
 *
 * This function is not blocking, if there is no space free then it
 * returns zero immediately.
 */
int spi_transmit_packet_nonblock(uint8_t *pkt, uint8_t bytes)
{
	int bytes_written = 0;

	if(SPI_IS_TX_OVERWATER()) {
		return 0;
	}

	while(bytes > 0) {
		if(!SPI_IS_TX_FULL()) {
			XSpiPs_WriteReg(g_spi_state.spi.Config.BaseAddress, XSPIPS_TXD_OFFSET, (uint32_t)(*pkt));
			bytes_written++;
			pkt++;
			bytes--;
		} else {
			return bytes_written;
		}
	}
}

/*
 * Find a free command in the command allocation table.  If no slots are available
 * then return NULL.  The first free slot is returned.
 */
int spi_command_find_free_slot()
{
	uint32_t free_mask;
	unsigned int i;
	int bit;

	for(i = 0; i < SPI_QUEUE_ALLOC_BITMASK_SIZE; i++) {
		// Find first set bit by using __builtin_ffs
		free_mask = g_spi_state.cmd_free_bitmask[i];

		// Can this we done without a branch?
		if(free_mask != 0x00000000) {
			bit = __builtin_ffs(free_mask);
			return (i * 32) + bit - 1;
		}
	}

	return -1;
}

/*
 * Process any commands in the command buffer.  Commands that are completed are popped
 * from the buffer.
 */
void spi_command_tick()
{
	struct spi_command_alloc_t *cmd;
	static int i;

	/*
	if(deque_size(g_spi_state.command_dq) == 0) {
		d_printf(D_INFO, "No entries %d (rxtx=%llu, crc=%llu)", i++, \
				g_spi_state.stats.num_bytes_rxtx, \
				g_spi_state.stats.num_crc_errors);
	}
	*/

	/*
	while(1) {
		d_printf(D_RAW, "(free: %08x %08x %08x %08x)\r\n",
				g_spi_state.cmd_free_bitmask[0],
				g_spi_state.cmd_free_bitmask[1],
				g_spi_state.cmd_free_bitmask[2],
				g_spi_state.cmd_free_bitmask[3]);
	}
	*/

	/*
	for(i = 0; i < 127; i++) {
		d_printf(D_RAW, "(free: %08x %08x %08x %08x)\r\n",
				g_spi_state.cmd_free_bitmask[0],
				g_spi_state.cmd_free_bitmask[1],
				g_spi_state.cmd_free_bitmask[2],
				g_spi_state.cmd_free_bitmask[3]);

		spi_command_mark_slot_occupied(i);
	}

	for(i = 0; i < 127; i++) {
		d_printf(D_RAW, "(free: %08x %08x %08x %08x)\r\n",
				g_spi_state.cmd_free_bitmask[0],
				g_spi_state.cmd_free_bitmask[1],
				g_spi_state.cmd_free_bitmask[2],
				g_spi_state.cmd_free_bitmask[3]);

		spi_command_mark_slot_free(i);
	}

	while(1) ;
	*/

	/*
	 * See how many entries in the queue are available.  Process each entry.
	 */
	while(deque_size(g_spi_state.command_dq) > 0) {
		// Pop the entry off the queue head
		deque_remove_first(g_spi_state.command_dq, (void*)&cmd);

		if(!cmd->crc_valid) {
			d_printf(D_RAW, "\033[31m");
		}

		d_printf(D_RAW, "Got command 0x%02x index %3d args %3d [ ", cmd->cmd, cmd->alloc_idx, cmd->nargs);

		for(i = 0; i < cmd->nargs; i++) {
			d_printf(D_RAW, "%02x ", cmd->args[i]);
		}

		d_printf(D_RAW, "] CRC_errors=%llu, full_alloc=%llu, full_deque=%llu (free: %08x %08x %08x %08x)\033[0m\r\n",
				g_spi_state.stats.num_crc_errors, \
				g_spi_state.stats.num_command_lost_full_alloc, \
				g_spi_state.stats.num_command_lost_full_deque,
				g_spi_state.cmd_free_bitmask[0],
				g_spi_state.cmd_free_bitmask[1],
				g_spi_state.cmd_free_bitmask[2],
				g_spi_state.cmd_free_bitmask[3]);

		// Free the alloc from the table making it available for later use
		spi_command_mark_slot_free(cmd->alloc_idx);
		//cmd->alloc = 0;
	}
}


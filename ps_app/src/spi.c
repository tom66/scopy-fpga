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
struct spi_version_resp_t g_version_resp;

volatile int test_counter = 0;

/*
 * Initialise the SPI controller.
 *
 * This must be called after the fabric configurator is loaded.
 */
void spi_init()
{
	char b0, b1, b2;
	int i, error;
	volatile int x;

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

	spi_reset_hw();
	XSpiPs_Reset(&g_spi_state.spi);

	/*
	 * SPI starts as slave.  Configure CPOL and CPHA to zero.  Disable ModeFail.
	 *
	 * The XSpiPs_SetOptions function is bugged;  write the bits manually.
	 */
	REG_CLR_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_CR_OFFSET, XSPIPS_CR_MODF_GEN_EN_MASK);
	REG_CLR_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_CR_OFFSET, XSPIPS_CR_MSTREN_MASK);
	REG_CLR_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_CR_OFFSET, XSPIPS_CR_CPOL_MASK);
	REG_CLR_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_CR_OFFSET, XSPIPS_CR_CPHA_MASK);

	// Set slave clock cycle count to 1 (effectively disables clock filtering?)
	//XSpiPs_WriteReg(g_spi_state.spi_config->BaseAddress, XSPIPS_SICR_OFFSET, 0x00000001);

	XSpiPs_SetRXWatermark(&g_spi_state.spi, 2);
	XSpiPs_SetTXWatermark(&g_spi_state.spi, 64 /*SPI_TX_OVERWATER_DEFAULT*/);

	d_printf(D_WARN, "SpiCR=0x%08x", XSpiPs_ReadReg(g_spi_state.spi.Config.BaseAddress, XSPIPS_CR_OFFSET));

	// Pack some shit into TX FIFO, you know, because why not
	/*
	for(i = 0; i < 120; i++) {
		spi_transmit_no_wait(i);
	}
	*/

	// Ensure RX FIFO is completely empty
	while(spi_read_sr_errata() & XSPIPS_IXR_RXNEMPTY_MASK) {
		spi_receive_no_wait();
	}

	/*
	 * Connect interrupts to the SPI peripheral, then enable the peripheral.
	 */
	error = XScuGic_Connect(&g_hal.xscu_gic, XPAR_XSPIPS_0_INTR, (Xil_ExceptionHandler)spi_isr_handler, NULL);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "spi: unable to connect ScuGic: error %d", error);
		exit(-1);
	}

	XSpiPs_Enable(&g_spi_state.spi);

	d_printf(D_INFO, "spi: peripheral initialised @ 0x%08x", g_spi_state.spi_config->BaseAddress);

	/*
	 * Initialise the SPI LUTs and command state machine.
	 */
	spi_crc_lut_gen();
	spi_command_lut_gen();

	// Set default values
	g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
	g_spi_state.proc_state = SPIPROC_STATE_UNPACK;

	g_spi_state.byte_tx = 0x00;
	g_spi_state.byte_send = 1;

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
	g_version_resp.bitstream_id = fabcfg_read(FAB_CFG_VERSION);
	g_version_resp.usraccess = fabcfg_read(FAB_CFG_USRACCESS);
	g_version_resp.ps_app_id = PS_APP_VERSION_INT;
	g_version_resp.build_timestamp = 0x00000000; // TBD

	//uint8_t buff1[1] = { test_counter };
	//uint8_t buff2[1];

	i = 0;

	/*
	 * Enable SPI interrupts.  Clear initial interrupts.
	 */
	REG_SET_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_SR_OFFSET, XSPIPS_IXR_WR_TO_CLR_MASK);
	REG_SET_BIT(g_spi_state.spi.Config.BaseAddress, XSPIPS_IER_OFFSET, XSPIPS_IXR_MODF_MASK | XSPIPS_IXR_TXUF_MASK | XSPIPS_IXR_RXNEMPTY_MASK);
	XScuGic_Enable(&g_hal.xscu_gic, XPAR_XSPIPS_0_INTR);

	d_printf(D_ERROR, "hanging at SPI processor");

	while(1) {
		spi_command_tick();
	}
}

/*
 * Reset the SPI hardware.  The XSpiPs driver is bugged in many ways, and one of the problems it has
 * is that the reset is incorrectly implemented.
 */
void spi_reset_hw()
{
	REG_SET_BIT(0x00000000, SPI_RST_CTRL_REG_SLCR, SPI_RST_CTRL_MASK);
	bogo_delay(10);
	REG_CLR_BIT(0x00000000, SPI_RST_CTRL_REG_SLCR, SPI_RST_CTRL_MASK);
	bogo_delay(10);
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
	char byte_rx;
	int tx_bytes = 0, sent_bytes = 0, slot_idx = 0;
	struct spi_command_alloc_t *slot;

	//test_counter++;

	gpio_led_write(1, 1);

	//d_printf(D_RAW, "I (SR=0x%08x)", spi_read_sr_errata());

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
	 * Output bytes:
	 *   - 0x00 = Pending/no state
	 *   - 0x08 = Processing command/wait for response
	 *   - 0x18 = Packing arguments
	 *   - 0x55 = NOP response
	 *   - 0xa5 = No response/end of process
	 *   - 0xab = Abort response
	 *   - 0xb0 = Waiting for command to complete
	 *   - 0xcc = Size byte(s) follow
	 *   - 0xfd = Internal error
	 *   - 0xfe = Error with checksum
	 *   - 0xff = Error with command
	 *
	 * Error states can occur, which will revert the state machine back to the header
	 * processing stage.
	 */
	if(spi_read_sr_errata() & XSPIPS_IXR_RXNEMPTY_MASK) {
		g_spi_state.stats.num_bytes_rxtx++;

		/*
		if(g_spi_state.byte_send) {
			if(!spi_transmit(g_spi_state.byte_tx)) {
				d_printf(D_RAW, "err-FIFO\r\n");
			}
		}
		*/

		// Send byte (from last iteration), if required
		/*
		if(g_spi_state.byte_send) {
			//gpio_led_write(0, 1);
			spi_transmit_no_wait(g_spi_state.byte_tx);

			// If TXUF bit is set, attempt to recover: pack the byte again
			if(REG_TEST_BIT(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET, XSPIPS_IXR_TXUF_MASK)) {
				spi_transmit_no_wait(g_spi_state.byte_tx);
			}

			//gpio_led_write(0, 0);
		}
		*/

		byte_rx = spi_receive_no_wait();

		if(byte_rx == 0xbb) {
			gpio_led_write(0, 1);
		} else if(byte_rx == 0xcc) {
			gpio_led_write(0, 0);
		}

#if 0
		// Check for FIFO TXUF
		if(REG_TEST_BIT(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET, XSPIPS_IXR_TXUF_MASK)) {
			/*
			while(1) {
				gpio_led_write(0, 1);
				gpio_led_write(0, 0);
			}
			*/
		}
#endif

		// Default byte to pack.
		//g_spi_state.byte_tx = test_counter++; // g_spi_state.cmd_state;
		//g_spi_state.byte_send = 1;

		switch(g_spi_state.cmd_state) {
			case SPI_STATE_CMD_HEADER:
				/*
				 * Command 0x00: special NOP, does not get processed or packed onto the stack
				 * and does not need any checksum.  Responds with 0x55 when ready.
				 */
				if(byte_rx == 0x00) {
					g_spi_state.stats.num_bytes_rx_valid++;
					g_spi_state.stats.num_command_nop++;
					SPI_SET_RESPONSE(SPI_RESP_CMD_NOP_READY);
				} else {
					/*
					 * Check to see if this byte is a valid command.  If it is, we advance to the
					 * next state with the argument count and command stored.
					 */
					if(g_spi_command_lut[byte_rx].valid) {
						g_spi_state.cmd_id = byte_rx;
						g_spi_state.has_response = g_spi_command_lut[byte_rx].has_response;
						g_spi_state.cmd_argpop = g_spi_command_lut[byte_rx].nargs;
						//d_printf(D_RAW, "CmdId%d,N%d,rr%d,", byte_rx, g_spi_command_lut[byte_rx].nargs, g_spi_state.has_response);
						g_spi_state.cmd_argidx = 0;
						g_spi_state.crc = g_spi_state.crc_table[byte_rx];
						memset(&g_spi_state.cmd_argdata, 0, SPI_COMMAND_MAX_ARGS);

						g_spi_state.stats.num_bytes_rx_valid++;
						g_spi_state.stats.num_command_ok++;
						SPI_SET_RESPONSE(SPI_RESP_PENDING);

						// Zero arguments: no args pushed into the stack, so jump straight to checksum state
						if(g_spi_state.cmd_argpop == 0) {
							g_spi_state.cmd_state = SPI_STATE_CHECKSUM;
						} else {
							g_spi_state.cmd_state = SPI_STATE_ARGS;
						}
					} else {
						g_spi_state.stats.num_command_errors++;
						SPI_SET_RESPONSE(SPI_RESP_CMD_ERROR);
					}
				}
				break;

			case SPI_STATE_ARGS:
				/*
				 * Pop off the arguments until there are none left.
				 */
				g_spi_state.cmd_argdata[g_spi_state.cmd_argidx] = byte_rx;
				g_spi_state.crc = g_spi_state.crc_table[g_spi_state.crc ^ byte_rx];
				g_spi_state.cmd_argpop--;
				g_spi_state.cmd_argidx++;
				g_spi_state.stats.num_bytes_rx_valid++;

				if(g_spi_state.cmd_argpop == 0) {
					g_spi_state.cmd_state = SPI_STATE_CHECKSUM;
				}

				SPI_SET_RESPONSE(SPI_RESP_PENDING_ARGS);
				break;

			case SPI_STATE_CHECKSUM:
				g_spi_state.stats.num_bytes_rx_valid++;

				// Pretend CRC always correct if SPI_IGNORE_CRC set
#if SPI_IGNORE_CRC == 1
				byte_rx = g_spi_state.crc;
#endif

				if(g_spi_state.crc == byte_rx) {
					/*
					 * Pack the command in the deque by finding a space for it.  If there's
					 * no free slot in the static allocation table, then throw away the command.
					 * If the deque is full, then throw away the command.
					 */
					slot_idx = spi_command_find_free_slot();

					if(slot_idx == -1) {
						SPI_SET_RESPONSE(SPI_RESP_INTERNAL_ERROR);
						g_spi_state.stats.num_command_lost_full_alloc++;
						g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
					} else {
						spi_command_mark_slot_occupied(slot_idx);
						slot = &g_spi_state.cmd_alloc_table[slot_idx];
						slot->cmd = g_spi_state.cmd_id;
						memcpy(slot->args, g_spi_state.cmd_argdata, SPI_COMMAND_MAX_ARGS);
						slot->nargs = g_spi_state.cmd_argidx;
						slot->resp_ready = 0;
						slot->crc_valid = g_spi_state.crc == byte_rx;

						// XXX: This *might* do a malloc, if we add more items than the capacity of the deque.
						// But this shouldn't normally happen, as we only have SPI_QUEUE_ALLOC_MAX slots available,
						// in our static allocation buffer, one less than the size of the deque SPI_QUEUE_SIZE.
						if(deque_add_last(g_spi_state.command_dq, slot) != CC_OK) {
							SPI_SET_RESPONSE(SPI_RESP_INTERNAL_ERROR);
							g_spi_state.stats.num_command_lost_full_deque++;
							g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
							d_printf(D_ERROR, "Out of space for SPI commands");
						} else {
							g_spi_state.commands_queued++;
							g_spi_state.stats.num_command_accepted++;
							g_spi_state.last_cmd = slot;

							// If the command has a response go to the response handler state.
							if(g_spi_state.has_response) {
								//d_printf(D_RAW, "R");
								SPI_SET_RESPONSE(SPI_RESP_WAIT_RESPONSE);
								g_spi_state.cmd_state = SPI_STATE_RESPONSE_WAIT;
							} else {
								SPI_SET_RESPONSE(SPI_RESP_NO_RESPONSE);
								g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
							}
						}
					}
				} else {
					// Invalid CRC.  Discard the packet after incrementing the relevant statistic.
					SPI_SET_RESPONSE(SPI_RESP_CRC_ERROR);
					d_printf(D_INFO, "spi: crc err, expect 0x%02x got 0x%02x (0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x ...)",
							g_spi_state.crc, byte_rx, g_spi_state.cmd_id, \
							g_spi_state.cmd_argdata[0], g_spi_state.cmd_argdata[1],
							g_spi_state.cmd_argdata[2], g_spi_state.cmd_argdata[3],
							g_spi_state.cmd_argdata[4], g_spi_state.cmd_argdata[5]);
					g_spi_state.stats.num_crc_errors++;
					g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
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
				if(byte_rx == 0x00) {
					//d_printf(D_RAW, "ZERO");
					if(g_spi_state.last_cmd->resp_ready) {
						SPI_SET_RESPONSE(SPI_RESP_SIZE_FOLLOWS);
						g_spi_state.cmd_state = SPI_STATE_RESPONSE_SIZE;
					} else {
						SPI_SET_RESPONSE(SPI_RESP_WAIT_RESPONSE);
					}
				} else {
					SPI_SET_RESPONSE(SPI_RESP_ABORT_RESPONSE);
					d_printf(D_RAW, "rx:0x%02x\r\n", byte_rx);
					g_spi_state.last_cmd->resp_done = 1;  // Signal done as we've aborted
					g_spi_state.stats.num_resp_aborts_byte_rec++;
					g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
				}
				break;

			case SPI_STATE_RESPONSE_SIZE:
				/*
				 * Size packet prefixes any returned data.  Size packet is 1 or 2 bytes.
				 *
				 * For transfers 1 ~ 127 bytes the size packet is 0x01 ~ 0x7f.
				 * For transfers 128 ~ 32384 bytes, the size packet is 0x80 ~ 0xff followed
				 * by another 8 bits (total of ~15 bits.)
				 */
				D_ASSERT(g_spi_state.last_cmd->resp_size <= SPI_RESPONSE_2BYTE_MAX) ;

				g_spi_state.resp_bytes = g_spi_state.last_cmd->resp_size;
				g_spi_state.resp_data_ptr = g_spi_state.last_cmd->resp_data;

				if(g_spi_state.last_cmd->resp_size <= SPI_RESPONSE_1BYTE_MAX) {
					// Pack one byte, then advance state machine.
					SPI_SET_RESPONSE(g_spi_state.last_cmd->resp_size);
					g_spi_state.cmd_state = SPI_STATE_RESPONSE;
				} else if(g_spi_state.last_cmd->resp_size <= SPI_RESPONSE_2BYTE_MAX) {
					// Pack two bytes; first in this state, and second in subsequent state
					SPI_SET_RESPONSE(0x80 + (g_spi_state.last_cmd->resp_size / 256));
					g_spi_state.resp_sz2 = g_spi_state.last_cmd->resp_size & 0xff;
					g_spi_state.cmd_state = SPI_STATE_RESPONSE_SIZE_EXTRA;
				}
				break;

			case SPI_STATE_RESPONSE_SIZE_EXTRA:
				// Pack remaining size LSB then pack the response
				SPI_SET_RESPONSE(g_spi_state.resp_sz2);
				g_spi_state.cmd_state = SPI_STATE_RESPONSE;
				break;

			case SPI_STATE_RESPONSE:
				/*
				 * Pack up to SPI_RESPONSE_PACK_SIZE bytes at a time to reduce CPU load.
				 * We return to CMD_HEADER once all bytes have been sent.
				 */
				if(g_spi_state.resp_bytes > 0) {
					tx_bytes = MIN(g_spi_state.resp_bytes, SPI_RESPONSE_PACK_SIZE);
					//d_printf(D_RAW, "[TX:%d,rem:%d]", tx_bytes, g_spi_state.resp_bytes);

					XSpiPs_SetTXWatermark(&g_spi_state.spi, SPI_TX_OVERWATER_DEFAULT); // ???

					sent_bytes = spi_transmit_packet_nonblock(g_spi_state.resp_data_ptr, tx_bytes);
					//d_printf(D_RAW, ",%d", sent_bytes);

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
						g_spi_state.last_cmd->resp_done = 1;
						g_spi_state.cmd_state = SPI_STATE_CMD_HEADER;
					}
				}

				// Do not pack an output byte.
				g_spi_state.byte_send = 0;
				break;
		}

		SPI_SET_RESPONSE(byte_rx);

		// Clear NEMPTY bit & TXUF
		//REG_SET_BIT(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET, XSPIPS_IXR_RXNEMPTY_MASK | XSPIPS_IXR_TXUF_MASK);
	} //while(spi_read_sr_errata() & XSPIPS_IXR_RXNEMPTY_MASK) ;

	// Clear other ISR bits
	REG_SET_BIT(g_spi_state.spi_config->BaseAddress, XSPIPS_SR_OFFSET, XSPIPS_IXR_WR_TO_CLR_MASK);

	gpio_led_write(1, 0);
	gpio_led_write(0, 0);
}

/*
 * Transmit a packet via the SPI port while TX FIFO is not overwater, and fill it until
 * it is FULL.
 *
 * This function is not blocking, if there is no space free then it returns zero immediately.
 */
int spi_transmit_packet_nonblock(uint8_t *pkt, int bytes)
{
	int bytes_written = 0, i;

	D_ASSERT(bytes > 0);

	if(SPI_IS_TX_OVERWATER()) {
		//d_printf(D_RAW, "OW!");
		return 0;
	}

	/*
	 * We know that we can pack at least (SPI_RESPONSE_PACK_SIZE - 1) bytes into the FIFO as it is
	 * not overwater.  Anything past this point is a bonus but we need to check the FULL flag for
	 * each byte we pack.
	 *
	 * We need to check for the case where we are transmitting less than (SPI_RESPONSE_PACK_SIZE - 1)
	 * bytes, but the bulk condition should be unrollable nicely.
	 */
	if(bytes < (SPI_RESPONSE_PACK_SIZE - 1)) {
		return _spi_transmit_fill_fifo(pkt, bytes);
	} else {
		for(i = 0; i < (SPI_RESPONSE_PACK_SIZE - 1); i++) {
			XSpiPs_WriteReg(g_spi_state.spi.Config.BaseAddress, XSPIPS_TXD_OFFSET, (uint8_t)(*pkt++));
		}

		bytes_written += (SPI_RESPONSE_PACK_SIZE - 1);
		bytes -= (SPI_RESPONSE_PACK_SIZE - 1);

		if(bytes > 0) {
			bytes_written += _spi_transmit_fill_fifo(pkt, bytes);
		}

		return bytes_written;
	}
}

/*
 * Find a free command in the command allocation table.  If no slots are available
 * then return -1.  The first free slot found is returned.
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
 * Count the number of commands currently allocated.
 */
int spi_command_count_allocated()
{
	uint32_t free_mask;
	unsigned int i;
	int count = 0;

	for(i = 0; i < SPI_QUEUE_ALLOC_BITMASK_SIZE; i++) {
		free_mask = g_spi_state.cmd_free_bitmask[i];
		count += __builtin_popcount(free_mask);
	}

	return count;
}

/*
 * Pack a response for a command using a memory copy.  This isn't suitable for
 * large commands as it has relatively high overheads in the form of a memcpy
 * (in case the response was on the stack beforehand.)
 */
int spi_command_pack_response_simple(struct spi_command_alloc_t *cmd, uint8_t *resp, int respsz)
{
	// Malloc the response buffer.  This'll be freed by the command tick once the response is done.
	cmd->resp_data = malloc(respsz);

	//d_printf(D_INFO, "spi: packing response 0x%08x into 0x%08x size:%d", resp, cmd->resp_data, respsz);

	if(cmd->resp_data == NULL) {
		d_printf(D_ERROR, "spi: error allocating %d bytes for command response - response failed", respsz);

		asm("cpsid I"); // Disable interrupts while we update key state
		cmd->resp_size = 0;
		cmd->resp_ready = 1;
		cmd->resp_error = 1;
		asm("cpsie I"); // Enable interrupts again

		return SPIRET_MEM_ERROR;
	}

	memcpy(cmd->resp_data, resp, respsz);

	asm("cpsid I");
	cmd->resp_size = respsz;
	cmd->resp_ready = 1;
	cmd->resp_error = 0;
	cmd->free_resp_reqd = 1;
	asm("cpsie I");

	return SPIRET_OK;
}

/*
 * Process any commands in the command buffer.  Commands that are completed are popped
 * from the buffer.
 */
void spi_command_tick()
{
	int i;
	struct spi_command_alloc_t *cmd;

	d_printf(D_RAW, "%d\r\n", spi_command_count_allocated());

	switch(g_spi_state.proc_state) {
		case SPIPROC_STATE_UNPACK:
			if(deque_size(g_spi_state.command_dq) > 0) {
				deque_remove_first(g_spi_state.command_dq, (void*)&cmd);
				g_spi_state.proc_cmd = cmd;
			}

			if(g_spi_state.proc_cmd != NULL) {
				//d_printf(D_INFO, "spi: executing callback for cmd 0x%02x", cmd->cmd);
				//d_printf(D_RAW, "X(0x%02x)", cmd->cmd);

				// If the command has a callback, deal with that.
				if(g_spi_command_lut[cmd->cmd].cmd_processor != NULL) {
					g_spi_command_lut[cmd->cmd].cmd_processor(cmd);
				}

				//d_printf(D_INFO, "spi: cmd done");

				// If the command generated a response then spin on the response readiness state later
				if(cmd->resp_ready) {
					for(i = 0; i < 120; i++) {
						spi_transmit_no_wait(i + 0x80);
					}

					//d_printf(D_INFO, "spi: response ready");
					//g_spi_state.proc_state = SPIPROC_STATE_SPIN_RESPONSE;
				} else {
					// Otherwise, free the alloc from the table making it available for use now
					spi_command_mark_slot_free(cmd->alloc_idx);
					cmd->resp_ready = 0;
					cmd->resp_done = 0;
					g_spi_state.proc_cmd = NULL;
				}
			}
			break;

		case SPIPROC_STATE_SPIN_RESPONSE:
			if(cmd->resp_done) {
				//d_printf(D_INFO, "spi: response process done");

				// Free the alloc from the table making it available for use now
				spi_command_mark_slot_free(cmd->alloc_idx);
				cmd->resp_ready = 0;
				cmd->resp_done = 0;
				cmd->resp_error = 0;

				// Free any malloc'd buffer if necessary
				if(cmd->free_resp_reqd) {
					//d_printf(D_INFO, "spi: freeing response buffer 0x%08x", cmd->resp_data);
					free(cmd->resp_data);
				}

				g_spi_state.proc_cmd = NULL;
				g_spi_state.proc_state = SPIPROC_STATE_UNPACK;
			}

			// TODO: Should we add a timeout here?
			break;
	}
}


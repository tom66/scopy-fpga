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

	XSpiPs_SetRXWatermark(&g_spi_state.spi, SPI_SHORTEST_MESSAGE);  // Interrupt when we have at least 2 bytes (SPI_SHORTEST_MESSAGE) available

	/*
	 * Connect interrupts to the SPI peripheral.
	 */
	error = XScuGic_Connect(&g_hal.xscu_gic, XPAR_XSPIPS_0_INTR, (Xil_ExceptionHandler)spi_isr_handler, NULL);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "spi: unable to connect ScuGic: error %d", error);
		exit(-1);
	}

	d_printf(D_INFO, "spi: peripheral initialised @ 0x%08x", g_spi_state.spi_config->BaseAddress);

	/*
	 * Initialise the SPI command LUT.
	 */
	spi_command_lut_gen();

	/*
	 * Initialise the Deque for commands.  Prepare the allocation table.
	 */
	error = deque_new(&g_spi_state.command_dq);

	if(error != CC_OK) {
		d_printf(D_ERROR, "spi: unable to initialise deque: error %d", error);
		exit(-1);
	}

	for(i = 0; i < SPI_QUEUE_ALLOC_MAX; i++) {
		g_spi_state.cmd_alloc_table[i].alloc = 0;
		g_spi_state.cmd_alloc_table[i].cmd = 0;
		g_spi_state.cmd_alloc_table[i].nargs = 0;
	}

	g_spi_state.cmd_alloc_count = 0;

	/*
	 * Prepare the 'Version' response now.
	 */
	version_resp.bitstream_id = fabcfg_read(FAB_CFG_VERSION);
	version_resp.usraccess = fabcfg_read(FAB_CFG_USRACCESS);
	version_resp.ps_app_id = PS_APP_VERSION_INT;
	version_resp.build_timestamp = 0x00000000; // TBD
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
	d_printf(D_INFO, "spi: isr");
}

/*
 * Process any commands in the command buffer.  Commands that are completed are popped
 * from the buffer.
 */
void spi_command_tick()
{

}

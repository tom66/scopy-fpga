/*
 * spi_commands.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 8 Apr 2020
 *      Author: Tom
 */

#include "spi.h"
#include "spi_commands.h"
#include "acquire.h"

/*
 * This file contains the list of supported commands.  A look up table is
 * constructed from this list upon initialisation.
 */
const struct spi_command_def_t spi_command_defs[] = {
	// ID    SHORT_NAME                  # ARGS   RESP?		CALLBACK
	{  0x00, "NOP",                      0,       0,		NULL }, 			// The only command that doesn't need a checksum
	{  0x01, "HELLO",                    2,       1,		spicmd_hello },
	{  0x02, "VERSION",                  0,       1,		spicmd_version },
	{  0x03, "POWER_STATE",              1,       0,		NULL },
	{  0x04, "FPGA_HEALTH",              0,       1,		NULL },
	{  0x05, "DEVICE_STATISTICS",        1,       1,		spicmd_stats },

	{  0x08, "WAIT_QUEUE",               0,       0,		NULL },
	{  0x09, "CLEAR_COMMAND_QUEUE",      2,       0,		NULL },

	{  0x10, "ACQ_SETUP_TRIGGERED",      13,      0,		NULL },
	{  0x11, "ACQ_START",                0,       0,		NULL },
	{  0x12, "ACQ_STOP",                 0,       0,		NULL },
	{  0x13, "ACQ_PAUSE",                0,       0,		NULL },
	{  0x14, "ACQ_STATUS",               0,       1,		NULL },
	{  0x15, "ACQ_FORCE_TRAIN",          0,       0,		NULL },
	{  0x16, "ACQ_TRAIN_STATUS",         0,       1,		NULL },

	// Last command 0xff not supported: end of initialisation table
	{  0xff, "NULL",					 0,		  0,		NULL },
};

/*
 * Hello command.  Responds with 55 CC followed by the two argument bytes (echo self test)
 */
void spicmd_hello(struct spi_command_alloc_t *cmd)
{
	uint8_t resp_buffer[] = { 0x55, 0xcc, cmd->args[0], cmd->args[1] };

	spi_command_pack_response_simple(cmd, resp_buffer, 4);
}

/*
 * Version command.  Responds with version structure defined in spi.h.
 */
void spicmd_version(struct spi_command_alloc_t *cmd)
{
	spi_command_pack_response_simple(cmd, &g_version_resp, sizeof(g_version_resp));
}

/*
 * Statistics command.  Responds with mega-structure of statistics.
 */
void spicmd_stats(struct spi_command_alloc_t *cmd)
{
	int i;
	struct spi_cmd_resp_stats_t resp;
	uint8_t *resp2 = (uint8_t*)&resp;

	resp.spi_stats = g_spi_state.stats;
	resp.acq_stats = g_acq_state.stats;

	for(i = 0; i < sizeof(resp); i++) {
		*resp2++ = i;
	}

	spi_command_pack_response_simple(cmd, &resp, sizeof(struct spi_cmd_resp_stats_t));
}

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
#include "trigger.h"

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

	{  0x10, "ACQ_SETUP_TRIGGERED",      13,      0,		spicmd_acq_setup_trigd },
	{  0x11, "ACQ_START",                1,       0,		spicmd_acq_start },
	{  0x12, "ACQ_STOP",                 0,       0,		spicmd_acq_stop },
	{  0x13, "ACQ_REWIND",               0,       0,		spicmd_acq_rewind },
	{  0x14, "ACQ_STATUS",               0,       1,		spicmd_acq_status },
	{  0x15, "ACQ_FORCE_TRAIN",          0,       0,		NULL },
	{  0x16, "ACQ_STATUS_TRAIN",         0,       1,		NULL },

	{  0x30, "TRIG_CONFIGURE_HOLDOFF",   8,       0,        NULL },
	{  0x31, "TRIG_CONFIGURE_SETTINGS",  1,       0,        NULL },
	{  0x32, "TRIG_CONFIGURE_EDGE",      6,       0,        spicmd_trig_configure_edge },
	{  0x33, "TRIG_CONFIGURE_ALWAYS",    0,       0,        spicmd_trig_configure_always },

	{  0x3c, "TRIG_WRITE_TIMER",         0,       0,        NULL },
	{  0x3d, "TRIG_FORCE",               0,       0,        spicmd_trig_force },
	{  0x3e, "TRIG_ARM",                 0,       0,        spicmd_trig_arm },
	{  0x3f, "TRIG_DISARM",              0,       0,        spicmd_trig_disarm },

	{  0x60, "CSI_SETUP_ADDR_RANGE",     8,       0,        NULL },
	{  0x61, "CSI_SETUP_WAVE_RANGE",     8,       0,        NULL },
	{  0x62, "CSI_SETUP_WAVE_ALL",       0,       0,        NULL },
	{  0x63, "CSI_SETUP_TRIGPOS_DATA",   8,       0,        NULL },
	{  0x64, "CSI_SETUP_TRIGPOS_ALL",    0,       0,        NULL },
	{  0x65, "CSI_SETUP_TESTPATT",       1,       0,        NULL },

	{  0x6e, "CSI_STREAM_CLEAR_QUEUE",   0,       0,        NULL },
	{  0x6e, "CSI_STREAM_UNPOP_START",   0,       0,        NULL },
	{  0x6f, "CSI_STREAM_STOP",          0,       0,        NULL },

	// Last command 0xff is required to be a NOP (marks end of table)
	{  0xff, "NOP",					     0,		  0,		NULL },
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
	//d_printf(D_RAW, "version");
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
		*resp2++ = 'A' + (i & 31);
	}

	spi_command_pack_response_simple(cmd, &resp, sizeof(struct spi_cmd_resp_stats_t));
}

/*
 * Acquisition triggered setup command.
 */
void spicmd_acq_setup_trigd(struct spi_command_alloc_t *cmd)
{
	uint32_t wavect, pre_sz, post_sz;
	uint8_t mode;
	int status;

	pre_sz = UINT32_UNPACK(cmd, 0);
	post_sz = UINT32_UNPACK(cmd, 4);
	wavect = UINT32_UNPACK(cmd, 8);
	mode = cmd->args[12];

	d_printf(D_INFO, "spi: new acquisition (pre:%d, post:%d, mode:0x%02x, wavect:%d)", pre_sz, post_sz, mode, wavect);

	status = acq_prepare_triggered(mode, pre_sz, post_sz, wavect);

	d_printf(D_INFO, "spi: new acquisition status=%d", status);
}

/*
 * Start the acquisition.
 */
void spicmd_acq_start(struct spi_command_alloc_t *cmd)
{
	int status;

	status = acq_start(cmd->args[0] & 0x01);

	if(status != ACQRES_OK) {
		d_printf(D_ERROR, "spi: acquistion unable to start: %d", status);
	}
}

/*
 * Stop the acquisition.
 */
void spicmd_acq_stop(struct spi_command_alloc_t *cmd)
{
	int status;

	status = acq_stop();

	if(status != ACQRES_OK) {
		d_printf(D_ERROR, "spi: acquistion unable to stop: %d", status);
	}

	//d_printf(D_INFO, "stop");
}

/*
 * Rewind the acquisition buffer, preparing to reacquire based on existing settings.
 */
void spicmd_acq_rewind(struct spi_command_alloc_t *cmd)
{
	acq_dealloc_rewind();
}

/*
 * Request status of acquistion.
 */
void spicmd_acq_status(struct spi_command_alloc_t *cmd)
{
	struct acq_status_resp_t status_resp;

	acq_make_status(&status_resp);
	spi_command_pack_response_simple(cmd, &status_resp, sizeof(struct acq_status_resp_t));

	//acq_debug_dump();
	//d_printf(D_INFO, "status");
}

/*
 * Configure the edge trigger.
 */
void spicmd_trig_configure_edge(struct spi_command_alloc_t *cmd)
{
	uint8_t ch, edge;
	uint16_t lvl, hyst;

	ch = cmd->args[0];
	edge = cmd->args[1];
	lvl = UINT16_UNPACK(cmd, 2);
	hyst = UINT16_UNPACK(cmd, 4);

	trig_configure_edge(ch, lvl, hyst, edge);
}

/*
 * Configure the always trigger.
 */
void spicmd_trig_configure_always(struct spi_command_alloc_t *cmd)
{
	trig_configure_always();
}

/*
 * Force a trigger.
 */
void spicmd_trig_force(struct spi_command_alloc_t *cmd)
{
	trig_force();
}

/*
 * Arm the trigger.
 */
void spicmd_trig_arm(struct spi_command_alloc_t *cmd)
{
	trig_arm();
}

/*
 * Disarm the trigger.
 */
void spicmd_trig_disarm(struct spi_command_alloc_t *cmd)
{
	trig_disarm();
}

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
#include "test_patterns.h"
#include "mipi_csi.h"

#include <stdlib.h>

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

	{  0x10, "ACQ_SETUP_TRIGGERED",      14,      0,		spicmd_acq_setup_trigd },
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

	{  0x60, "CSI_SETUP_ADDR_RANGE",     8,       0,        spicmd_csi_setup_addr_range },
	{  0x61, "CSI_SETUP_WAVE_RANGE",     8,       0,        spicmd_csi_setup_wave_range },
	{  0x62, "CSI_SETUP_WAVE_ALL",       0,       0,        spicmd_csi_setup_wave_all },
	{  0x63, "CSI_SETUP_TRIGPOS_RANGE",  8,       0,        spicmd_csi_setup_trigpos_range },
	{  0x64, "CSI_SETUP_TRIGPOS_ALL",    0,       0,        spicmd_csi_setup_trigpos_all },
	{  0x65, "CSI_SETUP_TESTPATT",       9,       0,        spicmd_csi_setup_testpatt },
	{  0x66, "CSI_SETUP_BITPACK_WAVE",   1,       0,        spicmd_csi_setup_bitpack_wave },

	{  0x6d, "CSI_STREAM_CLEAR_QUEUE",   0,       0,        spicmd_csi_stream_clear_queue },
	{  0x6e, "CSI_STREAM_START",         0,       0,        spicmd_csi_stream_unpop_start },
	{  0x6f, "CSI_STREAM_STOP",          0,       0,        spicmd_csi_stream_stop },
	{  0x70, "CSI_STATUS",               0,       1,        spicmd_csi_status },
	{  0x71, "CSI_SET_PARAMS_QUEUE",     3,       0,        spicmd_csi_set_params_queue },
	{  0x72, "CSI_STREAM_START_ALL",     0,       0,        spicmd_csi_stream_unpop_start_all },

	// Composite commands: these execute a combination of functions in one.  See spreadsheet for details.
	{  0xc0, "COMP0",                    2,       1,        spicmd_comp0 },

	// Command 0xfe is Marker NOP for debugging
	{  0xfe, "NOP_MARK",                 0,       0,        NULL },

	// Last command 0xff is required to be a NOP (marks end of table)
	{  0xff, "NOP",					     0,		  0,		NULL },
};

// Test patterns
extern const uint8_t testpat__norway_512x512_grey[];
uint8_t __attribute__((aligned(32))) testpatt_buffer[262144];

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
	uint16_t mode;
	int status;

	pre_sz = UINT32_UNPACK(cmd, 0);
	post_sz = UINT32_UNPACK(cmd, 4);
	wavect = UINT32_UNPACK(cmd, 8);
	mode = UINT16_UNPACK(cmd, 12); // cmd->args[12];

	d_printf(D_INFO, "spi: new acquisition (pre:%d, post:%d, mode:0x%04x, wavect:%d)", pre_sz, post_sz, mode, wavect);

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
 * Stop the acquisition.  If the acquisition is not running this command has no effect.
 */
void spicmd_acq_stop(struct spi_command_alloc_t *cmd)
{
	int status;

	if(g_acq_state.state != ACQSTATE_STOPPED) {
		status = acq_stop();

		if(status != ACQRES_OK) {
			d_printf(D_ERROR, "spi: acquistion unable to stop: %d", status);
		}
	}

	//d_printf(D_INFO, "stop");
}

/*
 * Rewind the acquisition buffer, preparing to reacquire based on existing settings.
 */
void spicmd_acq_rewind(struct spi_command_alloc_t *cmd)
{
	acq_rewind();
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

/*
 * Set up a CSI data transfer over an address range.  Addresses must
 * be 32-bit aligned.
 */
void spicmd_csi_setup_addr_range(struct spi_command_alloc_t *cmd)
{
	uint32_t start_addr, end_addr;

	start_addr = UINT32_UNPACK(cmd, 0);
	end_addr = UINT32_UNPACK(cmd, 4);

	mipi_csi_queue_buffer(start_addr, end_addr, NULL);
}

void spicmd_csi_setup_wave_range(struct spi_command_alloc_t *cmd)
{
}

void spicmd_csi_setup_wave_all(struct spi_command_alloc_t *cmd)
{
}

void spicmd_csi_setup_trigpos_range(struct spi_command_alloc_t *cmd)
{
}

void spicmd_csi_setup_trigpos_all(struct spi_command_alloc_t *cmd)
{
}

void spicmd_csi_setup_testpatt(struct spi_command_alloc_t *cmd)
{
	int i, j;
	uint8_t testpatt = cmd->args[8];
	uint32_t size = UINT32_UNPACK(cmd, 0);
	uint32_t init_value = UINT32_UNPACK(cmd, 4);
	uint32_t base = 0;
	uint8_t *buffer = NULL;

	/*
	 * BER test: Should be odd number of bytes to disperse across lanes
	 *
	 * 0xaa = High frequency test (@ bitclock)
	 * 0xcc = Mid frequency test (@ 50% bitclock)
	 * 0x0f = Low frequency test (@ 25% bitclock)
	 * 0x24 = Single bits set in each nybble
	 * 0xdb = Single bits clear in each nybble
	 * 0x04 = Single bit set in each byte
	 * 0xfe = Single bit clear in each byte
	 */
	const uint8_t ber_test[] = { 0xaa, 0xcc, 0x0f, 0x24, 0xdb, 0x04, 0xfe };

	/*
	 * Allocate a buffer of size bytes, rounded to the nearest 32 bytes, if we are
	 * doing a non-image transfer.  Only "Norway" (pattern #1) is image, so all
	 * other patterns require a buffer to be allocated.
	 *
	 * Buffer should be 32-byte aligned (cache line boundary).
	 */
	if(testpatt != 1) {
		size += 31;
		size &= ~31;

		buffer = (uint8_t*)memalign(32, size);
		if(buffer == NULL) {
			d_printf(D_ERROR, "spicmd: Unable to allocate %d bytes for test pattern", size);
			return;
		}

		base = (uint32_t)buffer;
	}

	d_printf(D_INFO, "spicmd: buffer 0x%08x size %d (0x%08x) bytes", base, size, size);

	/*
	 * Important: all test pattern buffers must be aligned to 4 byte boundaries
	 * Misaligned data will cause an AXIDMA exception.
	 */
	switch(testpatt) {
		case 1:
			// Norway Vastness
			base = (uint32_t)&testpatt_norway_512x512_grey;
			size = TESTPATT_NORWAY_512X512_SIZE;
			break;

		case 2:
			// All Zeroes
			d_printf(D_INFO, "All Zeroes");
			memset(buffer, 0x00, size);
			break;

		case 3:
			// All Ones
			d_printf(D_INFO, "All Ones");
			memset(buffer, 0xff, size);
			break;

		case 4:
			// Bit Error Rate test - see ber_test comment above for explanation
			for(i = 0, j = 0; i < size; i++) {
				*(buffer + i) = ber_test[j++ % sizeof(ber_test)];
			}
			break;

		case 5:
			// 32-bit counter test:  Detects line sync issues/word loss issues.  Each word increments by 1.
			for(i = 0, j = init_value; i < size; i += 4, j++) {
				*(buffer + i + 0) = (j >> 24) & 0xff;
				*(buffer + i + 1) = (j >> 16) & 0xff;
				*(buffer + i + 2) = (j >> 8) & 0xff;
				*(buffer + i + 3) = j & 0xff;
			}
			break;

		case 6:
			// 16-bit counter test:  Detects line sync issues/word loss issues.  Each halfword increments by 1.
			for(i = 0, j = init_value; i < size; i += 2, j++) {
				*(buffer + i + 1) = (j >> 8) & 0xff;
				*(buffer + i + 0) = j & 0xff;
			}
			break;

		case 7:
			// 8-bit counter test:  Detects line sync issues/word loss issues.  Each byte increments by 1.
			for(i = 0, j = init_value; i < size; i++, j++) {
				*(buffer + i) = j & 0xff;
			}
			break;

		case 8:
			// Repeats 32-bit word in init_value
			for(i = 0; i < size; i += 4) {
				*(buffer + i + 0) = (init_value >> 24) & 0xff;
				*(buffer + i + 1) = (init_value >> 16) & 0xff;
				*(buffer + i + 2) = (init_value >> 8) & 0xff;
				*(buffer + i + 3) = init_value & 0xff;
			}
			break;

		default:
			// Undefined; but we want to free the buffer to avoid a leak!
			d_printf(D_WARN, "spicmd: undefined testpatt!");
			break;
	}

	// `buffer` will be freed when the CSI operation is done
	//d_printf(D_INFO, "Base 0x%08x Base+Size 0x%08x", base, base + size);
	mipi_csi_queue_buffer(base, base + size, buffer);
}

void spicmd_csi_setup_bitpack_wave(struct spi_command_alloc_t *cmd)
{
}

void spicmd_csi_set_params_queue(struct spi_command_alloc_t *cmd)
{
	uint8_t data_type = cmd->args[2];
	uint16_t wct = UINT16_UNPACK(cmd, 0);

	d_printf(D_INFO, "spicmd_csi_set_params_queue: 0x%02x 0x%04x", data_type, wct);
	mipi_csi_set_datatype_and_frame_wct(data_type, wct);
}

void spicmd_csi_stream_clear_queue(struct spi_command_alloc_t *cmd)
{
	mipi_csi_clear_queue();
}

void spicmd_csi_stream_unpop_start(struct spi_command_alloc_t *cmd)
{
	mipi_csi_unpop_and_start();
}

void spicmd_csi_stream_unpop_start_all(struct spi_command_alloc_t *cmd)
{
	mipi_csi_unpop_and_start_all();
}

void spicmd_csi_stream_stop(struct spi_command_alloc_t *cmd)
{
	mipi_csi_stop();
}

void spicmd_csi_status(struct spi_command_alloc_t *cmd)
{
	struct mipi_csi_status_t status_resp;

	//d_printf(D_INFO, "StaReq");

	mipi_csi_get_status(&status_resp);
	spi_command_pack_response_simple(cmd, &status_resp, sizeof(struct mipi_csi_status_t));
}

/*
 * Composite command 0.  This command can control acquisition stop/start/rewind/swap,
 * as well as start streaming CSI data and return previously configured measurements.
 */
void spicmd_comp0(struct spi_command_alloc_t *cmd)
{
	const int resp_buff_maxsize = sizeof(struct acq_status_resp_t) + \
								  sizeof(struct mipi_tx_size_resp_t) + 4;

	struct acq_status_resp_t acq_status_resp;
	struct mipi_tx_size_resp_t mipi_tx_size_resp;

	uint16_t func = UINT16_UNPACK(cmd, 0);
	int csi_to_send = 0;
	void *resp_buffer_base;
	void *resp_buffer;
	int resp_size = 0, size = 0;

	// Commands below must be executed in order to create the right behaviour...
	if(func & SPICOMP0_ACQ_STOP) {
		if(acq_get_state() != ACQSTATE_STOPPED) {
			acq_stop();
		}
	}

	if(func & SPICOMP0_ACQ_GET_STATUS) {
		acq_make_status(&acq_status_resp);
	}

	//d_printf(D_INFO, "w:%d", acq_status_resp.waves_done);

	if(func & SPICOMP0_RESP_CSI_SIZE) {
		mipi_csi_get_size_report(&mipi_tx_size_resp);
	}

	if(func & SPICOMP0_ACQ_REWIND) {
		acq_rewind();
	}

	//d_printf(D_INFO, " Old_Ptrs=0x%08x 0x%08x", g_acq_state.acq_first, g_acq_state.acq_done_first);

	//d_printf(D_INFO, "Pfirstptr=0x%08x", g_acq_state.acq_first);

	//d_printf(D_INFO, "Swap_Ptrs=0x%08x 0x%08x", g_acq_state.acq_first, g_acq_state.acq_done_first);

	// for now, only stream if exact # waves available
	if(func & SPICOMP0_SEND_CSI_WAVES) {
		//d_printf(D_INFO, "q_waves");
		mipi_csi_queue_all_waves();
		csi_to_send = 1;
	}

	if(func & SPICOMP0_ACQ_SWAP) {
		//d_printf(D_WARN, "SWAP");
		acq_swap();
	}

	if(func & SPICOMP0_ACQ_START_RESFIFO) {
		//d_printf(D_INFO, "ResFifo");
		acq_start(1);
	} else if(func & SPICOMP0_ACQ_START_NORESFIFO) {
		//d_printf(D_INFO, "NORESET");
		acq_start(0);
	}

	if(csi_to_send) {
		//d_printf(D_INFO, "u_sall");
		mipi_csi_unpop_and_start_all();
	}

	//acq_debug_dump();
	//trig_dump_state();

	/*
	 * Check what we need to pack into the response buffer.  Malloc enough bytes for everything
	 * to be added, but calculate the actual size later.  free() will be called when the transmission
	 * is completed for this packet.
	 */
	resp_buffer_base = calloc(resp_buff_maxsize, 1);
	D_ASSERT(resp_buffer_base != NULL);
	resp_buffer = resp_buffer_base;

	//d_printf(D_INFO, "resp_buffer=0x%08x, resp_size=%d", resp_buffer, resp_buff_maxsize);

	// AWFUL HACK
	acq_status_resp.waves_done = acq_get_nwaves_request();

	if(func & SPICOMP0_ACQ_GET_STATUS) {
		size = sizeof(struct acq_status_resp_t);
		memcpy(resp_buffer, &acq_status_resp, size);
		resp_buffer += size;
		//d_printf(D_INFO, "resp_buffer=0x%08x acq_status_ptr=0x%08x size=%d", resp_buffer, &acq_status_resp, size);
		resp_size += size;
	}

	if(func & SPICOMP0_RESP_CSI_SIZE) {
		size = sizeof(struct mipi_tx_size_resp_t);
		memcpy(resp_buffer, &mipi_tx_size_resp, size);
		resp_buffer += size;
		//d_printf(D_INFO, "resp_buffer=0x%08x csi_status_ptr=0x%08x size=%d", resp_buffer, &mipi_tx_size_resp, size);
		resp_size += size;
	}

	// Add trailing bytes: copy of flags transmitted plus 0x55 0xcc
	*(uint8_t*)(resp_buffer + 0) = func >> 8;
	*(uint8_t*)(resp_buffer + 1) = func;
	*(uint8_t*)(resp_buffer + 2) = 0x55;
	*(uint8_t*)(resp_buffer + 3) = 0xcc;

	//d_printf(D_INFO, "resp_buffer=0x%08x resp_size=%d", resp_buffer_base, resp_size);
	spi_command_pack_response_pre_alloc(cmd, resp_buffer_base, resp_size);

	// Ugh.  HACK!
	bogo_delay(5000);

	//acq_debug_dump_wave(10);

	//d_printf(D_INFO, "spi_command_pack_response_pre_alloc");

	//free(resp_buffer);
	//d_printf(D_INFO, "done");

	//spi_command_pack_response_simple(cmd, &acq_status_resp, 1);
	//d_printf(D_INFO, "eof");
}

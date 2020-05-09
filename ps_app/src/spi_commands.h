/*
 * spi_commands.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 3 Apr 2020
 *      Author: Tom
 */

#ifndef SRC_SPI_COMMANDS_H_
#define SRC_SPI_COMMANDS_H_

#include <stdint.h>
#include <stddef.h>

#include "spi.h"
#include "acquire.h"

extern const struct spi_command_def_t spi_command_defs[];

struct spi_cmd_resp_stats_t {
	struct spi_stats_t spi_stats;
	struct acq_stats_t acq_stats;
};

#define UINT64_UNPACK(cmd, argbase)		(((cmd)->args[(argbase) + 0] << 56) | ((cmd)->args[(argbase) + 1] << 48) | \
										 ((cmd)->args[(argbase) + 2] << 40) | ((cmd)->args[(argbase) + 3] << 32) | \
										 ((cmd)->args[(argbase) + 4] << 24) | ((cmd)->args[(argbase) + 5] << 16) | \
										 ((cmd)->args[(argbase) + 6] <<  8) | ((cmd)->args[(argbase) + 7]))

#define UINT32_UNPACK(cmd, argbase)		(((cmd)->args[(argbase) + 0] << 24) | ((cmd)->args[(argbase) + 1] << 16) | \
										 ((cmd)->args[(argbase) + 2] <<  8) | ((cmd)->args[(argbase) + 3]))

#define UINT16_UNPACK(cmd, argbase)		(((cmd)->args[(argbase) + 0] <<  8) | ((cmd)->args[(argbase) + 1]))

// Composite command 0 bitfield
#define SPICOMP0_ACQ_STOP				0x0001
#define SPICOMP0_ACQ_GET_STATUS			0x0002		// Will respond with status if set
#define SPICOMP0_ACQ_REWIND				0x0004
#define SPICOMP0_ACQ_START_RESFIFO		0x0008
#define SPICOMP0_ACQ_START_NORESFIFO	0x0010
#define SPICOMP0_ACQ_SWAP				0x0020
#define SPICOMP0_SEND_CSI_WAVES			0x0040
#define SPICOMP0_SEND_CSI_BITPACK		0x0080
#define SPICOMP0_SEND_CSI_TRIGPOS		0x0100

#define SPICOMP0_RESP_CSI_SIZE			0x1000
#define SPICOMP0_RESP_COUNTERS			0x2000
#define SPICOMP0_RESP_MEAS				0x4000
#define SPICOMP0_RESP_HEALTH			0x8000

/*
 * Definitions of SPI commands that are implemented in this module.
 */
void spicmd_hello(struct spi_command_alloc_t *cmd);
void spicmd_version(struct spi_command_alloc_t *cmd);
void spicmd_stats(struct spi_command_alloc_t *cmd);

void spicmd_acq_setup_trigd(struct spi_command_alloc_t *cmd);
void spicmd_acq_start(struct spi_command_alloc_t *cmd);
void spicmd_acq_stop(struct spi_command_alloc_t *cmd);
void spicmd_acq_rewind(struct spi_command_alloc_t *cmd);
void spicmd_acq_status(struct spi_command_alloc_t *cmd);

void spicmd_trig_configure_edge(struct spi_command_alloc_t *cmd);
void spicmd_trig_configure_always(struct spi_command_alloc_t *cmd);
void spicmd_trig_force(struct spi_command_alloc_t *cmd);
void spicmd_trig_disarm(struct spi_command_alloc_t *cmd);
void spicmd_trig_arm(struct spi_command_alloc_t *cmd);

void spicmd_csi_setup_addr_range(struct spi_command_alloc_t *cmd);
void spicmd_csi_setup_wave_range(struct spi_command_alloc_t *cmd);
void spicmd_csi_setup_wave_all(struct spi_command_alloc_t *cmd);
void spicmd_csi_setup_trigpos_range(struct spi_command_alloc_t *cmd);
void spicmd_csi_setup_trigpos_all(struct spi_command_alloc_t *cmd);
void spicmd_csi_setup_testpatt(struct spi_command_alloc_t *cmd);
void spicmd_csi_setup_bitpack_wave(struct spi_command_alloc_t *cmd);
void spicmd_csi_set_params_queue(struct spi_command_alloc_t *cmd);
void spicmd_csi_stream_clear_queue(struct spi_command_alloc_t *cmd);
void spicmd_csi_stream_unpop_start(struct spi_command_alloc_t *cmd);
void spicmd_csi_stream_unpop_start_all(struct spi_command_alloc_t *cmd);
void spicmd_csi_stream_stop(struct spi_command_alloc_t *cmd);
void spicmd_csi_status(struct spi_command_alloc_t *cmd);

void spicmd_comp0(struct spi_command_alloc_t *cmd);

#endif // SRC_SPI_COMMANDS_H_

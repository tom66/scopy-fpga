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

/*
 * Definitions of SPI commands that are implemented in this module.
 */
void spicmd_hello(struct spi_command_alloc_t *cmd);
void spicmd_version(struct spi_command_alloc_t *cmd);
void spicmd_stats(struct spi_command_alloc_t *cmd);

void spicmd_acq_setup_trigd(struct spi_command_alloc_t *cmd);
void spicmd_acq_start(struct spi_command_alloc_t *cmd);
void spicmd_acq_stop(struct spi_command_alloc_t *cmd);
void spicmd_acq_pause(struct spi_command_alloc_t *cmd);
void spicmd_acq_status(struct spi_command_alloc_t *cmd);

#endif // SRC_SPI_COMMANDS_H_

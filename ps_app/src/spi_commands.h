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

/*
 * Definitions of SPI commands that are implemented in this module.
 */
void spicmd_hello(struct spi_command_alloc_t *cmd);
void spicmd_version(struct spi_command_alloc_t *cmd);
void spicmd_stats(struct spi_command_alloc_t *cmd);

#endif // SRC_SPI_COMMANDS_H_

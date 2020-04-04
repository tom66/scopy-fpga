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

/*
 * This file contains the list of supported commands.  A look up table is
 * constructed from this list upon initialisation.
 */
const struct spi_command_def_t spi_command_defs[] = {
	// ID    SHORT_NAME                  # ARGS   CALLBACK
	{  0x00, "HELLO",                    0,       NULL },
	{  0x01, "VERSION",                  0,       NULL },
	{  0x02, "POWER_STATE",              1,       NULL },
	{  0x03, "FPGA_HEALTH",              0,       NULL },
	{  0x04, "DEVICE_STATISTICS",        1,       NULL },

	{  0x08, "WAIT_QUEUE",               0,       NULL },
	{  0x09, "CLEAR_COMMAND_QUEUE",      2,       NULL },

	{  0x10, "ACQ_SET_SIZE",             8,       NULL },
	{  0x11, "ACQ_SETUP_TRIGGERED",      5,       NULL },
	{  0x12, "ACQ_START",                0,       NULL },
	{  0x13, "ACQ_STOP",                 0,       NULL },
	{  0x14, "ACQ_PAUSE",                0,       NULL },
	{  0x15, "ACQ_STATUS",               0,       NULL },
	{  0x16, "ACQ_FORCE_TRAIN",          0,       NULL },
	{  0x17, "ACQ_TRAIN_STATUS",         0,       NULL },

	// Last command 0xff not supported: end of initialisation table
	{  0xff, "NULL",					 0,		  NULL },
};

#endif // SRC_SPI_COMMANDS_H_

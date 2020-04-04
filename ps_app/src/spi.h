/*
 * spi.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 3 Apr 2020
 *      Author: Tom
 */

#ifndef SRC_SPI_H_
#define SRC_SPI_H_

#include <stdint.h>

#include "Collections-C/src/include/deque.h"

#include "xspips.h"

#define SPI_QUEUE_ALLOC_MAX				128		// Allowed to enqueue up to 128 commands

#define SPI_COMMAND_MAX_ARGS			8		// Max 8 arguments per command
#define SPI_COMMAND_SHORT_NAME_MAX		15		// Maximum 15 characters (plus NUL) in the short name
#define SPI_COMMAND_TOTAL_COUNT			256		// 256 possible commands (8-bit command ID)

#define SPI_DEVICE_ID					XPAR_PS7_SPI_0_DEVICE_ID

#define SPI_SHORTEST_MESSAGE			2		// Shortest message is cmd byte + CRC8

/*
 * This struct stores a decoded command as received from the SPI port
 * and packed into the command queue.
 */
struct spi_command_alloc_t {
	uint8_t alloc, cmd, nargs;
	uint8_t args[SPI_COMMAND_MAX_ARGS];
};

/*
 * This struct stores the state of the command processor and contains
 * pointers to the SPI peripheral.
 */
struct spi_state_t {
	XSpiPs spi;
	XSpiPs_Config *spi_config;

	// Deque for command task list (Collections-C)
	Deque *command_dq;

	/*
	 * Allocation table for the command task list.  Commands are packed into the Deque
	 * from this table.  Once a command is processed, the allocation is freed again.
	 */
	struct spi_command_alloc_t cmd_alloc_table[SPI_QUEUE_ALLOC_MAX];
	int cmd_alloc_count;
};

/*
 * This struct stores one const reference to a command in the command
 * definition table.
 */
struct spi_command_def_t {
	uint8_t cmd_id;
	char *short_name;
	uint8_t nargs;
	void (*cmd_processor)(struct spi_command_t *);
};

/*
 * This struct stores a transformed version of the above, copied into
 * RAM in a dictionary-style format.
 */
struct spi_command_lut_t {
	uint8_t valid;
	char short_name[SPI_COMMAND_SHORT_NAME_MAX + 1];
	uint8_t nargs;
	void (*cmd_processor)(struct spi_command_t *);
};

/*
 * Response to the "VERSION" command.
 */
struct spi_version_resp_t {
	uint32_t bitstream_id;
	uint32_t usraccess;
	uint32_t ps_app_id;
	uint32_t build_timestamp;
};

void spi_init();
void spi_command_lut_gen();
void spi_isr_handler(void *unused);
void spi_command_tick();

#endif // SRC_SPI_H_

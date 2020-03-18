/*
 * fabric_config.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 26 Jan 2020
 *      Author: Tom
 */

#ifndef SRC_FABRIC_CONFIG_H_
#define SRC_FABRIC_CONFIG_H_

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <ctype.h>

#include "platform.h"
#include "xparameters.h"

#include "hal.h"

/*
 * Fabric configuration driver.  This interfaces with the AXI configuration
 * peripheral on the FPGA which memory maps a small region of BRAM inside the FPGA.
 *
 * In addition, it handles the generation of the config_commit and read back of
 * config_commit_done signals.
 *
 * Note that for the fabric to be "made aware" of new data it is necessary to
 * drive the commit signal; the same applies for reading back new data. Changing
 * registers in the BRAM does not commit new values to the fabric immediately.
 */

// Base address of the memory mapped AXI BRAM peripheral
#define FAB_CFG_BASE_ADDRESS			XPAR_FABCFG_NEXTGEN_0_S00_AXI_BASEADDR

// Addresses of fabric registers.
#define FAB_CFG_DUMMY1					0x0000
#define FAB_CFG_DUMMY2					0x0004
#define FAB_CFG_MAGIC1					0x0008
#define FAB_CFG_VERSION					0x000c
#define FAB_CFG_USRACCESS				0x0010
#define FAB_CFG_ACQ_SIZE_A				0x0040
#define FAB_CFG_ACQ_SIZE_B				0x0044
#define FAB_CFG_ACQ_TRIGGER_PTR			0x0048
#define FAB_CFG_ACQ_DEMUX_MODE			0x004c
#define FAB_CFG_GPIO_TEST				0x0050	// move this?
#define FAB_CFG_CSI_LINE_COUNT			0x0100
#define FAB_CFG_CSI_LINE_BYTE_COUNT		0x0104
#define FAB_CFG_CSI_DATA_TYPE			0x0108
#define FAB_CFG_CSI_CTRL_FLAGS			0x010c

#define FAB_CFG_ADDR_MASK				0x03fc
#define FAB_CFG_MAGIC_VALUE				0x536d7670

#define _FAB_CFG_ACCESS(addr)			(*(volatile uint32_t*)((void *)((FAB_CFG_BASE_ADDRESS + (addr & FAB_CFG_ADDR_MASK)))))

// Fabric EMIO pin definitions
#define FAB_CFG_EMIO_COMMIT				(54 + 3)
#define FAB_CFG_EMIO_DONE				(54 + 4)

void fabcfg_init();
void fabcfg_commit();
void fabcfg_fastcfg_start();
void fabcfg_fastcfg_wait();

/*
 * Read data from fabric at a specified address.
 *
 * @param	reg		Register index
 *
 * @return	data	Data returned
 */
static inline uint32_t fabcfg_read(uint32_t reg)
{
	uint32_t res;

	reg &= FAB_CFG_ADDR_MASK;

	// Wrapped in dsb to ensure synchronous read
	dsb();
	res = _FAB_CFG_ACCESS(reg);
	dsb();

	return res;
}

/*
 * Write data to fabric BRAM at a specified address.
 *
 * @param	reg		Register index
 * @param	data	Data to write
 */
static inline void fabcfg_write(uint32_t reg, uint32_t data)
{
	reg &= FAB_CFG_ADDR_MASK;

	// Wrapped in dsb to ensure synchronous write
	dsb();
	_FAB_CFG_ACCESS(reg) = data;
	dsb();
}

#endif /* SRC_FABRIC_CONFIG_H_ */

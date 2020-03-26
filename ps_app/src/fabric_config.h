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
//#define FAB_CFG_ACQ_DEMUX_MODE		0x004c	// Deprecated
#define FAB_CFG_ACQ_CTRL_A				0x0050
//#define FAB_CFG_ACQ_CTRL_B			0x0054	// Reserved slot
#define FAB_CFG_ACQ_STATUS_A			0x0058
#define FAB_CFG_ACQ_STATUS_B			0x005c

#define FAB_CFG_TRIG_LEVEL0				0x0090
#define FAB_CFG_TRIG_LEVEL1				0x0094
#define FAB_CFG_TRIG_LEVEL2				0x0098
#define FAB_CFG_TRIG_LEVEL3				0x009c
#define FAB_CFG_TRIG_LEVEL4				0x00a0
#define FAB_CFG_TRIG_LEVEL5				0x00a4
#define FAB_CFG_TRIG_LEVEL6				0x00a8
#define FAB_CFG_TRIG_LEVEL7				0x00ac
#define FAB_CFG_TRIG_LEVEL_A_BASE		FAB_CFG_TRIG_LEVEL0
#define FAB_CFG_TRIG_LEVEL_B_BASE		FAB_CFG_TRIG_LEVEL4
#define FAB_CFG_TRIG_CONFIG_A			0x00b0
#define FAB_CFG_TRIG_STATE_A			0x00b8
#define FAB_CFG_TRIG_HOLDOFF			0x00c0
#define FAB_CFG_TRIG_AUTO_TIMERS		0x00c4
#define FAB_CFG_TRIG_DELAY_REG0			0x00c8
#define FAB_CFG_TRIG_DELAY_REG1			0x00cc

//#define FAB_CFG_GPIO_TEST				0x0050	// Deprecated, to be moved
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
void fabcfg_dump_state();

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
 * Read data from fabric at a specified address with sync barrier.
 *
 * @param	reg		Register index
 *
 * @return	data	Data returned
 */
static inline uint32_t fabcfg_read_no_dsb(uint32_t reg)
{
	uint32_t res;

	reg &= FAB_CFG_ADDR_MASK;
	res = _FAB_CFG_ACCESS(reg);

	return res;
}

/*
 * Test data from fabric at a specified address.
 *
 * @param	reg		Register index
 * @param	mask	Mask to test against
 *
 * @return	data	Data returned is AND of register data and mask (i.e. bit test)
 */
static inline uint32_t fabcfg_test(uint32_t reg, uint32_t mask)
{
	uint32_t res;

	reg &= FAB_CFG_ADDR_MASK;
	dsb();
	res = _FAB_CFG_ACCESS(reg);
	dsb();

	return res & mask;
}

/*
 * Write data in fabric at a specified address.
 *
 * @param	reg		Register index
 * @param	data	Data to write
 */
static inline void fabcfg_write(uint32_t reg, uint32_t data)
{
	reg &= FAB_CFG_ADDR_MASK;
	dsb();
	_FAB_CFG_ACCESS(reg) = data;
	dsb();
}

/*
 * OR (set) data in fabric at a specified address.
 *
 * @param	reg		Register index
 * @param	data	Data to OR
 */
static inline void fabcfg_set(uint32_t reg, uint32_t data)
{
	reg &= FAB_CFG_ADDR_MASK;
	dsb();
	_FAB_CFG_ACCESS(reg) |= data;
	dsb();
}

/*
 * AND-NOT (clear) data in fabric  at a specified address.
 *
 * @param	reg		Register index
 * @param	data	Data to AND-NOT
 */
static inline void fabcfg_clear(uint32_t reg, uint32_t data)
{
	reg &= FAB_CFG_ADDR_MASK;
	dsb();
	_FAB_CFG_ACCESS(reg) &= ~data;
	dsb();
}

/*
 * XOR (toggle) data in fabric at a specified address.
 *
 * @param	reg		Register index
 * @param	data	Data to XOR
 */
static inline void fabcfg_toggle(uint32_t reg, uint32_t data)
{
	reg &= FAB_CFG_ADDR_MASK;
	dsb();
	_FAB_CFG_ACCESS(reg) ^= data;
	dsb();
}

#endif /* SRC_FABRIC_CONFIG_H_ */

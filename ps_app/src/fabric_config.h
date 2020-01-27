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
#define AXI_CFG_BRAM_BASE_ADDRESS		XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR

// Addresses of fabric registers
#define FAB_CFG_DUMMY1					0x000
#define FAB_CFG_DUMMY2					0x001
#define FAB_CFG_MAGIC1					0x002
#define FAB_CFG_VERSION					0x003
#define FAB_CFG_ACQ_SIZE				0x004
#define FAB_CFG_ACQ_TRIGGER_PTR			0x005
#define FAB_CFG_ACQ_DEMUX_MODE			0x006
#define FAB_CFG_GPIO_TEST				0x007

#define FAB_CFG_ADDR_MASK				0xfff

// Fabric EMIO pin definitions
#define FAB_CFG_EMIO_COMMIT				3
#define FAB_CFG_EMIO_DONE				4

void fabcfg_init();
void fabcfg_write(uint32_t reg, uint32_t data);
uint32_t fabcfg_read(uint32_t reg);
void fabcfg_commit();

#endif /* SRC_FABRIC_CONFIG_H_ */
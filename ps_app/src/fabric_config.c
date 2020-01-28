/*
 * fabric_config.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 26 Jan 2020
 *      Author: Tom
 */

/*
 * Fabric configuration driver.  This interfaces with the AXI configuration
 * peripheral on the FPGA which memory maps a small region of BRAM inside the FPGA.
 *
 * In addition, it handles the generation of the config_commit and read back of
 * config_commit_done signals.
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <ctype.h>

// Local application includes
#include "hal.h"
#include "fabric_config.h"

/*
 * Initialise the fabric configuration engine.  Tests the peripheral.
 */
void fabcfg_init()
{
	int i;

	// Set commit pin as output and done pin as input
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, FAB_CFG_EMIO_COMMIT, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, FAB_CFG_EMIO_COMMIT, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, FAB_CFG_EMIO_DONE, 0);

	// Run the initial commit so that data is made available in BRAM
	fabcfg_commit();

	// Check BRAM data
#if 0
	while(1) {
		fabcfg_write(FAB_CFG_MAGIC1, 0xff5500ff);
		d_printf(D_INFO, "FabCfg: Magic 0x%08x", fabcfg_read(FAB_CFG_MAGIC1));
		fabcfg_commit();
		d_printf(D_INFO, "FabCfg: Magic 0x%08x (post commit)", fabcfg_read(FAB_CFG_MAGIC1));
	}

	d_printf(D_INFO, "FabCfg: Bitstream version 0x%08x", fabcfg_read(FAB_CFG_VERSION));
#endif

	XGpioPs_SetOutputEnable(&g_hal.xgpio_ps, 0, 0xffffffff);
	XGpioPs_SetOutputEnable(&g_hal.xgpio_ps, 1, 0xffffffff);
	XGpioPs_SetOutputEnable(&g_hal.xgpio_ps, 2, 0xffffffff);
	XGpioPs_SetOutputEnable(&g_hal.xgpio_ps, 3, 0xffffffff);
	XGpioPs_SetDirection(&g_hal.xgpio_ps, 0, 0xffffffff);
	XGpioPs_SetDirection(&g_hal.xgpio_ps, 1, 0xffffffff);
	XGpioPs_SetDirection(&g_hal.xgpio_ps, 2, 0xffffffff);
	XGpioPs_SetDirection(&g_hal.xgpio_ps, 3, 0xffffffff);

	while(1) {
		/*
		d_printf(D_INFO, "FabCfg: Setting all pins...", i);
		XGpioPs_Write(&g_hal.xgpio_ps, 0, 0x00000000);
		XGpioPs_Write(&g_hal.xgpio_ps, 1, 0x00000000);
		XGpioPs_Write(&g_hal.xgpio_ps, 2, 0x00000000);
		XGpioPs_Write(&g_hal.xgpio_ps, 3, 0x00000000);
		bogo_delay(1000000);

		XGpioPs_Write(&g_hal.xgpio_ps, 0, 0xffffffff);
		XGpioPs_Write(&g_hal.xgpio_ps, 1, 0xffffffff);
		XGpioPs_Write(&g_hal.xgpio_ps, 2, 0xffffffff);
		XGpioPs_Write(&g_hal.xgpio_ps, 3, 0xffffffff);
		bogo_delay(1000000);
		*/

		for(i = 0; i < 117; i++) {
			d_printf(D_INFO, "FabCfg: Toggling pin %d", i);

			//XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, 0 + i, 1);
			//XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, 0 + i, 1);
			XGpioPs_WritePin(&g_hal.xgpio_ps, 0 + i, 1);
			bogo_delay(20000);

			XGpioPs_WritePin(&g_hal.xgpio_ps, 0 + i, 0);
			bogo_delay(20000);
		}
	}

	/*
	while(1) {
		fabcfg_write(FAB_CFG_GPIO_TEST, 0xffffffff);
		fabcfg_commit();
	}
	*/
}

/*
 * Read data from fabric BRAM at a specified address.
 *
 * @param	reg		Register index
 *
 * @return	data	Data returned
 */
uint32_t fabcfg_read(uint32_t reg)
{
	reg &= FAB_CFG_ADDR_MASK;
	return Xil_In32(AXI_CFG_BRAM_BASE_ADDRESS + (reg * 4));
}

/*
 * Write data to fabric BRAM at a specified address.
 *
 * @param	reg		Register index
 * @param	data	Data to write
 */
void fabcfg_write(uint32_t reg, uint32_t data)
{
	reg &= FAB_CFG_ADDR_MASK;
	Xil_Out32(AXI_CFG_BRAM_BASE_ADDRESS + (reg * 4), data);
}

/*
 * Commit new data to the fabric, and read back any changes in registers.
 */
void fabcfg_commit()
{
	int timeout = 200;

	// Drive COMMIT for 10us (TODO: PL needs to ignore continuously held COMMIT signal as this will
	// lead to DONE never reading HIGH.)
	XGpioPs_WritePin(&g_hal.xgpio_ps, FAB_CFG_EMIO_COMMIT, 1);
	bogo_delay(1);
	XGpioPs_WritePin(&g_hal.xgpio_ps, FAB_CFG_EMIO_COMMIT, 0);

	// Read the DONE pin and wait for a logic HIGH.  (Wait up to 10ms.)
	d_start_timing(15);
	while(timeout--) {
		if(XGpioPs_ReadPin(&g_hal.xgpio_ps, FAB_CFG_EMIO_DONE)) {
			break;
		}

		bogo_delay(50);
	}
	d_stop_timing(15);
	d_dump_timing("FabCfg commit", 15);

	if(timeout == 0) {
		d_printf(D_ERROR, "FabCfg: Timeout waiting for fabric to respond to COMMIT");
		exit(-1);
	}
}

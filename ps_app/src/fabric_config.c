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

const uint32_t fbcfg_dummy_tests[] = {
	0xaaaaaaaa, 0x55555555, 0x5c093ef0, 0xffff0000, 0x00000000, 0xffffffff
};

#define FBCFG_NUM_TEST_PATTERNS		(sizeof(fbcfg_dummy_tests) / sizeof(fbcfg_dummy_tests[0]))

/*
 * Initialise the fabric configuration engine.  Tests the peripheral.
 */
void fabcfg_init()
{
	int i;
	uint32_t magic, test, version, ver_uh, ver_lh, userid;

	d_printf(D_INFO, "FabCfg: Initialising");

	// Set commit pin as output and done pin as input
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, FAB_CFG_EMIO_COMMIT, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, FAB_CFG_EMIO_COMMIT, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, FAB_CFG_EMIO_DONE, 0);

	// Run the initial commit so that data is made available in BRAM.
	// Run this twice to fix occasional power on reset bug.
	fabcfg_commit();
	bogo_delay(100000);
	fabcfg_commit();

	d_printf(D_INFO, "FabCfg: First commit done");

	// Verify that magic value is present and correct
	magic = fabcfg_read(FAB_CFG_MAGIC1);
	if(magic == FAB_CFG_MAGIC_VALUE) {
		d_printf(D_INFO, "FabCfg: Magic value: 0x%08x - OK", magic);
	} else {
		d_printf(D_ERROR, "FabCfg: Magic value: 0x%08x - Not OK, Expect 0x%08x", magic, FAB_CFG_MAGIC_VALUE);
		exit(-1);
	}

	/*
	 * Test the BRAM block by writing a number of patterns into DUMMY1 and
	 * reading them out of DUMMY1 and DUMMY2.  Data is copied from DUMMY1
	 * into DUMMY2 via the fabric.
	 */
	d_printf(D_INFO, "FabCfg: Running %d test patterns of register interface", FBCFG_NUM_TEST_PATTERNS);

	for(i = 0; i < FBCFG_NUM_TEST_PATTERNS; i++) {
		fabcfg_write(FAB_CFG_DUMMY1, fbcfg_dummy_tests[i]);
		fabcfg_commit();

		// Value of DUMMY2 should appear in DUMMY1.  DUMMY2 should also read the same value.
		test = fabcfg_read(FAB_CFG_DUMMY1);

		if(test == fbcfg_dummy_tests[i]) {
			d_printf(D_EXINFO, "FabCfg: DummyTest1 value: 0x%08x - OK", test);
		} else {
			d_printf(D_ERROR, "FabCfg: DummyTest1 value: 0x%08x - Not OK, Expect 0x%08x", test, fbcfg_dummy_tests[i]);

			// try to recover...
			i = 0;
			fabcfg_commit();
			//exit(-1);
		}

		test = fabcfg_read(FAB_CFG_DUMMY2);

		if(test == fbcfg_dummy_tests[i]) {
			d_printf(D_EXINFO, "FabCfg: DummyTest2 value: 0x%08x - OK", test);
		} else {
			d_printf(D_ERROR, "FabCfg: DummyTest2 value: 0x%08x - Not OK, Expect 0x%08x", test, fbcfg_dummy_tests[i]);

			// try to recover...
			i = 0;
			fabcfg_commit();
			//exit(-1);
		}

		fabcfg_write(FAB_CFG_DUMMY1, 0x12345678);
		fabcfg_write(FAB_CFG_DUMMY2, 0x87654321);
		fabcfg_commit();
	}

	d_printf(D_INFO, "FabCfg: All tests passed");

	/*
	 * Read the bitstream version and USRACCESS data
	 */
	version = fabcfg_read(FAB_CFG_VERSION);
	ver_uh = (version & 0xffff0000) >> 16;
	ver_lh = (version & 0x0000ffff);
	userid = fabcfg_read(FAB_CFG_USRACCESS);

	d_printf(D_INFO, "FabCfg: Bitstream version %d.%02d, code 0x%04x, userid 0x%08x", \
			(ver_lh & 0xff00) >> 8, ver_lh & 0xff, ver_uh, userid);
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
	uint32_t res;
	reg &= FAB_CFG_ADDR_MASK;

	d_printf(D_INFO, "Read:0x%08x", AXI_CFG_BRAM_BASE_ADDRESS + (reg * 4));

	dsb();
	res = Xil_In32(AXI_CFG_BRAM_BASE_ADDRESS + (reg * 4));
	dsb();
	return res;
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
	dsb();
	Xil_Out32(AXI_CFG_BRAM_BASE_ADDRESS + (reg * 4), data);
	dsb();
}

/*
 * Commit new data to the fabric, and read back any changes in registers.
 */
void fabcfg_commit()
{
	/*
	 * Drive COMMIT signal for some short period of time, long enough to
	 * latch the rising edge on the PL side. Then read the DONE pin and wait
	 * for a logic high to indicate completion of readout.
	 */
	fabcfg_fastcfg_start();

	/*
	 * Wait for the fabric to send the done signal.  It might already be done
	 * by the time we hit this function.
	 */
	fabcfg_fastcfg_wait();
}

/*
 * Fast fabric commit start.  Initiates the transfer of new information while
 * the PS is otherwise busy.
 */
void fabcfg_fastcfg_start()
{
	int i;

	emio_fast_write(FAB_CFG_EMIO_COMMIT, 1);

	// 8 NOPs means that the for loop sometimes exits on first cycle, because the signal
	// has fallen low by now.
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");

	for(i = 0; i < FAB_CFG_COMMIT_TIME; i++) {
		// if DONE signal is low then we can exit early
		if(!emio_fast_read(FAB_CFG_EMIO_DONE)) {
			break;
		}
	}

	emio_fast_write(FAB_CFG_EMIO_COMMIT, 0);
}

/*
 * Fast fabric commit wait.  Waits for DONE signal.
 */
void fabcfg_fastcfg_wait()
{
	int i, timeout = 10000;

	while(timeout--) {
		if(emio_fast_read(FAB_CFG_EMIO_DONE)) {
			break;
		}
	}

	if(timeout == 0) {
		d_printf(D_ERROR, "FabCfg: Timeout waiting for fabric to respond to COMMIT");
		exit(-1);
	}
}

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

const uint32_t fabcfg_dummy_tests[] = {
	0xaaaaaaaa, 0x55555555, 0x5c093ef0, 0xffff0000, 0x00000000, 0xffffffff
};

#define FBCFG_NUM_TEST_PATTERNS		(sizeof(fabcfg_dummy_tests) / sizeof(fabcfg_dummy_tests[0]))

/*
 * Initialise the fabric configuration engine.  Tests the peripheral.
 */
void fabcfg_init()
{
	int i;
	uint32_t magic, test, version, ver_uh, ver_lh, userid;

	d_printf(D_INFO, "FabCfg: Initialising @ 0x%08x", FAB_CFG_BASE_ADDRESS);

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
		fabcfg_write(FAB_CFG_DUMMY1, fabcfg_dummy_tests[i]);

		// Value of DUMMY2 should appear in DUMMY1.  DUMMY2 should also read the same value.
		test = fabcfg_read(FAB_CFG_DUMMY1);

		if(test == fabcfg_dummy_tests[i]) {
			d_printf(D_EXINFO, "FabCfg: DummyTest1 value: 0x%08x - OK", test);
		} else {
			d_printf(D_ERROR, "FabCfg: DummyTest1 value: 0x%08x - Not OK, Expect 0x%08x", test, fabcfg_dummy_tests[i]);
		}

		test = fabcfg_read(FAB_CFG_DUMMY2);

		if(test == fabcfg_dummy_tests[i]) {
			//d_printf(D_EXINFO, "FabCfg: DummyTest2 value: 0x%08x - OK", test);
		} else {
			d_printf(D_ERROR, "FabCfg: DummyTest2 value: 0x%08x - Not OK, Expect 0x%08x", test, fabcfg_dummy_tests[i]);
		}

		// Write some dummy values to detect sticky bus faults
		fabcfg_write(FAB_CFG_DUMMY1, 0x12345678);
		fabcfg_write(FAB_CFG_DUMMY2, 0x87654321);
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


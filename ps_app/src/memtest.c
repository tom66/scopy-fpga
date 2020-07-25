/*
 * memtest.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 22 Jul 2020
 *      Author: Tom
 */

#include "memtest.h"
#include "hal.h"

#include <stdint.h>

const uint32_t pattern_all_ones[] 		= { 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff };
const uint32_t pattern_all_zeroes[] 	= { 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000 };
const uint32_t pattern_counter[] 		= { 0x2468ace0, 0x13579bde, 0x12345678, 0x9abcdef0, 0x11223344 };
const uint32_t pattern_alternate[]   	= { 0xff55ccaa, 0x00ff55cc, 0xaa00ff55, 0xccaa00ff, 0x55ccaa00 };

const uint32_t *patterns[] = {
	(uint32_t*)&pattern_all_ones,
	(uint32_t*)&pattern_all_zeroes,
	(uint32_t*)&pattern_counter,
	(uint32_t*)&pattern_alternate
};

/*
 * Perform a OCM memory test.
 */
void memtest_ocm()
{
	const int ocm_size = 16384;
	uint32_t ocm_block[ocm_size / 4];

	// To test OCM, allocate 16KB on the stack which is always on OCM.
	d_printf(D_INFO, "memtest: OCM testing at 0x%08x (%d bytes)", &ocm_block, ocm_size);

	memtest_block_write(&ocm_block, ocm_size, PATT_ALL_ZEROES);
	if(memtest_block_verify(&ocm_block, ocm_size, PATT_ALL_ZEROES) != 0) {
		goto _memtest_ocm_failure;
	}

	memtest_block_write(&ocm_block, ocm_size, PATT_ALL_ONES);
	if(memtest_block_verify(&ocm_block, ocm_size, PATT_ALL_ONES) != 0) {
		goto _memtest_ocm_failure;
	}

	memtest_block_write(&ocm_block, ocm_size, PATT_COUNTER);
	if(memtest_block_verify(&ocm_block, ocm_size, PATT_COUNTER) != 0) {
		goto _memtest_ocm_failure;
	}

	memtest_block_write(&ocm_block, ocm_size, PATT_ALTERNATE);
	if(memtest_block_verify(&ocm_block, ocm_size, PATT_ALTERNATE) != 0) {
		goto _memtest_ocm_failure;
	}

	return;

_memtest_ocm_failure:
	d_printf(D_ERROR, "memtest: OCM memory test failure - fatal");
	exit(-1);
}

/*
 * Perform a DDR memory test.
 */
void memtest_ddr()
{
	uint8_t *ddr_block;
	const int ddr_size = 32 * 1024 * 1024;

	ddr_block = malloc(ddr_size);

	if(ddr_block == NULL) {
		d_printf(D_ERROR, "memtest: DDR testing failed to allocate %d bytes", ddr_size);
		goto _memtest_ddr_failure;
	}

	// To test DDR, allocate 32MB on the heap.
	d_printf(D_INFO, "memtest: DDR testing at 0x%08x (%d bytes)", ddr_block, ddr_size);

	d_printf(D_INFO, "memtest: DDR testing all zeroes");
	memtest_block_write(ddr_block, ddr_size, PATT_ALL_ZEROES);
	if(memtest_block_verify(ddr_block, ddr_size, PATT_ALL_ZEROES) != 0) {
		goto _memtest_ddr_failure;
	}

	d_printf(D_INFO, "memtest: DDR testing all ones");
	memtest_block_write(ddr_block, ddr_size, PATT_ALL_ONES);
	if(memtest_block_verify(ddr_block, ddr_size, PATT_ALL_ONES) != 0) {
		goto _memtest_ddr_failure;
	}

	d_printf(D_INFO, "memtest: DDR testing with counter");
	memtest_block_write(ddr_block, ddr_size, PATT_COUNTER);
	if(memtest_block_verify(ddr_block, ddr_size, PATT_COUNTER) != 0) {
		goto _memtest_ddr_failure;
	}

	d_printf(D_INFO, "memtest: DDR testing with alternating pattern");
	memtest_block_write(ddr_block, ddr_size, PATT_ALTERNATE);
	if(memtest_block_verify(ddr_block, ddr_size, PATT_ALTERNATE) != 0) {
		goto _memtest_ddr_failure;
	}

	free(ddr_block);
	d_printf(D_INFO, "memtest: DDR testing passed and memory released");

	return;

_memtest_ddr_failure:
	d_printf(D_ERROR, "memtest: DDR memory test failure - fatal");
	exit(-1);
}

/*
 * Write a memory test starting at base using pattern provided of total size bytes.
 *
 * @param	base		Base memory address
 * @param	pattern		Pattern index to use
 * @param	size		Number of bytes to write
 */
void memtest_block_write(uint32_t *base, uint32_t size, int pattern)
{
	while(size > 4) {
		*base = patterns[pattern][size % 5];
		//d_printf(D_INFO, "0x%08x 0x%08x", base, *base);
		base++;
		size -= 4;
	}
}

/*
 * Verify a memory test starting at base using pattern provided of total size bytes.
 *
 * @param	base		Base memory address
 * @param	pattern		Pattern index to use
 * @param	size		Number of bytes to write
 *
 * @return	Returns the failing address or 0 if no failure occurs
 */
uint32_t memtest_block_verify(uint32_t *base, int pattern, uint32_t size)
{
	while(size > 4) {
		if(*base != patterns[pattern][size % 5]) {
			d_printf(D_ERROR, "memtest: error verifying at addr 0x%08x (read: 0x%08x, expect: 0x%08x)", \
				base, *base, patterns[pattern][size % 5]);

			return base;
		}
		base++;
		size -= 4;
	}

	return 0;
}

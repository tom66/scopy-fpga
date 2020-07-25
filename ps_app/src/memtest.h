/*
 * memtest.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 22 Jul 2020
 *      Author: Tom
 */

/*
 * Memory test routines.
 */

#ifndef SRC_MEMTEST_H_
#define SRC_MEMTEST_H_

#include <stdint.h>

#define PATT_ALL_ZEROES		0
#define PATT_ALL_ONES		1
#define PATT_COUNTER		2
#define PATT_ALTERNATE		3

void memtest_ocm();
void memtest_ddr();

void memtest_block_write(uint32_t *base, uint32_t size, int pattern);
uint32_t memtest_block_verify(uint32_t *base, int pattern, uint32_t size);

#endif

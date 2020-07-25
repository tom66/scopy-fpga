/*
 * tests.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 25 Jul 2020
 *      Author: Tom
 */

/*
 * Some test cases to diagnose and assess the performance of various functions.
 */
#include <malloc.h>
#include <stdlib.h>

#include "dma_bd.h"
#include "tests.h"
#include "hal.h"

/*
 * Allocate a large number (10,000+) of 64 byte memory blocks and measure the
 * time it takes to complete.  If align is set, blocks are memalign'd on malloc_size
 * boundaries (malloc_size must be power of two if this is set.)
 */
void test_timing_many_mallocs(int malloc_size, int malloc_count, int align)
{
	uint32_t *pointers, *pointers_base;
	uint8_t *new_block;
	int i;

	align = !!align;

	d_start_timing(TMR_TESTS_0);

	/*
	 * Allocate the block to store our pointers first - this will be used to
	 * free the blocks.
	 */
	pointers = calloc(malloc_count * sizeof(void *), 1);
	if(pointers == NULL) {
		d_printf(D_ERROR, "tests: malloc_timing failed - unable to allocate pointer block");
		return;
	}

	pointers_base = pointers;
	//d_printf(D_INFO, "block @ 0x%08x", pointers);

	/*
	 * Allocate the blocks and store their pointers in our pointer table so
	 * that we can free them later.
	 */
	d_start_timing(TMR_TESTS_1);

	if(!align) {
		for(i = 0; i < malloc_count; i++) {
			//d_printf(D_INFO, "malloc %d", i);

			new_block = (uint32_t*)malloc(malloc_size);
			if(new_block == NULL) {
				d_printf(D_ERROR, "tests: malloc_timing failed - unable to allocate block %d", i);
				return;
			}
			*pointers++ = new_block;
		}
	} else {
		for(i = 0; i < malloc_count; i++) {
			//d_printf(D_INFO, "memalign %d", i);

			new_block = (uint32_t*)memalign(malloc_size, malloc_size);
			if(new_block == NULL) {
				d_printf(D_ERROR, "tests: malloc_timing failed - unable to allocate block %d", i);
				return;
			}
			*pointers++ = new_block;
		}
	}

	d_stop_timing(TMR_TESTS_1);

	/*
	 * Free all the allocated pointers.  Time this as well.
	 */
	pointers = pointers_base;
	d_start_timing(TMR_TESTS_2);

	for(i = 0; i < malloc_count; i++) {
		//d_printf(D_INFO, "free %d 0x%08x", i, *pointers);
		free(*pointers++);
	}

	d_stop_timing(TMR_TESTS_2);

	free(pointers_base);
	d_stop_timing(TMR_TESTS_0);

	/*
	 * Print out a summary of the time taken and the time per malloc/free.
	 */
	d_printf(D_INFO, "");
	d_printf(D_INFO, "** Memory allocation and free performance test (Align = %d) **", align);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Number of blocks:     %d", malloc_count);
	d_printf(D_INFO, "Size of each block:   %d", malloc_size);
	d_printf(D_INFO, "Total time taken:     %.3f us", d_read_timing_us(TMR_TESTS_0));
	d_printf(D_INFO, "Alloc time taken:     %.3f us (%.3f ns/block)", d_read_timing_us(TMR_TESTS_1), (d_read_timing_us(TMR_TESTS_1) / malloc_count) * 1000);
	d_printf(D_INFO, "Free time taken:      %.3f us (%.3f ns/block)", d_read_timing_us(TMR_TESTS_2), (d_read_timing_us(TMR_TESTS_2) / malloc_count) * 1000);
	d_printf(D_INFO, "");
}

/*
 * Test the performance of the DMA BD controller.
 */
void test_timing_dma_bd(int num_bds)
{
	struct dma_bd_ring_t *ring;
	int i = 0;

	/*
	 * Create a num_bds BD entry ring.
	 */
	d_start_timing(TMR_TESTS_0);
	dma_bd_create_ring(&ring);

	d_start_timing(TMR_TESTS_1);

	for(i = 0; i < num_bds; i++) {
		dma_bd_add_raw_sg_entry(ring, i * 0x8000, 0x8000, 0, NULL);
	}

	d_stop_timing(TMR_TESTS_1);
	d_stop_timing(TMR_TESTS_0);


	/*
	 * Print out a summary of the time taken and the time per malloc/free.
	 */
	d_printf(D_INFO, "");
	d_printf(D_INFO, "** BD allocation performance test **");
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Number of BDs:        %d", num_bds);
	d_printf(D_INFO, "Total time taken:     %.3f us", d_read_timing_us(TMR_TESTS_0));
	d_printf(D_INFO, "Alloc time taken:     %.3f us (%.3f ns/block)", d_read_timing_us(TMR_TESTS_1), (d_read_timing_us(TMR_TESTS_1) / num_bds) * 1000);
	d_printf(D_INFO, "");
}

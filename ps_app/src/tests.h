/*
 * tests.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 25 Jul 2020
 *      Author: Tom
 */

#ifndef SRC_TESTS_H_
#define SRC_TESTS_H_

/*
 * Some test cases to diagnose and assess the performance of various functions.
 */
void test_timing_many_mallocs(int malloc_size, int malloc_count, int align);
void test_timing_dma_bd();

#endif // SRC_TESTS_H_

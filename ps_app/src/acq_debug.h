/*
 * acq_debug.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 19 Jul 2020
 *      Author: Tom
 */

#ifndef SRC_ACQ_CTRL_H_
#define SRC_ACQ_CTRL_H_

int acq_copy_slow_mipi(int index, uint32_t *buffer);
void acq_debug_dump();
void acq_debug_ll_dump(struct acq_buffer_t *base, char *str);
void acq_debug_dump_wave(int index, int list);
void acq_debug_dump_wordline(int index, uint8_t *wordptr, uint8_t trig, char rf, uint8_t pretrig, uint8_t posttrig, uint8_t subpos, int mode);
void acq_debug_dump_wave_pointer(struct acq_buffer_t *waveptr);

#endif // SRC_ACQ_CTRL_H_

/*
 * acquire.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 1 Feb 2020
 *      Author: Tom
 */

/*
 * Acquistion control engine.  This handles all oscilloscope acquisition functions
 * including memory buffer allocation, PL interface, AXI bus DMA and trigger setup.
 *
 * The acquisition engine is primarily driven by interrupts.
 */

#ifndef SRC_ACQUIRE_H_
#define SRC_ACQUIRE_H_

#include <stdint.h>
#include <stdbool.h>

#define ACQSTATE_UNINIT			0						// Not ready: not initialised (memory or other)
#define ACQSTATE_STOPPED		1						// Stopped but ready to start
#define ACQSTATE_PREP			2						// Started but not acquiring data yet
#define ACQSTATE_WAIT_TRIG		3						// Waiting for trigger, pre-trigger buffer running
#define ACQSTATE_RUNNING		4						// Data acquisition in progress
#define ACQSTATE_HOLDOFF		5						// Data acquisition done and now in holdoff period

#define ACQ_MIN_BUFFER_SIZE		1024					// Minimum 1K samples buffer size
#define ACQ_MAX_BUFFER_SIZE		(64 * 1024 * 1024)		// Maximum 64M samples buffer size

#define ACQ_MIN_PREPOST_SIZE	128						// Minimum size of any pre or post window.

#define ACQ_MODE_8BIT			0x00000001				// 8-bit high speed
#define ACQ_MODE_12BIT			0x00000002				// 12-bit mid speed
#define ACQ_MODE_14BIT			0x00000004				// 14-bit low speed
#define ACQ_MODE_1CH			0x00000020				// 1 channel mode
#define ACQ_MODE_2CH			0x00000040				// 2 channel mode
#define ACQ_MODE_4CH			0x00000080				// 4 channel mode
#define ACQ_MODE_TRIGGERED		0x00000100				// Triggered mode (normal/auto/single acquisition)
#define ACQ_MODE_CONTINUOUS		0x00000200				// Special continuous mode (rolling buffer)

#define ACQ_BUFFER_ALIGN		8						// Required byte alignment for AXI DMA (Must be a power of two)
#define ACQ_BUFFER_ALIGN_AMOD	(ACQ_BUFFER_ALIGN - 1)	// Modulo (binary-AND) used to determine alignment of above value

#define ACQERR_MALLOC_FAIL		-1

struct acq_state_t {
	// State of the acquisition state machine
	int state;

	// Acquisition control flags

	// Sizes of the acquisition ranges and number of acquisitions to make
	uint32_t pre_buffsz;
	uint32_t post_buffsz;
	uint32_t total_buffsz;
	uint32_t num_acq;

	// Pointer to the first and current acquisiton buffers.
	struct acq_buffer_t *acq_first;
	struct acq_buffer_t *acq_current;
};

struct acq_buffer_t {
	int idx;
	uint32_t *buff_alloc;		// Pointer that was actually allocated
	uint32_t *buff_real;		// Pointer that is used for acquisition
	uint32_t trigger_at;
	struct acq_buffer_t *next;
};

extern struct acq_state_t g_acq_state;

void acq_init();
int acq_get_next_alloc(struct acq_buffer_t *next);
void acq_prepare(int32_t bias_point, uint32_t acq_total_size, uint32_t num_acq);
bool acq_is_done();

#endif // SRC_ACQUIRE_H_

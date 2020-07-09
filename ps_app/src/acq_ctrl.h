/*
 * acq_ctrl.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 15 Jun 2020
 *      Author: Tom
 */

#ifndef SRC_ACQ_CTRL_H_
#define SRC_ACQ_CTRL_H_

/*
 * Acquisition control:  outer control of acquisition engine behaviour.
 */

#include <stdint.h>
#include <stdbool.h>

#define ACQCTRL_RES_OK						0
#define ACQCTRL_RES_PARAM_ERROR				-1
#define ACQCTRL_RES_NOT_STOPPED				-2

#define ACQCTRL_MIN_PERIOD					5e-3			// Min 5ms period between acquisition
#define ACQCTRL_MAX_PERIOD					1000			// Max 1000s period between acquisition

#define ACQCTRL_IRQIO_READY					1
#define ACQCTRL_IRQIO_SEND					2

#define ACQCTRL_IDLE						1
#define ACQCTRL_ACQUIRING					2
#define ACQCTRL_DONE_ACQUIRE_WAIT_PI_READY	3
#define ACQCTRL_DONE_ACQUIRE_WAIT_PI_ACK	4
#define ACQCTRL_SEND_DATA					5
#define ACQCTRL_WAIT_FOR_SEND				6

#define SEC_TO_US(x)				(x * 1e6)

struct acq_ctrl_statistics_t {
	uint32_t slot_miss_countA;
	uint32_t slot_miss_countB;
};

struct acq_ctrl_state_t {
	uint64_t last_acquisition;
	uint64_t auto_trigger_counter;
	uint64_t auto_trigger_timeout;
	uint32_t seq;

	struct acq_ctrl_statistics_t stats;

	uint32_t acq_period;

	uint32_t n_wave_groups;

	bool start_run;
	bool stop_run;
	bool tick_run;
	bool miss_slotA;
	bool miss_slotB;

	int state;
};

void acq_ctrl_init();
int acq_ctrl_setup_auto_period(uint32_t period_us);
void acq_ctrl_set_auto_trig_mode();
int acq_ctrl_start();
void acq_ctrl_stop();
void acq_ctrl_force_stop();
void acq_ctrl_reset();
void acq_ctrl_tick();

#endif // SRC_ACQ_CTRL_H_

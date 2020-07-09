/*
 * system_control.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 19 Apr 2020
 *      Author: Tom
 */

#ifndef SRC_SYSTEM_CONTROL_H_
#define SRC_SYSTEM_CONTROL_H_

#include <stdint.h>
#include <stddef.h>

#include "xscugic.h"
#include "xttcps.h"
#include "xttcps_hw.h"

#define SYSCTRL_WAKE_FREQUENCY		25000		// Wake frequently
#define SYSCTRL_TIME_ADD_US			(1e6 / SYSCTRL_WAKE_FREQUENCY)

#define SYSCTRL_SPI_DIVIDER			1			// Run SPI processor every iteration (changing this has no effect)
#define SYSCTRL_ACQ_DIVIDER			1			// Run acquisition processor every iteration (changing this has no effect)
#define SYSCTRL_XADC_DIVIDER		16383		// Run ADC task on this divider

#define SYSCTRL_TTCPS_DEV_ID		XPAR_PS7_TTC_0_DEVICE_ID

#define SYSCTRL_LED_MODE_HEARTBEAT	1			// Heartbeat mode; default
#define SYSCTRL_LED_MODE_GP			2			// General purpose/diagnostic mode

#define SC_HEARTBEAT_ON1			1270
#define SC_HEARTBEAT_ON2			2550
#define SC_HEARTBEAT_OFF1			1300
#define SC_HEARTBEAT_OFF2			2580
#define SC_HEARTBEAT_TOTAL			10240

#define SC_HEARTBEAT_ON1_SCALE		((int)(SC_HEARTBEAT_ON1   * (SYSCTRL_WAKE_FREQUENCY / 10000.0f)))
#define SC_HEARTBEAT_ON2_SCALE		((int)(SC_HEARTBEAT_ON2   * (SYSCTRL_WAKE_FREQUENCY / 10000.0f)))
#define SC_HEARTBEAT_OFF1_SCALE		((int)(SC_HEARTBEAT_OFF1  * (SYSCTRL_WAKE_FREQUENCY / 10000.0f)))
#define SC_HEARTBEAT_OFF2_SCALE		((int)(SC_HEARTBEAT_OFF2  * (SYSCTRL_WAKE_FREQUENCY / 10000.0f)))
#define SC_HEARTBEAT_TOTAL_SCALE	((int)(SC_HEARTBEAT_TOTAL * (SYSCTRL_WAKE_FREQUENCY / 10000.0f)))

struct sysctrl_state_t {
	XTtcPs ttc;
	XTtcPs_Config *ttc_config;

	volatile int wakeup : 1;
	uint64_t time_us;				// Time in microseconds since boot (overflow at 584,900 years; I think we'll be safe.)
	int led_ctr;
	int led_mode;

	// Counters for functions that are not executed on every tick
	int xadc_counter;
};

struct sysctrl_health_t {
	uint64_t last_health_time;
	int16_t fpga_temp;
	uint16_t vcore_fpga;
	uint16_t vcore_ps;
	uint16_t vaux_fpga;
	uint16_t vaux_ps;
	uint16_t vddr;
	uint16_t ddr_clock;
	uint16_t cpu_clock;
	uint16_t pl_clock;
};

extern struct sysctrl_state_t g_sysctrl_state;
extern struct sysctrl_health_t g_sysctrl_health;

void sysctrl_init();
uint64_t systick_get_time_us_nonirq();
void sysctrl_led_mode(int mode);
void sysctrl_led_tick();
void sysctrl_xadc_tick();
void sysctrl_tick_irq(void *cb_ref);
void sysctrl_main_loop();

#endif // SRC_SYSTEM_CONTROL_H_

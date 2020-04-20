/*
 * system_control.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 19 Apr 2020
 *      Author: Tom
 */

#include "hal.h"
#include "spi.h"
#include "system_control.h"

#include "xscugic.h"
#include "xttcps.h"

/*
 * This module implements the system control loop.  Nominally, the control
 * loop runs various tasks at various frequencies in a psuedo-RTOS manner.
 *
 * At some point in the future, the processor will sleep when idle to save
 * some power.
 *
 * The system controller runs an iteration SYSCTRL_WAKE_FREQUENCY times
 * per second.
 */

struct sysctrl_state_t g_sysctrl_state;

/*
 * Initialise the system controller.  Sets up interrupts and timers.
 */
void sysctrl_init()
{
	uint32_t options;
	uint16_t interval;
	uint8_t prescaler;
	int error;

	sysctrl_led_mode(SYSCTRL_LED_MODE_HEARTBEAT);

	/*
	 * Initialise the XTTCPS, device ID zero.
	 */
	g_sysctrl_state.ttc_config = XTtcPs_LookupConfig(SYSCTRL_TTCPS_DEV_ID);
	D_ASSERT(g_sysctrl_state.ttc_config != NULL) ;

	XTtcPs_CfgInitialize(&g_sysctrl_state.ttc, g_sysctrl_state.ttc_config, g_sysctrl_state.ttc_config->BaseAddress);

	options = (XTTCPS_OPTION_INTERVAL_MODE | XTTCPS_OPTION_WAVE_DISABLE);
	XTtcPs_SetOptions(&g_sysctrl_state.ttc, options);

	/*
	 * Configure TTC0 to generate interrupts at SYSCTRL_WAKE_FREQUENCY.
	 */
	XTtcPs_CalcIntervalFromFreq(&g_sysctrl_state.ttc, SYSCTRL_WAKE_FREQUENCY, &interval, &prescaler);
	XTtcPs_SetInterval(&g_sysctrl_state.ttc, interval);
	XTtcPs_SetPrescaler(&g_sysctrl_state.ttc, prescaler);

	d_printf(D_INFO, "sysctrl: ttc configured [frequency:%d Hz, interval:%d, prescaler:%d]", \
			SYSCTRL_WAKE_FREQUENCY, interval, prescaler);

	/*
	 * Enable the interrupt on the SCUGIC controller and on the TTC0 channel,
	 * then start the timer.
	 */
	XScuGic_Connect(&g_hal.xscu_gic, XPAR_XTTCPS_0_INTR, (Xil_ExceptionHandler)sysctrl_tick_irq, &g_sysctrl_state.ttc);
	XScuGic_Enable(&g_hal.xscu_gic, XPAR_XTTCPS_0_INTR);
	XTtcPs_EnableInterrupts(&g_sysctrl_state.ttc, XTTCPS_IXR_INTERVAL_MASK);
	XTtcPs_Start(&g_sysctrl_state.ttc);
}

/*
 * System tick IRQ.  Sets flag notifying main loop that iteration has occurred.
 * In power-down modes, this IRQ will wake up the processor.
 */
void sysctrl_tick_irq(void *cb_ref)
{
	uint32_t status;

	status = XTtcPs_GetInterruptStatus((XTtcPs *)cb_ref);
	XTtcPs_ClearInterruptStatus((XTtcPs *)cb_ref, status);

	g_sysctrl_state.wakeup = 1;
	g_sysctrl_state.time_us += SYSCTRL_TIME_ADD_US;
}

/*
 * Change the LED mode.  In the default configuration PS#0 LED is a heartbeat/active
 * indicator LED.  It can be switched to a GP mode where it will be under pure
 * software control.
 */
void sysctrl_led_mode(int mode)
{
	D_ASSERT(mode == SYSCTRL_LED_MODE_HEARTBEAT || mode == SYSCTRL_LED_MODE_GP);

	// Set mode, reset LED to off.
	g_sysctrl_state.led_mode = mode;
	gpio_led_write(0, 0);
}

/*
 * Blinks the LED PS#0 periodically according to the LED counter.  Used as a diagnostic.
 * The LED blinks like a "pulse".
 */
void sysctrl_led_tick()
{
	g_sysctrl_state.led_ctr++;

	if(g_sysctrl_state.led_ctr > SC_HEARTBEAT_TOTAL_SCALE) {
		g_sysctrl_state.led_ctr = 0;
	}

	// These values are similar to the values used by the STM32 system controller on Scopy MVP.
	if(g_sysctrl_state.led_mode == SYSCTRL_LED_MODE_HEARTBEAT) {
		if(g_sysctrl_state.led_ctr == SC_HEARTBEAT_ON1_SCALE || g_sysctrl_state.led_ctr == SC_HEARTBEAT_ON2_SCALE) {
			gpio_led_write(0, 1);
		}

		if(g_sysctrl_state.led_ctr == SC_HEARTBEAT_OFF1_SCALE || g_sysctrl_state.led_ctr == SC_HEARTBEAT_OFF2_SCALE) {
			gpio_led_write(0, 0);
		}
	}
}

/*
 * XADC iteration.
 */
void sysctrl_xadc_tick()
{
	// STUB
}

/*
 * Main system control loop.  The application never escapes this loop, except
 * by forceful termination.
 */
void sysctrl_main_loop()
{
	int sleep_ok, gen_wakeup = 0;

	while(1) {
		sleep_ok = 1;

		// Don't execute this block if ISR flag not set.
		if(!g_sysctrl_state.wakeup && !gen_wakeup) {
			continue;
		}

		/*
		 * Execute always-tick functions.  SPI engine can block a processor sleep
		 * request, and force continuous execution of the processing block regardless
		 * of the state of the wakeup bit.
		 *
		 * LED tick only executes if microsecond TTC tick was source of wakeup.
		 */
		if(g_sysctrl_state.wakeup) {
			sysctrl_led_tick();
		}

		if(spi_command_tick() != SPIENGINE_IDLE) {
			// Set flag so we process again and iterate immediately, and we inhibit sleeping
			sleep_ok = 0;
			gen_wakeup = 1;
		}

		/*
		 * Execute XADC tick if the counter requires; but only if we aren't otherwise
		 * busy dealing with SPI traffic (sleep_ok is not set.)
		 */
		if(sleep_ok && (g_sysctrl_state.time_us & SYSCTRL_XADC_DIVIDER) == 0) {
			g_sysctrl_state.xadc_counter = SYSCTRL_XADC_DIVIDER;
			sysctrl_xadc_tick();
		}

		// Clear any wakeup flags.
		gen_wakeup = 0;
		g_sysctrl_state.wakeup = 0;

		/*
		 * If we're OK to sleep, put the Zynq PS into standby.
		 *
		 * A number of things should wake us up:
		 *   - Timer interrupt (TTC or ScuTimer)
		 *   - SPI data reception
		 *   - Acquisition DMA tasks
		 *   - Any CSI interrupts
		 *
		 * In this mode, we save power by not running the CPU when it is not needed.
		 */
		if(sleep_ok) {
			gpio_led_write(1, 0);
			asm("wfi");
			gpio_led_write(1, 1);
		}
	}
}

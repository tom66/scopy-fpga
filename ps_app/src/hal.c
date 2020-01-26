/*
 * hal.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 26 Jan 2020
 *      Author: Tom
 */

/*
 * Hardware abstraction layer.  This interfaces with the Xilinx BSP and platform code
 * and abstracts common functions into a simpler API.
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <ctype.h>

// Local application includes
#include "hal.h"
#include "version_tag.h"

// Xilinx includes
#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_cache.h"
#include "xil_assert.h"
#include "xil_io.h"
#include "xil_testmem.h"
#include "xuartps_hw.h"
#include "xgpiops.h"
#include "xaxidma.h"
#include "xscugic.h"
#include "xscutimer.h"
#include "xdebug.h"

struct hal_t g_hal;

/**
 * Interrupt handler for XScuTimer.
 */
volatile void irq_xscutimer(void *callback)
{
	XScuTimer *timer = (XScuTimer *) callback;

	if(XScuTimer_IsExpired(timer)) {
		g_hal.g_timer_overflow++;
	}
}

/**
 * Initialise hardware - entry point.
 */
void hal_init()
{
	int error;

	// Get platform up. This also initialises USART, so we can start debug output immediately.
    init_platform();
    Xil_AssertSetCallback(&d_xilinx_assert);

    // Clear junk on terminal, if any present; print startup message.
	d_printf(D_RAW, "\r\n\r\n\033[2J\033[0m\r\n");
	d_printf(D_INFO, "ps_app: Zynq application for YAOS Oscilloscope Project (%s)", PS_APP_VERSION_TAG);
	d_printf(D_INFO, "Built %s %s", __DATE__, __TIME__);
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Application (C) 2020 Tomato Engineering Ltd.");
	d_printf(D_INFO, "Parts       (C) 2005 - 2015 Xilinx, Inc.");
	d_printf(D_INFO, "");
	d_printf(D_INFO, "Application is licenced under the MIT Licence");
	d_printf(D_INFO, "For information see LICENCE in the Git repository");
	d_printf(D_INFO, "");

    /*
     * Prepare global interrupt controller.
     */
	g_hal.xscu_gic_cfg = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	if(g_hal.xscu_gic_cfg == NULL) {
		d_printf(D_ERROR, "XScuGic: configuration lookup returns NULL");
		exit(-1);
	}

	error = XScuGic_CfgInitialize(&g_hal.xscu_gic, g_hal.xscu_gic_cfg, g_hal.xscu_gic_cfg->CpuBaseAddress);

	if(error != XST_SUCCESS) {
		d_printf(D_ERROR, "XScuGic: configuration init returned error %d", error);
		exit(-1);
	}

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &g_hal.xscu_gic);

	d_printf(D_INFO, "XScuGic: interrupt controller ready");

	/*
	 * Prepare the SCU timer, which is used to time events and the time since boot.
	 * An interrupt handler is set up on overflow (approx every ~12.88s).
	 */
	g_hal.xscu_timer_cfg = XScuTimer_LookupConfig(XPAR_PS7_SCUTIMER_0_DEVICE_ID);
	error = XScuTimer_CfgInitialize(&g_hal.xscu_timer, g_hal.xscu_timer_cfg, g_hal.xscu_timer_cfg->BaseAddr);

	if (error != XST_SUCCESS) {
		d_printf(D_ERROR, "XScuTimer: returned error code: %d, unable to start", error);
		exit(-1);
	}

	error = XScuTimer_SelfTest(&g_hal.xscu_timer);

	if (error != XST_SUCCESS) {
		d_printf(D_ERROR, "XScuTimer: self test failed with error %d", error);
		exit(-1);
	}

	d_printf(D_INFO, "XScuTimer: ready");
	d_printf(D_EXINFO, "XScuTimer: config: %3.3f MHz, 1 tick = %.3f us", XSCUTIMER_CLOCK / 1e6f, XSCUTIMER_TICKS_TO_US);

	error = XScuGic_Connect(&g_hal.xscu_gic, XPAR_SCUTIMER_INTR, (Xil_ExceptionHandler)irq_xscutimer, (void *)&g_hal.xscu_timer);

	// Enable CPU excception handler
	Xil_ExceptionEnable();

	/*
	 * Start the timer, loaded with the maximum 32-bit count.  Enable auto reload so the
	 * timer will refresh once it downcounts to zero.  Enable the interrupts.
	 */
	g_hal.g_timer_overflow = 0;
	XScuTimer_LoadTimer(&g_hal.xscu_timer, 0xffffffff);
	XScuTimer_EnableAutoReload(&g_hal.xscu_timer);
	XScuTimer_EnableInterrupt(&g_hal.xscu_timer);
	XScuGic_Enable(&g_hal.xscu_gic, XPAR_SCUTIMER_INTR);
	XScuTimer_Start(&g_hal.xscu_timer);
	g_hal.g_timer_have_init = 1;

	/*
	 * Initialise the GPIO controller.  EMIO is primarily used inside the device to pass
	 * signals between the fabric and the ARM.
	 */
	g_hal.xgpio_ps_cfg = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	error = XGpioPs_CfgInitialize(&g_hal.xgpio_ps, g_hal.xgpio_ps_cfg, g_hal.xgpio_ps_cfg->BaseAddr);

	if (error != XST_SUCCESS) {
		d_printf(D_ERROR, "XGpioPs: returned error code: %d, unable to start", error);
		exit(-1);
	}

	d_printf(D_INFO, "XGpioPs: ready");
}

/**
 * Debug handler.
 *
 * @param	debug_code	D_RAW, D_EXINFO, D_INFO, D_WARN, D_ERR, etc.  The print might be ignored if a filter is applied.
 * @param	fmt			Format - supports all libc printf format specifiers
 * @param	...			Varadic args
 *
 * @note	For formats besides D_RAW, this function appends \r\n to all outputs and prints info/warn/error code and
 * 			optionally prints the system timer.
 */
void d_printf(int debug_code, char *fmt, ...)
{
	uint64_t total_usec;
	uint32_t sec, usec, timer;

	char buffer[DBG_BUFFSIZE];  // XXX: Should this be on the stack?
	char time_buffer[10];

	if(debug_code == D_RAW || debug_code >= DBG_LEVEL) {
		switch(debug_code) {
			case D_EXINFO:
				print("[--] ");							// dull white text (default)
				break;

			case D_INFO:
				print("\033[0;97m[ii] "); 				// bright white text
				break;

			case D_WARN:
				print("\033[30;103m[WW]\033[0;93m ");	// yellow text
				break;

			case D_ERROR:
				print("\033[97;41m[EE]\033[0;91m ");	// red text
				break;
		}

#if DBG_PRINT_TIMES == 1
		if(g_hal.g_timer_have_init) {
			timer = XScuTimer_GetCounterValue(&g_hal.xscu_timer);
			total_usec = (XSCUTIMER_OVERFLOW_TIME_US * g_hal.g_timer_overflow) + ((0xffffffff - timer) * XSCUTIMER_TICKS_TO_US);
			sec = total_usec / 1000000;
			usec = total_usec % 1000000;
		} else {
			sec = 0;
			usec = 0;
		}

		if(debug_code != D_RAW) {
			snprintf(time_buffer, DBG_BUFFSIZE, "[%3u.%06u] ", (unsigned int)sec, (unsigned int)usec);
			print(time_buffer);
		}
#endif

		va_list args;
		va_start(args, fmt);

		vsnprintf(buffer, DBG_BUFFSIZE, fmt, args);
		print(buffer);

		if(debug_code != D_RAW) {
			print("\033[m\r\n");
		}

		va_end(args);
	}
}

/**
 * Read the timer value as an MSB, LSB pair.  The values are returned by reference.
 *
 * This function attempts to safely read the registers and avoids overflow errors
 * by checking for an overflow boundary and waiting for it before occurs.  This has
 * the side effect of the timer having a +/-1us uncertainty, but this is unavoidable
 * with the present implementation.
 */
void d_read_global_timer(uint32_t *lsb_ret, uint32_t *msb_ret)
{
	uint32_t lsb, msb;

	// Read the timer as LSB
	lsb = XScuTimer_GetCounterValue(&g_hal.xscu_timer);

	/*
	 * If the timer is within a few counts of the upper-most count then we need
	 * to be careful to avoid overflow.  This is because we might need to ping
	 * the MSB from DDR and the timer is an internal register.  We allow a generous
	 * 255 ticks (~765ns) for this window.
	 *
	 * TODO:  It might be beneficial to ensure that the MSB is kept in OCM
	 * via a linker script/mapping; this might eliminate overflow errors.
	 */
	if(lsb > XSCUTIMER_NEAR_OVERFLOW) {
		 /*
		  * Read the MSB and then timer until the timer reads less than our threshold (essentially,
		  * waiting for an overflow.)
		  */
		while(lsb < XSCUTIMER_NEAR_OVERFLOW) {
			msb = g_hal.g_timer_overflow;
			lsb = XScuTimer_GetCounterValue(&g_hal.xscu_timer);
		}
	} else {
		msb = g_hal.g_timer_overflow;
	}

	*lsb_ret = lsb;
	*msb_ret = msb;
}

/**
 * Record the current timer value for timing purposes under the given index.
 *
 * @param	Timer index (0-15)
 */
void d_start_timing(int index)
{
	uint32_t lsb, msb;
	uint64_t timer_value;

	D_ASSERT(index < NUM_DEBUG_TIMERS) ;

	d_read_global_timer(&lsb, &msb);
	timer_value = (((uint64_t)msb) << 32) | lsb;

	g_hal.timers[index] = timer_value;
}

/**
 * Capture the timer event and calculate the time since `d_start_timing` was
 * called, storing the result in the timer_deltas array.
 *
 * @param	Timer index (0-15)
 */
void d_stop_timing(int index)
{
	uint32_t lsb, msb;
	uint64_t timer_value;
	int64_t t_delta;

	D_ASSERT(index < NUM_DEBUG_TIMERS) ;

	d_read_global_timer(&lsb, &msb);
	timer_value = (((uint64_t)msb) << 32) | lsb;

	g_hal.timer_deltas[index] = timer_value - g_hal.timers[index];
}

/**
 * Return the time delta for a given debug timer.
 *
 * @param	Timer index (0-15)
 *
 * @return	64-bit counter value
 */
uint64_t d_read_timing(int index)
{
	D_ASSERT(index < NUM_DEBUG_TIMERS) ;
	return g_hal.timer_deltas[index];
}

/**
 * Return the time delta in microseconds for a given debug timer.
 *
 * @param	Timer index (0-15)
 *
 * @return	Floating point microsecond value
 */
float d_read_timing_us(int index)
{
	D_ASSERT(index < NUM_DEBUG_TIMERS) ;
	return g_hal.timer_deltas[index] * XSCUTIMER_TICKS_TO_US;
}

/**
 * Dump timing data for a given timer index.
 *
 * @paraam	Prefix string (to indicate e.g. what this timed)
 * @param	Timer index (0-15)
 */
void d_dump_timing(char *s, int index)
{
	d_printf("%s [~%d CPU cycles (~%4.1f us)]\r\n", s, d_read_timing(index) * XSCUTIMER_TICKS_TO_CPUCYC, d_read_timing_us(index));
}

/**
 * Xilinx assert handler.
 */
void d_xilinx_assert(const char8 *file, s32 line)
{
	d_printf(D_ERROR, "Assert failed at line %d of file `%s'\r\n", line, file);
}

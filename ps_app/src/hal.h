/*
 * hal.h
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

#ifndef SRC_HAL_H_
#define SRC_HAL_H_

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>

#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xil_testmem.h"
#include "xuartps_hw.h"
#include "xgpiops.h"
#include "xaxidma.h"
#include "xscugic.h"
#include "xscutimer.h"
#include "xdebug.h"

#include "clkwiz_interface.h"

#define DBG_LEVEL					1
#define DBG_BUFFSIZE				4096

#define DBG_PRINT_TIMES				1		// If set to '1' then the time of the event (in seconds since SCU-timer boot) is printed with the debug event.

#define D_RAW						0		// Always printed
#define D_EXINFO					1		// Usually not printed
#define D_INFO						2		// Usually printed
#define D_WARN						3		// Always printed
#define D_ERROR						4		// Always printed

#define XSCUTIMER_CLOCK				(XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ / 2.0f)
#define XSCUTIMER_TICKS_TO_S		(2.0f / XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ)
#define XSCUTIMER_TICKS_TO_US		(XSCUTIMER_TICKS_TO_S * 1e6)
#define XSCUTIMER_TICKS_TO_CPUCYC	2

#define XSCUTIMER_LOAD_VALUE		(0xffffffff)
#define XSCUTIMER_LOAD_VALUE_LU		(0xffffffffLU)

#define XSCUTIMER_OVERFLOW_TIME		(XSCUTIMER_LOAD_VALUE_LU / XSCUTIMER_CLOCK)
#define XSCUTIMER_OVERFLOW_TIME_US	((XSCUTIMER_OVERFLOW_TIME) * 1e6)

#define XSCUTIMER_NEAR_OVERFLOW		(XSCUTIMER_LOAD_VALUE - 0xff)

#define NUM_DEBUG_TIMERS			16

#define GPIO_PS_LED_0_PIN			9
#define GPIO_PS_LED_1_PIN			37

#define D_ASSERT(expr)				{ \
										if(!(expr)) { \
											d_printf(D_ERROR, "assertion failed: `%s' (file %s, line %d)", #expr, __FILE__, __LINE__);  \
											exit(-99) ; \
										} \
									} \

#define BOGOCAL_ITERAMT				100000
#define BOGOCAL_ITERCNT				2							// XXX: Bug if this is more than 2 causing shorter bogotimes than expected, to be investigated
																// at a later date (26/01/2020)

#define CLKWIZ_CFG_MIPI				(XPAR_CLK_WIZ_0_DEVICE_ID)
#define CLKWIZ_CFG_MIPI_REFCLK		177.77777777				// Should be adjusted to meet the refclk into the ClkWiz.  Bug in XSA generation makes
																// this otherwise invalid.

// TODO:  Move to common utils file
#define MAX(a,b) 					((a) > (b) ? (a) : (b))
#define MIN(a,b) 					((a) < (b) ? (a) : (b))

struct hal_t {
	XScuGic xscu_gic;
	XScuGic_Config *xscu_gic_cfg;
	XScuTimer xscu_timer;
	XScuTimer_Config *xscu_timer_cfg;
	XGpioPs xgpio_ps;
	XGpioPs_Config *xgpio_ps_cfg;

	// Global timer extension: 32-bit counter increments on every overflow
	volatile uint32_t g_timer_overflow;
	uint32_t g_timer_have_init;

	// Internal timer table used to debug various events
	uint64_t timers[NUM_DEBUG_TIMERS];
	int64_t timer_deltas[NUM_DEBUG_TIMERS];

	// BogoDelay calibration
	float bogo_cal;

	// ClockWizards
	struct clkwiz_interface_t clkwiz_mipi;
};

extern struct hal_t g_hal;

void hal_init();
void bogo_delay(uint32_t us);
void gpio_led_write(int index, int enable);
void d_printf(int debug_code, char *fmt, ...);
void d_waitkey();
bool d_iskeypress();
void d_read_global_timer(uint32_t *lsb_ret, uint32_t *msb_ret);
void d_start_timing(int index);
void d_stop_timing(int index);
uint64_t d_read_timing(int index);
float d_read_timing_us(int index);
void d_dump_timing(char *s, int index);
void d_dump_timing_ex(char *s, int index);
void d_xilinx_assert(const char8 *File, s32 Line);

/**
 * Fast read/write functions for EMIO port.  These are inlined
 * into code where possible and included in the .h as they are not
 * linked objects.
 */

/*
 * Write a pin on the EMIO port quickly.  Only supports pins in range 53 ~ 117.
 */
inline static void emio_fast_write(unsigned int pin, int state)
{
	unsigned int bank;
	uint32_t write;
	uint32_t *reg;

	D_ASSERT(pin >= 53 && pin <= 117) ;

	state &= 1;
	pin -= 54;
	bank = (pin >> 5) + 2; // divide by 32, starting at offset '2'
	reg = (uint32_t*)(bank * XGPIOPS_DATA_MASK_OFFSET);

	if(pin > 15) {
		pin -= 16;
		reg += XGPIOPS_DATA_MSW_OFFSET;
	} else {
		reg += XGPIOPS_DATA_LSW_OFFSET;
	}

	write = ~(1 << (pin + 16)) & ((state << pin) | 0xffff0000);

	XGpioPs_WriteReg(XPS_GPIO_BASEADDR, reg, write);
}

/*
 * Read a pin on the EMIO port quickly.  Only supports pins in range 53 ~ 117.
 */
inline static int emio_fast_read(unsigned int pin)
{
	unsigned int bank;
	uint32_t read;
	uint32_t *reg;

	D_ASSERT(pin >= 53 && pin <= 117) ;

	pin -= 54;
	bank = (pin >> 5) + 2;
	reg = (uint32_t*)(bank * XGPIOPS_DATA_BANK_OFFSET);

	return (XGpioPs_ReadReg(XPS_GPIO_BASEADDR, ((bank) * XGPIOPS_DATA_BANK_OFFSET) + XGPIOPS_DATA_RO_OFFSET) >> pin) & 0x01;
}

#endif /* SRC_HAL_H_ */

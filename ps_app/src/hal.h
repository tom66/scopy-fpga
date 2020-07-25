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

#include "dma_bd.h"
#include "clkwiz_interface.h"

#define DBG_LEVEL					2
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

#define NUM_DEBUG_TIMERS			256

#define GPIO_PS_LED_0_PIN			9
#define GPIO_PS_LED_1_PIN			37

#define GPIO_PS_IRQ_1_PIN			32
#define GPIO_PS_IRQ_2_PIN			34
#define GPIO_PS_IRQ_3_PIN			50
#define GPIO_PS_IRQ_4_PIN			36

#define GPIO_HAL_OUTPUT				0
#define GPIO_HAL_INPUT				1

// TODO:  Move below to common utils file ***
#define COND_UNLIKELY(expr)			__builtin_expect((expr), 0)
#define COND_LIKELY(expr)			__builtin_expect((expr), 1)

#define D_ASSERT(expr)				{ \
										if(COND_UNLIKELY(!(expr))) { \
											d_printf(D_ERROR, "assertion failed: `%s' (file %s, line %d)", #expr, __FILE__, __LINE__);  \
											exit(-99) ; \
										} \
									} \

#define MAX(a,b) 					((a) > (b) ? (a) : (b))
#define MIN(a,b) 					((a) < (b) ? (a) : (b))

#define INT_IS_EVEN(x)				(((x) % 2) == 0)
#define INT_IS_ODD(x)				(!IS_EVEN(x))

#define GLOBAL_IRQ_DISABLE()		asm("cpsid I")
#define GLOBAL_IRQ_ENABLE()			asm("cpsie I")
// *** end

#define BOGOCAL_ITERAMT				100000
#define BOGOCAL_ITERCNT				2							// XXX: Bug if this is more than 2 causing shorter bogotimes than expected, to be investigated
																// at a later date (26/01/2020)

#define CLKWIZ_CFG_MIPI				(XPAR_CLK_WIZ_0_DEVICE_ID)
#define CLKWIZ_CFG_MIPI_REFCLK		177.77777777				// Should be adjusted to meet the refclk into the ClkWiz.  Bug in XSA generation makes
																// this otherwise invalid.

#define FPGA0_CLK_CTRL				0xF8000170
#define PS_CLK_REG_DIVISOR0_SHIFT	8
#define PS_CLK_REG_DIVISOR1_SHIFT	20
#define PS_CLK_REG_DIVISOR0_MASK	((0x3f) << PS_CLK_REG_DIVISOR0_SHIFT)
#define PS_CLK_REG_DIVISOR1_MASK	((0x3f) << PS_CLK_REG_DIVISOR1_SHIFT)

#define REG_SET_BIT(base, rg, msk)	Xil_Out32((base) + (rg), Xil_In32((base) + (rg)) | (msk))
#define REG_CLR_BIT(base, rg, msk)	Xil_Out32((base) + (rg), Xil_In32((base) + (rg)) & (~(msk)))
#define REG_TOG_BIT(base, rg, msk)	Xil_Out32((base) + (rg), Xil_In32((base) + (rg)) ^ (msk))

#define REG_MASK_BIT(base, rg, msk)	(Xil_In32((base) + (rg)) & msk)
#define REG_TEST_BIT(base, rg, msk)	(!!(REG_MASK_BIT(base, rg, msk)))

#define TMR_TESTS_0					0xe0
#define TMR_TESTS_1					0xe1
#define TMR_TESTS_2					0xe2
#define TMR_TESTS_3					0xe3
#define TMR_TESTS_4					0xe4

#define TMR_MIPI_PERFORMANCE		0xf0
#define TMR_MIPI_SG_OVERALL			0xf1
#define TMR_MIPI_SG_BDFILL			0xf2

typedef int16_t temp_t;			// Temperature represented from -273.15C to +327.68C
typedef uint16_t mvolt_t;		// System voltages from 0.0 ~ 6.5535V

struct __attribute__ ((packed)) hal_health_t {
	// FPGA health.
	temp_t die_temp;
	mvolt_t vcore_ps;
	mvolt_t vaux_ps;
	mvolt_t vcore_pl;
	mvolt_t vaux_pl;
	mvolt_t vddr;
};

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

// Linker script values
extern void *_STACK_SIZE;
extern void *_HEAP_SIZE;

void hal_init();
void gpio_set_ps_irq_direction(int index, int mode);
void gpio_write_ps_irq(int index, int state);
int gpio_read_ps_irq(int index);
void bogo_delay(uint32_t us);
void d_printf(int debug_code, char *fmt, ...);
void d_waitkey();
bool d_iskeypress();
char d_getkey();
void d_read_global_timer(uint32_t *lsb_ret, uint32_t *msb_ret);
void d_start_timing(int index);
void d_stop_timing(int index);
uint64_t d_read_timing(int index);
float d_read_timing_us(int index);
void d_dump_timing(char *s, int index);
void d_dump_timing_ex(char *s, int index);
void d_xilinx_assert(const char8 *File, s32 Line);
void d_dump_malloc_info();
void d_trap_handle();

/**
 * Fast read/write functions for EMIO port.  These are inlined
 * into code where possible and included in the .h as they are not
 * linked objects.
 */

/*
 * Write a pin on the GPIO EM port quickly.  Only supports pins in range 0 ~ 53.
 */
inline static void gpio_fast_write(unsigned int pin, int state)
{
	unsigned int bank;
	uint32_t write;
	uint32_t *reg;

	D_ASSERT(pin >= 0 && pin <= 53) ;

	state &= 1;
	bank = (pin >> 5); // divide by 32, starting at offset '0'
	reg = (uint32_t*)(bank * XGPIOPS_DATA_MASK_OFFSET);
	pin &= 31; // Likely also need to port this to emio_fast_write to fix bug

	if(pin > 15) {
		pin -= 16;
		reg += XGPIOPS_DATA_MSW_OFFSET;
	} else {
		reg += XGPIOPS_DATA_LSW_OFFSET;
	}

	write = ~(1 << (pin + 16)) & ((state << pin) | 0xffff0000);

	// d_printf(D_RAW, "p:%2d,b:%d,s:%d,reg:0x%08,write:0x%08x\r\n", pin, bank, state, reg, write);

	XGpioPs_WriteReg(XPS_GPIO_BASEADDR, reg, write);
}

/*
 * Write a pin on the EMIO port quickly.  Only supports pins in range 53 ~ 117.
 *
 * XXX: Is 53 an EMIO?
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

/**
 * Control one of the two LEDs attached to the PS.  Fast inlinable function.
 *
 * @param	index		0 or 1, for PS LEDs 0 and 1
 * @param	enable		0 = off, 1 = on
 */
inline static void gpio_led_write(int index, int enable)
{
	// Permit LEDs 0 or 1, ensure enable is 0/1
	D_ASSERT(index == 0 || index == 1);
	enable = !!(enable);

	switch(index) {
		case 0:
			gpio_fast_write(GPIO_PS_LED_0_PIN, enable);
			break;

		case 1:
			gpio_fast_write(GPIO_PS_LED_1_PIN, enable);
			break;
	}
}

#endif /* SRC_HAL_H_ */

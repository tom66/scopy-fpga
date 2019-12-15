/**
 * This file is part of YAOS and licenced under the MIT licence.
 * Copyright (c) 2019 Thomas Oldbury
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef ___HAL_H___
#define ___HAL_H___

#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_usart.h"
#include "stm32f0xx_hal_rcc.h"

#include <stdint.h>

#define UART_DEBUG_PORT                 GPIOC
#define UART_DEBUG_TX_PIN               GPIO_PIN_10
#define UART_DEBUG_RX_PIN               GPIO_PIN_11
#define UART_DEBUG_ALT_FUNC             GPIO_AF0_USART4
#define UART_DEBUG_PERIPH               USART4
#define UART_DEBUG_PERIPH_RCC_ENABLE()  __HAL_RCC_USART4_CLK_ENABLE()

#define LED_1_PIN                       GPIO_PIN_0
#define LED_2_PIN                       GPIO_PIN_1
#define LED_3_PIN                       GPIO_PIN_0
#define LED_P_RED_PIN                   GPIO_PIN_9
#define LED_P_BLU_PIN                   GPIO_PIN_10

#define LED_1_PORT                      GPIOF
#define LED_2_PORT                      GPIOF
#define LED_3_PORT                      GPIOC
#define LED_P_RED_PORT                  GPIOA
#define LED_P_BLU_PORT                  GPIOA

#define FPGA_PS_POR_B_PORT              GPIOD
#define FPGA_PS_SRST_B_PORT             GPIOD

#define FPGA_PS_POR_B_PIN               GPIO_PIN_6
#define FPGA_PS_SRST_B_PIN              GPIO_PIN_7

#define DDR_VTT_VREF_EN_PORT            GPIOA
#define DDR_VTT_VREF_EN_PIN             GPIO_PIN_12

#define PWR_5V0_MAIN_GO_PORT            GPIOC
#define PWR_3V3_MAIN_GO_PORT            GPIOC
#define PWR_1V8_MAIN_GO_PORT            GPIOC
#define PWR_5V0_PI_GO_PORT              GPIOD
#define PWR_3V3_PI_GO_PORT              GPIOD
#define PWR_1V8_PI_GO_PORT              GPIOD

#define PWR_5V0_MAIN_GO_PIN             GPIO_PIN_8
#define PWR_3V3_MAIN_GO_PIN             GPIO_PIN_7
#define PWR_1V8_MAIN_GO_PIN             GPIO_PIN_6
#define PWR_5V0_PI_GO_PIN               GPIO_PIN_15
#define PWR_3V3_PI_GO_PIN               GPIO_PIN_14
#define PWR_1V8_PI_GO_PIN               GPIO_PIN_13

#define PWR_1V05_ZYNQ_CORE_GO_PIN       GPIO_PIN_8      // VccPINT, VccINT
#define PWR_1V5_DDR_GO_PIN              GPIO_PIN_9      // VccO(DDR)
#define PWR_FPGA_AUX_PLL_ADC_GO_PIN     GPIO_PIN_13     // VccPAUX, VccAUX, VccPLL
#define PWR_FPGA_PL_1V8_IO_GO_PIN       GPIO_PIN_5      // 1V8_FPGA_35 (VccO)
#define PWR_FPGA_PS_PL_IO_GO_PIN        GPIO_PIN_6      // 3V3_FPGA_PS, 3V3_FPGA0/13, 2V5_FPGA_34

#define PWR_1V05_ZYNQ_CORE_GO_PORT      GPIOA
#define PWR_1V5_DDR_GO_PORT             GPIOC
#define PWR_FPGA_AUX_PLL_ADC_GO_PORT    GPIOC
#define PWR_FPGA_PL_1V8_IO_GO_PORT      GPIOE
#define PWR_FPGA_PS_PL_IO_GO_PORT       GPIOE

#define CM3_RUN_PORT                    GPIOE
#define CM3_RUN_PIN                     GPIO_PIN_1

#define GPIO_ADC_DC_IN_MEAS_PORT        GPIOC
#define GPIO_ADC_DC_IN_MEAS_PIN         GPIO_PIN_1

#define GPIO_FAST_SET_PIN(port, pin)    ((port)->BSRRL = (1 << pin)) ;
#define GPIO_FAST_CLR_PIN(port, pin)    ((port)->BSRRH = (1 << pin)) ;

#define DC_INPUT_LOW_THRESHOLD          9500            // Input below 9.5V triggers shutdown
#define DC_INPUT_HIGH_THRESHOLD         11000           // Input above 11V allows restart

#define ADC_DC_INPUT_SCALE              15766
#define ADC_DC_INPUT_SHIFT              12

#define TEMP_TOO_HOT_ZYNQ               8000            // 80C limit for Zynq
#define TEMP_TOO_HOT_CM3                9000            // 90C limit for CM3
#define TEMP_TOO_HOT_AMB_PSU            5000            // 50C limit for ambient or PSU section

#define TEMP_COOL_THRESHOLD             4500            // Any given component must fall to this temperature to allow restart

#define LED_ERROR_PSU_INPUT             2               // 2 blinks: PSU input error
#define LED_ERROR_PSU_PROTECT           3               // 3 blinks: PSU protect error
#define LED_ERROR_TEMPERATURE           4               // 4 blinks: Temperature
#define LED_ERROR_BOOT_FAIL             5               // 5 blinks: Bootup problem - Pi or Zynq (timed out trying to boot)

#define FLAG_ZYNQ_ON                    0x00000001
#define FLAG_RASPI_ON                   0x00000002
#define FLAG_PLL_ON                     0x00000004
#define FLAG_ADC_ON                     0x00000008
#define FLAG_DC_INPUT_LOW               0x00000100      // Set if DC input is low and operation of peripherals inhibited.
#define FLAG_TEMP_TOO_HOT               0x00000200      // Set if a temperature sensor is too hot and shutdown has occurred

#define FLAG_GRP_POWER_PROHIBIT         (FLAG_DC_INPUT_LOW | FLAG_TEMP_TOO_HOT)

#define RAIL_1V05_ZYNQ                  1
#define RAIL_1V5_DDR                    2
#define RAIL_FPGA_AUX_PLL_ADC           3
#define RAIL_FPGA_PL_1V8_IO             4
#define RAIL_FPGA_PS_PL_IO              5
#define RAIL_VTT_DDR                    6

struct sys_state_t {
    // General flags register
    uint32_t flags;
    
    // Temperature of various peripherals
    float temp_psu;
    float temp_amb;
    float temp_mcu;
    float temp_fpga;
    float temp_raspi;
    
    // Power supply voltage
    uint32_t dc_input_mv;
    
    // 
    uint32_t prot_power_grp;
};

struct prot_power_rail_t {
    uint32_t ref;
    GPIO_TypeDef* port;
    uint16_t pin;
};

extern struct sys_state_t sys_state;

void hal_init();
void arb_delay(volatile uint32_t n);
void systick_wait(uint32_t ms);
void uart_putsraw(char *str);
void uart_printf(char *fmt, ...);
void gpio_set_output(GPIO_TypeDef *gpio_port, uint32_t gpio_pin);
void gpio_set_input(GPIO_TypeDef *gpio_port, uint32_t gpio_pin);
void gpio_prot_power_rail_enable(struct prot_power_rail_t *rail, int32_t dly);
void gpio_prot_power_rail_disable(struct prot_power_rail_t *rail, int32_t dly);
void gpio_prot_power_start();
void gpio_prot_power_end();
void main_psu_power_on();
void main_psu_power_off();
void raspi_power_on();
void raspi_power_off();
void raspi_rapid_power_off();
void zynq_power_on();
void zynq_power_off();
void zynq_rapid_power_off();

#endif // ___HAL_H___

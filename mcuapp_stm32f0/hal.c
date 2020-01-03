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

#include "hal.h"
#include "hmcad151x.h"

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>

static UART_HandleTypeDef g_UARTHandle;
static ADC_HandleTypeDef g_ADCHandle;
    
struct sys_state_t sys_state;

struct prot_power_rail_t prot_rail_1v05_zynq          = { RAIL_1V05_ZYNQ, PWR_1V05_ZYNQ_CORE_GO_PORT, PWR_1V05_ZYNQ_CORE_GO_PIN };
struct prot_power_rail_t prot_rail_1v5_ddr            = { RAIL_1V5_DDR, PWR_1V5_DDR_GO_PORT, PWR_1V5_DDR_GO_PIN };
struct prot_power_rail_t prot_rail_fpga_aux_pll_adc   = { RAIL_FPGA_AUX_PLL_ADC, PWR_FPGA_AUX_PLL_ADC_GO_PORT, PWR_FPGA_AUX_PLL_ADC_GO_PIN };
struct prot_power_rail_t prot_rail_fpga_pl_1v8_io     = { RAIL_FPGA_PL_1V8_IO, PWR_FPGA_PL_1V8_IO_GO_PORT, PWR_FPGA_PL_1V8_IO_GO_PIN };
struct prot_power_rail_t prot_rail_fpga_ps_pl_io      = { RAIL_FPGA_PS_PL_IO, PWR_FPGA_PS_PL_IO_GO_PORT, PWR_FPGA_PS_PL_IO_GO_PIN };
struct prot_power_rail_t prot_rail_vtt_ddr            = { RAIL_VTT_DDR, DDR_VTT_VREF_EN_PORT, DDR_VTT_VREF_EN_PIN };

/*
 * Layer to interface with STM32F0 processor.  This layer was ported over from
 * an early prototype that used an STM32F4.
 */

char vsnprint_buffer[1024];

uint64_t ms_since_boot;
uint32_t ms_counter;

/*
 * SysTick_Handler: Interrupt handler for SysTick events.
 */
void SysTick_Handler(void)  
{ 
    uint32_t ctr_masked;
    uint32_t code;
    
    ms_since_boot++;
    ms_counter++;
    
    // Monitor 12V input.  If it drops below an acceptable threshold send the kill
    // signal.  This shuts off power to Pi and gracefully shuts down Zynq to avoid eFUSE
    // failure.
    if(HAL_ADC_PollForConversion(&g_ADCHandle, 0) == HAL_OK) {
        code = HAL_ADC_GetValue(&g_ADCHandle);
        sys_state.dc_input_mv = (code * ADC_DC_INPUT_SCALE) >> ADC_DC_INPUT_SHIFT;
    }
    
    if(sys_state.dc_input_mv > DC_INPUT_HIGH_THRESHOLD) {
        // Clear flag indicating good DC is present again.
        sys_state.flags &= ~FLAG_DC_INPUT_LOW;
    }
    
    if(sys_state.dc_input_mv < DC_INPUT_LOW_THRESHOLD) {
        // Woah.  DC voltage low.  Kill the Zynq safely.
        sys_state.flags |= FLAG_DC_INPUT_LOW;
        if(sys_state.flags & FLAG_ZYNQ_ON) {
            pll_power_off();
            adc_power_off();
            raspi_rapid_power_off();
            zynq_rapid_power_off();
        }
    }
    
    // Set an LED if DC power low
    if(sys_state.flags & FLAG_DC_INPUT_LOW) {
        HAL_GPIO_WritePin(LED_2_PORT, LED_2_PIN, GPIO_PIN_SET);
    } else {
        HAL_GPIO_WritePin(LED_2_PORT, LED_2_PIN, GPIO_PIN_RESET);
    }
    
    HAL_ADC_Start(&g_ADCHandle);
    
    // Toggle heartbeat LED every 0.127s & 0.511s
    ctr_masked = ms_since_boot & 1023;
    
    if(ctr_masked == 127 || ctr_masked == 255) {
        HAL_GPIO_WritePin(LED_1_PORT, LED_1_PIN, GPIO_PIN_SET);
    } else if(ctr_masked == 130 || ctr_masked == 258) {
        HAL_GPIO_WritePin(LED_1_PORT, LED_1_PIN, GPIO_PIN_RESET);
    }
}

/*
 * hal_init:  Initialise key hardware resources
 */
void hal_init()
{
    GPIO_InitTypeDef GPIO_Def;
    RCC_ClkInitTypeDef RCC_ClkInitDef;
    RCC_OscInitTypeDef RCC_OscInitDef;
    RCC_PeriphCLKInitTypeDef PeriphClkDef;
    USART_InitTypeDef USART_InitDef;
    ADC_ChannelConfTypeDef ADC_ChannelDef;
    
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();
    __HAL_RCC_GPIOC_CLK_ENABLE();
    __HAL_RCC_GPIOD_CLK_ENABLE();
    __HAL_RCC_GPIOE_CLK_ENABLE();
    __HAL_RCC_GPIOF_CLK_ENABLE();
    __HAL_RCC_GPIOF_CLK_ENABLE();
    UART_DEBUG_PERIPH_RCC_ENABLE();
    __HAL_RCC_HSI14_ENABLE(); // for ADC
    __HAL_RCC_ADC1_CLK_ENABLE();
    
    SystemInit();
    SystemCoreClockUpdate();
    
    /*
     * Initialise 48MHz oscillator.
     */
    RCC_OscInitDef.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitDef.HSI48State = RCC_HSI48_ON;
    HAL_RCC_OscConfig(&RCC_OscInitDef);

    RCC_ClkInitDef.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitDef.APB1CLKDivider = RCC_HCLK_DIV1;
    RCC_ClkInitDef.SYSCLKSource = RCC_CFGR_SW_HSI48;
    RCC_ClkInitDef.ClockType = RCC_CLOCKTYPE_SYSCLK;
    HAL_RCC_ClockConfig(&RCC_ClkInitDef, FLASH_LATENCY_1);
    
    PeriphClkDef.PeriphClockSelection = RCC_PERIPHCLK_USART1|RCC_PERIPHCLK_I2C1;
    PeriphClkDef.Usart1ClockSelection = RCC_USART1CLKSOURCE_PCLK1;
    PeriphClkDef.I2c1ClockSelection = RCC_I2C1CLKSOURCE_HSI;
    HAL_RCCEx_PeriphCLKConfig(&PeriphClkDef);

    __HAL_RCC_SYSCFG_CLK_ENABLE();
    
    /*
     * Setup GPIO states.
     */
    gpio_set_output(LED_1_PORT, LED_1_PIN);
    gpio_set_output(LED_2_PORT, LED_2_PIN);
    gpio_set_output(LED_3_PORT, LED_3_PIN);
    gpio_set_output(LED_P_RED_PORT, LED_P_RED_PIN);
    gpio_set_output(LED_P_BLU_PORT, LED_P_BLU_PIN);
    
    gpio_set_output(PWR_5V0_MAIN_GO_PORT, PWR_5V0_MAIN_GO_PIN);
    gpio_set_output(PWR_3V3_MAIN_GO_PORT, PWR_3V3_MAIN_GO_PIN);
    gpio_set_output(PWR_1V8_MAIN_GO_PORT, PWR_1V8_MAIN_GO_PIN);
    gpio_set_output(PWR_5V0_PI_GO_PORT, PWR_5V0_PI_GO_PIN);
    gpio_set_output(PWR_3V3_PI_GO_PORT, PWR_3V3_PI_GO_PIN);
    gpio_set_output(PWR_1V8_PI_GO_PORT, PWR_1V8_PI_GO_PIN);
    
    gpio_set_output(PWR_1V05_ZYNQ_CORE_GO_PORT, PWR_1V05_ZYNQ_CORE_GO_PIN);
    gpio_set_output(PWR_FPGA_AUX_PLL_ADC_GO_PORT, PWR_FPGA_AUX_PLL_ADC_GO_PIN);
    gpio_set_output(PWR_FPGA_PL_1V8_IO_GO_PORT, PWR_FPGA_PL_1V8_IO_GO_PIN);
    gpio_set_output(PWR_FPGA_PS_PL_IO_GO_PORT, PWR_FPGA_PS_PL_IO_GO_PIN);
    gpio_set_output(FPGA_PS_POR_B_PORT, FPGA_PS_POR_B_PIN);
    HAL_GPIO_WritePin(FPGA_PS_POR_B_PORT, FPGA_PS_POR_B_PIN, GPIO_PIN_RESET);  // POR_B kept low during power up to ensure eFUSE integrity
    gpio_set_output(FPGA_PS_SRST_B_PORT, FPGA_PS_SRST_B_PIN);
    
    gpio_set_output(PWR_1V5_DDR_GO_PORT, PWR_1V5_DDR_GO_PIN);
    gpio_set_output(DDR_VTT_VREF_EN_PORT, DDR_VTT_VREF_EN_PIN);
    
    gpio_set_output(CM3_RUN_PORT, CM3_RUN_PIN);
    
    gpio_set_output(PWR_PLL_GO_PORT, PWR_PLL_GO_PIN);
    gpio_set_output(PWR_ADC_GO_PORT, PWR_ADC_GO_PIN);
    
    // Keep LEDs off (for now)
    HAL_GPIO_WritePin(LED_1_PORT, LED_1_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(LED_2_PORT, LED_2_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(LED_3_PORT, LED_3_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(LED_P_RED_PORT, LED_P_RED_PIN, GPIO_PIN_SET);
    HAL_GPIO_WritePin(LED_P_BLU_PORT, LED_P_BLU_PIN, GPIO_PIN_SET);
    
    /* 
     * Configure SysTick to generate 1ms interrupts
     */
    SysTick_Config(SystemCoreClock / 1000);
    
    /*
     * Initialise USART peripheral and relevant GPIOs.
     */
    GPIO_Def.Pin = UART_DEBUG_TX_PIN;
    GPIO_Def.Mode = GPIO_MODE_AF_PP;
    GPIO_Def.Alternate = UART_DEBUG_ALT_FUNC;
    GPIO_Def.Speed = GPIO_SPEED_FREQ_LOW;
    GPIO_Def.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(UART_DEBUG_PORT, &GPIO_Def);
    
    GPIO_Def.Pin = UART_DEBUG_RX_PIN;
    GPIO_Def.Mode = GPIO_MODE_AF_OD;
    GPIO_Def.Alternate = UART_DEBUG_ALT_FUNC;
    GPIO_Def.Speed = GPIO_SPEED_FREQ_LOW;
    GPIO_Def.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(UART_DEBUG_PORT, &GPIO_Def);
    
    g_UARTHandle.Instance = UART_DEBUG_PERIPH;
    g_UARTHandle.Init.BaudRate = 115200;
    g_UARTHandle.Init.Mode = USART_MODE_TX_RX;
    g_UARTHandle.Init.Parity = USART_PARITY_NONE;
    g_UARTHandle.Init.StopBits = USART_STOPBITS_1;
    g_UARTHandle.Init.WordLength = USART_WORDLENGTH_8B;
    g_UARTHandle.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    HAL_UART_Init(&g_UARTHandle);
    
    uart_putsraw("\r\n\r\n");
    uart_putsraw("ScopyMVP MCU Main Application\r\n");
    uart_putsraw("hal: IO initialised\r\n");
    
    /*
     * Initialise the ADC peripheral.
     */
    g_ADCHandle.Instance = ADC1;
    g_ADCHandle.Init.ClockPrescaler = ADC_CLOCK_ASYNC_DIV1;
    g_ADCHandle.Init.ContinuousConvMode = DISABLE;
    g_ADCHandle.Init.DataAlign = ADC_DATAALIGN_RIGHT;
    g_ADCHandle.Init.DiscontinuousConvMode = DISABLE;
    g_ADCHandle.Init.DMAContinuousRequests = DISABLE;
    g_ADCHandle.Init.EOCSelection = ADC_EOC_SINGLE_CONV;
    g_ADCHandle.Init.ExternalTrigConv = ADC_SOFTWARE_START;
    g_ADCHandle.Init.ExternalTrigConvEdge = ADC_EXTERNALTRIGCONVEDGE_NONE;
    g_ADCHandle.Init.LowPowerAutoPowerOff = DISABLE;
    g_ADCHandle.Init.LowPowerAutoWait = ENABLE;
    g_ADCHandle.Init.Overrun = ADC_OVR_DATA_OVERWRITTEN;
    g_ADCHandle.Init.Resolution = ADC_RESOLUTION_12B;
    g_ADCHandle.Init.SamplingTimeCommon = ADC_SAMPLETIME_28CYCLES_5;     // Initial guess
    g_ADCHandle.Init.ScanConvMode = ADC_SCAN_DIRECTION_FORWARD;          // Ignored

    HAL_ADC_Init(&g_ADCHandle);
    
    // Initialise GPIO ADC input on PC1
    GPIO_Def.Pin = GPIO_ADC_DC_IN_MEAS_PIN;
    GPIO_Def.Mode = GPIO_MODE_ANALOG;
    GPIO_Def.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(GPIO_ADC_DC_IN_MEAS_PORT, &GPIO_Def);
    
    ADC_ChannelDef.Channel = ADC_CHANNEL_11;
    ADC_ChannelDef.Rank = 1;
    ADC_ChannelDef.SamplingTime = ADC_SAMPLETIME_28CYCLES_5;
    
    HAL_ADC_ConfigChannel(&g_ADCHandle, &ADC_ChannelDef);
    
    uart_putsraw("hal: MCU ADC initialised\r\n");
    
    // Default power state
    adc_power_off();
    pll_power_off();
    raspi_power_off();
    zynq_power_off();
    main_psu_power_off();
}

/**
 * arb_delay:  Function to wait an arbitrary amount of time.
 *
 * This should eventually be replaced with systick.
 */
void arb_delay(volatile uint32_t n)
{
    for(; n > 0; n--) {
        __asm__("nop");
    }
}

/**
 * systick_wait:  Wait a number of milliseconds using systick.
 */
void systick_wait(uint32_t ms)
{
    ms_counter = 0;
    
    while(ms_counter < ms) ;
}

/*
 * uart_putsraw:  Put debug string without any formatting.
 *
 * @param   string      String to print
 */
void uart_putsraw(char *str)
{
    do {
        while(!(g_UARTHandle.Instance->ISR & UART_FLAG_TXE)) ;
        g_UARTHandle.Instance->TDR = *str;
    } while(*str++) ;
}

/*
 * uart_snprintf:  Put debug string with printf formatting.
 *
 * @param   fmt         Format string
 * @param   len         Length of buffer (limited to sizeof(vsnprint_buffer) max)
 * @param   ...         Zero or more arguments for format string
 */
void uart_snprintf(char *fmt, uint32_t len, ...)
{
    va_list args;
    va_start(args, fmt);
    
    if(len > sizeof(vsnprint_buffer))
        len = sizeof(vsnprint_buffer);
    
    vsnprintf(vsnprint_buffer, len, fmt, args);
    uart_putsraw(vsnprint_buffer);
    
    va_end(args);
}

/*
 * uart_printf:  Put debug string with printf formatting.
 *
 * @note    buffer size limit enforced by vsnprintf
 *
 * @param   fmt         Format string
 * @param   ...         Zero or more arguments for format string
 */
void uart_printf(char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    
    vsnprintf(vsnprint_buffer, sizeof(vsnprint_buffer), fmt, args);
    uart_putsraw(vsnprint_buffer);
    
    va_end(args);
}

/*
 * uart_getchar:  Get a character from the UART port, blocking until
 * the character is available.
 */
char uart_getchar()
{
    while(!(g_UARTHandle.Instance->ISR & UART_FLAG_RXNE)) ;
    return g_UARTHandle.Instance->RDR;
}

/*
 * uart_getchar_nb:  Get a character from the UART port, but don't block
 * if one isn't available.  Simply return what is available in the buffer,
 * which may not be valid data.
 */
char uart_getchar_nb()
{
    return g_UARTHandle.Instance->RDR;
}

/*
 * gpio_set_output:  Set a GPIO port/pin combination to push-pull output.
 *
 * @param   gpio_port   GPIO_TypeDef pointer to the port base
 * @param   gpio_pin    GPIO_PIN_xx or bit-shifted representation of pin number
 */
void gpio_set_output(GPIO_TypeDef *gpio_port, uint32_t gpio_pin)
{
    GPIO_InitTypeDef GPIO_Def;
    
    GPIO_Def.Pin = gpio_pin;
    GPIO_Def.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_Def.Speed = GPIO_SPEED_FREQ_LOW;  // Default low to keep J Pawson happy
    
    HAL_GPIO_Init(gpio_port, &GPIO_Def);
}

/*
 * gpio_set_input:  Set a GPIO port/pin combination to an unpulled input.
 *
 * @param   gpio_port   GPIO_TypeDef pointer to the port base
 * @param   gpio_pin    GPIO_Pin_xx or bit-shifted representation of pin number
 */
void gpio_set_input(GPIO_TypeDef *gpio_port, uint32_t gpio_pin)
{
    GPIO_InitTypeDef GPIO_Def;
   
    GPIO_Def.Pin = gpio_pin;
    GPIO_Def.Mode = GPIO_MODE_INPUT;
    
    HAL_GPIO_Init(gpio_port, &GPIO_Def);
}

/**
 * gpio_prot_power_rail_enable:  Enable a protected rail.  Protected rails are defined
 * as rails where damage to the Zynq could occur if the start process was executed while
 * a low DC input condition was present (or becomes present) then the rail won't be switched
 * on and future rails switch on events will be disabled until the fault condition clears.
 */ 
void gpio_prot_power_rail_enable(struct prot_power_rail_t *rail, int32_t dly)
{
    if(sys_state.flags & FLAG_GRP_POWER_PROHIBIT) 
        return;
    
    HAL_GPIO_WritePin(rail->port, rail->pin, GPIO_PIN_SET);
    
    while(dly > 0) {
        systick_wait(3);
        dly -= 3;
        
        if(sys_state.flags & FLAG_GRP_POWER_PROHIBIT) {
            HAL_GPIO_WritePin(rail->port, rail->pin, GPIO_PIN_RESET);
            return;
        }
    }
}

/**
 * gpio_prot_power_rail_disable:  Disable a protected rail.  This function is
 * more of a convenience wrapper, and doesn't do anything different to a GPIO
 * clear followed by a delay.
 */ 
void gpio_prot_power_rail_disable(struct prot_power_rail_t *rail, int32_t dly)
{
    HAL_GPIO_WritePin(rail->port, rail->pin, GPIO_PIN_RESET);
        
    if(dly > 0) {
        systick_wait(dly);
    }
}

/**
 * gpio_prot_power_start:  Mutexing function to set a flag which tells the SysTick
 * interrupt to not clear any fault flags until the equivalent _end statement is 
 * called. This ensures all power rails in a given group are disabled if a fault
 * occurs in the middle of a power up cycle.
 */
void gpio_prot_power_start()
{
    sys_state.prot_power_grp = 1;
}

/**
 * gpio_prot_power_end:  End power protection group.
 */
void gpio_prot_power_end()
{
    sys_state.prot_power_grp = 0;
}

/**
 * main_psu_power_on:   Power up the main 5V/3V3/1V8 rails.  These are needed
 * to run the Pi, Zynq, ADC, PLL, etc.
 */
void main_psu_power_on()
{
    // Sequence start main power rails with 10ms between each rail start
    // to limit inrush current.  Lower rails start first.
    HAL_GPIO_WritePin(PWR_1V8_MAIN_GO_PORT, PWR_1V8_MAIN_GO_PIN, GPIO_PIN_SET);
    systick_wait(10);
    HAL_GPIO_WritePin(PWR_3V3_MAIN_GO_PORT, PWR_3V3_MAIN_GO_PIN, GPIO_PIN_SET);
    systick_wait(10);
    HAL_GPIO_WritePin(PWR_5V0_MAIN_GO_PORT, PWR_5V0_MAIN_GO_PIN, GPIO_PIN_SET);
    
    // Wait for rails to start
    systick_wait(80);
}

/**
 * main_psu_power_off:   Power off the main rails.  This is the last stage of shutdown.
 * It cannot be run if the Zynq and RasPi are switched on.
 */
void main_psu_power_off()
{
    if(sys_state.flags & (FLAG_ZYNQ_ON | FLAG_RASPI_ON)) {
        uart_printf("hal: error: unable to shut PSU down - Raspi/Zynq still enabled (0x%08x)\r\n", sys_state.flags & (FLAG_ZYNQ_ON | FLAG_RASPI_ON));
        return;
    }
    
    // Shut down all power rails simultaneously.  All loads should be disconnected at this 
    // point, so the sequencing shouldn't matter.
    HAL_GPIO_WritePin(PWR_1V8_MAIN_GO_PORT, PWR_1V8_MAIN_GO_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(PWR_3V3_MAIN_GO_PORT, PWR_3V3_MAIN_GO_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(PWR_5V0_MAIN_GO_PORT, PWR_5V0_MAIN_GO_PIN, GPIO_PIN_RESET);
}

/**
 * raspi_power_on:  Power up the Raspberry Pi CM3 module.
 */
void raspi_power_on()
{
    // Check if we are OK to power up: not in shutdown state.
    if(sys_state.flags & FLAG_GRP_POWER_PROHIBIT) {
        uart_printf("hal: error: unable to power up Pi due to prohibit flags 0x%08x\r\n", sys_state.flags & FLAG_GRP_POWER_PROHIBIT);
        // TODO: Set error state here to flash LED with error code.
        return;
    }
    
    // Sequence start Pi power rails with 50ms between each rail start
    // to limit inrush current.  Higher rails start first.
    HAL_GPIO_WritePin(PWR_5V0_PI_GO_PORT, PWR_5V0_PI_GO_PIN, GPIO_PIN_SET);
    systick_wait(20);
    HAL_GPIO_WritePin(PWR_3V3_PI_GO_PORT, PWR_3V3_PI_GO_PIN, GPIO_PIN_SET);
    systick_wait(20);
    HAL_GPIO_WritePin(PWR_1V8_PI_GO_PORT, PWR_1V8_PI_GO_PIN, GPIO_PIN_SET);
    systick_wait(20);
    
    // Hold run LOW then release
    HAL_GPIO_WritePin(CM3_RUN_PORT, CM3_RUN_PIN, GPIO_PIN_RESET);
    systick_wait(50);
    HAL_GPIO_WritePin(CM3_RUN_PORT, CM3_RUN_PIN, GPIO_PIN_SET);
    systick_wait(20);
    
    sys_state.flags |= FLAG_RASPI_ON;
}

/**
 * raspi_power_off:  Power off the Raspberry Pi CM3 module.
 *
 * Note - the proper shutdown process on the Pi application side should be 
 * executed before this is run. Otherwise, SD card corruption could occur.
 */
void raspi_power_off()
{
    if(!(sys_state.flags & FLAG_RASPI_ON))
        return;
    
    // Run goes low to shut down Pi CPU complex.
    HAL_GPIO_WritePin(CM3_RUN_PORT, CM3_RUN_PIN, GPIO_PIN_RESET);
    systick_wait(100);
    
    // Kill rails starting with the lowest and ending with the highest.
    HAL_GPIO_WritePin(PWR_1V8_PI_GO_PORT, PWR_1V8_PI_GO_PIN, GPIO_PIN_RESET);
    systick_wait(20);
    HAL_GPIO_WritePin(PWR_3V3_PI_GO_PORT, PWR_3V3_PI_GO_PIN, GPIO_PIN_RESET);
    systick_wait(20);
    HAL_GPIO_WritePin(PWR_5V0_PI_GO_PORT, PWR_5V0_PI_GO_PIN, GPIO_PIN_RESET);
    systick_wait(20);
    
    sys_state.flags &= ~FLAG_RASPI_ON;
}

/**
 * raspi_rapid_power_off:  Power off the Raspberry Pi CM3 module rapidly
 * to reduce load on rails and allow Zynq to shut down safely.
 *
 * We're in interrupts when this is called, so we can't use systick.
 */
void raspi_rapid_power_off()
{
    HAL_GPIO_WritePin(CM3_RUN_PORT, CM3_RUN_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(PWR_1V8_PI_GO_PORT, PWR_1V8_PI_GO_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(PWR_3V3_PI_GO_PORT, PWR_3V3_PI_GO_PIN, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(PWR_5V0_PI_GO_PORT, PWR_5V0_PI_GO_PIN, GPIO_PIN_RESET);
    
    sys_state.flags &= ~FLAG_RASPI_ON;
}

/**
 * zynq_power_on:  Power up the Zynq, correctly sequencing the rails and 
 * driving the POR_B input.  It is essential that this routine be used;  
 * failure to power up the Zynq correctly could lead to eFUSE damage.
 */
void zynq_power_on()
{
    // Check if we are OK to power up: not in shutdown state.
    if(sys_state.flags & FLAG_GRP_POWER_PROHIBIT) {
        uart_printf("hal: error: unable to power up Zynq due to prohibit flags 0x%08x\r\n", sys_state.flags & FLAG_GRP_POWER_PROHIBIT);
        // TODO: Set error state here to flash LED with error code.
        return;
    }
    
    gpio_prot_power_start();
    
    // POR_B kept low during power up to ensure eFUSE integrity
    HAL_GPIO_WritePin(FPGA_PS_POR_B_PORT, FPGA_PS_POR_B_PIN, GPIO_PIN_RESET);
    systick_wait(30); 
    arb_delay(10000);   // this can be deleted once we are sufficiently confident about Systick delay never being zero
    
    // *** Start Zynq core rails ***
    // Enable rails through protection function (which will abort if protection flag
    // has been set during power up): Core -> PS/PL AUX -> 3V3 MIO -> DDR3+I/O
    // This complies with T(vcco2vccaux) requirement.
    gpio_prot_power_rail_enable(&prot_rail_1v05_zynq, 100);
    gpio_prot_power_rail_enable(&prot_rail_fpga_aux_pll_adc, 20);
    gpio_prot_power_rail_enable(&prot_rail_fpga_pl_1v8_io, 20);
    gpio_prot_power_rail_enable(&prot_rail_fpga_ps_pl_io, 50);  // Wait a bit longer to ensure oscillator on 3V3 rail starts up cleanly
    
    // *** Start DDR3 ***
    // DDR3 Vdd -> DDR3 Vtt
    gpio_prot_power_rail_enable(&prot_rail_1v5_ddr, 50);
    gpio_prot_power_rail_enable(&prot_rail_vtt_ddr, 0);
    
    // *** Make SRST high after ramp up complete - permitted per Chapter 6 UG585 (pg 161) ***
    HAL_GPIO_WritePin(FPGA_PS_SRST_B_PORT, FPGA_PS_SRST_B_PIN, GPIO_PIN_SET);
    systick_wait(10); 
    
    // *** Send POR_B to start PL ***
    // Distinct delay:  waits for all rails to be at correct level before asserting power.
    // Secure Lockdown Window is 39ms maximum, but we wait a lot longer to ensure that we are -well- outside
    // of the SLW and avoid boot issues.
    systick_wait(200);   
    arb_delay(10000);   // this can be deleted once we are sufficiently confident about Systick delay never being zero
    HAL_GPIO_WritePin(FPGA_PS_POR_B_PORT, FPGA_PS_POR_B_PIN, GPIO_PIN_SET);
    systick_wait(10); 
    
    sys_state.flags |= FLAG_ZYNQ_ON;
    
    gpio_prot_power_end();
}

/**
 * zynq_power_off:  Power off the Zynq, correctly sequencing the shutdown process.
 * The POR_B input MUST be deasserted to safely power off the Zynq without risking
 * damage to the eFUSEs. 
 */
void zynq_power_off()
{
    gpio_prot_power_start();
    
    // SRST goes low.
    HAL_GPIO_WritePin(FPGA_PS_SRST_B_PORT, FPGA_PS_SRST_B_PIN, GPIO_PIN_RESET);
    systick_wait(4); 
    
    // POR_B goes low.  At this point the Zynq should be off...
    HAL_GPIO_WritePin(FPGA_PS_POR_B_PORT, FPGA_PS_POR_B_PIN, GPIO_PIN_RESET);
    systick_wait(50); 
    
    // But, just to make sure... kill the 3V3 feed to the oscillator by killing all IO voltages.
    gpio_prot_power_rail_disable(&prot_rail_fpga_pl_1v8_io, 0);
    gpio_prot_power_rail_disable(&prot_rail_fpga_ps_pl_io, 10);
    gpio_prot_power_rail_disable(&prot_rail_1v5_ddr, 0);
    gpio_prot_power_rail_disable(&prot_rail_vtt_ddr, 10);
    
    // Then turn off core voltages & aux voltage
    gpio_prot_power_rail_disable(&prot_rail_1v05_zynq, 2);
    gpio_prot_power_rail_disable(&prot_rail_fpga_aux_pll_adc, 2);
    
    sys_state.flags &= ~FLAG_ZYNQ_ON;
    
    gpio_prot_power_end();
}

/**
 * zynq_rapid_power_off:  Power off the Zynq rapidly and safely.  But less safely
 * than the normal power off routine.  By less safely, it is meant that it is possible
 * for some bias currents to flow between IO domains.  This is less of a risk than eFUSE
 * failure, and unlikely to cause a problem if used only occasionally.
 *
 * We're in interrupts when this is called, so we can't use systick.
 */
void zynq_rapid_power_off()
{
    // SRST goes low.
    HAL_GPIO_WritePin(FPGA_PS_SRST_B_PORT, FPGA_PS_SRST_B_PIN, GPIO_PIN_RESET);
    arb_delay(5000); // wait a bit - IRQ safe
    
    // POR_B goes low.  At this point the Zynq should be off.
    HAL_GPIO_WritePin(FPGA_PS_POR_B_PORT, FPGA_PS_POR_B_PIN, GPIO_PIN_RESET);
    arb_delay(20000); // wait a bit - IRQ safe
    
    // Kill all IO voltages quickly.  Some device currents may flow between domains
    // because these don't all shut down at the same time.
    gpio_prot_power_rail_disable(&prot_rail_fpga_pl_1v8_io, 0);
    gpio_prot_power_rail_disable(&prot_rail_fpga_ps_pl_io, 0);
    gpio_prot_power_rail_disable(&prot_rail_1v5_ddr, 0);
    gpio_prot_power_rail_disable(&prot_rail_vtt_ddr, 0);
    arb_delay(10000);
    
    // Kill core voltages.
    gpio_prot_power_rail_disable(&prot_rail_1v05_zynq, 0);
    gpio_prot_power_rail_disable(&prot_rail_fpga_aux_pll_adc, 0);
    
    sys_state.flags &= ~FLAG_ZYNQ_ON;
}

/**
 * pll_power_on: Enable power to the PLL.
 */
void pll_power_on()
{
    HAL_GPIO_WritePin(PWR_PLL_GO_PORT, PWR_PLL_GO_PIN, GPIO_PIN_SET);
    sys_state.flags |= FLAG_PLL_ON;
}

/**
 * pll_power_off: Disable power to the PLL.
 */
void pll_power_off()
{
    HAL_GPIO_WritePin(PWR_PLL_GO_PORT, PWR_PLL_GO_PIN, GPIO_PIN_RESET);
    sys_state.flags &= ~FLAG_PLL_ON;
}

/**
 * adc_power_on: Enable power to the HMCAD ADC.
 */
void adc_power_on()
{
    HAL_GPIO_WritePin(PWR_ADC_GO_PORT, PWR_ADC_GO_PIN, GPIO_PIN_SET);
    sys_state.flags |= FLAG_ADC_ON;
}

/**
 * adc_power_off: Disable power to the HMCAD ADC.
 */
void adc_power_off()
{
    HAL_GPIO_WritePin(PWR_ADC_GO_PORT, PWR_ADC_GO_PIN, GPIO_PIN_RESET);
    sys_state.flags &= ~FLAG_ADC_ON;
}

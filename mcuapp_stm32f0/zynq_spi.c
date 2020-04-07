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

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>

#include "hal.h"
#include "zynq_spi.h"

#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_spi.h"
#include "stm32f0xx_hal_rcc.h"

SPI_HandleTypeDef zynq_spi;

/*
 * Initialise the Zynq SPI master driver.
 */
void zynq_spi_init()
{
    GPIO_InitTypeDef gpio_init;
    CRC_HandleTypeDef crc_init;
    
    // Configure GPIO for the SPI
    gpio_init.Pin = FPGA_SCLK_3V3_PIN;
    gpio_init.Mode = GPIO_MODE_AF_PP;
    gpio_init.Pull = GPIO_PULLDOWN;
    gpio_init.Speed = GPIO_SPEED_FREQ_HIGH;
    gpio_init.Alternate = FPGA_SPI_AF;
    HAL_GPIO_Init(FPGA_SCLK_3V3_PORT, &gpio_init);

    gpio_init.Pin = FPGA_MISO_3V3_PIN;
    gpio_init.Mode = GPIO_MODE_AF_PP;
    gpio_init.Pull = GPIO_PULLDOWN;
    gpio_init.Speed = GPIO_SPEED_FREQ_HIGH;
    gpio_init.Alternate = FPGA_SPI_AF;
    HAL_GPIO_Init(FPGA_MISO_3V3_PORT, &gpio_init);

    gpio_init.Pin = FPGA_MOSI_3V3_PIN;
    gpio_init.Mode = GPIO_MODE_AF_PP;
    gpio_init.Pull = GPIO_PULLDOWN;
    gpio_init.Speed = GPIO_SPEED_FREQ_HIGH;
    gpio_init.Alternate = FPGA_SPI_AF;
    HAL_GPIO_Init(FPGA_MOSI_3V3_PORT, &gpio_init);
    
    /*
     * Configure software chip select and IRQ responses.
     *
     * FPGA_PS_IRQ1 signals that the FPGA is ready to send a response.
     *
     * FPGA_PS_IRQ2 signals that the FPGA is too busy to accept further commands (commands 
     * will be ignored until this signal goes low.)
     *
     * FPGA_PS_IRQ3..4 are not used currently, and neither are FPGA_IRQ1..3.  All are still
     * initialised correctly.
     */
    gpio_set_output(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    gpio_set_input(FPGA_PS_IRQ1_PORT, FPGA_PS_IRQ1_PIN);
    gpio_set_input(FPGA_PS_IRQ2_PORT, FPGA_PS_IRQ2_PIN);
    gpio_set_input(FPGA_PS_IRQ3_PORT, FPGA_PS_IRQ3_PIN);
    gpio_set_input(FPGA_PS_IRQ4_PORT, FPGA_PS_IRQ4_PIN);
    gpio_set_input(FPGA_IRQ1_PORT, FPGA_IRQ1_PIN);
    gpio_set_input(FPGA_IRQ2_PORT, FPGA_IRQ2_PIN);
    gpio_set_input(FPGA_IRQ3_PORT, FPGA_IRQ3_PIN);
    
    // Configure the SPI peripheral
    zynq_spi.Instance = SPI1;
    zynq_spi.Init.Mode = SPI_MODE_MASTER;
    zynq_spi.Init.Direction = SPI_DIRECTION_2LINES;
    zynq_spi.Init.DataSize = SPI_DATASIZE_8BIT;
    zynq_spi.Init.CLKPolarity = SPI_POLARITY_LOW;
    zynq_spi.Init.CLKPhase = SPI_PHASE_1EDGE;
    zynq_spi.Init.NSS = SPI_NSS_SOFT;
    zynq_spi.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_4; // FPClk/4 (12MHz SPI)
    zynq_spi.Init.FirstBit = SPI_FIRSTBIT_MSB;
    zynq_spi.Init.TIMode = SPI_TIMODE_DISABLE;
    zynq_spi.Init.CRCCalculation = SPI_CRCCALCULATION_ENABLE;
    zynq_spi.Init.CRCPolynomial = 0x9b; // P.Koopman, CMU
    zynq_spi.Init.CRCLength = SPI_CRC_LENGTH_8BIT; 
    zynq_spi.Init.NSSPMode = SPI_NSS_PULSE_DISABLE;
    
    __HAL_RCC_SPI1_CLK_ENABLE();
    HAL_SPI_Init(&zynq_spi);
    __HAL_SPI_ENABLE(&zynq_spi);
    
    uart_putsraw("spi: initialised\r\n");
}

/*
 * Transmit a command with 0-8 argument bytes and a CRC8.
 */
void zynq_command_transmit(uint8_t command, uint8_t nargs, uint8_t *args)
{
    int timeout = 10000;
    int i;
    uint8_t command_data[16] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    uint8_t *data = (uint8_t*)&command_data;
    
    command_data[0] = command;
    
    // Pack arguments.  Unused arguments packed as NUL.
    for(i = 0; i < nargs; i++) {
        command_data[i + 1] = *(args + i);
    }
    
    // Transmit bytes.  Drive CS throughout transaction.
    GPIO_FAST_CLR_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    //GPIO_FAST_SET_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    zynq_spi_transmit_no_read(data, nargs + 1);
    
    __disable_irq();
    
    // Wait for the transmit FIFO to empty
    while(!(zynq_spi.Instance->SR & SPI_FLAG_TXE) && timeout--) ;
    
    // Send CRC using the hardware CRC generator.
    zynq_spi.Instance->CR1 |= SPI_CR1_CRCNEXT;
    
    // Wait for the busy flag to clear
    while((zynq_spi.Instance->SR & SPI_FLAG_BSY) && timeout--) ;
    
    __enable_irq();
    
    // Remove drive on CS.
    //GPIO_FAST_CLR_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    GPIO_FAST_SET_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
}

/*
 * Fast transmit with discard read.  CS is not driven.
 */
inline void zynq_spi_transmit_no_read(uint8_t *data, uint32_t size)
{
    while(size > 0) {
        if(!((zynq_spi.Instance->SR & SPI_FLAG_FTLVL) & SPI_FTLVL_HALF_FULL)) {
            if(size >= 2) {
                zynq_spi.Instance->DR = *((uint16_t *)data);
                data += 2;
                size -= 2;
            } else {
                *((__IO uint8_t *)&zynq_spi.Instance->DR) = (*data++);
                size--;
            }
        }
    }
}

/*
 * Test the Zynq SPI interface. (Shell command.)
 */
void scmd_zynq_spi_test()
{
    int state, j, i = 0;
    
    if(!(sys_state.flags & FLAG_ZYNQ_ON)) {
        uart_putsraw("Zynq not powered on!\r\n");
        return;
    }
    
    // SPI SS is active low, but this causes 4mA continuous current flow into ESD
    // diodes via current limiting resistors.  Will flip polarity on PL later.
    // Turn on CS now, before starting transactions, etc.
    GPIO_FAST_SET_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    
    //uint8_t test_msg1[] = { 0x00, 0x55 };
    //uint8_t test_msg2[] = { 0x01 };
    
    uint8_t test_args[] = { 0x00, 0x00, 0x7f, 0xff, 0x00, 0x00, 0x7f, 0xff, 0x01, 0x00, 0x00, 0x00, 0x80 };
    
    uart_putsraw("Starting Zynq SPI test, press a key to abort\r\n");
    uart_flush();
    
    while(1) {
        state = 0;
        
        for(j = 0; j < 180; j++) {
            zynq_command_transmit(0x10, 13, (uint8_t*)&test_args);
            test_args[0] = i;
            test_args[1] = i;
            
            if(state)
                HAL_GPIO_WritePin(LED_3_PORT, LED_3_PIN, GPIO_PIN_SET);
            else
                HAL_GPIO_WritePin(LED_3_PORT, LED_3_PIN, GPIO_PIN_RESET);
            
            state = ~state;
            
            //uart_printf("%d ", j);
            i++;
        }
        
        systick_wait(10);
            
        if(uart_char_is_available()) {
            break;
        }
        
        //arb_delay(400);
    }
    
    uart_putsraw("Ends\r\n");
}
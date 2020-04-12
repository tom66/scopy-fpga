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

#ifndef ___ZYNQ_SPI_H___
#define ___ZYNQ_SPI_H___

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>

#include "hal.h"

#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_spi.h"
#include "stm32f0xx_hal_rcc.h"

#define SPI_WORD_WRITE(x)       { zynq_spi.Instance->DR = *((uint16_t *)(x)); }

#define SPI_BYTE_WRITE(x)       { *((__IO uint8_t *)&zynq_spi.Instance->DR) = (x); }
#define SPI_BYTE_READ(x)        ( *((__IO uint8_t *)&zynq_spi.Instance->DR) )

extern SPI_HandleTypeDef zynq_spi;

void zynq_spi_init(void);
void zynq_command_transmit(uint8_t command, uint8_t nargs, uint8_t *args);
void zynq_command_transmit_with_response(uint8_t command, uint8_t nargs, uint8_t *args);
void scmd_zynq_spi_test(void);

/*
 * Fast transmit with discard read.  CS is not driven.
 */
static void inline zynq_spi_transmit_no_read_crc_end(uint8_t *data, uint32_t size)
{
    while(size > 0) {
        if(!((zynq_spi.Instance->SR & SPI_FLAG_FTLVL) & SPI_FTLVL_HALF_FULL)) {
            /* if(size >= 2) {
                //zynq_spi.Instance->DR = *((uint16_t *)data);
                SPI_WORD_WRITE(data);
                data += 2;
                size -= 2;
            } else */ {
                //GPIO_FAST_CLR_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
                SPI_BYTE_WRITE(*data++);
                
                //while(zynq_spi.Instance->SR & SPI_FLAG_BSY) ;
                
                if(size == 1) {
                    // Send CRC using the hardware CRC generator.
                    zynq_spi.Instance->CR1 |= SPI_CR1_CRCNEXT;
                }
                
                //GPIO_FAST_SET_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
                size--;
            }
        }
    }
}

/*
 * Fast byte transmit with byte read.  CS is not driven.
 */
static uint8_t inline zynq_spi_byte_txrx(uint8_t tx)
{
    uint8_t byte;
    
    while(zynq_spi.Instance->SR & SPI_FTLVL_FULL) ;
    
    //GPIO_FAST_CLR_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    SPI_BYTE_WRITE(tx);
    byte = SPI_BYTE_READ();
    
    //GPIO_FAST_SET_PINDEF(FPGA_CSN_3V3_PORT, FPGA_CSN_3V3_PIN);
    return byte;
}

#endif // ___ZYNQ_SPI_H___

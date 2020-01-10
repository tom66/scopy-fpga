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

#ifndef ___HMCAD151X_H___
#define ___HMCAD151X_H___

#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_usart.h"
#include "stm32f0xx_hal_rcc.h"

#include <stdint.h>
#include <stdbool.h>

#define HMC_DELAY_BIT_CYCLE()   { __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); \
                                  __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); \
                                  __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); \
                                  __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); __asm__("nop"); }

#define HMC_RSTN_PORT           GPIOA
#define HMC_RSTN_PIN            0

#define HMC_PDN_PORT            GPIOF
#define HMC_PDN_PIN             3
                                  
#define HMC_CSN_PORT            GPIOF
#define HMC_CSN_PIN             2          
                                  
#define HMC_SDATA_PORT          GPIOC
#define HMC_SDATA_PIN           3
                                                                     
#define HMC_SCLK_PORT           GPIOC
#define HMC_SCLK_PIN            2  

#define HMC_TEST_OFF            0
#define HMC_TEST_COUNTER        1
#define HMC_TEST_ALTERNATE_WORD 2
#define HMC_TEST_SINGLE_WORD    3
#define HMC_TEST_DESKEW         4
#define HMC_TEST_SYNC           5  

#define HMC_AD_INPUT1           0x01
#define HMC_AD_INPUT2           0x02
#define HMC_AD_INPUT3           0x04
#define HMC_AD_INPUT4           0x08

struct hmcad151x_state_t {
    // LVDS current for clock, frame and data pairs in mA.  Range 0-7 with a 0.5mA offset.
    uint8_t clock_curr_lvds, frame_curr_lvds, data_curr_lvds;
    
    // Termination settings for clock, frame and data pairs as an index.
    uint8_t clock_term_lvds, frame_term_lvds, data_term_lvds;
    
    // LVDS advance/delay and phase settings
    int8_t lvds_advance_delay;      // -1 = delay, 0 = neutral, 1 = advance
    uint8_t lvds_phase;             // phases as specified in HMCAD151x datasheet 
    
    // Channel input settings for each ADC
    uint8_t adc_input[4];
};

extern struct hmcad151x_state_t hmcad151x_state;
extern const uint16_t hmcad_lvds_term_lut[];
extern const float hmcad_lvds_current_lut[];

/*
 * Function prototypes
 */
void hmcad151x_init();
void hmcad151x_write_reg(uint8_t reg, uint16_t data);
void hmcad151x_test_mode(uint32_t mode, uint16_t word);
void hmcad151x_sync_lvds_settings();
void hmcad151x_sync_channel_settings();

#endif // ___HMCAD151X_H___

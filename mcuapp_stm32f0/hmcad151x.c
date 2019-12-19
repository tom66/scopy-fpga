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

#include "hmcad151x.h"
#include "hal.h"

/*
 * hmcad151x_init:  Initialise hmcad151x ADC.
 */
void hmcad151x_init()
{
    uint8_t test_byte = 0x00;
    uint32_t n = 0;
    
    // Prepare all IOs and default states
    gpio_set_output(HMC_PDN_PORT, 1 << HMC_PDN_PIN);
    gpio_set_output(HMC_RSTN_PORT, 1 << HMC_RSTN_PIN);
    gpio_set_output(HMC_CSN_PORT, 1 << HMC_CSN_PIN);
    gpio_set_output(HMC_SDATA_PORT, 1 << HMC_SDATA_PIN);
    gpio_set_output(HMC_SCLK_PORT, 1 << HMC_SCLK_PIN);
    
    // Enable power supply to ADC
    adc_power_on();
    systick_wait(5);
    
    // init ports in default state
    GPIO_FAST_CLR_PIN(HMC_PDN_PORT, HMC_PDN_PIN);
    GPIO_FAST_SET_PIN(HMC_RSTN_PORT, HMC_RSTN_PIN);
    GPIO_FAST_SET_PIN(HMC_CSN_PORT, HMC_CSN_PIN);
    GPIO_FAST_CLR_PIN(HMC_SDATA_PORT, HMC_SDATA_PIN);
    GPIO_FAST_CLR_PIN(HMC_SCLK_PORT, HMC_SCLK_PIN);
    systick_wait(1);
    
    // Send RESETN and PDN pulse to HMCAD ADC
    // per page 8 of datasheet, RESETN must pulse min. 20ns low to correctly reset ...
    GPIO_FAST_CLR_PIN(HMC_RSTN_PORT, HMC_RSTN_PIN);
    arb_delay(200);
    GPIO_FAST_SET_PIN(HMC_RSTN_PORT, HMC_RSTN_PIN);
    
    // ... and PD must pulse min. 20ns high to correctly reset
    GPIO_FAST_SET_PIN(HMC_PDN_PORT, HMC_PDN_PIN);
    arb_delay(200);
    GPIO_FAST_CLR_PIN(HMC_PDN_PORT, HMC_PDN_PIN);
    
    uart_printf("hmcad151x: reset complete\r\n");
    
    // single channel mode, clock divided /1
    hmcad151x_write_reg(0x31, 0x01 | (0x00 << 8));
    
    // VCM enabled with 700uA sink/source
    hmcad151x_write_reg(0x50, 0x03 << 4);
    
    // disable low clock frequency mode, no LVDS advance, no LVDS delay
    hmcad151x_write_reg(0x53, 0);
    
    // write test patterns
    hmcad151x_write_reg(0x25, (1 << 6));  // for counter mode
    
    // minimum clock jitter (all buffers enabled)
    hmcad151x_write_reg(0x30, 0x000f);
    
    // LVDS drive at default 3.5mA for data, LCLK, and FCLK
    hmcad151x_write_reg(0x11, 0x0000);
    
    // LVDS drive at 7.5mA for data, LCLK, and FCLK
    //hmcad151x_write_reg(0x11, 0x0444);
    
    // LVDS phase: change from default configuration to ISERDESE2 supported config (data changes on clock edge)
    hmcad151x_write_reg(0x42, (0 << 5) | (0 << 6));

    // LVDS advance: set
    //hmcad151x_write_reg(0x53, (1 << 4));
    
    // termination bits enable terminators: 260 ohm, 150 ohm and 125 ohm, +/-20% tolerance
    // bit pattern can enable each termination as required to create total required termination. 
    // these are all disabled for now
    hmcad151x_write_reg(0x12, 0x0000);
    
    uart_printf("hmcad151x: register write complete\r\n");
}

/*
 * hmcad151x_write_reg:  Write an 8-bit register address with 16-bit data.
 */
void hmcad151x_write_reg(uint8_t reg, uint16_t data)
{
    uint32_t packet = (reg << 16) | data;
    int32_t n;
    
    // drive CSN low for two bit cycles
    GPIO_FAST_CLR_PIN(HMC_CSN_PORT, HMC_CSN_PIN);
    HMC_DELAY_BIT_CYCLE();
    HMC_DELAY_BIT_CYCLE();
    
    // drive 24 bits data output
    for(n = 23; n >= 0; --n) {
        // drive data bit
        if(!!(packet & (1 << n))) {
            GPIO_FAST_SET_PIN(HMC_SDATA_PORT, HMC_SDATA_PIN);
        } else {
            GPIO_FAST_CLR_PIN(HMC_SDATA_PORT, HMC_SDATA_PIN);
        }
        
        // toggle clock
        GPIO_FAST_CLR_PIN(HMC_SCLK_PORT, HMC_SCLK_PIN);
        HMC_DELAY_BIT_CYCLE();
        GPIO_FAST_SET_PIN(HMC_SCLK_PORT, HMC_SCLK_PIN);
        HMC_DELAY_BIT_CYCLE();
    }
    
    // return CSN high
    HMC_DELAY_BIT_CYCLE();
    HMC_DELAY_BIT_CYCLE();
    GPIO_FAST_SET_PIN(HMC_CSN_PORT, HMC_CSN_PIN);
    HMC_DELAY_BIT_CYCLE();
    HMC_DELAY_BIT_CYCLE();
    
    // return SDATA/SCLK high
    GPIO_FAST_SET_PIN(HMC_SDATA_PORT, HMC_SDATA_PIN);
    GPIO_FAST_SET_PIN(HMC_SCLK_PORT, HMC_SCLK_PIN);
    HMC_DELAY_BIT_CYCLE();
    HMC_DELAY_BIT_CYCLE();
}
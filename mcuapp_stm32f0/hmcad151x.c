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

// LUT to convert LVDS current to ADC setting
const uint8_t hmcad_lvds_current_index[] = {
    3, // 0.5mA
    2, // 1.5mA
    1, // 2.5mA
    0, // 3.5mA
    7, // 4.5mA
    6, // 5.5mA
    5, // 6.5mA
    4, // 7.5mA
};

// LUT to convert LVDS termination setting to resistance
const uint16_t hmcad_lvds_term_lut[] = {
    49999,
    260,
    150,
    94,
    125,
    80,
    66,
    55
};

// LUT to convert LVDS drive current setting to actual current
const float hmcad_lvds_current_lut[] = {
    0.5f,
    1.5f,
    2.5f,
    3.5f,
    4.5f,
    5.5f,
    6.5f,
    7.5f
};


struct hmcad151x_state_t hmcad151x_state;

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
    
    // minimum clock jitter (all buffers enabled)
    hmcad151x_write_reg(0x30, 0x000f);
    
    // slow start up mode
    hmcad151x_write_reg(0x56, 0x0003);
    
    // For now, set full scale range at +/-0% adjust
    hmcad151x_write_reg(0x55, 0x0020);
    
    // For now, set ADC current control to nominal and VCM drive strength to +/-0.7mA
    hmcad151x_write_reg(0x50, 0x0030);
    
    // set default LVDS and bus parameters and write these to the ADC
    // these values can change to alter the performance of the ADC LVDS bus e.g. if overclocking
    hmcad151x_state.clock_curr_lvds = 3;    // default 3.5mA
    hmcad151x_state.frame_curr_lvds = 3;    // default 3.5mA
    hmcad151x_state.data_curr_lvds = 3;     // default 3.5mA
    hmcad151x_state.clock_term_lvds = 0;    // default no termination
    hmcad151x_state.frame_term_lvds = 0;    // default no termination
    hmcad151x_state.data_term_lvds = 0;     // default no termination
    hmcad151x_state.data_term_lvds = 0;     // default no termination
    hmcad151x_state.lvds_advance_delay = 0; // default no advance/delay
    hmcad151x_state.lvds_phase = 0;         // default phasing
    hmcad151x_sync_lvds_settings();
    
    // Set default channel settings for ADC: all connected to CH4
    hmcad151x_state.adc_input[0] = HMC_AD_INPUT4;
    hmcad151x_state.adc_input[1] = HMC_AD_INPUT4;
    hmcad151x_state.adc_input[2] = HMC_AD_INPUT4;
    hmcad151x_state.adc_input[3] = HMC_AD_INPUT4;
    hmcad151x_sync_channel_settings();
    
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
    
    uart_printf("hmcad151x: write 0x%04x to 0x%02x\r\n", data, reg);
}

/* 
 * hmcad151x_test_mode:  Select one of several test options (see HMC_TEST_x).  For options
 * HMC_TEST_ALTERNATE_WORD and HMC_TEST_SINGLE_WORD: pass two 8-bit values packed in `word`
 * for alternate and a single 8-bit word LSB-packed in `word` for single.
 *
 * Note:  ADC test mode should be disabled for channel inputs to work correctly.
 */
void hmcad151x_test_mode(uint32_t mode, uint16_t word)
{
    switch(mode) {
        default:
        case HMC_TEST_OFF:
            hmcad151x_write_reg(0x25, 0x0000);
            hmcad151x_write_reg(0x26, 0x0000);
            hmcad151x_write_reg(0x27, 0x0000);
            hmcad151x_write_reg(0x45, 0x0000);
            break;
        
        case HMC_TEST_COUNTER:
            hmcad151x_write_reg(0x25, 0x0040);
            hmcad151x_write_reg(0x26, 0x0000);
            hmcad151x_write_reg(0x27, 0x0000);
            hmcad151x_write_reg(0x45, 0x0000);
            break;
        
        case HMC_TEST_ALTERNATE_WORD:
            hmcad151x_write_reg(0x25, 0x0020);
            hmcad151x_write_reg(0x26, (word & 0xff00));
            hmcad151x_write_reg(0x27, (word & 0x00ff) << 8);
            hmcad151x_write_reg(0x45, 0x0000);
            break;
        
        case HMC_TEST_SINGLE_WORD:
            // This mode could also be implemented as dual custom pattern with both words
            // identical.  Not sure why ADI provide this option - may be legacy.
            hmcad151x_write_reg(0x25, 0x0010);
            hmcad151x_write_reg(0x26, (word & 0x00ff) << 8);
            hmcad151x_write_reg(0x27, 0x0000);
            hmcad151x_write_reg(0x45, 0x0000);
            break;
        
        case HMC_TEST_DESKEW:
            // This seems to be the same as writing 0x55 to the single test mode
            hmcad151x_write_reg(0x25, 0x0000);
            hmcad151x_write_reg(0x26, 0x0000);
            hmcad151x_write_reg(0x27, 0x0000);
            hmcad151x_write_reg(0x45, 0x0001);
            break;
        
        case HMC_TEST_SYNC:
            // This seems to be the same as writing 0xf0 to the single test mode
            hmcad151x_write_reg(0x25, 0x0000);
            hmcad151x_write_reg(0x26, 0x0000);
            hmcad151x_write_reg(0x27, 0x0000);
            hmcad151x_write_reg(0x45, 0x0002);
            break;
    }
}

/*
 * hmcad151x_sync_lvds_settings:  Syncs the current LVDS settings (drive current, termination,
 * advance/delay and phase) to the ADC.
 */
void hmcad151x_sync_lvds_settings()
{
    uint8_t clock, frame, data, term = 0;
    
    // write LVDS drive current settings
    clock = hmcad_lvds_current_index[hmcad151x_state.clock_curr_lvds] & 7;
    frame = hmcad_lvds_current_index[hmcad151x_state.frame_curr_lvds] & 7;
    data = hmcad_lvds_current_index[hmcad151x_state.data_curr_lvds] & 7;
    
    hmcad151x_write_reg(0x11, clock | (frame << 4) | (data << 8));
    
    // write LVDS termination settings
    clock = hmcad151x_state.clock_term_lvds & 7;
    frame = hmcad151x_state.frame_term_lvds & 7;
    data = hmcad151x_state.data_term_lvds & 7;
    
    if(clock > 0 || frame > 0 || data > 0)
        term = 1;
    
    hmcad151x_write_reg(0x12, clock | (frame << 4) | (data << 8) | (term << 14));
    
    // write LVDS advance/delay setting
    if(hmcad151x_state.lvds_advance_delay == -1) {
        hmcad151x_write_reg(0x53, (1 << 5));
    } else if(hmcad151x_state.lvds_advance_delay == +1) {
        hmcad151x_write_reg(0x53, (1 << 4));
    } else {
        hmcad151x_write_reg(0x53, 0x00);
    }
    
    // write the LVDS phase setting
    hmcad151x_write_reg(0x42, (hmcad151x_state.lvds_phase & 3) << 5);
}

/*
 * hmcad151x_sync_channel_settings:  Syncs the current channel settings to the ADC.
 * Run this after the ADC channel state is changed.
 */
void hmcad151x_sync_channel_settings()
{
    uint8_t adc_input[4];
    uint32_t i;
    
    // Write channel multiplex signals.  Only permit one bit to be set at once.
    for(i = 0; i < 4; i++) {
        adc_input[i] = hmcad151x_state.adc_input[i] & 0x0f;
        if(__builtin_popcount(adc_input[i]) > 1) {
            adc_input[i] = 0; // Disable all input if multiple inputs asserted
            uart_printf("WARN(hmcad): Multiple channels enabled #%d, disabling all\r\n", i);
        }
    }
    
    hmcad151x_write_reg(0x3a, (adc_input[0] << 1) | (adc_input[1] << 9));
    hmcad151x_write_reg(0x3b, (adc_input[2] << 1) | (adc_input[3] << 9));
}

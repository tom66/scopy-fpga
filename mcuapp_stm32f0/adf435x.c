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
 
/*
 * Driver layer to interface with ADF435x devices.  A bit-bang method is used
 * to write the registers of the device. 
 */

// Driver layer
#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_usart.h"
#include "stm32f0xx_hal_rcc.h"

// Local includes
#include "adf435x.h"
#include "hal.h"

// State of ADF435x chip
struct adf435x_state_t adf435x_state;

struct adf435x_config_t adf_configs[ADF_NUM_CONFIGS] = {
    {
        ._int = 25,
        .frac = 3,
        .phase = 0,
        .mod = 5,
        .rfdiv = ADF_RFDIV_64,
        .charge_pump = 8,       // 2.50
        .r_counter = 1,
        .bandsel = 200,
        .flags = (ADF_FLG_PRESCALER_8_9 | ADF_FLG_LDP_10NS | ADF_FLG_PD_POL_POS | ADF_FLG_AUX_FUNDAMENTAL | ADF_FLG_LD_PIN_DIG)
    }
};

/*
 * adf435x_init:  Initialise the ADF435x driver.
 */
void adf435x_init()
{
    volatile uint32_t n;
    
    // Switch on device power and wait a few ms for 3V3_PLL rail to come up.
    pll_power_on();
    systick_wait(5);
    
    // Setup GPIO
    gpio_set_output(ADF435X_CLK_PORT, 1 << ADF435X_CLK_PIN);
    gpio_set_output(ADF435X_DAT_PORT, 1 << ADF435X_DAT_PIN);
    gpio_set_output(ADF435X_LE_PORT, 1 << ADF435X_LE_PIN);
    gpio_set_output(ADF435X_CE_PORT, 1 << ADF435X_CE_PIN);
    
    // Drive CE high to activate device
    GPIO_FAST_SET_PIN(ADF435X_CE_PORT, ADF435X_CE_PIN);
    
    // Set initial state
    adf435x_state.r0 = (72 << _ADF435X_R0_INT_SHIFT) | (0 << _ADF435X_R0_FRAC_SHIFT);
    
    adf435x_state.r1 =  ADF435X_R1_PRESCALER_8_9 | (0 << _ADF435X_R1_PHASE_SHIFT) | \
                       (2 << _ADF435X_R1_MOD_SHIFT);
    
    adf435x_state.r2 =  ADF435X_R2_LDF_FRAC_N | ADF435X_R2_LDP_10NS | 
                       (ADF435X_R2_MUX_3STATE << _ADF435X_R2_MUX_SHIFT) |
                        ADF435X_R2_PD_POL_POS | ADF435X_R2_POWERDOWN_DIS | 
                        ADF435X_R2_DOUBLE_BUFF_DIS | (0 << _ADF435X_R2_CHARGEPUMP_SHIFT) | 
                        ADF435X_R2_CP_3STATE_DIS | ADF435X_R2_CP_CTR_RESET_DIS |
                       (1 << _ADF435X_R2_RCOUNTER_SHIFT);
    
    adf435x_state.r3 =  ADF435X_R3_BAND_SEL_LOW | ADF435X_R3_CYCLE_SLIP_RED_DIS | 
                        ADF435X_R3_CHARGE_CANCEL_DIS | ADF435X_R3_ANTIBACKLASH_6NS |
                        ADF435X_R3_CLOCK_DIV_OFF | (0 << _ADF435X_R3_CLOCK_DIV_VAL_SHIFT);
    
    adf435x_state.r4 = (ADF435X_R4_RF_POWER_POS_5DBM << _ADF435X_R4_RF_POWER_SHIFT) |
                        ADF435X_R4_RF_OUT_ENABLED |
                       (ADF435X_R4_AUX_POWER_POS_5DBM << _ADF435X_R4_AUX_POWER_SHIFT) |
                        ADF435X_R4_AUX_OUT_ENABLED | ADF435X_R4_MUTE_DISABLED | 
                        ADF435X_R4_VCO_POWERED_UP | ADF435X_R4_AUX_FUNDAMENTAL | 
                        ADF435X_R4_RFDIV_SEL_64 | (200 << _ADF435X_R4_BSEL_CLK_DIV_SHIFT) |
                        ADF435X_R4_FBACK_FUNDAMENTAL;
    
    adf435x_state.r5 = ADF435X_R5_LD_PIN_DIGITAL | ADF435X_R5_RESV_2_BITS;
    
    adf435x_state.r4 = 0xEC83FC;
    
    /*
    // 50MHz output
    adf435x_state.r0 = 0x400000;
    adf435x_state.r1 = 0x8008011;
    adf435x_state.r2 = 0x4e42;
    adf435x_state.r3 = 0x4b3;
    adf435x_state.r4 = 0xec803c;
    adf435x_state.r5 = 0x580005;
    adf435x_sync();
    */
    
    // 160MHz output
    /*
    adf435x_state.r0 = 0x330010;
    adf435x_state.r1 = 0x8008029;
    adf435x_state.r2 = 0x4e42;
    adf435x_state.r3 = 0x4b3;
    adf435x_state.r4 = 0xcc803c;
    adf435x_state.r5 = 0x580005;
    adf435x_sync();
    */
    
    /*
    // 1GHz output
    adf435x_state.r0 = 0x500000;
    adf435x_state.r1 = 0x8008011;
    adf435x_state.r2 = 0x4e42;
    adf435x_state.r3 = 0x4b3;
    adf435x_state.r4 = 0xac803c;
    adf435x_state.r5 = 0x580005;
    adf435x_sync();
    */
    
    // 500MHz output
    adf435x_state.r0 = 0x500000;
    adf435x_state.r1 = 0x8008011;
    adf435x_state.r2 = 0x4e42;
    adf435x_state.r3 = 0x4b3;
    adf435x_state.r4 = 0xbc803c;
    adf435x_state.r5 = 0x580005;
    adf435x_sync();
    
    /*
    // ramp output
    adf435x_state.r0 = 0x500000;
    adf435x_state.r1 = 0x8008011;
    adf435x_state.r2 = 0x4e42;
    adf435x_state.r3 = 0x4b3;
    adf435x_state.r4 = 0x9c803c;
    adf435x_state.r5 = 0x580005;
    adf435x_sync();
    
    n = 60;
    
    while(1) {
        adf435x_state.r0 = (n << _ADF435X_R0_INT_SHIFT) | (0 << _ADF435X_R0_FRAC_SHIFT);
        adf435x_sync();
        systick_wait(1200);
        n++;
        
        uart_printf("adf435x: n=%d, computed freq=%2.2f MHz\r\n", n, (n * 25) / 2.0f);
        
        if(n > 200) {
            n = 80;
        }
    }
    */
    
    // Sync initial data with ADF435x
    /*
    while(1) {
        adf435x_sync();
        //for(n = 10000; n > 0; n--) ;
        //while(1) ;
    }
    */
    
    adf435x_sync();
    
    uart_putsraw("adf435x: ready\r\n");
}

/*
 * adf435x_write_out:  Shift out 32-bit data on our write port.
 */
void adf435x_write_out(uint32_t data)
{
    uint32_t n, mask;
    
    // LE goes low during transaction, CLK starts low.
    GPIO_FAST_CLR_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
    GPIO_FAST_SET_PIN(ADF435X_LE_PORT, ADF435X_LE_PIN);
    ADF345X_DELAY_BIT_CYCLE();
    GPIO_FAST_CLR_PIN(ADF435X_LE_PORT, ADF435X_LE_PIN);
    ADF345X_DELAY_BIT_CYCLE();
    
    // Clock bits in MSB - LSB order
    // Bits are asserted when clock is low, and read by ADF435x when clock falls.
    for(n = 32, mask = 0x80000000; n > 0; mask >>= 1, n--) {
        GPIO_FAST_CLR_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
        if(mask & data) {
            GPIO_FAST_SET_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
        } else {
            GPIO_FAST_CLR_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
        }
        ADF345X_DELAY_BIT_CYCLE();
        GPIO_FAST_SET_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
        ADF345X_DELAY_BIT_CYCLE();
    }
    
    // Drive LE high to latch data, ensure CLK & DAT returns low.
    GPIO_FAST_CLR_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
    ADF345X_DELAY_BIT_CYCLE();
    GPIO_FAST_SET_PIN(ADF435X_LE_PORT, ADF435X_LE_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
}

/*
 * adf435x_write_reg:  Write register data to register index to ADF435x.
 */
void adf435x_write_reg(uint32_t data, uint32_t reg)
{
    uint32_t packet = (data & _ADF435X_REG_DATA_MASK) | (reg & _ADF435X_REG_CTRL_BITS_MASK);
    
    //uart_printf("adf435x: write register %d: 0x%08x (29-bit: 0x%08x)\r\n", reg, packet, packet >> 3);
    
    adf435x_write_out(packet);
}

/*
 * adf435x_sync:  Sync state to ADF435x device.
 */
void adf435x_sync()
{
    adf435x_write_reg(adf435x_state.r5, ADF435X_R5);
    adf435x_write_reg(adf435x_state.r4, ADF435X_R4);
    adf435x_write_reg(adf435x_state.r3, ADF435X_R3);
    adf435x_write_reg(adf435x_state.r2, ADF435X_R2);
    adf435x_write_reg(adf435x_state.r1, ADF435X_R1);
    adf435x_write_reg(adf435x_state.r0, ADF435X_R0);
}

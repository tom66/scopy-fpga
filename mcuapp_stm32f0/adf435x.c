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

#include <stdint.h>
#include <string.h>
#include <math.h>

// Driver layer
#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_usart.h"
#include "stm32f0xx_hal_rcc.h"

// Local includes
#include "shell.h"
#include "adf435x.h"
#include "hal.h"

// State of ADF435x chip
struct adf435x_state_t adf435x_state;

struct adf435x_config_t adf_configs[] = {
    // blank entry - customisable
    { 0 },
    // 100MHz ADC clock (Continuous Acquisition, No Trigger)
    {
        .short_name = "100M_ContAcq",
        ._int = 128,
        .frac = 0,
        .phase = 0,
        .mod = 250,
        .rfdiv = ADF_RFDIV_32,
        .charge_pump = 8,
        .r_counter = 1,
        .bandsel = 1,
        .flags = (ADF_FLG_PRESCALER_8_9 | ADF_FLG_LDP_10NS | ADF_FLG_PD_POL_POS)
    },
    // 160MHz ADC clock (14-Bit Mode)
    {
        .short_name = "160M_Precision",
        ._int = 102,
        .frac = 100,
        .phase = 0,
        .mod = 250,
        .rfdiv = ADF_RFDIV_16,
        .charge_pump = 8,
        .r_counter = 1,
        .bandsel = 1,
        .flags = (ADF_FLG_PRESCALER_8_9 | ADF_FLG_LDP_10NS | ADF_FLG_PD_POL_POS)
    },
    // 500MHz ADC clock (12-Bit Mode)
    {
        .short_name = "500M_HighRes",
        ._int = 160,
        .frac = 0,
        .phase = 0,
        .mod = 250,
        .rfdiv = ADF_RFDIV_8,
        .charge_pump = 8,
        .r_counter = 1,
        .bandsel = 1,
        .flags = (ADF_FLG_PRESCALER_8_9 | ADF_FLG_LDP_10NS | ADF_FLG_PD_POL_POS)
    },
    // 1GHz ADC clock (8-Bit Mode)
    {
        .short_name = "1G_NormRes",
        ._int = 160,
        .frac = 0,
        .phase = 0,
        .mod = 250,
        .rfdiv = ADF_RFDIV_4,
        .charge_pump = 8,
        .r_counter = 1,
        .bandsel = 1,
        .flags = (ADF_FLG_PRESCALER_8_9 | ADF_FLG_LDP_10NS | ADF_FLG_PD_POL_POS)
    },
    // 1.15GHz ADC clock (8-Bit Mode) - Overclocked
    {
        .short_name = "1150M_Overclocked",
        ._int = 92,
        .frac = 0,
        .phase = 0,
        .mod = 250,
        .rfdiv = ADF_RFDIV_2,
        .charge_pump = 8,
        .r_counter = 1,
        .bandsel = 1,
        .flags = (ADF_FLG_PRESCALER_8_9 | ADF_FLG_LDP_10NS | ADF_FLG_PD_POL_POS)
    },
    // Terminating config
    {
        .short_name = "",
    }
};

const uint8_t adf_rf_dividers[] = {1, 2, 4, 8, 16, 32, 64};

/*
 * adf435x_init:  Initialise the ADF435x driver.
 */
void adf435x_init()
{
    volatile uint32_t n;
    float freq;
    
    // Switch on device power and wait a few ms for 3V3_PLL rail to come up.
    pll_power_on();
    systick_wait(5);
    
    // Setup GPIO
    gpio_set_output(ADF435X_CLK_PORT, 1 << ADF435X_CLK_PIN);
    gpio_set_output(ADF435X_DAT_PORT, 1 << ADF435X_DAT_PIN);
    gpio_set_output(ADF435X_LE_PORT, 1 << ADF435X_LE_PIN);
    gpio_set_output(ADF435X_CE_PORT, 1 << ADF435X_CE_PIN);
    gpio_set_output(ADF435X_PD_PORT, 1 << ADF435X_PD_PIN);
    
    GPIO_FAST_CLR_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_LE_PORT, ADF435X_LE_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_CE_PORT, ADF435X_CE_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_PD_PORT, ADF435X_PD_PIN);
    
    // Drive CE high to activate device after a short wait
    systick_wait(2);
    GPIO_FAST_SET_PIN(ADF435X_CE_PORT, ADF435X_CE_PIN);
    
    // Load default configuration, set default power output and sync but RF remains OFF.
    adf435x_load_config(&adf_configs[1]);
    adf435x_rf_off();
    adf435x_set_power_level(ADF_POWER_POS_5DBM);
}

/*
 * adf435x_shutdown:  Turn off ADF435X, ensuring the lowest power state for this block.
 * Configuration will need to be rewritten when power is restored.
 */
void adf435x_shutdown()
{
    pll_power_off();
    
    // Ensure all GPIOs go low so we don't backfeed the PLL
    GPIO_FAST_CLR_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_LE_PORT, ADF435X_LE_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_CE_PORT, ADF435X_CE_PIN);
    GPIO_FAST_CLR_PIN(ADF435X_PD_PORT, ADF435X_PD_PIN);
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
        if(mask & data) {
            GPIO_FAST_SET_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
        } else {
            GPIO_FAST_CLR_PIN(ADF435X_DAT_PORT, ADF435X_DAT_PIN);
        }
        GPIO_FAST_CLR_PIN(ADF435X_CLK_PORT, ADF435X_CLK_PIN);
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
    
    // uart_printf("adf435x: write register %d: 0x%08x (29-bit: 0x%08x)\r\n", reg, packet, packet >> 3);
    
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

/*
 * adf435x_sync_rf_power_state:  Restores current RF on/off and power state
 * to the ADF435x registers.
 */
void adf435x_sync_rf_power_state()
{
    adf435x_set_power_level(adf435x_state.power_level);
    
    if(adf435x_state.state_flags & ADF_STATE_RF_ON) {
        adf435x_rf_on();
    } else {
        adf435x_rf_off();
    }
}

/*
 * adf435x_load_config:  Load a configuration passed by pointer.  Configuration
 * is NOT synced until adf435x_sync() is called.
 *
 * @param   config  
 */
void adf435x_load_config(struct adf435x_config_t *cfg)
{    
    // Load primary configuration values
    adf435x_state.r0 = ((cfg->_int & 65535) << _ADF435X_R0_INT_SHIFT) | 
                       ((cfg->frac & 4095) << _ADF435X_R0_FRAC_SHIFT);
    
    adf435x_state.r1 = ((cfg->phase & 4095) << _ADF435X_R1_PHASE_SHIFT) | \
                       ((cfg->mod & 4095) << _ADF435X_R1_MOD_SHIFT);
    
    adf435x_state.r2 =  ADF435X_R2_LOW_NOISE_MODE | ADF435X_R2_LDF_FRAC_N | ADF435X_R2_LDP_10NS | 
                       (ADF435X_R2_MUX_3STATE << _ADF435X_R2_MUX_SHIFT) |
                        ADF435X_R2_PD_POL_POS | ADF435X_R2_POWERDOWN_DIS | 
                        ADF435X_R2_DOUBLE_BUFF_DIS | ((cfg->charge_pump & 15) << _ADF435X_R2_CHARGEPUMP_SHIFT) | 
                        ADF435X_R2_CP_3STATE_DIS | ADF435X_R2_CP_CTR_RESET_DIS |
                       ((cfg->r_counter & 1023) << _ADF435X_R2_RCOUNTER_SHIFT);
    
    adf435x_state.r3 = (1 << _ADF435X_R3_CLOCK_DIV_VAL_SHIFT);
    
    // XXX: Band Sel must be set to 255 to allow accurate VCO operation - unsure why.  5/01/20 T.G.O. 
    adf435x_state.r4 =  ADF435X_R4_RF_POWER_NEG_4DBM | ADF435X_R4_RF_OUT_DISABLED | 
                        ADF435X_R4_AUX_POWER_NEG_4DBM | ADF435X_R4_AUX_OUT_DISABLED | 
                        ADF435X_R4_MUTE_DISABLED | ADF435X_R4_VCO_POWERED_UP | ADF435X_R4_AUX_FUNDAMENTAL | 
                        ((cfg->rfdiv & 7) << _ADF435X_R4_RFDIV_SEL_SHIFT) | (0xff << _ADF435X_R4_BSEL_CLK_DIV_SHIFT);
    
    adf435x_state.r5 = ADF435X_R5_LD_PIN_DIGITAL | ADF435X_R5_RESV_2_BITS;
    
    // Add flags as appropriate
    if(cfg->flags & ADF_FLG_PRESCALER_4_5) {
        adf435x_state.r1 |= ADF435X_R1_PRESCALER_4_5;
    } else if(cfg->flags & ADF_FLG_PRESCALER_8_9) {
        adf435x_state.r1 |= ADF435X_R1_PRESCALER_8_9;
    }
    
    if(cfg->flags & ADF_FLG_REF_DOUBLE) {
        adf435x_state.r2 |= ADF435X_R2_REF_DOUBLER;
    } else if(cfg->flags & ADF_FLG_REF_HALF) {
        adf435x_state.r2 |= ADF435X_R2_REF_DIVIDE_BY_2;
    }
    
    if(cfg->flags & ADF_FLG_DOUBLE_BUFF) {
        adf435x_state.r2 |= ADF435X_R2_DOUBLE_BUFF_ENA;
    }
    
    if(cfg->flags & ADF_FLG_LDF_FRAC_N) {
        adf435x_state.r2 |= ADF435X_R2_LDF_FRAC_N;
    } else if(cfg->flags & ADF_FLG_LDF_INT_N) {
        adf435x_state.r2 |= ADF435X_R2_LDF_INT_N;
    }
    
    if(cfg->flags & ADF_FLG_LDP_10NS) {
        adf435x_state.r2 |= ADF435X_R2_LDP_10NS;
    } else if(cfg->flags & ADF_FLG_LDP_6NS) {
        adf435x_state.r2 |= ADF435X_R2_LDP_6NS;
    }
    
    if(cfg->flags & ADF_FLG_PD_POL_POS) {
        adf435x_state.r2 |= ADF435X_R2_PD_POL_POS;
    } else if(cfg->flags & ADF_FLG_PD_POL_NEG) {
        adf435x_state.r2 |= ADF435X_R2_PD_POL_NEG;
    }
    
    if(cfg->flags & ADF_FLG_POWERDOWN) {
        adf435x_state.r2 |= ADF435X_R2_POWERDOWN_ENA;
    }
    
    if(cfg->flags & ADF_FLG_CP_3STATE) {
        adf435x_state.r2 |= ADF435X_R2_CP_3STATE_ENA;
    }
    
    if(cfg->flags & ADF_FLG_CTR_RESET) {
        adf435x_state.r2 |= ADF435X_R2_CP_CTR_RESET_ENA;
    }
    
    if(cfg->flags & ADF_FLG_BAND_SEL_LOW) {
        adf435x_state.r3 |= ADF435X_R3_BAND_SEL_LOW;
    } else if(cfg->flags & ADF_FLG_BAND_SEL_HIGH) {
        adf435x_state.r3 |= ADF435X_R3_BAND_SEL_HIGH;
    }
    
    if(cfg->flags & ADF_FLG_ANTIBACKLASH) {
        adf435x_state.r3 |= ADF435X_R3_ANTIBACKLASH_3NS;
    }
    
    if(cfg->flags & ADF_FLG_CHARGE_CANCEL) {
        adf435x_state.r3 |= ADF435X_R3_CHARGE_CANCEL_ENA;
    }
    
    if(cfg->flags & ADF_FLG_CYCLE_SLIP_RED) {
        adf435x_state.r3 |= ADF435X_R3_CYCLE_SLIP_RED_ENA;
    }
    
    if(cfg->flags & ADF_FLG_CLOCK_DIV_OFF) {
        adf435x_state.r3 |= ADF435X_R3_CLOCK_DIV_OFF << _ADF435X_R3_CLOCK_DIV_SHIFT;
    } else if(cfg->flags & ADF_FLG_CLOCK_DIV_FASTLOCK) {
        adf435x_state.r3 |= ADF435X_R3_CLOCK_DIV_FASTLOCK << _ADF435X_R3_CLOCK_DIV_SHIFT;
    } else if(cfg->flags & ADF_FLG_CLOCK_DIV_RESYNC) {
        adf435x_state.r3 |= ADF435X_R3_CLOCK_DIV_RESYNC << _ADF435X_R3_CLOCK_DIV_SHIFT;
    }
    
    if(cfg->flags & ADF_FLG_FEEDBACK_DIV) {
        adf435x_state.r4 |= ADF435X_R4_FBACK_DIVIDED;
    } else {
        adf435x_state.r4 |= ADF435X_R4_FBACK_FUNDAMENTAL;
    }
    
    if(cfg->flags & ADF_FLG_MUTE) {
        adf435x_state.r4 |= ADF435X_R4_MUTE_ENABLED;
    }
    
    adf435x_sync();
    adf435x_sync_rf_power_state();
    
    // copy current configuration
    adf435x_state.cfg_curr = *cfg;
    
    // calculate and store output frequency
    adf435x_state.calc_output_freq = adf435x_compute_frequency(cfg->_int, cfg->frac, cfg->mod, adf_rf_dividers[cfg->rfdiv & 7]);
}

/*
 * adf435x_load_config_index:  Load a configuration passed by index.
 *
 * Some bounds checking is done to make sure that the configuration exists;
 * if it doesn't exist no configuration is loaded.
 *
 * @param   config  
 */
void adf435x_load_config_index(uint32_t index)
{
    uint32_t i;
    
    if(index > ADF_MAX_CONFIGS)
        return;
    
    for(i = 1; i < ADF_MAX_CONFIGS; i++) {
        if(i == index)
            break;
        
        // find terminator
        if(strlen(adf_configs[i].short_name) == 0)
            return;
    }
    
    adf435x_load_config(&adf_configs[index]);
}

/*
 * adf435x_rf_on:  Switch on RF output.
 */
void adf435x_rf_on()
{
    adf435x_state.state_flags |= ADF_STATE_RF_ON;
    adf435x_state.r4 |= ADF435X_R4_RF_OUT_ENABLED;
    
    adf435x_sync();
    GPIO_FAST_SET_PIN(ADF435X_PD_PORT, ADF435X_PD_PIN);  // Enable RF output digital control
}

/*
 * adf435x_rf_off:  Switch off RF output.
 */
void adf435x_rf_off()
{
    adf435x_state.state_flags &= ~ADF_STATE_RF_ON;
    adf435x_state.r4 &= ~ADF435X_R4_RF_OUT_ENABLED;
    
    GPIO_FAST_CLR_PIN(ADF435X_PD_PORT, ADF435X_PD_PIN);  // Disable RF output digital control
    adf435x_sync();
}

/*
 * adf435x_set_power_level:  Set RF power level for main output.
 */
void adf435x_set_power_level(uint32_t rf_power)
{
    adf435x_state.r4 &= ~_ADF435X_R4_RF_POWER_MASK;
    adf435x_state.power_level = rf_power;
    
    switch(rf_power) {
        case ADF_POWER_NEG_4DBM:
            adf435x_state.r4 |= ADF435X_R4_RF_POWER_NEG_4DBM;
            break;
        
        case ADF_POWER_NEG_1DBM:
            adf435x_state.r4 |= ADF435X_R4_RF_POWER_NEG_1DBM;
            break;
        
        case ADF_POWER_POS_2DBM:
            adf435x_state.r4 |= ADF435X_R4_RF_POWER_POS_2DBM;
            break;
        
        case ADF_POWER_POS_5DBM:
            adf435x_state.r4 |= ADF435X_R4_RF_POWER_POS_5DBM;
            break;
        
        default:
            adf435x_state.power_level = ADF_POWER_NEG_4DBM;
            adf435x_state.r4 |= ADF435X_R4_RF_POWER_NEG_4DBM;
            break;
    }
    
    adf435x_sync();
}

/*
 * adf435x_change_pll_prop:  Change the PLL properties, syncing the changes.  The
 * configuration in use isn't changed.
 *
 * @param   int
 * @param   frac
 * @param   mod
 * @param   rf_div (from set: ADF_RFDIV_x)
 */
void adf435x_change_pll_prop(uint32_t _int, uint32_t frac, uint32_t mod, uint32_t rf_div)
{
    adf435x_state.r0 = ((_int & 65535) << _ADF435X_R0_INT_SHIFT) | ((frac & 4095) << _ADF435X_R0_FRAC_SHIFT);
    
    adf435x_state.r1 = ((adf435x_state.cfg_curr.phase & 4095) << _ADF435X_R1_PHASE_SHIFT) | \
                       ((mod & 4095) << _ADF435X_R1_MOD_SHIFT);

    if(adf435x_state.cfg_curr.flags & ADF_FLG_PRESCALER_4_5) {
        adf435x_state.r1 |= ADF435X_R1_PRESCALER_4_5;
    } else if(adf435x_state.cfg_curr.flags & ADF_FLG_PRESCALER_8_9) {
        adf435x_state.r1 |= ADF435X_R1_PRESCALER_8_9;
    }
    
    adf435x_state.r4 &= ~_ADF435X_R4_RFDIV_SEL_MASK;
    adf435x_state.r4 |= (rf_div & 7) << _ADF435X_R4_RFDIV_SEL_SHIFT;
    
    adf435x_sync();
    
    adf435x_state.calc_output_freq = adf435x_compute_frequency(_int, frac, mod, adf_rf_dividers[rf_div]);
    adf435x_dump_state();
}
    
/*
 * adf435x_change_frequency:  Change the frequency of the output.  Calculates new 
 * dividers.  The configuration in use isn't changed.
 */
void adf435x_change_frequency(float freq)
{
    uint32_t div, found = 0, freq_div = 1, freq_div_index = 0;
    float freq_scaled, mult = 0.0f, actual_freq, candidate_freq;
    int32_t int_part, frac_part, mod_part;
    
    // Choose a divider to keep the fundamental between 2200 and 4440MHz.  
    for(div = 0; div < sizeof(adf_rf_dividers); div++) {
        freq_scaled = freq * adf_rf_dividers[div];
        
        if(freq_scaled > 2200 && freq_scaled < 4440) {
            freq_div = adf_rf_dividers[div];
            freq_div_index = div;
            found = 1;
            break;
        }
    }
    
    if(!found) {
        shell_error("Unable to find divider for input frequency");
        return;
    }
    
    // uart_printf("adf435x: Chosen divider %d\r\n", freq_div);
    
    // Find integer component for divider
    freq_scaled = freq_div * freq;
    mult = freq_scaled / ADF435X_INPUT_REF_MHZ;
    int_part = (int)mult;
    
    // Find fractional component for divider.  Assume mod is 250.
    mod_part = 250;
    frac_part = (int)((mult - int_part) * mod_part);
    actual_freq = adf435x_compute_frequency(int_part, frac_part, mod_part, freq_div);
    
    // If the frequency isn't exact (+/-100Hz) then try incrementing frac_part by 1 count; 
    // if the error is better then use that value instead.
    if(fabs(actual_freq - freq) > 0.0001) {
        candidate_freq = adf435x_compute_frequency(int_part, frac_part + 1, mod_part, freq_div);
        
        if(fabs(candidate_freq - freq) < fabs(actual_freq - freq)) {
            actual_freq = candidate_freq;
            frac_part++; // Apply our correct guess
        } 
    }
     
    uart_printf("adf435x: Target_freq=%2.4f, INT=%d, FRAC=%d, MOD=%d, Divider=%d [idx=%d], Actual_freq=%2.4f, Error=%2.6f\r\n", \
        freq, int_part, mod_part, frac_part, freq_div, freq_div_index, actual_freq, actual_freq - freq);
    
    adf435x_change_pll_prop(int_part, frac_part, mod_part, freq_div_index);
}
    
/*
 * adf435x_compute_frequency:  Compute the expected frequency given PLL parameters.
 * No sanity checking for reasonable values is done, so these values may not actually
 * produce this output.  However, if the values are within the device's range, then 
 * this calculation will be accurate.
 *
 * @param   int
 * @param   frac
 * @param   mod
 * @param   rf_div (one of: 1, 2, 4, 8, 16, 32, 64)
 * 
 * @return  Frequency in MHz
 */
float adf435x_compute_frequency(uint32_t _int, uint32_t frac, uint32_t mod, uint32_t rfdiv_value)
{
    return ((_int * ADF435X_INPUT_REF_MHZ) + ((frac * ADF435X_INPUT_REF_MHZ) / (float)mod)) / rfdiv_value;
}

/*
 * adf435x_dump_state:  Dump state of ADF435x registers (as in our state memory, may
 * not reflect reality if not synced.)
 */
void adf435x_dump_state()
{
    uart_printf("adf435x: Register dump follows - N.B.: register number OR'd with each register to match ADI ADF435x utility\r\n");
    uart_printf("adf435x: r0=0x%08x\r\n", adf435x_state.r0 | 0x00);
    uart_printf("adf435x: r1=0x%08x\r\n", adf435x_state.r1 | 0x01);
    uart_printf("adf435x: r2=0x%08x\r\n", adf435x_state.r2 | 0x02);
    uart_printf("adf435x: r3=0x%08x\r\n", adf435x_state.r3 | 0x03);
    uart_printf("adf435x: r4=0x%08x\r\n", adf435x_state.r4 | 0x04);
    uart_printf("adf435x: r5=0x%08x\r\n", adf435x_state.r5 | 0x05);
    uart_printf("adf435x: state_flags=0x%08x, calc_out_freq=%2.7f MHz, cfg_name=%s\r\n", \
        adf435x_state.state_flags, adf435x_state.calc_output_freq, adf435x_state.cfg_curr.short_name);
}
    

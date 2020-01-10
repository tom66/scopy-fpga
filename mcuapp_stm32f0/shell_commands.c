/**
 * This file is part of YAOS and licenced under the MIT licence.
 * Copyright (c) 2020 Thomas Oldbury
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
 
#include <stdint.h>
#include <math.h>
#include <ctype.h>

#include "shell_commands.h"
#include "shell.h"
#include "hmcad151x.h"
#include "adf435x.h"
#include "hal.h"

struct shell_command_t shell_commands[] = {
    { "help",      ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_help },
    { "reset",     ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_reset },
    { "volts",     ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_volts }, 
    { "adcpwr",    ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_pwr },
    { "pllpwr",    ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_pll_pwr },
    { "zynqpwr",   ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_zynq_pwr },
    { "raspipwr",  ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_raspi_pwr },
    { "pwroff",    ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_all_off },
    { "pllfreq",   ARG_FLOAT,  ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_pll_freq },         // Set frequency of PLL (calculate N, FRAC, M, RFDIV)
    //{ "pllpar",    ARG_INT,    ARG_INT,    ARG_INT,    ARG_INT,   0 },                    // Set N, FRAC, MOD, RFDIV of PLL directly
    { "plltune",   ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_pll_tune },         // Interactive PLL tuner
    { "pllprof",   ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_pll_profile },      // Load PLL profile
    { "adcreset",  ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_reset },
    { "adctest",   ARG_INT,    ARG_STROPT, ARG_NONE,   ARG_NONE,  &scmd_adc_test },
    { "adcwalk",   ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_walk },
    { "lvdscdrv",  ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_cdrv },    // Set LVDS drive strength in mA for clock
    { "lvdsfdrv",  ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_fdrv },    // Set LVDS drive strength in mA for frame
    { "lvdsddrv",  ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_ddrv },    // Set LVDS drive strength in mA for data
    { "lvdsdrv",   ARG_INT,    ARG_INT,    ARG_INT,    ARG_NONE,  &scmd_adc_lvds_drv },     // Set LVDS drive strength in mA for all
    { "lvdscterm", ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_cterm },   // Select LVDS termination options for clock
    { "lvdsfterm", ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_fterm },   // Select LVDS termination options for frame
    { "lvdsdterm", ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_dterm },   // Select LVDS termination options for data
    { "lvdsterm",  ARG_INT,    ARG_INT,    ARG_INT,    ARG_NONE,  &scmd_adc_lvds_term },    // Select LVDS termination options for all
    { "lvdsadv",   ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_adv },     // Select LVDS advance/delay options
    { "lvdsphas",  ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_phas },    // Select LVDS phase options
    { "lvdsdef",   ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_lvds_def },     // Load LVDS defaults
    //{ "sleep",     ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    //{ "ledon",     ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    //{ "ledoff",    ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    { 0 },
};

/*
 * scmd_help:  Print commands list.  Wrapper function.
 */
void scmd_help()
{
    shell_print_help();
}

/*
 * scmd_reset:  Reset the processor.
 */
void scmd_reset()
{
    zynq_rapid_power_off(); // safer to call this first
    NVIC_SystemReset();
}

/*
 * scmd_volts:  Report the device DC input voltage for diagnostics.
 */
void scmd_volts()
{
    uart_printf("I can feel %2.2f volts coarsing 'cross my heart...\r\n", sys_state.dc_input_mv / 1000.0f);
}

/*
 * scmd_adc_pwr:  Shell command 'adcpwr', boolean argument determines power status.
 */
void scmd_adc_pwr()
{
    uint32_t arg = shell_unpop_int();
    
    if(arg) {
        main_psu_power_on_if_off();
        hmcad151x_init();
        uart_printf("adc: power up\r\n");
    } else {
        adc_power_off();
        uart_printf("adc: power down\r\n");
    }
}

/*
 * scmd_pll_pwr:  Shell command 'pllpwr', boolean argument determines power status.
 */
void scmd_pll_pwr()
{
    uint32_t arg = shell_unpop_int();
    
    if(arg) {
        main_psu_power_on_if_off();
        adf435x_init();
        uart_printf("pll: power up\r\n");
    } else {
        pll_power_off();
        uart_printf("pll: power down\r\n");
    }
}

/*
 * scmd_zynq_pwr:  Shell command 'zynqpwr', boolean argument determines power status.
 */
void scmd_zynq_pwr()
{
    uint32_t arg = shell_unpop_int();
    
    if(arg) {
        main_psu_power_on_if_off();
        zynq_power_on();
        uart_printf("zynq: power up\r\n");
    } else {
        zynq_power_off();
        uart_printf("zynq: power down\r\n");
    }
}

/*
 * scmd_raspi_pwr:  Shell command 'raspipwr', boolean argument determines power status.
 */
void scmd_raspi_pwr()
{
    uint32_t arg = shell_unpop_int();
    
    if(arg) {
        main_psu_power_on_if_off();
        raspi_power_on();
        uart_printf("raspi: power up\r\n");
    } else {
        raspi_power_off();
        uart_printf("raspi: power down\r\n");
    }
}

/*
 * scmd_all_off:  Shell command to shutdown all power rails in the correct order.
 */
void scmd_all_off()
{
    zynq_power_off();
    raspi_power_off();
    adf435x_shutdown();
    adc_power_off();
    
    main_psu_power_off();
    
    uart_printf("pwr: everything goes dark\r\n");
}

/*
 * scmd_pll_freq:  Shell command to change PLL frequency.
 */
void scmd_pll_freq()
{
    float freq = shell_unpop_float();
    
    adf435x_change_frequency(freq);
    
    uart_printf("pll: frequency change request sent (%4.7f MHz)\r\n", freq);
}

/*
 * scmd_pll_tune:  Interactive shell PLL tuner.  Allows user to fine adjust frequency.
 */
void scmd_pll_tune()
{
    uint32_t run = 1;
    float freq = adf435x_state.calc_output_freq;
    
    while(1) {
        uart_printf("Current frequency is (requested) %4.4f MHz (calculated) %4.4f MHz \r\n\r\n", freq, adf435x_state.calc_output_freq);
        uart_printf("Press 'X' to exit.\r\n");
        uart_printf("Press 'Q' to increment 10MHz.\r\n");
        uart_printf("Press 'A' to decrement 10MHz.\r\n");
        uart_printf("Press 'W' to increment 1MHz.\r\n");
        uart_printf("Press 'S' to decrement 1MHz.\r\n");
        uart_printf("Press 'E' to increment 0.01MHz.\r\n");
        uart_printf("Press 'D' to decrement 0.01MHz.\r\n\r\n");
        
        switch(toupper(uart_getchar())) {
            case 'X':
                run = 0;
                break;
            
            case 'Q':
                freq += 10;
                break;
            
            case 'A':
                freq -= 10;
                break;
            
            case 'W':
                freq += 1;
                break;
            
            case 'S':
                freq -= 1;
                break;
            
            case 'E':
                freq += 0.01;
                break;
            
            case 'D':
                freq -= 0.01;
                break;
        }
        
        // Limits
        if(freq < 36)
            freq = 36;
        if(freq > 4400)
            freq = 4400;
        
        if(!run) {
            break;
        }
        
        // truncate & round to 0.001f resolution
        freq = ((int)(freq * 1000)) * 0.001f;
        adf435x_change_frequency(freq);
        uart_printf("\r\n\r\n");
    }
}

/*
 * scmd_pll_profile:  Load PLL profile passed by index.
 */
void scmd_pll_profile()
{
    uint32_t arg = shell_unpop_int();
    
    adf435x_load_config_index(arg);
    adf435x_dump_state();
}

/*
 * scmd_adc_reset:  Reset the ADC to default configuration.
 */
void scmd_adc_reset()
{
    adc_power_off();
    adc_power_on();
    hmcad151x_init();
}

/*
 * scmd_adc_test:  Select an ADC test mode.
 */
void scmd_adc_test()
{
    char *hex_string = shell_unpop_string();
    uint32_t mode = shell_unpop_int();
    uint16_t out_word = (HEX2DEC(hex_string[0]) << 12) | (HEX2DEC(hex_string[1]) << 8) | (HEX2DEC(hex_string[2]) << 4) | HEX2DEC(hex_string[3]);
    
    uart_printf("adc: test mode %d hex word 0x%04x\r\n", mode, out_word);
    
    hmcad151x_test_mode(mode, out_word);
}

/*
 * scmd_adc_walk:  Run ADC walk test.  The ADC outputs a walking "1", changing every 500ms.
 */
void scmd_adc_walk()
{
    uint8_t walk_word = 0x01;
    uint32_t walk_pos = 0, run = 1, b = 0, time;
    
    uart_printf("Walk test running, press 'x' to abort.\r\n\r\n");
    
    while(run) {
        for(walk_pos = 0; walk_pos < 8; walk_pos++) {
            walk_word = 1 << walk_pos;
            hmcad151x_test_mode(HMC_TEST_SINGLE_WORD, walk_word);
            
            uart_printf("Walking: 0x%02x (", walk_word);
            
            for(b = 0; b < 8; b++) {
                if(b == walk_pos)
                    uart_putsraw("1");
                else
                    uart_putsraw("0");
            }
            
            uart_printf(")\r\n");
            
            for(time = 500; time > 0; time--) {
                systick_wait(1);
                
                if(uart_getchar_nb() == 'x') {
                    run = 0;
                    walk_pos = 9;
                    break;
                }
            }
        }
    }
    
    hmcad151x_test_mode(HMC_TEST_OFF, 0);
}

/*
 * Below functions control LVDS properties for the ADC outputs that feed the FPGA.
 */
void scmd_adc_lvds_cdrv()
{
    hmcad151x_state.clock_curr_lvds = shell_unpop_int();
    hmcad151x_state.clock_curr_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS drive [clock] = %2.1f mA\r\n", hmcad_lvds_current_lut[hmcad151x_state.clock_curr_lvds]);
}

void scmd_adc_lvds_fdrv()
{
    hmcad151x_state.frame_curr_lvds = shell_unpop_int();
    hmcad151x_state.frame_curr_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS drive [frame] = %2.1f mA\r\n", hmcad_lvds_current_lut[hmcad151x_state.frame_curr_lvds]);
}

void scmd_adc_lvds_ddrv()    
{
    hmcad151x_state.data_curr_lvds = shell_unpop_int();
    hmcad151x_state.data_curr_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS drive [data ] = %2.1f mA\r\n", hmcad_lvds_current_lut[hmcad151x_state.data_curr_lvds]);
}

void scmd_adc_lvds_drv()
{
    hmcad151x_state.data_curr_lvds = shell_unpop_int();
    hmcad151x_state.data_curr_lvds &= 7;
    hmcad151x_state.frame_curr_lvds = shell_unpop_int();
    hmcad151x_state.frame_curr_lvds &= 7;
    hmcad151x_state.clock_curr_lvds = shell_unpop_int();
    hmcad151x_state.clock_curr_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS drive [data ] = %2.1f mA\r\n", hmcad_lvds_current_lut[hmcad151x_state.data_curr_lvds]);
    uart_printf("ADC LVDS drive [frame] = %2.1f mA\r\n", hmcad_lvds_current_lut[hmcad151x_state.frame_curr_lvds]);
    uart_printf("ADC LVDS drive [clock] = %2.1f mA\r\n", hmcad_lvds_current_lut[hmcad151x_state.clock_curr_lvds]);
    // hmcad_lvds_current_lut
}

void scmd_adc_lvds_cterm()
{
    hmcad151x_state.clock_term_lvds = shell_unpop_int();
    hmcad151x_state.clock_term_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS term [clock] = %d\r\n", hmcad_lvds_term_lut[hmcad151x_state.clock_term_lvds]);
}

void scmd_adc_lvds_fterm()
{
    hmcad151x_state.frame_term_lvds = shell_unpop_int();
    hmcad151x_state.frame_term_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS term [frame] = %d\r\n", hmcad_lvds_term_lut[hmcad151x_state.frame_term_lvds]);
}

void scmd_adc_lvds_dterm()
{
    hmcad151x_state.data_term_lvds = shell_unpop_int();
    hmcad151x_state.data_term_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS term [data ] = %d\r\n", hmcad_lvds_term_lut[hmcad151x_state.data_term_lvds]);
}

void scmd_adc_lvds_term()
{
    hmcad151x_state.data_term_lvds = shell_unpop_int();
    hmcad151x_state.data_term_lvds &= 7;
    hmcad151x_state.frame_term_lvds = shell_unpop_int();
    hmcad151x_state.frame_term_lvds &= 7;
    hmcad151x_state.clock_term_lvds = shell_unpop_int();
    hmcad151x_state.clock_term_lvds &= 7;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS term [data ] = %d ohms\r\n", hmcad_lvds_term_lut[hmcad151x_state.data_term_lvds]);
    uart_printf("ADC LVDS term [frame] = %d ohms\r\n", hmcad_lvds_term_lut[hmcad151x_state.frame_term_lvds]);
    uart_printf("ADC LVDS term [clock] = %d ohms\r\n", hmcad_lvds_term_lut[hmcad151x_state.clock_term_lvds]);
}

void scmd_adc_lvds_adv()
{
    hmcad151x_state.lvds_advance_delay = shell_unpop_int();
    
    if(hmcad151x_state.lvds_advance_delay < -1 || hmcad151x_state.lvds_advance_delay > +1) {
        hmcad151x_state.lvds_advance_delay = 0;
    }
    
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS adv/delay = %d\r\n", hmcad151x_state.lvds_advance_delay);
}

void scmd_adc_lvds_phas()
{
    hmcad151x_state.lvds_phase = shell_unpop_int();
    hmcad151x_state.lvds_phase &= 3;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS phase register now = %d\r\n", hmcad151x_state.lvds_phase);
}

void scmd_adc_lvds_def()
{
    hmcad151x_state.lvds_phase = 0;
    hmcad151x_state.lvds_advance_delay = 0;
    hmcad151x_state.clock_term_lvds = 0;
    hmcad151x_state.frame_term_lvds = 0;
    hmcad151x_state.data_term_lvds = 0;
    hmcad151x_state.clock_curr_lvds = 0;
    hmcad151x_state.frame_curr_lvds = 0;
    hmcad151x_state.data_curr_lvds = 0;
    hmcad151x_sync_lvds_settings();
    
    uart_printf("ADC LVDS settings set to default.\r\n");
}

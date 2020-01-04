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
 
#include "shell_commands.h"
#include "shell.h"

struct shell_command_t shell_commands[] = {
    { "help",      ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_help },
    { "adcpwr",    ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  &scmd_adc_pwr },
    { "zynqpwr",   ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    { "raspipwr",  ARG_BOOL,   ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    { "pllfreq",   ARG_FLOAT,  ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },              // Set frequency of PLL (calculate N, FRAC, M, RFDIV)
    { "pllpar",    ARG_INT,    ARG_INT,    ARG_INT,    ARG_INT,   0 },              // Set N, FRAC, MOD, RFDIV of PLL directly
    { "sleep",     ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    { "ledon",     ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    { "ledoff",    ARG_INT,    ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
    { "reset",     ARG_NONE,   ARG_NONE,   ARG_NONE,   ARG_NONE,  0 },
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
 * scmd_adc_pwr:  Shell command 'adcpwr', boolean argument determines power status.
 */
void scmd_adc_pwr()
{
    
}

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
#include <string.h>

#include "hal.h"
#include "shell.h"
#include "shell_commands.h"

#include "microrl/src/microrl.h"

microrl_t rl;
microrl_t *prl = &rl;

/*
 * shell_init:  Initialise resources for the shell.
 */
void shell_init()
{
	struct microrl_config config = {
		.print = _shell_print_wrapper,
		.execute = _shell_execute,
		.sigint = _shell_sigint
	};
    
    shell_print_help();
    
    uart_putsraw("\r\n\r\n");
	microrl_init(prl, &config);
}

/*
 * shell_print_help:  List all supported commands.
 */
void shell_print_help()
{
    uint32_t i, a, nargs;
    
    uart_putsraw("\r\n");
    uart_putsraw(" Command      Argument Spec                       Required\r\n");
    uart_putsraw("-------------------------------------------------------------\r\n");
    
    for(i = 0; shell_commands[i].command_name != 0; i++) {
        uart_printf(" \033[97m%-12s\033[0m ", shell_commands[i].command_name);
        
        for(nargs = 0, a = 0; a < SHELL_MAX_ARGS; a++) {
            switch(shell_commands[i].arg_spec[a]) {
                case ARG_INT:
                    uart_putsraw("\033[96m<NUMBER>");
                    nargs++;
                    break;
                case ARG_BOOL:
                    uart_putsraw("\033[91m<BOOL>  ");
                    nargs++;
                    break;
                case ARG_STRING:
                    uart_putsraw("\033[93m<STRING>");
                    nargs++;
                    break;
                case ARG_FLOAT:
                    uart_putsraw("\033[94m<FLOAT> ");
                    nargs++;
                    break;
                
                default:
                case ARG_NONE:
                    uart_putsraw("        ");
                    break;
            }
            
            uart_putsraw("\033[0m ");
        }
        
        uart_printf("\033[97m(%d args)\033[0m\r\n", nargs);
    }
    
    uart_printf("\r\n\r\n");
}

/*
 * shell_error:  Print an error message.
 */
void shell_error(char *s)
{
    uart_printf("\033[91mError:\033[0m %s\r\n", s);
}

/*
 * _shell_execute:  Callback to execute a shell command from microrl. 
 */
int _shell_execute(void *userdata, int32_t argc, char **argv)
{
    uint32_t i, found = 0;
    
    if(argc == 0)
        return 0;
    
    // Compare the first argument against the list of commands, looking for
    // an exact (non case-sensitive match)
    for(i = 0; shell_commands[i].command_name != 0; i++) {
        if(strcasecmp(shell_commands[i].command_name, argv[0]) == 0) {
            found = 1;
        }
    }
    
    if(!found) {
        shell_error("Command not found");
        uart_putsraw("\r\n");
    }
}

/*
 * _shell_print_wrapper:  Callback from microrl to print string.
 */
void _shell_print_wrapper(char *s)
{
    uart_putsraw(s);
}

/*
 * _shell_sigint:  Callback from microrl to signal Ctrl+C press.  Triggers
 * a system reset.
 */
void _shell_sigint()
{
    NVIC_SystemReset();
}

/*
 * shell_run:  Indefinitely run the shell processor.
 */
void shell_run()
{
    while(1) {
        shell_iter();
    }
}

/*
 * shell_iter:  Run one iteration of the shell processor.  Not guaranteed to 
 * return immediately.
 */
void shell_iter()
{
    if(uart_char_is_available()) {
        //uart_printf("%02x\r\n", uart_getchar());
        microrl_insert_char(prl, uart_getchar());
    }
}

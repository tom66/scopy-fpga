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
#include <stdlib.h>
#include <string.h>

#include "hal.h"
#include "shell.h"
#include "shell_commands.h"

#include "microrl/src/microrl.h"

microrl_t rl;
microrl_t *prl = &rl;

struct shell_state_t sh_state;

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
 * shell_push_arg_raw:  Push an arg directly onto the stack, as a shell_arg_t struct.
 *
 * @return      0 = Failed to find space for argument, 1 = Argument added
 */
int32_t shell_push_arg_raw(struct shell_arg_t *arg)
{
    if(sh_state.arg_sp == (SHELL_MAX_ARGS - 1))
        return 0;
    
    sh_state.arg_stack[sh_state.arg_sp++] = *arg; // Copy argument
    return 1;
}

/*
 * shell_push_arg_int:  Push an int argument onto the arg stack.
 *
 * @return      0 = Failed to find space for argument, 1 = Argument added
 */
int32_t shell_push_arg_int(int32_t arg)
{
    struct shell_arg_t as;
    
    as.type = ARG_INT;
    as.arg_str = (char*)0;
    as.arg_float = 0.0f;
    as.arg_int = arg;
    
    return shell_push_arg_raw(&as);
}

/*
 * shell_push_arg_float:  Push a float argument onto the arg stack.
 *
 * @return      0 = Failed to find space for argument, 1 = Argument added
 */
int32_t shell_push_arg_float(float arg)
{
    struct shell_arg_t as;
    
    as.type = ARG_FLOAT;
    as.arg_str = (char*)0;
    as.arg_float = arg;
    as.arg_int = 0;
    
    return shell_push_arg_raw(&as);
}

/*
 * shell_push_arg_string:  Push a string argument onto the arg stack.
 *
 * @return      0 = Failed to find space for argument, 1 = Argument added
 */
int32_t shell_push_arg_string(char *arg)
{
    struct shell_arg_t as;
    
    // Copy into a new buffer because the stack pointer might be invalid later
    strncpy(arg_str_buffer[sh_state.arg_sp], arg, SHELL_STR_MAX_LEN - 1);
    
    as.type = ARG_STRING;
    as.arg_str = arg_str_buffer[sh_state.arg_sp];
    as.arg_float = 0.0f;
    as.arg_int = 0;
    
    return shell_push_arg_raw(&as);
}

/*
 * shell_unpop_arg:  Discard all arguments from the shell.
 *
 * @param       arg - Pointer to a struct to store the argument data in.  Not filled if no argument present.
 *
 * @return      The number of remaining arguments in the stack prior to this call, or 0 if no arguments are left.
 */
int32_t shell_unpop_arg(struct shell_arg_t *arg)
{
    if(sh_state.arg_sp == 0)
        return 0;
    
    sh_state.arg_sp--;
    *arg = sh_state.arg_stack[sh_state.arg_sp];
    return sh_state.arg_sp + 1;
}

/*
 * shell_unpop_all_args:  Discard all arguments from the shell.
 */
void shell_unpop_all_args()
{
    uint32_t a;
    struct shell_arg_t discard;
    
    for(a = 0; a < SHELL_MAX_ARGS; a++) {
        shell_unpop_arg(&discard);
    }
}

/*
 * _shell_execute:  Callback to execute a shell command from microrl. 
 */
int _shell_execute(void *userdata, int32_t argc, char **argv)
{
    uint32_t i, a, found = 0, opt = 0;
    uint8_t arg_spec;
    int32_t arg_int;
    float arg_float;
    
    if(argc == 0)
        return 0;
    
    // Compare the first argument against the list of commands, looking for
    // an exact (non case-sensitive match)
    for(i = 0; shell_commands[i].command_name != 0; i++) {
        if(strcasecmp(shell_commands[i].command_name, argv[0]) == 0) {
            found = 1;
            shell_unpop_all_args();
            
            for(a = 0; a < SHELL_MAX_ARGS; a++) {
                opt = 0;
                arg_spec = shell_commands[i].arg_spec[a] & ~ARG_OPT;
                
                if(arg_spec & shell_commands[i].arg_spec[a]) {
                    opt = 1;
                }
                
                if(arg_spec != ARG_NONE && a > (argc - 1)) {
                    shell_error("Command requires more arguments");
                }
                
                switch(arg_spec) {
                    case ARG_INT:
                        arg_int = atoi(argv[a]);
                        shell_push_arg_int(arg_int);
                        break;
                    case ARG_FLOAT:
                        arg_float = atof(argv[a]);
                        shell_push_arg_float(arg_int);
                        break;
                    case ARG_BOOL:
                        if(_shell_arg_is_true()) {
                            shell_push_arg_int(1);
                        } else if(_shell_arg_is_false())  {
                            shell_push_arg_int(0);
                        } else {
                            shell_error("Invalid boolean argument");
                        }
                        break;
                    case ARG_STRING:
                        shell_push_arg_string(argv[a]);
                        break;
                }
            }
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

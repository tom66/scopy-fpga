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

#ifndef ___SHELL_H___
#define ___SHELL_H___

#include <stdint.h>

#define ARG_NONE            0x00
#define ARG_INT             0x01
#define ARG_STRING          0x02
#define ARG_FLOAT           0x03        // not implemented right now
#define ARG_BOOL            0x04        // maps to int, accepts 'T', 'F', 'Y', 'N', 'on', 'off', 'true', 'false', 'yes', 'no'.
#define ARG_OPT             0x80        // flag to mark optional argument

#define ARG_INTOPT          (ARG_INT | ARG_OPT)
#define ARG_STROPT          (ARG_STRING | ARG_OPT)
#define ARG_FLTOPT          (ARG_FLOAT | ARG_OPT)
#define ARG_BOOLOPT         (ARG_BOOL | ARG_OPT)

#define SHELL_MAX_ARGS      4
#define SHELL_STR_MAX_LEN   20

#define HEX2DEC(x)          (((x) >= '0' && (x) <= '9') ? ((x) - '0') : ((toupper(x) >= 'A' && toupper(x) <= 'F') ? (toupper(x) - 'A' + 10) : 0))

extern char shell_arg_str_buffer[SHELL_MAX_ARGS][SHELL_STR_MAX_LEN];

struct shell_command_t {
    char *command_name;
    char arg_spec[SHELL_MAX_ARGS];
    void (*callback)();
};

struct shell_arg_t {
    uint8_t type;
    char *arg_str;
    int32_t arg_int;
    float arg_float;
};

struct shell_state_t {
    uint32_t arg_sp;
    struct shell_arg_t arg_stack[SHELL_MAX_ARGS + 1];
};

extern struct shell_command_t shell_commands[];

void shell_init();
void shell_print_help();
void shell_error(char *s);
void _shell_print_wrapper(char *s);
int _shell_execute(void *userdata, int32_t argc, char **argv);
int32_t shell_push_arg_raw(struct shell_arg_t *arg);
int32_t shell_push_arg_int(int32_t arg);
int32_t shell_push_arg_float(float arg);
int32_t shell_push_arg_string(char *arg);
int32_t shell_unpop_arg(struct shell_arg_t *arg);
int32_t shell_unpop_int();
float shell_unpop_float();
char* shell_unpop_string();
void shell_unpop_all_args();
int32_t _shell_arg_is_true(char *arg);
int32_t _shell_arg_is_false(char *arg);
void _shell_sigint();
void shell_run();
void shell_iter();

#endif // ___SHELL_H___

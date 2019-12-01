/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdarg.h>

#include "platform.h"
#include "xil_printf.h"

uint32_t *mem_addr;
uint32_t *base;

void debug_printf(char *fmt, ...)
{
	char buffer[1024];

	va_list args;
	va_start(args, fmt);

	vsnprintf(buffer, 1024, fmt, args);
	print(buffer);

	va_end(args);
}

void arb_delay(uint32_t n)
{
	while(n--) {
		__asm__("nop");
	}
}

int main()
{
	uint32_t data;
	uint32_t i;
	uint32_t loops = 0;
	int32_t k;

    init_platform();

    while(1) {
		debug_printf("\r\n\r\nSequential Write with Random Data...\r\n\r\n");

		base = 0x00100000;
		mem_addr = base;
		srand(loops);

		for(i = 0; i < ((1024 * 1024 * 63)); i++) {
			data = rand() * rand();
			if((i & ((1024 * 1024 * 1) - 1)) == 0) {
				debug_printf("Write: 0x%08x to 0x%08x (%3.3f KiB)\r\n", data, mem_addr, (mem_addr - base) / 256.0f);
			}
			*mem_addr = data;
			mem_addr++;
		}

		mem_addr = base;
		srand(loops);

		debug_printf("\r\n\r\nSequential Read of Same Random Data...\r\n\r\n");

		for(i = 0; i < ((1024 * 1024 * 63)); i++) {
			data = rand() * rand();
			if((i & ((1024 * 1024 * 1) - 1)) == 0) {
				debug_printf("Read: 0x%08x from 0x%08x expect 0x%08x (%3.3f KiB) (%d loop passes)\r\n", *mem_addr, mem_addr, data, (mem_addr - base) / 256.0f, loops);
			}

			if(((*mem_addr) != data)) {
				debug_printf("FAIL: 0x%08x from 0x%08x expect 0x%08x\r\n", *mem_addr, mem_addr, data);
				while(1) ;
			}
			mem_addr++;
		}

		debug_printf("\r\n\r\nRandom Write with Random Data...\r\n\r\n");

		base = 0x00100000;
		srand(loops);

		for(i = 0; i < ((1024 * 1024 * 255)); i++) {
			mem_addr = base + (rand() % ((1024 * 1024 * 63)));
			k = (uint32_t)mem_addr;
			data = (k * k) + 0x12345679;

			if((i & ((1024 * 1024 * 1) - 1)) == 0) {
				debug_printf("Write: 0x%08x to 0x%08x\r\n", data, mem_addr);
			}
			*mem_addr = data;
			mem_addr++;
		}

		debug_printf("\r\n\r\nRandom Read of Same Data...\r\n\r\n");

		base = 0x00100000;
		srand(loops);

		for(i = 0; i < ((1024 * 1024 * 255)); i++) {
			mem_addr = base + (rand() % ((1024 * 1024 * 63)));
			k = (uint32_t)mem_addr;
			data = (k * k) + 0x12345679;

			if((i & ((1024 * 1024 * 1) - 1)) == 0) {
				debug_printf("Read: 0x%08x from 0x%08x expect 0x%08x (%d loop passes)\r\n", *mem_addr, mem_addr, data, loops);
			}

			if(((*mem_addr) != data)) {
				debug_printf("FAIL: 0x%08x from 0x%08x expect 0x%08x\r\n", *mem_addr, mem_addr, data);
				while(1) ;
			}
			*mem_addr = data;
			mem_addr++;
		}
		loops++;
    }

    while(1) {
    	arb_delay(1000000);
    }

    cleanup_platform();
    return 0;
}

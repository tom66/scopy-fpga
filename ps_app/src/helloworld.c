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
#include <ctype.h>

#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xil_testmem.h"
#include "xuartps_hw.h"
#include "xaxidma.h"
#include "xdebug.h"

uint32_t *mem_addr;
uint32_t *base;

#define PACKET_MAXSIZE		16383

// These MUST be on 1MB boundaries to allow the cache to be invalidated safely
// and they MUST be integer MB in size
uint8_t rx_buffer[1048576] __attribute__((aligned (1048576))) __attribute__((section("ddr3")));
uint8_t tx_buffer[1048576] __attribute__((aligned (1048576))) __attribute__((section("ddr3")));

//#define MEM_TEST

#define MARK_UNCACHEABLE	0x701

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
	int32_t error;
	uint32_t addr;
	uint32_t *ptr;
	int32_t result;
	uint32_t n;
	uint32_t iter = 0, iter2 = 0;

	XAxiDma dma0_pointer;
	XAxiDma_Config *dma0_config;

    init_platform();

	debug_printf("\r\n\r\nDemoApp v1.0 - DMA controlled transfers\r\n");

	dma0_config = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);
		error = XAxiDma_CfgInitialize(&dma0_pointer, dma0_config);

	debug_printf("XAxiDma_CfgInitialize error=%d\r\n", error);

	debug_printf("TXBuff Addr=0x%08x\r\n", &tx_buffer);
	debug_printf("RXBuff Addr=0x%08x\r\n", &rx_buffer);

	//debug_printf("Flush and disable data cache...\r\n");

	//Xil_DCacheFlush();
	//Xil_DCacheDisable();

	/*
	if(XAxiDma_HasSg(&dma0_pointer)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}
	*/

	// Disable interrupts, we use polling mode
	XAxiDma_IntrDisable(&dma0_pointer, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&dma0_pointer, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DMA_TO_DEVICE);

	debug_printf("OK, done.\r\n");

	while(1) {
		//debug_printf("Sending uncache flag to addr 0x%08x\r\n", addr);
		//Xil_SetTlbAttributes(addr, MARK_UNCACHEABLE);
		//debug_printf("Sending Dinvalidate flag to addr 0x%08x\r\n", addr);
		//Xil_DCacheInvalidateRange(addr, 1);

		//debug_printf("Start SimpleTransfer\r\n");

		// prep DMAblock
		dma0_config = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);
		error = XAxiDma_CfgInitialize(&dma0_pointer, dma0_config);

		for(n = 0; n < PACKET_MAXSIZE; n++) {
			tx_buffer[n] = n + iter;
		}

		Xil_DCacheFlushRange(tx_buffer, PACKET_MAXSIZE);

		//error = XAxiDma_SimpleTransfer(&dma0_pointer, (uint8_t *) rx_buffer, 1, XAXIDMA_DEVICE_TO_DMA);
		//debug_printf("Short Xfer error=%d\r\n", error);

		error = XAxiDma_SimpleTransfer(&dma0_pointer, (uint8_t *) rx_buffer, 128, XAXIDMA_DEVICE_TO_DMA);
		//error = XAxiDma_SimpleTransfer(&dma0_pointer, (uint8_t *) tx_buffer, PACKET_MAXSIZE, XAXIDMA_DMA_TO_DEVICE);

		//while(XAxiDma_Busy(&dma0_pointer, XAXIDMA_DEVICE_TO_DMA) /* || XAxiDma_Busy(&dma0_pointer, XAXIDMA_DMA_TO_DEVICE) */) {
		//	debug_printf("w");
		//}

		arb_delay(4000000);

		debug_printf("\033[2J");
		debug_printf("Initialise Xfer error=%d, iter=%d\r\n", error, iter);

		/*
		while(XAxiDma_Busy(&dma0_pointer, XAXIDMA_DEVICE_TO_DMA)) {
			debug_printf("w");
		}
		*/

		Xil_DCacheInvalidateRange(rx_buffer, PACKET_MAXSIZE);

		if(1 /*iter2 > 0*/) {
			debug_printf("Data: \r\n %08d  ", 0);

			ptr = rx_buffer;
			for(k = 0; k < (32); k++) {
				debug_printf("0x%08x ", *ptr++);
				if(((k + 1) & 7) == 0) {
					debug_printf("\r\n %08d  ", (k + 1) * 4);
				}
			}

			debug_printf("\r\n\r\n");
			//debug_printf("X");
			iter2 = 0;
		}

		debug_printf("Press 'r' to reset app processor\r\n");

		if(XUartPs_IsReceiveData(STDOUT_BASEADDRESS)) {
			if(tolower(XUartPs_RecvByte(STDOUT_BASEADDRESS)) == 'r') {
				debug_printf("Reset in progress...\r\n");
				main();
			}
		}

		iter++;
		iter2++;

		arb_delay(20000000);
	}

    cleanup_platform();
    return 0;
}

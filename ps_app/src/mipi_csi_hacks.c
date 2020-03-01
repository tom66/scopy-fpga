/*
 * mipi_csi_hacks.c
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: ?
 *      Author: Tom
 */

/*
 * Control for the PL fabric MIPI CSI transmitter, used to move large blocks
 * of data into the CM3.
 *
 * This is a really hacky version for testing purposes only.  It will be removed
 * from later releases as the code is integrated elsewhere (hah!)
 */

#include "fabric_config.h"
#include "mipi_csi_hacks.h"
#include "hal.h"

uint8_t src_buffer[32768] __attribute__((aligned(32)));
// uint8_t dest_buffer[2048] __attribute__((aligned(32)));

void csi_hack_run()
{
	float freq = 20.00;
	int i;

	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, CSI_EMIO_START_FRAME, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, CSI_EMIO_START_FRAME, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, CSI_EMIO_START_LINES, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, CSI_EMIO_START_LINES, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, CSI_EMIO_END_FRAME, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, CSI_EMIO_END_FRAME, 1);
	XGpioPs_SetOutputEnablePin(&g_hal.xgpio_ps, CSI_EMIO_STOP, 1);
	XGpioPs_SetDirectionPin(&g_hal.xgpio_ps, CSI_EMIO_STOP, 1);

	for(i = 0; i < 32768; i++) {
		//src_buffer[i] = (0x01 << (i / 2048)) - 1;
		src_buffer[i] = ((i / 2048) & 0x01) * 0xff;
	}

	memcpy((XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR), src_buffer, 32768);

	fabcfg_write(FAB_CFG_CSI_LINE_COUNT, 4);
	fabcfg_write(FAB_CFG_CSI_LINE_BYTE_COUNT, 2048);
	fabcfg_write(FAB_CFG_CSI_DATA_TYPE, 0x2b);
	fabcfg_commit();
	fabcfg_commit();
	fabcfg_commit();

#if 0
	while(1) {
		emio_fast_write(CSI_EMIO_START_FRAME, 1);
		emio_fast_write(CSI_EMIO_START_LINES, 1);
		emio_fast_write(CSI_EMIO_END_FRAME, 1);
		emio_fast_write(CSI_EMIO_START_FRAME, 0);
		emio_fast_write(CSI_EMIO_START_LINES, 0);
		emio_fast_write(CSI_EMIO_END_FRAME, 0);

		/*
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_FRAME, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_LINES, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_END_FRAME, 1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_LINES, 0);
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_END_FRAME, 0);
		*/
	}
#endif

	clkwiz_change_mipi_freq(&g_hal.clkwiz_mipi, freq);

	while(1) {
		outbyte('X');

		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_STOP, 1);
		bogo_delay(1);
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_STOP, 0);

		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_FRAME, 1);
		while( XGpioPs_ReadPin(&g_hal.xgpio_ps, CSI_EMIO_DONE)) ;	// wait for DONE to be LOW - ack/ready
		while(!XGpioPs_ReadPin(&g_hal.xgpio_ps, CSI_EMIO_DONE)) ;	// wait for DONE to go HIGH - this cmd done
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_FRAME, 0);

		//d_printf(D_INFO, "end_start_frame");

		for(i = 0; i < 16; i++) {
			XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_LINES, 1);
			while( XGpioPs_ReadPin(&g_hal.xgpio_ps, CSI_EMIO_DONE)) ;	// wait for DONE to go LOW - ack of command
			while(!XGpioPs_ReadPin(&g_hal.xgpio_ps, CSI_EMIO_DONE)) ;	// then wait for DONe to go HIGH - command done
			XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_START_LINES, 0);
			bogo_delay(1);
		}

		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_END_FRAME, 1);
		while( XGpioPs_ReadPin(&g_hal.xgpio_ps, CSI_EMIO_DONE)) ;	// wait for DONE to go LOW - ack of command
		while(!XGpioPs_ReadPin(&g_hal.xgpio_ps, CSI_EMIO_DONE)) ;
		XGpioPs_WritePin(&g_hal.xgpio_ps, CSI_EMIO_END_FRAME, 0);

		bogo_delay(100000);
	}
}

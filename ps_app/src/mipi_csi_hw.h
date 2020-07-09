/*
 * mipi_csi_hw.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 12 June 2020
 *      Author: Tom
 */

#ifndef SRC_MIPI_CSI_HW_H_
#define SRC_MIPI_CSI_HW_H_

#include "mipi_csi.h"
#include "fabric_config.h"

/*
 * Hardware interfcace for revised MIPI streaming core.
 */

#define CSI_CTRL_A_START_LINES			0x00000001
#define CSI_CTRL_A_START_FRAME			0x00000002
#define CSI_CTRL_A_END_FRAME			0x00000004
#define CSI_CTRL_A_STOP					0x00000008
#define CSI_CTRL_A_SLEEP				0x00000010
#define CSI_CTRL_A_CLOCK_SLEEP_ENABLE	0x00000020
#define CSI_CTRL_A_RESET_FIFO			0x00000040
#define CSI_CTRL_A_RESET_PERIPHERAL		0x00000080
#define CSI_CTRL_A_LINE_BYTE_COUNT_MSK	0xffff0000
#define CSI_CTRL_A_LINE_BYTE_COUNT_SFT	16

#define CSI_CTRL_A_INIT_SIGNALS			(CSI_CTRL_A_START_LINES | CSI_CTRL_A_START_FRAME | CSI_CTRL_A_END_FRAME | CSI_CTRL_A_SLEEP)

#define CSI_CTRL_B_LINE_COUNT_MSK		0x0000ffff
#define CSI_CTRL_B_LINE_COUNT_SFT		0
#define CSI_CTRL_B_DATA_TYPE_MSK		0xff000000
#define CSI_CTRL_B_DATA_TYPE_SFT		24

#define CSI_CTRL_C_WCT_HEADER_MSK		0x0000ffff
#define CSI_CTRL_C_WCT_HEADER_SFT		0

#define CSI_STATUS_A_DONE				0x00000001
#define CSI_STATUS_A_CLKWIZ_LOCK		0x00000002
#define CSI_STATUS_A_RUNNING			0x00000004
#define CSI_STATUS_A_DBG_RV				0x00001000
#define CSI_STATUS_A_DBG_RR				0x00002000
#define CSI_STATUS_A_DBG_SA				0x00004000
#define CSI_STATUS_A_DBG_II				0x00008000
#define CSI_STATUS_A_DBG_IL				0x00010000
#define CSI_STATUS_A_DBG_IS				0x00020000
#define CSI_STATUS_A_DBG_DB				0x00040000
#define CSI_STATUS_A_DBG_DD				0x00080000
#define CSI_STATUS_A_DBG_CTRL_ST_MSK	0x03f00000
#define CSI_STATUS_A_DBG_CTRL_ST_SFT	20
#define CSI_STATUS_A_DBG_MIPI_ST_MSK	0xfc000000
#define CSI_STATUS_A_DBG_MIPI_ST_SFT	26

void mipi_csi_send_fifo_reset();
void mipi_csi_send_sof();
void mipi_csi_send_eof();
void mipi_csi_stop();
void mipi_csi_transfer_packet(struct mipi_csi_stream_queue_item_t *q_item);

#endif // SRC_MIPI_CSI_HW_H_

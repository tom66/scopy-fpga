/*
 * mipi_csi_hacks.h
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

#ifndef SRC_MIPI_CSI_HACKS_H_
#define SRC_MIPI_CSI_HACKS_H_

#define CSI_EMIO_START_LINES			(54 + 20)
#define CSI_EMIO_START_FRAME			(54 + 21)
#define CSI_EMIO_END_FRAME				(54 + 22)
#define CSI_EMIO_STOP					(54 + 23)
#define CSI_EMIO_SLEEP					(54 + 24)
#define CSI_EMIO_DONE					(54 + 25)

#endif // SRC_MIPI_CSI_HACKS_H_

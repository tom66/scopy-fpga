/*
 * acquire.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 1 Feb 2020
 *      Author: Tom
 */

/*
 * Acquistion control engine.  This handles all oscilloscope acquisition functions
 * including memory buffer allocation, PL interface, AXI bus DMA and trigger setup.
 *
 * The acquisition engine is primarily driven by interrupts.  Hold-off is implemented
 * by the trigger engine.
 */

#ifndef SRC_ACQUIRE_H_
#define SRC_ACQUIRE_H_

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include "xaxidma.h"
#include "xscugic.h"

#include "fabric_config.h"

#define ACQSTATE_UNINIT				0								// Not ready: not initialised (memory or other)
#define ACQSTATE_STOPPED			1								// Stopped but ready to start
#define ACQSTATE_PREP				2								// Started but not acquiring data yet
#define ACQSTATE_WAIT_TRIG			3								// Waiting for trigger, pre-trigger buffer running
#define ACQSTATE_RUNNING			4								// Data acquisition in progress
#define ACQSTATE_DONE				5								// All acquisitions complete

#define ACQSUBST_NONE				0								// Sub state machine not running
#define ACQSUBST_PRE_TRIG_FILL		1								// Gathering first pre-trigger buffer
#define ACQSUBST_PRE_TRIG_WAIT		2								// Waiting for trigger, continuing to loop through pre-trigger buffer
#define ACQSUBST_POST_TRIG			3								// Post trigger acquisition
#define ACQSUBST_DONE_WAVE			4								// Post trigger done, so next waveform to be acquired
#define ACQSUBST_DONE_ALL			5								// All waveforms acquired as requested

#define ACQ_MIN_BUFFER_SIZE			16								// Minimum 16 samples buffer size
#define ACQ_MAX_BUFFER_SIZE			(64 * 1024 * 1024)				// Maximum 64M samples buffer size

#define ACQ_MIN_PREPOST_SIZE		8								// Minimum size of any pre or post window.

#define ACQ_WORD_SCALE				8								// Always 64-bit wide sample words by fabric design

#define ACQ_SHORT_THRESHOLD			8192							// Acquisition windows below this threshold (total samples) cause
																	// a FIFO reset at every pre-fill iteration.

#define ACQ_MODE_8BIT				0x00000001						// 8-bit high speed
#define ACQ_MODE_12BIT				0x00000002						// 12-bit mid speed
#define ACQ_MODE_14BIT				0x00000004						// 14-bit low speed
#define ACQ_MODE_1CH				0x00000020						// 1 channel mode
#define ACQ_MODE_2CH				0x00000040						// 2 channel mode
#define ACQ_MODE_4CH				0x00000080						// 4 channel mode
#define ACQ_MODE_TRIGGERED			0x00000100						// Triggered mode (normal/auto/single acquisition)
#define ACQ_MODE_CONTINUOUS			0x00000200						// Special continuous mode (rolling buffer)
#define ACQ_MODE_SHORT_WITH_RESET	0x00000400						// Short acquisition - FIFO reset on each cycle for performance

#define ACQ_SAMPLES_ALIGN_8B		8								// Buffers must be 8-sample sized in 8-bit mode
#define ACQ_SAMPLES_ALIGN_8B_AMOD	(ACQ_SAMPLES_ALIGN_8B - 1)

#define ACQ_SAMPLES_ALIGN_PR		4								// Buffers must be 4-sample sized in 12-bit/14-bit mode (precision modes)
#define ACQ_SAMPLES_ALIGN_PR_AMOD	(ACQ_SAMPLES_ALIGN_PR - 1)

#define ACQ_BUFFER_ALIGN			32								// Required byte alignment for AXI DMA (Must be a power of two)
#define ACQ_BUFFER_ALIGN_AMOD		(ACQ_BUFFER_ALIGN - 1)			// Modulo (binary-AND) used to determine alignment of above value

#define ACQRES_WAVE_NOT_READY		-10
#define ACQRES_WAVE_NOT_FOUND		-9
#define ACQRES_NOT_STOPPED			-8
#define ACQRES_NOT_IMPLEMENTED		-7
#define ACQRES_NOT_INITIALISED		-6
#define ACQRES_DMA_FAIL				-5
#define ACQRES_TOTAL_MALLOC_FAIL	-4
#define ACQRES_PARAM_FAIL			-3
#define ACQRES_ALIGN_FAIL			-2
#define ACQRES_MALLOC_FAIL			-1
#define ACQRES_OK					0

// Control signals for ACQ_CTRL_A
#define ACQ_CTRL_A_RUN				0x00000001
#define ACQ_CTRL_A_AXI_RUN			0x00000002
#define ACQ_CTRL_A_TRIG_MASK		0x00000004
#define ACQ_CTRL_A_TRIG_RST			0x00000008
#define ACQ_CTRL_A_DEPTH_MUX		0x00000010
#define ACQ_CTRL_A_FIFO_RESET		0x00000020
#define ACQ_CTRL_A_ABORT			0x00000040
#define ACQ_CTRL_A_EOF				0x00000080
#define ACQ_CTRL_A_DATA_VALID		0x00000100
#define ACQ_CTRL_A_EARLY_TLAST		0x00000800
#define ACQ_CTRL_A_ACQ_SUSPEND		0x00010000
#define ACQ_CTRL_A_POST_TRIG_MODE	0x00020000

#define ACQ_STATUS_A_DONE			0x00000001
#define ACQ_STATUS_A_HAVE_TRIG		0x00000002
#define ACQ_STATUS_A_DATA_LOSS		0x00000004
#define ACQ_STATUS_A_IDLYPLL_LOCK	0x00000008
#define ACQ_STATUS_A_RG_FIFO_STALL	0x00000010

#define ACQ_STATUS_B_DBG_AXI_RDY	0x00000001
#define ACQ_STATUS_B_DBG_INT_RDY	0x00000002
#define ACQ_STATUS_B_DBG_TRIG_PF	0x00000004						// Trigger post-FIFO

#define ACQ_STATUS_A_FIFO_MASK		0xffff0000
#define ACQ_STATUS_A_FIFO_SHIFT		16
#define ACQ_STATUS_B_FIFO_MASK		0xffff0000
#define ACQ_STATUS_B_FIFO_SHIFT		16

#define ACQ_STATUS_C_WSEL_VALID		0x00008000
#define ACQ_STATUS_C_BITSLIP_LOCK	0x00004000
#define ACQ_STATUS_C_DELAY_LOADED	0x00002000
#define ACQ_STATUS_C_MATCH_55		0x00001000
#define ACQ_STATUS_C_IDLYCTL_RDY	0x00080000
#define ACQ_STATUS_C_ADC_WORD_MASK	0xff000000
#define ACQ_STATUS_C_ADC_WORD_SHFT	24

#define ACQ_TRAIN_A_LOAD			0x00000001

// Flags for acq_buffer_t
#define ACQBUF_FLAG_PKT_DONE		0x0001							// Packet is done
#define ACQBUF_FLAG_PKT_OVERRUN		0x0002							// Packet contains bad data due to FIFO overrun and will be discarded
#define ACQBUF_FLAG_NOTE_FIFOSTALL	0x0004							// "Note" flag to indicate that this packet was recovered from a FIFO stall condition
#define ACQBUF_FLAG_ALLOC			0x0080							// Marker flag set when memory allocated for this buffer

// Demux register on PL.  6-bits wide  [to be implemented]
#define ADCDEMUX_1CH				0x01
#define ADCDEMUX_2CH				0x02
#define ADCDEMUX_4CH				0x04
#define ADCDEMUX_8BIT				0x08
#define ADCDEMUX_12BIT				0x10
#define ADCDEMUX_14BIT				0x20

#define ADC_CH1						1
#define ADC_CH2						2
#define ADC_CH3						3
#define ADC_CH4						4

#define ACQ_TOTAL_MEMORY_AVAIL		(192 * 1024 * 1024)				// Configured total memory limit for general purpose acquisition.

#define ACQ_DMA_ENGINE				XPAR_ADC_DMA_DEVICE_ID
#define ACQ_DMA_RX_IRQ				XPAR_FABRIC_ADC_DMA_S2MM_INTROUT_INTR
#define ACQ_DMA_RX_IRQ_PRIO			0x40							// High priority
#define ACQ_DMA_RX_IRQ_TRIG			0x03							// Rising edge trigger

#define ACQ_FIFO_STALL_IRQ			XPS_FPGA1_INT_ID
#define ACQ_FIFO_STALL_IRQ_PRIO		0x20							// Higher priority
#define ACQ_FIFO_STALL_IRQ_TRIG		0x03							// ???

// Trigger position signalling words (passed in trigger_pos from fabric)
#define TRIGGER_INVALID_NOT_ACQ		0xfffffffe						// Trigger position invalid as acquisition not yet run
#define TRIGGER_INVALID_NO_TRIG		0xffffffff						// Trigger position invalid as no trigger occurred within window
#define TRIGGER_INVALID_MASK		0x80000000						// This bit set indicates invalid trigger pointer

// Reset FIFO behaviour
#define ACQ_START_NO_FIFO_RESET		0
#define ACQ_START_FIFO_RESET		1

// Line training data configuration
#define ADC_LANE_L1A				0
#define ADC_LANE_L1B				1
#define ADC_LANE_L2A				2
#define ADC_LANE_L2B				3
#define ADC_LANE_L3A				4
#define ADC_LANE_L3B				5
#define ADC_LANE_L4A				6
#define ADC_LANE_L4B				7

/*
 * Statistics counters for acquisition engine.
 */
struct acq_stat_t {
	uint64_t num_acq_total;				// Total number of acq. completed
	uint64_t num_pre_total;				// Total number of pre-trigger acq. completed
	uint64_t num_pre_fill_total;		// Total number of pre-trigger fill acq. completed
	uint64_t num_post_total;			// Total number of post-trigger acq. completed
	uint64_t num_err_total;				// Total number of errors during transfer
	uint64_t num_fifo_stall_total;		// Total number of FIFO stall events handled
	uint64_t num_samples;				// Total number of samples acquired into memory (excluding pre-trig fill)
	uint64_t num_samples_raw;			// Total number of samples acquired into memory (including pre-trig fill); not entirely correct!
	uint64_t num_alloc_err_total;		// Total number of errors while allocating buffers
	uint64_t num_alloc_total;			// Total number of successful buffer allocations
	uint64_t num_irqs;					// Total number of IRQs for DMA
	uint64_t num_fifo_full;				// Total number of FIFO full events
	uint64_t num_fifo_pkt_dscd;			// Total number of discarded packets due to FIFO overrun
};

/*
 * One buffer reference with allocated memory and a pointer to the next buffer
 * in the linked list of buffers.
 */
struct acq_buffer_t {
	int idx;
	uint32_t *buff_alloc;		// Pointer that was actually allocated
	uint32_t *buff_acq;			// Pointer that is used for acquisition
	uint32_t trigger_at;
	uint16_t flags;
	uint32_t pre_sz, post_sz;	// Byte copies for size values
	struct acq_buffer_t *next;
};

/*
 * The global structure storing all related control variables for the acquisition
 * engine, and the root of the linked list of acquisition buffers.
 */
struct acq_state_t {
	// States of the acquisition state machine
	int state;
	int sub_state;

	// AXI DMA peripheral references
	XAxiDma dma;
	XAxiDma_Config *dma_config;

	// Acquisition control flags
	uint32_t acq_mode_flags;

	// Sizes of the acquisition ranges (in bytes) and number of acquisitions to make
	uint32_t pre_buffsz;
	uint32_t post_buffsz;
	uint32_t total_buffsz;
	uint32_t aligned_buffsz;	// Aligned buffsz so that buffer terminates within a cache line
	uint32_t num_acq_request;	// Number of acquisitions requested
	uint32_t num_acq_made;		// Number of acquisitions made so far

	// Local state of acq_ctrl_a register used to reduce number of RMW operations made
	uint32_t acq_ctrl_a;

	// Local state of DMACR register used to reduce number of RMW operations made
	uint32_t dmacr_state;

	/*
	 * Sizes (in words) of the acquisition data;  the counts are given in 64-bit words
	 * so there is an 8x or 4x relationship to the sample counts. This maximises the depth of
	 * the on-fabric 28-bit counter.
	 */
	uint32_t pre_sampct;
	uint32_t post_sampct;

	// Demux configuration - used by trigger engine.
	uint32_t demux_reg;

	// Debug state: ISR recorded values for PL state
	uint32_t dbg_isr_acq_ctrl_a;
	uint32_t dbg_isr_acq_status_a, dbg_isr_acq_status_b, dbg_isr_acq_trig_ptr;

	// Statistics counters
	struct acq_stat_t stats;

	// Structure used to calculate acquisition rate
	uint64_t last_debug_timer;
	struct acq_stat_t stat_last;

	// Pointer to the first and current acquisiton buffers.
	struct acq_buffer_t *acq_first;
	struct acq_buffer_t *acq_current;

	/*
	 * Line training data.  These are computed during line training which will be
	 * performed on restart of the acquistion engine (e.g. resume from standby state.)
	 */
	uint8_t line_train[8];
};

extern struct acq_state_t g_acq_state;

void _acq_irq_error_dma(int cause_index);
void _acq_irq_rx_handler(void *cb);
void _acq_irq_fifo_gen_rst(void *none);
void _acq_reset_PL_fifo();
void _acq_reset_trigger();
void _acq_fast_dma_start(uint32_t *buff_ptr, uint32_t buff_sz);
int _acq_core_dma_start(uint32_t *buff_ptr, uint32_t buff_sz);
void acq_init();
void acq_write_training();
int acq_get_next_alloc(struct acq_buffer_t *next);
int acq_append_next_alloc();
void acq_free_all_alloc();
void acq_dealloc_rewind();
int acq_prepare_triggered(uint32_t mode_flags, int32_t bias_point, uint32_t acq_total_size, uint32_t num_acq);
int acq_start(int reset_fifo);
int acq_force_stop();
bool acq_is_done();
void acq_debug_dump();
void acq_debug_dump_wave();
int acq_get_ll_pointer(int index, struct acq_buffer_t **buff);
void acq_debug_dump_wave(int index);
int acq_copy_slow_mipi(int index, uint32_t *buffer);

/*
 * Inlined functions that reduce RMW AXI pressure by keeping track of the internal state of
 * R_acq_ctrl_a on the PL.  It is vital that *only* these functions be used to set and clear
 * bits in this register.  Call a function whenever data needs to be updated on the PL, but
 * try to bunch calls together as much as possible to reduce writes.
 */
static inline void _acq_set_ctrl_a(uint32_t bitmask)
{
	g_acq_state.acq_ctrl_a |= bitmask;
	fabcfg_write(FAB_CFG_ACQ_CTRL_A, g_acq_state.acq_ctrl_a);
}

static inline void _acq_clear_ctrl_a(uint32_t bitmask)
{
	g_acq_state.acq_ctrl_a &= ~bitmask;
	fabcfg_write(FAB_CFG_ACQ_CTRL_A, g_acq_state.acq_ctrl_a);
}

static inline void _acq_clear_and_set_ctrl_a(uint32_t bitmask_clear, uint32_t bitmask_set)
{
	g_acq_state.acq_ctrl_a &= ~bitmask_clear;
	g_acq_state.acq_ctrl_a |= bitmask_set;
	fabcfg_write(FAB_CFG_ACQ_CTRL_A, g_acq_state.acq_ctrl_a);
}

#endif // SRC_ACQUIRE_H_

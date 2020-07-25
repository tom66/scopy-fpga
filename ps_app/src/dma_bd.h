/*
 * dma_bd.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 11 Jun 2020
 *      Author: Tom
 */

/*
 * DMA BD allocator.  This handles allocating large blocks of BDs in system memory
 * and creating a linked list of BDs for passing to the DMA controller used by the
 * MIPI CSI stream out hardware.
 *
 * BDs are allocated in chunks to reduce malloc overheads and increase the chance
 * of us being able to pull these out via the RAM controller FIFO in short bursts.
 */

#ifndef SRC_DMA_BD_H_
#define SRC_DMA_BD_H_

#include <stdint.h>
#include "xaxidma.h"

// All BDs are effectively 64 bytes in size and must be aligned along this boundary
#define BD_SIZE					64
#define BD_ALIGN				64
#define BD_ALIGN_MASK			(BD_ALIGN - 1)

// We allocate up to 128 BDs at a time (8KB + tags)
#define BD_ALLOC_BLOCK_COUNT	128

// Function responses
#define BD_RES_OK				0
#define BD_RES_MEM_ALLOC_ERR 	-1
#define BD_RES_PARAM_ERR 		-2
#define BD_RES_ZERO_SIZE		-3

// Function parameters
#define BD_NEXT_ENTRY			0
#define BD_FIRST_ENTRY			1

#define BD_SIZE_MASK			0x003ffffff
#define BD_SOF					(1 << 26)
#define BD_EOF					(1 << 27)
#define BD_FLAGS_MASK			(BD_SOF | BD_EOF)

#define BD_STATUS_MASK			0x80000000

#define BD_STFLAGS_TRANSMIT		0x00000001
#define BD_STFLAGS_RECEIVE		0x00000002
#define BD_STFLAGS_DUMP_DEBUG	0x00000004

#define BD_VOID_ZONE_BYTES		65536

#define BD_MAX_SIZE				(1 << 18)	// 256KB

/*
 * Statistics counters.  These are only reset by destroying the BD; they do not
 * track the current state exclusively.
 */
struct dma_bd_stats_t {
	uint64_t num_bds_alloc;
	uint64_t num_bds_filled;
	uint64_t num_tags_alloc;
	uint64_t total_bytes;
};

/*
 * Structure to store one BD ring, non Xilinx style :).
 */
struct dma_bd_ring_t {
	struct dma_bd_tag_t *base;							// First tag
	struct dma_bd_tag_t *last;							// Last tag written to
	struct dma_bd_tag_t *current;						// Current working tag
	struct dma_bd_stats_t stats;
	uint32_t total_bd_count;
	uint32_t total_block_size;
};

/*
 * Structure to store one BD allocation group.  bd_base_ptr points to the base
 * where n_bds, each 64 bytes apart, is allocated.
 */
struct dma_bd_tag_t {
	int n_bds, n_bds_free;
	struct dma_bd_sg_descriptor_t *bd_base_ptr;			// First entry
	struct dma_bd_sg_descriptor_t *bd_last_ptr;			// Last complete entry
	struct dma_bd_sg_descriptor_t *bd_working_ptr;		// Location of next entry
	struct dma_bd_tag_t *next_alloc;
};

struct dma_bd_sg_descriptor_t {
	// Do NOT modify the order of entries in this struct -- it MUST correspond to the AXIDMA layout
	uint32_t nxtdesc;				// Next Descriptor Pointer
	uint32_t nxtdesc_msb;			// Unused (64-bit)
	uint32_t buffer_address;		// Buffer Address
	uint32_t buffer_address_msb;	// Unused (64-bit)

	uint32_t reserved1;
	uint32_t reserved2;

	uint32_t control;				// Control + Length
	uint32_t status;				// Status written back to BD

	uint32_t app0;					// Application Tags 0-4
	uint32_t app1;
	uint32_t app2;
	uint32_t app3;
	uint32_t app4;

	uint32_t pad0;					// Pad to length 0x40
	uint32_t pad1;
	uint32_t pad2;
};

struct dma_bd_sg_userdata_t {
	uint32_t app0;
	uint32_t app1;
	uint32_t app2;
	uint32_t app3;
	uint32_t app4;
};

void dma_bd_init();
int dma_bd_create_ring(struct dma_bd_ring_t **ring);
int dma_bd_allocate(struct dma_bd_ring_t *ring, int n_bds_req, int first);
int dma_bd_destroy_ring(struct dma_bd_ring_t *ring);
void dma_bd_free_from(struct dma_bd_tag_t *tag_in);
void dma_bd_free(struct dma_bd_ring_t *ring);
void dma_bd_trim(struct dma_bd_ring_t *ring);
void dma_bd_rewind(struct dma_bd_ring_t *ring);

int dma_bd_add_raw_sg_entry(struct dma_bd_ring_t *ring, uint32_t base_addr, int size, int flags, struct dma_bd_sg_userdata_t *user);
int dma_bd_add_large_sg_entry(struct dma_bd_ring_t *ring, uint32_t base_addr, int size, int flags, struct dma_bd_sg_userdata_t *user);
int dma_bd_add_zero_sg_entry(struct dma_bd_ring_t *ring, int size, int flags, struct dma_bd_sg_userdata_t *user);

void dma_bd_flush_to_ram(struct dma_bd_ring_t *ring);
int dma_bd_finalise(struct dma_bd_ring_t *ring);
int dma_bd_start(XAxiDma *periph, struct dma_bd_ring_t *ring, int tx_rx);

void dma_bd_debug_dump(struct dma_bd_ring_t *ring);
void dma_bd_test();

/*
 * Get BD size
 */
inline uint32_t dma_bd_get_total_block_size(struct dma_bd_ring_t *ring)
{
	return ring->total_block_size;
}

/*
 * Get total number of BDs in given ring.
 */
inline uint64_t dma_bd_get_total_bd_count(struct dma_bd_ring_t *ring)
{
	return ring->total_bd_count;
}

#endif // SRC_DMA_BD_H_

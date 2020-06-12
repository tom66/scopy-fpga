/*
 * dma_bd.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 11 Jun 2020
 *      Author: Tom
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <malloc.h>
#include <ctype.h>

#include "hal.h"
#include "dma_bd.h"

/*
 * DMA BD allocator.  This handles allocating large blocks of BDs in system memory
 * and creating a linked list of BDs for passing to the DMA controller used by the
 * MIPI CSI stream out hardware.
 *
 * BDs are allocated in chunks to reduce malloc overheads and increase the chance
 * of us being able to pull these out via the RAM controller FIFO in short bursts.
 */

struct dma_bd_tag_t *g_dma_bd_base = NULL;
struct dma_bd_tag_t *g_dma_bd_current = NULL;
struct dma_bd_stats_t g_dma_bd_stats;

/*
 * A 64KB block of zero data which is used to pad transmissions with null data.  Allocated on boot
 * from the heap.
 */
uint8_t *g_void_zone;

/*
 * Initialise the DMA BD allocator
 */
void dma_bd_init()
{
	// Build sanity check
	D_ASSERT(sizeof(struct dma_bd_sg_descriptor_t) == BD_SIZE);

	if(g_dma_bd_base != NULL) {
		free(g_dma_bd_base);
	}

	// Allocate void zone
	g_void_zone = calloc(BD_VOID_ZONE_BYTES, 1);
	if(g_void_zone == NULL) {
		d_printf(D_ERROR, "dma_bd: fatal error allocating void zone of %d bytes", BD_VOID_ZONE_BYTES);
		exit(-1);
	}

	d_printf(D_INFO, "dma_bd: void zone @ 0x%08x (%d bytes)", g_void_zone, BD_VOID_ZONE_BYTES);
}

/*
 * Allocate a BD tag with block and append it to the list.  By default, n_bds is passed
 * as zero, which causes the typical size to be allocated.  A smaller or larger size,
 * passed as a positive integer, can be also allocated.
 */
int dma_bd_allocate(struct dma_bd_ring_t *ring, int n_bds_req, int first)
{
	int n_bds, bd_size;
	struct dma_bd_tag_t *tag;

	// The tag's alignment is free
	tag = malloc(sizeof(struct dma_bd_tag_t));

	if(tag == NULL) {
		d_printf(D_ERROR, "dma_bd: failed to allocate header block (%d bytes)", sizeof(struct dma_bd_tag_t));
		return BD_RES_MEM_ALLOC_ERR;
	}

	// Try to allocate a memaligned block within
	if(n_bds_req == 0) {
		n_bds = BD_ALLOC_BLOCK_COUNT;
	} else {
		if(n_bds_req > 0) {
			n_bds = n_bds_req;
		} else {
			return BD_RES_PARAM_ERR;
		}
	}

	bd_size = n_bds * BD_SIZE;

	tag->n_bds = n_bds;
	tag->n_bds_free = n_bds;
	tag->bd_base_ptr = memalign(bd_size, BD_ALIGN);
	tag->bd_working_ptr = tag->bd_base_ptr;

	if(tag->bd_base_ptr == NULL) {
		d_printf(D_ERROR, "dma_bd: failed to allocate BD block (%d bytes)", bd_size);
		return BD_RES_MEM_ALLOC_ERR;
	}

	D_ASSERT(((int)(tag->bd_base_ptr) % BD_ALIGN) == 0);

	if(first == BD_FIRST_ENTRY) {
		// Make this block the first entry
		ring->dma_bd_current = tag;
	} else {
		// Append this block to the list and move the current pointer
		ring->dma_bd_current->next_alloc = tag;
		ring->dma_bd_current = g_dma_bd_current->next_alloc;
	}

	ring->dma_bd_stats.num_bds_alloc += n_bds;
	ring->dma_bd_stats.num_tags_alloc++;

	return BD_RES_OK;
}

/*
 * Free all BDs starting from a given entry until the end of the list.
 * N.B. May contain gluten.
 */
void dma_bd_free_from(struct dma_bd_tag_t *tag_in)
{
	struct dma_bd_tag_t *tag = tag_in;
	struct dma_bd_tag_t *tag_next;

	while(tag != NULL) {
		tag_next = tag->next_alloc;

		free(tag->bd_base_ptr);
		free(tag);

		tag = tag_next;
	}
}

/*
 * Walk the list and free all BD blocks and tag entries.  The ring itself is
 * NOT freed.
 */
void dma_bd_free(struct dma_bd_ring_t *ring)
{
	dma_bd_free_from(ring->dma_bd_base);
}

/*
 * Trim the list of blocks, freeing any unused blocks at the end of the BD ring.
 * This walks from the working pointer until it reaches a NULL next tag.
 */
void dma_bd_trim(struct dma_bd_ring_t *ring)
{
	dma_bd_free_from(ring->dma_bd_current);
}

/*
 * Walk the list and make all BD blocks free, without truly freeing anything.
 * The individual tags are set to have all space available and pointers are
 * reset, but stale data might remain in the blocks.  This can be safely ignored
 * in most cases, provided the peripheral is never pointed to the corrupt/incomplete
 * list fragments.
 */
void dma_bd_rewind(struct dma_bd_ring_t *ring)
{
	struct dma_bd_tag_t *tag = ring->dma_bd_base;

	while(tag != NULL) {
		tag->n_bds_free = tag->n_bds;
		tag->bd_working_ptr = tag->bd_base_ptr;

		tag = tag->next_alloc;
	}

	ring->dma_bd_current = ring->dma_bd_base;
}

/*
 * Add an entry to the current BD list.  If the number of BDs available in the current tag
 * has been exhausted, then a new tag will be allocated.
 *
 * If the `user` field is set to NULL, then no userdata entries will be written.
 *
 * Note that normally flags should be zero because the finalise function adds the SOF
 * and EOF flags.  Only use for packet marking (not presently used for MIPI.)
 */
int dma_bd_add_raw_sg_entry(struct dma_bd_ring_t *ring, uint32_t base_addr, int size, int flags, struct dma_bd_sg_userdata_t *user)
{
	struct dma_bd_sg_descriptor_t *parent, *next;
	int res;

	// Nothing to do?  Zero size is invalid for a BD, see pg. 42 of Xil PG021
	// Maximum size exceeded is also an error
	if(size == 0) {
		return BD_RES_PARAM_ERR;
	}

	if(size > BD_MAX_SIZE) {
		return BD_RES_PARAM_ERR;
	}

	// Find a slot for this descriptor.
	if(ring->dma_bd_current->n_bds_free == 0) {
		res = dma_bd_allocate(ring, 0, BD_NEXT_ENTRY);
		if(res != BD_RES_OK) {
			return res;
		}
	}

	parent = ring->dma_bd_current->bd_working_ptr;
	next = parent + 1;  // + BD_SIZE bytes, pointer arithmetic

	D_ASSERT((((int)parent) % BD_ALIGN) == 0);
	D_ASSERT((((int)next) % BD_ALIGN) == 0);

	// Zero any unused fields.
	next->status = 0;
	next->buffer_address_msb = 0;
	next->nxtdesc_msb = 0;

	// Write important fields
	next->control = (size & BD_SIZE_MASK) | (flags & BD_FLAGS_MASK);
	next->buffer_address = base_addr;
	next->nxtdesc = 0;
	parent->nxtdesc = (uint32_t)next;

	// Copy user fields (if applicable)
	if(user != NULL) {
		next->app0 = user->app0;
		next->app1 = user->app1;
		next->app2 = user->app2;
		next->app3 = user->app3;
		next->app4 = user->app4;
	}

	ring->dma_bd_current->n_bds_free--;
	ring->dma_bd_current->bd_working_ptr = next;
	ring->dma_bd_stats.num_bds_filled++;

	return BD_RES_OK;
}

/*
 * Add a potentially large scatter-gather entry, which might require more than
 * one SG entry to be added if the size exceeds the nominal BD size.
 */
int dma_bd_add_large_sg_entry(struct dma_bd_ring_t *ring, uint32_t base_addr, int size, int flags, struct dma_bd_sg_userdata_t *user)
{
	int res, block_size = 0;
	uint32_t addr = base_addr;

	while(size > 0) {
		block_size = MIN(size, BD_MAX_SIZE);

		res = dma_bd_add_raw_sg_entry(ring, addr, block_size, flags, user);
		if(res != BD_RES_OK) {
			return res;
		}

		addr += block_size;
		size -= block_size;
	}

	return BD_RES_OK;
}

/*
 * Add a zero data section to the SG ring given by `ring'.  The number of
 * bytes is specified.  References to the void area of memory will be added
 * which can be used to pad a transfer to the required size.  Userdata and
 * flags can be packed with the zero data, if required.
 */
int dma_bd_add_zero_sg_entry(struct dma_bd_ring_t *ring, int size, int flags, struct dma_bd_sg_userdata_t *user)
{
	int res, block_size = 0;

	while(size > 0) {
		block_size = MIN(size, BD_VOID_ZONE_BYTES);

		res = dma_bd_add_raw_sg_entry(ring, (uint32_t)g_void_zone, block_size, flags, user);
		if(res != BD_RES_OK) {
			return res;
		}

		size -= block_size;
	}

	return BD_RES_OK;
}

/*
 * Start the DMA BD process:
 *   - Set the first and last entries as SOF and EOF.
 *   - Ensure the last pointer points to the first.
 *   - Write the starting pointer to the peripheral
 *   - Start the peripheral
 *
 * @param	periph		Reference to the peripheral
 * @param	tx_rx		0 = Transmit, 1 = Receive
 */
int dma_bd_start(XAxiDma *periph, struct dma_bd_ring_t *ring, int tx_rx)
{
	uint32_t reg_base;

	if(tx_rx == BD_TRANSMIT) {
		reg_base = XAXIDMA_TX_OFFSET;
	} else if(tx_rx == BD_RECEIVE) {
		reg_base = XAXIDMA_RX_OFFSET;
	} else {
		return BD_RES_PARAM_ERR;
	}

	ring->dma_bd_base->bd_base_ptr->control |= BD_SOF;

	/*
	 * Create a circular linked list.  The AXIDMA peripheral stops when the next
	 * pointer points to the first pointer.
	 */
	ring->dma_bd_current->bd_working_ptr->nxtdesc = (uint32_t)ring->dma_bd_base->bd_base_ptr;
	ring->dma_bd_current->bd_working_ptr->control |= BD_EOF;

	// We must write CDESC before TDESC, before starting the engine.  Page 20, Xil PG021.
	XAxiDma_WriteReg(periph->RegBase, XAXIDMA_CDESC_OFFSET + reg_base, (uint32_t)ring->dma_bd_base->bd_base_ptr);
	XAxiDma_WriteReg(periph->RegBase, XAXIDMA_TDESC_OFFSET + reg_base, (uint32_t)ring->dma_bd_current->bd_working_ptr);

	XAxiDma_WriteReg(periph->RegBase, XAXIDMA_CR_OFFSET + reg_base, \
			XAxiDma_ReadReg(periph->RegBase, XAXIDMA_CR_OFFSET + reg_base) | XAXIDMA_CR_RUNSTOP_MASK);

	return BD_RES_OK;
}

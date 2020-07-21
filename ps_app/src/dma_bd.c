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

#include "xil_cache.h"
#include "xaxidma.h"

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

/*
 * A 64KB block of zero data which is used to pad transmissions with null data.  Allocated on boot
 * from the heap.
 */
uint8_t *g_void_zone;

/*
 * Initialise the DMA BD allocator.
 */
void dma_bd_init()
{
	// Build sanity check
	D_ASSERT(sizeof(struct dma_bd_sg_descriptor_t) == BD_SIZE);

	// Allocate global void zone: a 'guaranteed' block of zeroes BD_VOID_ZONE_BYTES long.
	// Must be 32-byte aligned (i.e. along cache lines.)
	g_void_zone = memalign(32, BD_VOID_ZONE_BYTES);
	if(g_void_zone == NULL) {
		d_printf(D_ERROR, "dma_bd: fatal error allocating void zone of %d bytes", BD_VOID_ZONE_BYTES);
		d_trap_handle();
		return;
	}

	memset(g_void_zone, 0x00, BD_VOID_ZONE_BYTES);
	Xil_DCacheFlushRange((INTPTR)g_void_zone, BD_VOID_ZONE_BYTES);

	d_printf(D_INFO, "dma_bd: void zone @ 0x%08x (%d bytes)", g_void_zone, BD_VOID_ZONE_BYTES);
}

/*
 * Create a BD ring.  The initial tag is also created and allocated.  If this function fails,
 * `ring` is written with a NULL pointer and an error response is returned.
 */
int dma_bd_create_ring(struct dma_bd_ring_t **ring)
{
	struct dma_bd_ring_t *work;
	int res;

	work = calloc(sizeof(struct dma_bd_ring_t), 1);

	if(work == NULL) {
		d_printf(D_ERROR, "dma_bd: failed to allocate ring (%d bytes)", sizeof(struct dma_bd_ring_t));
		return BD_RES_MEM_ALLOC_ERR;
	}

	res = dma_bd_allocate(work, 0, BD_FIRST_ENTRY);

	if(res != BD_RES_OK) {
		*ring = NULL;
		return res;
	}

	*ring = work;
	return BD_RES_OK;
}

/*
 * Destroy and free a BD ring.  All tags are also freed.  (Something-something Sauron...)
 */
int dma_bd_destroy_ring(struct dma_bd_ring_t *ring)
{
	D_ASSERT(ring != NULL);

	dma_bd_free(ring);
	free(ring);

	return BD_RES_OK;
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
	struct dma_bd_tag_t *next_tag = ring->current->next_alloc;

	/*
	 * If the ring has a next item then reuse that instead, after scrubbing it.
	 */
	if(next_tag != NULL) {
		if(next_tag->bd_base_ptr != NULL && next_tag->n_bds > 0) {
			ring->current = next_tag;
			ring->last = ring->current;
			next_tag->bd_working_ptr = next_tag->bd_base_ptr;
			next_tag->bd_last_ptr = next_tag->bd_base_ptr;
			next_tag->n_bds_free = next_tag->n_bds;
			return BD_RES_OK;
		} else {
			// Cleanup if invalid tag.  Should not happen.
			d_printf(D_WARN, "dma_bd: cleaning invalid tag 0x%08x", next_tag);
			dma_bd_free_from(next_tag);
		}
	}

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
	tag->bd_base_ptr = memalign(BD_ALIGN, bd_size);

	tag->bd_last_ptr = 0;
	tag->bd_working_ptr = tag->bd_base_ptr;
	tag->bd_base_ptr->nxtdesc = tag->bd_base_ptr + 1;  // Create first nxtdesc reference  [TODO: Fix warning]

	if(tag->bd_base_ptr == NULL) {
		d_printf(D_ERROR, "dma_bd: failed to allocate BD block (%d bytes, %d BDs)", bd_size, n_bds);
		return BD_RES_MEM_ALLOC_ERR;
	}

	D_ASSERT(((int)(tag->bd_base_ptr) % BD_ALIGN) == 0);

	// Clear the BD region.
	memset(tag->bd_base_ptr, 0x00, bd_size);

	if(first == BD_FIRST_ENTRY) {
		// Make this block the first, last and current entry
		ring->base = tag;
		ring->current = tag;
		ring->last = tag;
	} else {
		/*
		 * Append this block to the list and move the current pointer.  Link the last working BD entry
		 * to the first entry of the new one, creating an inner linked list.
		 */
		ring->current->bd_working_ptr = tag->bd_base_ptr;
		ring->current->next_alloc = tag;
		ring->current = ring->current->next_alloc;
	}

	tag->next_alloc = NULL;

	ring->stats.num_bds_alloc += n_bds;
	ring->stats.num_tags_alloc++;

	return BD_RES_OK;
}

/*
 * Free all BDs starting from a given entry, until the end of the list.
 *
 * N.B. May contain gluten.
 */
void dma_bd_free_from(struct dma_bd_tag_t *tag)
{
	struct dma_bd_tag_t *tag_next;

	while(tag != NULL) {
		d_printf(D_INFO, "Free: 0x%08x (bd_base_ptr)", tag->bd_base_ptr);

		free(tag->bd_base_ptr);
		tag->bd_base_ptr = NULL;

		d_printf(D_INFO, "Free: 0x%08x (prev)", tag);

		tag_next = tag->next_alloc;
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
	dma_bd_free_from(ring->base);
	ring->total_bd_count = 0;
}

/*
 * Trim the list of blocks, freeing any unused blocks at the end of the BD ring.
 * This walks from the working pointer until it reaches a NULL next tag.
 */
void dma_bd_trim(struct dma_bd_ring_t *ring)
{
	if(ring->current->next_alloc != NULL) {
		dma_bd_free_from(ring->current->next_alloc);
		ring->current->next_alloc = NULL;
	}
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
	struct dma_bd_tag_t *tag = ring->base;

	while(tag != NULL) {
		tag->n_bds_free = tag->n_bds;
		tag->bd_working_ptr = tag->bd_base_ptr;

		tag = tag->next_alloc;
	}

	ring->total_bd_count = 0;
	ring->total_block_size = 0;
	ring->current = ring->base;
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
	struct dma_bd_sg_descriptor_t *entry = NULL;
	int res, alloc = 0;

	D_ASSERT(ring != NULL);

	// BD sizes and addresses must be 64-bit aligned
	D_ASSERT((size & 7) == 0);
	D_ASSERT((base_addr & 7) == 0);

	//d_printf(D_INFO, "dma_bd_add_raw_sg_entry(0x%08x, 0x%08x, %8d, 0x%08x, 0x%08x)", ring, base_addr, size, flags, user);

	/*
	 * Nothing to do?  Zero size is invalid for a BD, see pg. 42 of Xil PG021.
	 *
	 * Maximum size exceeded is also an error (use dma_bd_add_large_sg_entry for
	 * spanning blocks.)
	 */
	if(size == 0) {
		return BD_RES_PARAM_ERR;
	} else if(size > BD_MAX_SIZE) {
		return BD_RES_PARAM_ERR;
	}

	/*
	 * Fetch the working BD.  This is guaranteed by design to always point to an available
	 * BD.  Once the working pointer is incremented beyond the list size,
	 */
	entry = ring->current->bd_working_ptr;

	//d_printf(D_INFO, "dma_bd_add_raw_sg_entry @ 0x%08x", entry);

	// Cheap sanity checks providing BD_ALIGN is pow2 (guaranteed by design)
	D_ASSERT((((int)entry) % BD_ALIGN) == 0);

	entry->status = 0;
	entry->buffer_address_msb = 0;
	entry->control = (size & BD_SIZE_MASK) | (flags & BD_FLAGS_MASK);
	entry->buffer_address = base_addr;

	// Copy user fields (if applicable)
	if(user != NULL) {
		entry->app0 = user->app0;
		entry->app1 = user->app1;
		entry->app2 = user->app2;
		entry->app3 = user->app3;
		entry->app4 = user->app4;
	}

	ring->stats.num_bds_filled++;
	ring->stats.total_bytes += size;
	ring->current->n_bds_free--;

	ring->total_bd_count++;
	ring->total_block_size += size;

	/*
	 * Find a slot for the next descriptor.
	 *
	 * If there are insufficient BDs free at the current tag, allocate a new tag,
	 * and set the previous descriptor (the one we just added) to point to this
	 * new buffer.
	 */
	ring->current->bd_last_ptr = entry;
	ring->last = ring->current;

	if(ring->current->n_bds_free == 0) {
		res = dma_bd_allocate(ring, 0, BD_NEXT_ENTRY);
		if(res != BD_RES_OK) {
			return res;
		}
	} else {
		ring->current->bd_working_ptr++;
	}

	entry->nxtdesc = (uint32_t)ring->current->bd_working_ptr;
	entry->nxtdesc_msb = 0;

	//ring->current->bd_working_ptr->nxtdesc = (uint32_t)entry;
	//ring->current->bd_working_ptr->nxtdesc_msb = 0;

	return BD_RES_OK;
}

/*
 * Add a potentially large scatter-gather entry, which might require more than
 * one SG entry to be added if the size exceeds the nominal BD size.  If this
 * is not required, then only one entry will be added.
 */
int dma_bd_add_large_sg_entry(struct dma_bd_ring_t *ring, uint32_t base_addr, int size, int flags, struct dma_bd_sg_userdata_t *user)
{
	int res, block_size = 0;
	uint32_t addr = base_addr;

	// Zero size entries not supported
	if(size == 0) {
		return BD_RES_ZERO_SIZE;
	}

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
 *
 * To create the zero entry, references to the 64KB zero page are created,
 * up to the length required.
 */
int dma_bd_add_zero_sg_entry(struct dma_bd_ring_t *ring, int size, int flags, struct dma_bd_sg_userdata_t *user)
{
	int res, block_size = 0;

	// Zero size entries not supported
	if(size == 0) {
		return BD_RES_ZERO_SIZE;
	}

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
 * Ensures all BDs are flushed to RAM.  Each block, starting from the base block
 * and going up to the current block but no further, is flushed.  Since each block
 * is guaranteed to be 64-byte aligned (per AxiDma requirements) this lines up
 * nicely with the 32-byte cache lines.
 */
void dma_bd_flush_to_ram(struct dma_bd_ring_t *ring)
{
	struct dma_bd_tag_t *tag = ring->base;

	//d_printf(D_WARN, "Flush to RAM");

	do {
		//d_printf(D_INFO, "FlushRange 0x%08x, %d bytes", (INTPTR)tag->bd_base_ptr, (tag->n_bds - tag->n_bds_free) * BD_SIZE);
		Xil_DCacheFlushRange((INTPTR)tag->bd_base_ptr, (tag->n_bds - tag->n_bds_free) * BD_SIZE);
		tag = tag->next_alloc;
	} while(tag != NULL) ;

	//d_printf(D_WARN, "Flush DONE");
}

/*
 * Finalise the BD ring:
 *   - Set the first and last entries as SOF and EOF.
 *   - Ensure the last pointer points to the first.
 *
 * @param	ring		Reference to the ring
 */
int dma_bd_finalise(struct dma_bd_ring_t *ring)
{
	ring->base->bd_base_ptr->control |= BD_SOF;

	// Create a circular linked list.  The AXIDMA peripheral stops when the next
	// pointer points to the first pointer.
	//ring->last->bd_last_ptr->nxtdesc = 0x00000000;
	ring->last->bd_last_ptr->nxtdesc = (uint32_t)ring->base->bd_base_ptr;
	ring->last->bd_last_ptr->control |= BD_EOF;
}

/*
 * Start the DMA BD process:
 *   - Set the first and last entries as SOF and EOF.
 *   - Ensure the last pointer points to the first.
 *   - Write the starting pointer to the peripheral
 *   - Start the peripheral
 *
 * @param	periph		Reference to the peripheral
 * @param	ring		Reference to the ring
 * @param	flags		See BD_STFLAGS_x
 */
int dma_bd_start(XAxiDma *periph, struct dma_bd_ring_t *ring, int flags)
{
	uint32_t reg_base;

	// At least TRANSMIT or RECEIVE must be set
	if(flags & BD_STFLAGS_TRANSMIT) {
		reg_base = XAXIDMA_TX_OFFSET;
	} else if(flags & BD_STFLAGS_RECEIVE) {
		reg_base = XAXIDMA_RX_OFFSET;
	} else {
		return BD_RES_PARAM_ERR;
	}

	dma_bd_finalise(ring);
	dma_bd_flush_to_ram(ring);

	// if DEBUG flag set then print debug info after finalising
	if(flags & BD_STFLAGS_DUMP_DEBUG) {
		dma_bd_debug_dump(ring);
	}

	XAxiDma_WriteReg(periph->RegBase, XAXIDMA_CDESC_OFFSET + reg_base, (uint32_t)ring->base->bd_base_ptr);

	XAxiDma_WriteReg(periph->RegBase, XAXIDMA_CR_OFFSET + reg_base, \
			XAxiDma_ReadReg(periph->RegBase, XAXIDMA_CR_OFFSET + reg_base) | XAXIDMA_CR_RUNSTOP_MASK);

	XAxiDma_WriteReg(periph->RegBase, XAXIDMA_TDESC_OFFSET + reg_base, (uint32_t)ring->last->bd_last_ptr);

	return BD_RES_OK;
}


/*
 * Dump the state of a given BD ring.
 */
void dma_bd_debug_dump(struct dma_bd_ring_t *ring)
{
	struct dma_bd_tag_t *tag = ring->base;
	struct dma_bd_sg_descriptor_t *desc;
	char desc_as_bytes[BD_SIZE];
	int used, i, b;
	char s, e, c;
	uint32_t total_bytes = 0;

	d_printf(D_RAW, "\r\n");
	d_printf(D_RAW, "** Debug for dma_bd_ring_t @ 0x%08x **\r\n", ring);
	d_printf(D_RAW, "\r\n");
	d_printf(D_RAW, "base           = 0x%08x\r\n", ring->base);
	d_printf(D_RAW, "current        = 0x%08x\r\n", ring->current);
	d_printf(D_RAW, "num_bds_alloc  = %d\r\n", ring->stats.num_bds_alloc);
	d_printf(D_RAW, "num_bds_filled = %d\r\n", ring->stats.num_bds_filled);
	d_printf(D_RAW, "num_tags_alloc = %d\r\n", ring->stats.num_tags_alloc);
	d_printf(D_RAW, "total_bd_count = %d\r\n", ring->total_bd_count);
	d_printf(D_RAW, "\r\n");

	while(tag != NULL) {
		used = tag->n_bds - tag->n_bds_free;

		d_printf(D_RAW, "== Tag @ 0x%08x,  next tag @ 0x%08x,  base_bd 0x%08x,  working_bd 0x%08x,  last_bd 0x%08x,  %d/%d entries consumed == \r\n", \
				tag, tag->next_alloc, tag->bd_base_ptr, tag->bd_working_ptr, tag->bd_last_ptr, used, tag->n_bds);

		//Xil_DCacheInvalidateRange((INTPTR)tag->bd_base_ptr, used * BD_SIZE);

		for(i = 0; i < used; i++) {
			desc = tag->bd_base_ptr + i;
			memcpy(&desc_as_bytes, desc, BD_SIZE);

			//desc_as_bytes = (char*)tag->bd_base_ptr;

			d_printf(D_RAW, "0x%08x: ", desc);

			for(b = 0; b < BD_SIZE; b++) {
				c = desc_as_bytes[b];

				if(c != '\0') {
					d_printf(D_RAW, "\033[97m%02x\033[0m", c);
				} else {
					d_printf(D_RAW, "%02x", c);
				}
			}

			// Start/End flags
			s = (desc->control & BD_SOF) ? 'S' : ' ';
			e = (desc->control & BD_EOF) ? 'E' : ' ';
			total_bytes += (desc->control & BD_SIZE_MASK);

			d_printf(D_RAW, "    B:0x%08x, L:0x%08x (%8d) F:%c%c N:0x%08x S:0x%08x T:%9d %c\r\n", \
					desc->buffer_address, desc->control & BD_SIZE_MASK, desc->control & BD_SIZE_MASK, s, e, desc->nxtdesc, desc->status, total_bytes, \
					((desc->status & ~BD_STATUS_MASK) == (desc->control & BD_SIZE_MASK)) ? 'C' : '-');
		}

		d_printf(D_RAW, "\r\n");

		tag = tag->next_alloc;
	}

	d_printf(D_RAW, "** Ends **\r\n\r\n");
}

/*
 * Testcase for dma_bd library.  dma_bd_init should have been called first.
 */
void dma_bd_test()
{
	struct dma_bd_ring_t *ring;
	int i;

	dma_bd_create_ring(&ring);
	dma_bd_debug_dump(ring);

	for(i = 0; i < 256; i++) {
		dma_bd_add_large_sg_entry(ring, 0x80000000, 262144, 0, NULL);
	}

	d_printf(D_RAW, "\r\n\r\n** Finalise **\r\n\r\n");

	dma_bd_finalise(ring);
	dma_bd_debug_dump(ring);

	d_printf(D_RAW, "\r\n\r\n** Rewind **\r\n\r\n");

	dma_bd_rewind(ring);
	dma_bd_debug_dump(ring);

	d_printf(D_RAW, "\r\n\r\n** Add again **\r\n\r\n");

	for(i = 0; i < 90; i++) {
		dma_bd_add_large_sg_entry(ring, 0x80000000, 262144, 0, NULL);
	}

	dma_bd_debug_dump(ring);

	d_printf(D_RAW, "\r\n\r\n** Free **\r\n\r\n");

	dma_bd_free(ring);
	dma_bd_debug_dump(ring);

	//dma_bd_destroy_ring(ring);
}

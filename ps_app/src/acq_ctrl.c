/*
 * acq_ctrl.h
 *
 * This file is part of YAOS and is licensed under the MIT License.
 *
 *  Created on: 15 Jun 2020
 *      Author: Tom
 */

#include "acq_ctrl.h"
#include "acquire.h"
#include "mipi_csi.h"
#include "system_control.h"

#include <stdint.h>

/*
 * Acquisition control:  outer control of acquisition engine behaviour.
 */

struct acq_ctrl_state_t g_acq_ctrl_state;

/*
 * Initialise the acquistion outer controller.
 */
void acq_ctrl_init()
{
	g_acq_ctrl_state.last_acquisition = 0;
	g_acq_ctrl_state.acq_period = 1000000 / 50;
	g_acq_ctrl_state.auto_trigger_counter = 0;
	g_acq_ctrl_state.seq = 0;

	g_acq_ctrl_state.state = ACQCTRL_IDLE;

	// For the time being this is set to two but later it will change according to
	// the requested memory depth.
	g_acq_ctrl_state.n_wave_groups = 2;

	// Setup IOs
	gpio_set_ps_irq_direction(ACQCTRL_IRQIO_READY, GPIO_HAL_OUTPUT);
	gpio_set_ps_irq_direction(ACQCTRL_IRQIO_SEND, GPIO_HAL_INPUT);

	gpio_write_ps_irq(ACQCTRL_IRQIO_READY, 0);
}

/*
 * Set the period between acquisition.  Bounds checks are performed.
 */
int acq_ctrl_setup_auto_period(uint32_t period_us)
{
	// Can't change if not stopped: ignore
	if(g_acq_ctrl_state.tick_run) {
		return ACQCTRL_RES_NOT_STOPPED;
	}

	if(period_us < SEC_TO_US(ACQCTRL_MIN_PERIOD)) {
		return ACQCTRL_RES_PARAM_ERROR;
	}

	if(period_us > SEC_TO_US(ACQCTRL_MAX_PERIOD)) {
		return ACQCTRL_RES_PARAM_ERROR;
	}

	d_printf(D_INFO, "Set period to %d us", period_us);
	g_acq_ctrl_state.acq_period = period_us;

	return ACQCTRL_RES_OK;
}

/*
 * Start the acquisition controller; does not start the acquisition
 * until the next tick.
 */
int acq_ctrl_start()
{
	// Can't re-start if not stopped: ignore
	/*
	if(g_acq_ctrl_state.tick_run) {
		return ACQCTRL_RES_NOT_STOPPED;
	}
	*/

	// Set acquisition time to force an acquisition start soon
	g_acq_ctrl_state.last_acquisition = systick_get_time_us_nonirq();
	g_acq_ctrl_state.start_run = 1;

	// Start the acquisition now ... we handle the results in the tick
	acq_start(ACQ_START_FIFO_RESET);
}

/*
 * Stop the acquisition.  The acquisition stops on the next tick.
 */
void acq_ctrl_stop()
{
	g_acq_ctrl_state.stop_run = 1;
}

/*
 * Reset the acquisition controller.
 */
void acq_ctrl_reset()
{
	acq_ctrl_stop();
	acq_ctrl_tick();

	// just in case the message was not received...
	g_acq_ctrl_state.state = ACQCTRL_IDLE;
}

/*
 * Main tick controller for acquisition.  Manages acquisition super-controller behaviour.
 */
void acq_ctrl_tick()
{
	struct mipi_csi_stream_queue_item_t q_item;
	uint64_t time = systick_get_time_us_nonirq();

	switch(g_acq_ctrl_state.state) {
		case ACQCTRL_IDLE:
			//outbyte('I');

			g_acq_ctrl_state.tick_run = 0;

			if(g_acq_ctrl_state.start_run) {
				g_acq_ctrl_state.state = ACQCTRL_ACQUIRING;
				g_acq_ctrl_state.tick_run = 1;
			}

			if(g_acq_ctrl_state.stop_run) {
				g_acq_ctrl_state.stop_run = 0;
				g_acq_ctrl_state.tick_run = 0;
			}
			break;

		case ACQCTRL_ACQUIRING:
			//outbyte('a');

			if(g_acq_ctrl_state.stop_run) {
				g_acq_ctrl_state.state = ACQCTRL_IDLE;
				g_acq_ctrl_state.stop_run = 0;
			} else {
				if((time - g_acq_ctrl_state.last_acquisition) > g_acq_ctrl_state.acq_period) {
					// Stop the acquisition
					acq_stop();

					/*
					// How many waves do we have?  Zero = start the auto trigger timer (if enabled)
					if(acq_get_nwaves_done() == 0) {
						if(g_acq_ctrl_state.auto_trigger_counter > g_acq_ctrl_state.auto_trigger_timeout) {
							// here we'd force a trigger ... ?
						} else {
							g_acq_ctrl_state.auto_trigger_counter += g_acq_ctrl_state.acq_period;
						}

						//d_printf(D_RAW, "NoTrg ");
					} else {
						g_acq_ctrl_state.state = ACQCTRL_DONE_ACQUIRE_WAIT_PI_READY;
					}
					*/

					g_acq_ctrl_state.state = ACQCTRL_DONE_ACQUIRE_WAIT_PI_READY;
				}
			}
			break;

		case ACQCTRL_DONE_ACQUIRE_WAIT_PI_READY:
			/*
			 * Wait for the Pi to signal that it is done processing the last packet.  This
			 * is signalled by the SEND signal being low.
			 */
			//outbyte('R');

			if(!gpio_read_ps_irq(ACQCTRL_IRQIO_SEND)) {
				g_acq_ctrl_state.state = ACQCTRL_DONE_ACQUIRE_WAIT_PI_ACK;
			} else {
				if(!g_acq_ctrl_state.miss_slotA) {
					if((time - g_acq_ctrl_state.last_acquisition) > (g_acq_ctrl_state.acq_period * 2)) {
						g_acq_ctrl_state.miss_slotA = 1;
						g_acq_ctrl_state.stats.slot_miss_countA++;
					}
				}
			}
			break;

		case ACQCTRL_DONE_ACQUIRE_WAIT_PI_ACK:
			/*
			 * Signal packet availability.  Wait (through a re-entrant mode) for the Pi to say
			 * that it is ready to accept this data.
			 */
			//outbyte('A');

			gpio_write_ps_irq(ACQCTRL_IRQIO_READY, 1);

			if(gpio_read_ps_irq(ACQCTRL_IRQIO_SEND)) {
				gpio_write_ps_irq(ACQCTRL_IRQIO_READY, 0);
				g_acq_ctrl_state.state = ACQCTRL_SEND_DATA;
			} else {
				if(!g_acq_ctrl_state.miss_slotB) {
					if((time - g_acq_ctrl_state.last_acquisition) > (g_acq_ctrl_state.acq_period * 2)) {
						g_acq_ctrl_state.miss_slotB = 1;
						g_acq_ctrl_state.stats.slot_miss_countB++;
					}
				}
			}
			break;

		case ACQCTRL_SEND_DATA:
			/*
			 * If using >=2 buffers then we need to swap the buffers (in future software, rotate through
			 * the list of buffers available.)
			 */
			//outbyte('S');

			if(g_acq_ctrl_state.n_wave_groups >= 2) {
				acq_swap();
				acq_rewind();
				g_acq_ctrl_state.last_acquisition = time;
				acq_start(ACQ_START_FIFO_RESET);

				// Prepare the queued item.  In the future we'll remove all references to the previous task queue.
				q_item.item_type = MCSI_TYPE_WAVEFORM_RANGE;
				q_item.config.clip_start = 0;
				q_item.config.clip_end = g_acq_state.pre_buffsz + g_acq_state.post_buffsz;
				q_item.config.wave_start = 0;
				q_item.config.wave_end = acq_get_nwaves_request();
				q_item.config.flags = 0;
				q_item.config.seq = g_acq_ctrl_state.seq;
				q_item.wave_buffer_first = g_acq_state.acq_done_first;
				g_acq_ctrl_state.seq++;

				//mipi_csi_generate_sg_list_for_waves(&q_item);
				mipi_csi_process_queue_item(&q_item);

				g_acq_ctrl_state.state = ACQCTRL_WAIT_FOR_SEND;
			} else {
				// Case not handled yet
				D_ASSERT(0);
			}

			// Clear slot miss state so we can count next slot miss
			g_acq_ctrl_state.miss_slotA = 0;
			g_acq_ctrl_state.miss_slotB = 0;
			break;

		case ACQCTRL_WAIT_FOR_SEND:
			if(mcsi_get_task_done()) {
				//outbyte('W');

				// If done we can go back to waiting for the acquisition to complete
				g_acq_ctrl_state.state = ACQCTRL_ACQUIRING;
			}
			break;
	}
}

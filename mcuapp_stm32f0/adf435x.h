/**
 * This file is part of YAOS and licenced under the MIT licence.
 * Copyright (c) 2019 Thomas Oldbury
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef ___ADF435X_H___
#define ___ADF435X_H___

#include "stm32f0xx.h"
#include "stm32f0xx_hal.h"
#include "stm32f0xx_hal_gpio.h"
#include "stm32f0xx_hal_usart.h"
#include "stm32f0xx_hal_rcc.h"

#include <stdint.h>
#include <stdbool.h>

#define ADF345X_DELAY_BIT_CYCLE()       // { __asm__("nop"); }

#define ADF435X_INPUT_REF_MHZ           25
                                          
/*
 * ADF435x registe definitions
 */
#define _ADF435X_R0_INT_MASK            0xffff
#define _ADF435X_R0_INT_SHIFT           15

#define _ADF435X_R0_FRAC_MASK           0x0fff
#define _ADF435X_R0_FRAC_SHIFT          3

#define ADF435X_R1_PHASE_ADJ_OFF        (0 << 28)
#define ADF435X_R1_PHASE_ADJ_ON         (1 << 28)
#define ADF435X_R1_PRESCALER_4_5        (0 << 27)
#define ADF435X_R1_PRESCALER_8_9        (1 << 27)

#define _ADF435X_R1_PHASE_MASK          0x0fff
#define _ADF435X_R1_PHASE_SHIFT         15

#define _ADF435X_R1_MOD_MASK            0x0fff
#define _ADF435X_R1_MOD_SHIFT           3

#define _ADF435X_R2_LNLS_SHIFT          29
#define ADF435X_R2_LOW_NOISE_MODE       (0x00 << _ADF435X_R2_LNLS_SHIFT)
#define ADF435X_R2_LOW_SPUR_MODE        (0x03 << _ADF435X_R2_LNLS_SHIFT)

#define _ADF435X_R2_MUX_SHIFT           26
#define ADF435X_R2_MUX_3STATE           (0x00 << _ADF435X_R2_MUX_SHIFT)
#define ADF435X_R2_MUX_DVDD             (0x01 << _ADF435X_R2_MUX_SHIFT)
#define ADF435X_R2_MUX_DGND             (0x02 << _ADF435X_R2_MUX_SHIFT)
#define ADF435X_R2_MUX_RCTR             (0x03 << _ADF435X_R2_MUX_SHIFT)
#define ADF435X_R2_MUX_NDIV             (0x04 << _ADF435X_R2_MUX_SHIFT)
#define ADF435X_R2_MUX_ALOCK            (0x05 << _ADF435X_R2_MUX_SHIFT)
#define ADF435X_R2_MUX_DLOCK            (0x06 << _ADF435X_R2_MUX_SHIFT)

#define ADF435X_R2_REF_DOUBLER          (1 << 25)
#define ADF435X_R2_REF_DIVIDE_BY_2      (1 << 24)

#define _ADF435X_R2_RCOUNTER_MASK       0x03ff
#define _ADF435X_R2_RCOUNTER_SHIFT      14

#define ADF435X_R2_DOUBLE_BUFF_DIS      (0 << 13)
#define ADF435X_R2_DOUBLE_BUFF_ENA      (1 << 13)

#define _ADF435X_R2_CHARGEPUMP_MASK     0x000f
#define _ADF435X_R2_CHARGEPUMP_SHIFT    9

#define ADF435X_R2_LDF_FRAC_N           (0 << 8)
#define ADF435X_R2_LDF_INT_N            (1 << 8)
#define ADF435X_R2_LDP_10NS             (0 << 7)
#define ADF435X_R2_LDP_6NS              (1 << 7)
#define ADF435X_R2_PD_POL_NEG           (0 << 6)
#define ADF435X_R2_PD_POL_POS           (1 << 6)
#define ADF435X_R2_POWERDOWN_DIS        (0 << 5)
#define ADF435X_R2_POWERDOWN_ENA        (1 << 5)
#define ADF435X_R2_CP_3STATE_DIS        (0 << 4)
#define ADF435X_R2_CP_3STATE_ENA        (1 << 4)
#define ADF435X_R2_CP_CTR_RESET_DIS     (0 << 3)
#define ADF435X_R2_CP_CTR_RESET_ENA     (1 << 3)

#define ADF435X_R3_BAND_SEL_LOW         (0 << 23)
#define ADF435X_R3_BAND_SEL_HIGH        (1 << 23)
#define ADF435X_R3_ANTIBACKLASH_6NS     (0 << 22)
#define ADF435X_R3_ANTIBACKLASH_3NS     (1 << 22)
#define ADF435X_R3_CHARGE_CANCEL_DIS    (0 << 21)
#define ADF435X_R3_CHARGE_CANCEL_ENA    (1 << 21)
#define ADF435X_R3_CYCLE_SLIP_RED_DIS   (0 << 18)
#define ADF435X_R3_CYCLE_SLIP_RED_ENA   (1 << 18)

#define _ADF435X_R3_CLOCK_DIV_SHIFT     15
#define ADF435X_R3_CLOCK_DIV_OFF        (0x00 << _ADF435X_R3_CLOCK_DIV_SHIFT)
#define ADF435X_R3_CLOCK_DIV_FASTLOCK   (0x01 << _ADF435X_R3_CLOCK_DIV_SHIFT)
#define ADF435X_R3_CLOCK_DIV_RESYNC     (0x02 << _ADF435X_R3_CLOCK_DIV_SHIFT)

#define _ADF435X_R3_CLOCK_DIV_VAL_MASK  0x0fff
#define _ADF435X_R3_CLOCK_DIV_VAL_SHIFT 3

#define ADF435X_R4_FBACK_DIVIDED        (0 << 23)
#define ADF435X_R4_FBACK_FUNDAMENTAL    (1 << 23)

#define _ADF435X_R4_RFDIV_SEL_SHIFT     20
#define _ADF435X_R4_RFDIV_SEL_MASK      (0x07 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_1          (0x00 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_2          (0x01 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_4          (0x02 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_8          (0x03 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_16         (0x04 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_32         (0x05 << _ADF435X_R4_RFDIV_SEL_SHIFT)
#define ADF435X_R4_RFDIV_SEL_64         (0x06 << _ADF435X_R4_RFDIV_SEL_SHIFT)

#define _ADF435X_R4_BSEL_CLK_DIV_MASK   0x00ff
#define _ADF435X_R4_BSEL_CLK_DIV_SHIFT  12

#define ADF435X_R4_VCO_POWERED_UP       (0 << 11)
#define ADF435X_R4_VCO_POWERED_DOWN     (1 << 11)
#define ADF435X_R4_MUTE_DISABLED        (0 << 10)
#define ADF435X_R4_MUTE_ENABLED         (1 << 10)
#define ADF435X_R4_AUX_DIV_OUT          (0 << 9)
#define ADF435X_R4_AUX_FUNDAMENTAL      (1 << 9)

#define ADF435X_R4_AUX_OUT_DISABLED     (0 << 8)
#define ADF435X_R4_AUX_OUT_ENABLED      (1 << 8)

#define _ADF435X_R4_AUX_POWER_SHIFT     6
#define _ADF435X_R4_AUX_POWER_MASK      (0x03 << _ADF435X_R4_AUX_POWER_SHIFT)
#define ADF435X_R4_AUX_POWER_NEG_4DBM   (0x00 << _ADF435X_R4_AUX_POWER_SHIFT)
#define ADF435X_R4_AUX_POWER_NEG_1DBM   (0x01 << _ADF435X_R4_AUX_POWER_SHIFT)
#define ADF435X_R4_AUX_POWER_POS_2DBM   (0x02 << _ADF435X_R4_AUX_POWER_SHIFT)
#define ADF435X_R4_AUX_POWER_POS_5DBM   (0x03 << _ADF435X_R4_AUX_POWER_SHIFT)

#define ADF435X_R4_RF_OUT_DISABLED      (0 << 5)
#define ADF435X_R4_RF_OUT_ENABLED       (1 << 5)

#define _ADF435X_R4_RF_POWER_SHIFT      3
#define _ADF435X_R4_RF_POWER_MASK       (0x03 << _ADF435X_R4_RF_POWER_SHIFT)
#define ADF435X_R4_RF_POWER_NEG_4DBM    (0x00 << _ADF435X_R4_RF_POWER_SHIFT)
#define ADF435X_R4_RF_POWER_NEG_1DBM    (0x01 << _ADF435X_R4_RF_POWER_SHIFT)
#define ADF435X_R4_RF_POWER_POS_2DBM    (0x02 << _ADF435X_R4_RF_POWER_SHIFT)
#define ADF435X_R4_RF_POWER_POS_5DBM    (0x03 << _ADF435X_R4_RF_POWER_SHIFT)

#define _ADF435X_R5_LD_PIN_MODE_SHIFT   22
#define ADF435X_R5_LD_PIN_LOW1          (0x00 << _ADF435X_R5_LD_PIN_MODE_SHIFT)
#define ADF435X_R5_LD_PIN_DIGITAL       (0x01 << _ADF435X_R5_LD_PIN_MODE_SHIFT)
#define ADF435X_R5_LD_PIN_LOW2          (0x02 << _ADF435X_R5_LD_PIN_MODE_SHIFT)
#define ADF435X_R5_LD_PIN_HIGH          (0x03 << _ADF435X_R5_LD_PIN_MODE_SHIFT)

// two reserved bits in R5 must be set to '11' to write successfully
#define ADF435X_R5_RESV_2_BITS          (0x03 << 19)

#define ADF435X_R0                      0
#define ADF435X_R1                      1
#define ADF435X_R2                      2
#define ADF435X_R3                      3
#define ADF435X_R4                      4
#define ADF435X_R5                      5
 
#define _ADF435X_REG_DATA_MASK          0xfffffff8
#define _ADF435X_REG_CTRL_BITS_MASK     0x00000007

/*
 * Flags for state of ADF435X.
 */
#define ADF_STATE_RF_ON                 0x00000001
#define ADF_STATE_AUX_ON                0x00000002
#define ADF_STATE_VCO_ON                0x00000004

/*
 * This structure is used to represent one of several supported and tested 
 * configurations for the PLL setup.
 *
 * The Raspberry Pi application software can switch to one of these configurations
 * or alter the first configuration in the list for a custom setup.
 */
struct adf435x_config_t {
    char short_name[20];
    uint16_t _int;
    uint16_t frac;
    uint16_t phase;
    uint16_t mod;
    uint8_t rfdiv;
    uint8_t charge_pump;
    uint16_t r_counter;
    uint16_t bandsel;
    uint32_t flags;
};

/*
 * Struct that represents state of ADF435x.
 */
struct adf435x_state_t {
    // Six 29-bit registers.  Control bits are always unused.
    uint32_t r0, r1, r2, r3, r4, r5;
    
    // Internal state flags
    uint32_t state_flags;
    uint8_t power_level;
    
    // Current configuration in use
    struct adf435x_config_t cfg_curr;
    
    // Current calculated output frequency
    float calc_output_freq;
};

extern struct adf435x_state_t adf435x_state;

/*
 * Port/pin combinations for ADF435X on Scopy MVP board.
 *  
 * CLK      Serial clock                PD0  
 * DAT      Serial data                 PD1
 * LE       Latch signal                PD2
 * CE       Chip enable                 PD3
 * LD       Lock detect (unused)
 * MUX      Mux input (unused)
 */
#define ADF435X_CLK_PORT                GPIOB
#define ADF435X_CLK_PIN                 0
#define ADF435X_DAT_PORT                GPIOE
#define ADF435X_DAT_PIN                 7
#define ADF435X_LE_PORT                 GPIOB
#define ADF435X_LE_PIN                  1
#define ADF435X_CE_PORT                 GPIOB
#define ADF435X_CE_PIN                  2
#define ADF435X_PD_PORT                 GPIOE
#define ADF435X_PD_PIN                  8

/*
 * This set of flags is used for each configuration.  It's used to condense the 
 * mix of flags into something that fits in one 32-bit word.
 */
#define ADF_FLG_PHASE_ADJ           0x00000001
#define ADF_FLG_PRESCALER_4_5       0x00000002  // Only one prescaler should be set at a time
#define ADF_FLG_PRESCALER_8_9       0x00000004  // ^^^^
#define ADF_FLG_REF_DOUBLE          0x00000008  // Only set ref double, ref half or neither
#define ADF_FLG_REF_HALF            0x00000010  // ^^^^
#define ADF_FLG_DOUBLE_BUFF         0x00000020
#define ADF_FLG_LDF_FRAC_N          0x00000040  // Only one LDF flag should be set
#define ADF_FLG_LDF_INT_N           0x00000080  // ^^^^
#define ADF_FLG_LDP_10NS            0x00000100  // Only one LDP flag should be set
#define ADF_FLG_LDP_6NS             0x00000200  // ^^^^
#define ADF_FLG_PD_POL_POS          0x00000400  // Only one PD_POL flag should be set
#define ADF_FLG_PD_POL_NEG          0x00000800  // ^^^^
#define ADF_FLG_POWERDOWN           0x00001000  // If set this sets the powerdown flag, if clear this clears the powerdown flag
#define ADF_FLG_CP_3STATE           0x00002000  // If set this disables chargepump 3-state mode
#define ADF_FLG_CTR_RESET           0x00004000  // If set then CTR_RESET is enabled
#define ADF_FLG_BAND_SEL_LOW        0x00008000  // Only one BAND_SEL flag should be set
#define ADF_FLG_BAND_SEL_HIGH       0x00010000  // ^^^^
#define ADF_FLG_ANTIBACKLASH        0x00020000  // If set then antibacklash feature is enabled
#define ADF_FLG_CHARGE_CANCEL       0x00040000  // If set then charge cancel feature is enabled
#define ADF_FLG_CYCLE_SLIP_RED      0x00080000  // If set then cycle slip reduction is enabled
#define ADF_FLG_CLOCK_DIV_OFF       0x00100000  // Only one CLOCK_DIV flag should be set
#define ADF_FLG_CLOCK_DIV_FASTLOCK  0x00200000  // ^^^^
#define ADF_FLG_CLOCK_DIV_RESYNC    0x00400000  // ^^^^
#define ADF_FLG_FEEDBACK_DIV        0x00800000  // If set then feedback is divided
#define ADF_FLG_MUTE                0x01000000  // If set then MUTE is on

/*
 * Possible values for RFDIV field in adf435x_config_t.
 */
#define ADF_RFDIV_1                 0x00
#define ADF_RFDIV_2                 0x01
#define ADF_RFDIV_4                 0x02
#define ADF_RFDIV_8                 0x03
#define ADF_RFDIV_16                0x04
#define ADF_RFDIV_32                0x05
#define ADF_RFDIV_64                0x06
#define _ADF_RFDIV_MASK_OFF         0x07        // prevent write to adjacent bits if this value is wrong

/*
 * Possible levels for power fields in adf435x_set_power_level(). 
 */
#define ADF_POWER_NO_CHANGE         0x00
#define ADF_POWER_NEG_4DBM          0x01
#define ADF_POWER_NEG_1DBM          0x02
#define ADF_POWER_POS_2DBM          0x03
#define ADF_POWER_POS_5DBM          0x04

/*
 * This list stores ADF_MAX_CONFIGS which can be addressed by index or 
 * by pointer.
 *
 * The first config can be edited remotely.  To be implemented.
 */
#define ADF_MAX_CONFIGS             16

extern struct adf435x_config_t adf_configs[];

/*
 * Function prototypes.
 */ 
void adf435x_init(void);
void adf435x_write_out(uint32_t data);
void adf435x_write_reg(uint32_t data, uint32_t reg);
void adf435x_sync(void);
void adf435x_sync_rf_power_state(void);
void adf435x_shutdown(void);
void adf435x_load_config(struct adf435x_config_t *config);
void adf435x_load_config_index(uint32_t index);
void adf435x_rf_on(void);
void adf435x_rf_off(void);
void adf435x_set_power_level(uint32_t rf_power);
void adf435x_change_frequency(float freq);
float adf435x_compute_frequency(uint32_t _int, uint32_t frac, uint32_t mod, uint32_t rfdiv);
void adf435x_dump_state(void);

#endif // ___ADF435X_H___

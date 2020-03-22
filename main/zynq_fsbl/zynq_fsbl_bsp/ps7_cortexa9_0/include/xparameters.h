#ifndef XPARAMETERS_H   /* prevent circular inclusions */
#define XPARAMETERS_H   /* by using protection macros */

/* Definition for CPU ID */
#define XPAR_CPU_ID 0U

/* Definitions for peripheral PS7_CORTEXA9_0 */
#define XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ 666666687


/******************************************************************/

/* Canonical definitions for peripheral PS7_CORTEXA9_0 */
#define XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ 666666687


/******************************************************************/

#include "xparameters_ps.h"

#define STDIN_BASEADDRESS 0xE0001000
#define STDOUT_BASEADDRESS 0xE0001000

/******************************************************************/

/* Platform specific definitions */
#define PLATFORM_ZYNQ
 
/* Definitions for sleep timer configuration */
#define XSLEEP_TIMER_IS_DEFAULT_TIMER
 
 
/******************************************************************/
/* Definitions for driver FABCFG_NEXTGEN */
#define XPAR_FABCFG_NEXTGEN_NUM_INSTANCES 1

/* Definitions for peripheral FABCFG_NEXTGEN_0 */
#define XPAR_FABCFG_NEXTGEN_0_DEVICE_ID 0
#define XPAR_FABCFG_NEXTGEN_0_S00_AXI_BASEADDR 0x40010000
#define XPAR_FABCFG_NEXTGEN_0_S00_AXI_HIGHADDR 0x4001FFFF


/******************************************************************/

/* Definitions for driver AXIDMA */
#define XPAR_XAXIDMA_NUM_INSTANCES 2

/* Definitions for peripheral ADC_DMA */
#define XPAR_ADC_DMA_DEVICE_ID 0
#define XPAR_ADC_DMA_BASEADDR 0x40400000
#define XPAR_ADC_DMA_HIGHADDR 0x4040FFFF
#define XPAR_ADC_DMA_SG_INCLUDE_STSCNTRL_STRM 0
#define XPAR_ADC_DMA_INCLUDE_MM2S_DRE 0
#define XPAR_ADC_DMA_INCLUDE_S2MM_DRE 1
#define XPAR_ADC_DMA_INCLUDE_MM2S 0
#define XPAR_ADC_DMA_INCLUDE_S2MM 1
#define XPAR_ADC_DMA_M_AXI_MM2S_DATA_WIDTH 64
#define XPAR_ADC_DMA_M_AXI_S2MM_DATA_WIDTH 64
#define XPAR_ADC_DMA_INCLUDE_SG 0
#define XPAR_ADC_DMA_ENABLE_MULTI_CHANNEL 0
#define XPAR_ADC_DMA_NUM_MM2S_CHANNELS 1
#define XPAR_ADC_DMA_NUM_S2MM_CHANNELS 1
#define XPAR_ADC_DMA_MM2S_BURST_SIZE 16
#define XPAR_ADC_DMA_S2MM_BURST_SIZE 16
#define XPAR_ADC_DMA_MICRO_DMA 0
#define XPAR_ADC_DMA_ADDR_WIDTH 32
#define XPAR_ADC_DMA_SG_LENGTH_WIDTH 24


/* Definitions for peripheral MIPI_DMA */
#define XPAR_MIPI_DMA_DEVICE_ID 1
#define XPAR_MIPI_DMA_BASEADDR 0x40410000
#define XPAR_MIPI_DMA_HIGHADDR 0x4041FFFF
#define XPAR_MIPI_DMA_SG_INCLUDE_STSCNTRL_STRM 0
#define XPAR_MIPI_DMA_INCLUDE_MM2S_DRE 0
#define XPAR_MIPI_DMA_INCLUDE_S2MM_DRE 0
#define XPAR_MIPI_DMA_INCLUDE_MM2S 1
#define XPAR_MIPI_DMA_INCLUDE_S2MM 0
#define XPAR_MIPI_DMA_M_AXI_MM2S_DATA_WIDTH 64
#define XPAR_MIPI_DMA_M_AXI_S2MM_DATA_WIDTH 64
#define XPAR_MIPI_DMA_INCLUDE_SG 0
#define XPAR_MIPI_DMA_ENABLE_MULTI_CHANNEL 0
#define XPAR_MIPI_DMA_NUM_MM2S_CHANNELS 1
#define XPAR_MIPI_DMA_NUM_S2MM_CHANNELS 1
#define XPAR_MIPI_DMA_MM2S_BURST_SIZE 32
#define XPAR_MIPI_DMA_S2MM_BURST_SIZE 16
#define XPAR_MIPI_DMA_MICRO_DMA 0
#define XPAR_MIPI_DMA_ADDR_WIDTH 32
#define XPAR_MIPI_DMA_SG_LENGTH_WIDTH 24


/******************************************************************/

/* Canonical definitions for peripheral ADC_DMA */
#define XPAR_AXIDMA_0_DEVICE_ID XPAR_ADC_DMA_DEVICE_ID
#define XPAR_AXIDMA_0_BASEADDR 0x40400000
#define XPAR_AXIDMA_0_SG_INCLUDE_STSCNTRL_STRM 0
#define XPAR_AXIDMA_0_INCLUDE_MM2S 0
#define XPAR_AXIDMA_0_INCLUDE_MM2S_DRE 0
#define XPAR_AXIDMA_0_M_AXI_MM2S_DATA_WIDTH 64
#define XPAR_AXIDMA_0_INCLUDE_S2MM 1
#define XPAR_AXIDMA_0_INCLUDE_S2MM_DRE 1
#define XPAR_AXIDMA_0_M_AXI_S2MM_DATA_WIDTH 64
#define XPAR_AXIDMA_0_INCLUDE_SG 0
#define XPAR_AXIDMA_0_ENABLE_MULTI_CHANNEL 0
#define XPAR_AXIDMA_0_NUM_MM2S_CHANNELS 1
#define XPAR_AXIDMA_0_NUM_S2MM_CHANNELS 1
#define XPAR_AXIDMA_0_MM2S_BURST_SIZE 16
#define XPAR_AXIDMA_0_S2MM_BURST_SIZE 16
#define XPAR_AXIDMA_0_MICRO_DMA 0
#define XPAR_AXIDMA_0_c_addr_width 32
#define XPAR_AXIDMA_0_c_sg_length_width 24

/* Canonical definitions for peripheral MIPI_DMA */
#define XPAR_AXIDMA_1_DEVICE_ID XPAR_MIPI_DMA_DEVICE_ID
#define XPAR_AXIDMA_1_BASEADDR 0x40410000
#define XPAR_AXIDMA_1_SG_INCLUDE_STSCNTRL_STRM 0
#define XPAR_AXIDMA_1_INCLUDE_MM2S 1
#define XPAR_AXIDMA_1_INCLUDE_MM2S_DRE 0
#define XPAR_AXIDMA_1_M_AXI_MM2S_DATA_WIDTH 64
#define XPAR_AXIDMA_1_INCLUDE_S2MM 0
#define XPAR_AXIDMA_1_INCLUDE_S2MM_DRE 0
#define XPAR_AXIDMA_1_M_AXI_S2MM_DATA_WIDTH 64
#define XPAR_AXIDMA_1_INCLUDE_SG 0
#define XPAR_AXIDMA_1_ENABLE_MULTI_CHANNEL 0
#define XPAR_AXIDMA_1_NUM_MM2S_CHANNELS 1
#define XPAR_AXIDMA_1_NUM_S2MM_CHANNELS 1
#define XPAR_AXIDMA_1_MM2S_BURST_SIZE 32
#define XPAR_AXIDMA_1_S2MM_BURST_SIZE 16
#define XPAR_AXIDMA_1_MICRO_DMA 0
#define XPAR_AXIDMA_1_c_addr_width 32
#define XPAR_AXIDMA_1_c_sg_length_width 24


/******************************************************************/

/* Definitions for driver CLK_WIZ */
#define XPAR_XCLK_WIZ_NUM_INSTANCES 1

/* Definitions for peripheral CLK_WIZ_0 */
#define XPAR_CLK_WIZ_0_DEVICE_ID 0
#define XPAR_CLK_WIZ_0_BASEADDR 0x40000000
#define XPAR_CLK_WIZ_0_HIGHADDR 0x4000FFFF
#define XPAR_CLK_WIZ_0_ENABLE_CLOCK_MONITOR 0
#define XPAR_CLK_WIZ_0_ENABLE_USER_CLOCK0 0
#define XPAR_CLK_WIZ_0_ENABLE_USER_CLOCK1 0
#define XPAR_CLK_WIZ_0_ENABLE_USER_CLOCK2 0
#define XPAR_CLK_WIZ_0_ENABLE_USER_CLOCK3 0
#define XPAR_CLK_WIZ_0_REF_CLK_FREQ 100.0
#define XPAR_CLK_WIZ_0_USER_CLK_FREQ0 100.0
#define XPAR_CLK_WIZ_0_USER_CLK_FREQ1 100.0
#define XPAR_CLK_WIZ_0_USER_CLK_FREQ2 100.0
#define XPAR_CLK_WIZ_0_USER_CLK_FREQ3 100.0
#define XPAR_CLK_WIZ_0_PRECISION 1
#define XPAR_CLK_WIZ_0_ENABLE_PLL0 0
#define XPAR_CLK_WIZ_0_ENABLE_PLL1 0


/******************************************************************/


/******************************************************************/


/* Definitions for peripheral PS7_DDR_0 */
#define XPAR_PS7_DDR_0_S_AXI_BASEADDR 0x00100000
#define XPAR_PS7_DDR_0_S_AXI_HIGHADDR 0x0FFFFFFF


/******************************************************************/

/* Definitions for driver DEVCFG */
#define XPAR_XDCFG_NUM_INSTANCES 1U

/* Definitions for peripheral PS7_DEV_CFG_0 */
#define XPAR_PS7_DEV_CFG_0_DEVICE_ID 0U
#define XPAR_PS7_DEV_CFG_0_BASEADDR 0xF8007000U
#define XPAR_PS7_DEV_CFG_0_HIGHADDR 0xF80070FFU


/******************************************************************/

/* Canonical definitions for peripheral PS7_DEV_CFG_0 */
#define XPAR_XDCFG_0_DEVICE_ID XPAR_PS7_DEV_CFG_0_DEVICE_ID
#define XPAR_XDCFG_0_BASEADDR 0xF8007000U
#define XPAR_XDCFG_0_HIGHADDR 0xF80070FFU


/******************************************************************/

/* Definitions for driver DMAPS */
#define XPAR_XDMAPS_NUM_INSTANCES 2

/* Definitions for peripheral PS7_DMA_NS */
#define XPAR_PS7_DMA_NS_DEVICE_ID 0
#define XPAR_PS7_DMA_NS_BASEADDR 0xF8004000
#define XPAR_PS7_DMA_NS_HIGHADDR 0xF8004FFF


/* Definitions for peripheral PS7_DMA_S */
#define XPAR_PS7_DMA_S_DEVICE_ID 1
#define XPAR_PS7_DMA_S_BASEADDR 0xF8003000
#define XPAR_PS7_DMA_S_HIGHADDR 0xF8003FFF


/******************************************************************/

/* Canonical definitions for peripheral PS7_DMA_NS */
#define XPAR_XDMAPS_0_DEVICE_ID XPAR_PS7_DMA_NS_DEVICE_ID
#define XPAR_XDMAPS_0_BASEADDR 0xF8004000
#define XPAR_XDMAPS_0_HIGHADDR 0xF8004FFF

/* Canonical definitions for peripheral PS7_DMA_S */
#define XPAR_XDMAPS_1_DEVICE_ID XPAR_PS7_DMA_S_DEVICE_ID
#define XPAR_XDMAPS_1_BASEADDR 0xF8003000
#define XPAR_XDMAPS_1_HIGHADDR 0xF8003FFF


/******************************************************************/


/* Definitions for peripheral PS7_AFI_0 */
#define XPAR_PS7_AFI_0_S_AXI_BASEADDR 0xF8008000
#define XPAR_PS7_AFI_0_S_AXI_HIGHADDR 0xF8008FFF


/* Definitions for peripheral PS7_AFI_1 */
#define XPAR_PS7_AFI_1_S_AXI_BASEADDR 0xF8009000
#define XPAR_PS7_AFI_1_S_AXI_HIGHADDR 0xF8009FFF


/* Definitions for peripheral PS7_AFI_2 */
#define XPAR_PS7_AFI_2_S_AXI_BASEADDR 0xF800A000
#define XPAR_PS7_AFI_2_S_AXI_HIGHADDR 0xF800AFFF


/* Definitions for peripheral PS7_AFI_3 */
#define XPAR_PS7_AFI_3_S_AXI_BASEADDR 0xF800B000
#define XPAR_PS7_AFI_3_S_AXI_HIGHADDR 0xF800BFFF


/* Definitions for peripheral PS7_DDRC_0 */
#define XPAR_PS7_DDRC_0_S_AXI_BASEADDR 0xF8006000
#define XPAR_PS7_DDRC_0_S_AXI_HIGHADDR 0xF8006FFF


/* Definitions for peripheral PS7_GLOBALTIMER_0 */
#define XPAR_PS7_GLOBALTIMER_0_S_AXI_BASEADDR 0xF8F00200
#define XPAR_PS7_GLOBALTIMER_0_S_AXI_HIGHADDR 0xF8F002FF


/* Definitions for peripheral PS7_GPV_0 */
#define XPAR_PS7_GPV_0_S_AXI_BASEADDR 0xF8900000
#define XPAR_PS7_GPV_0_S_AXI_HIGHADDR 0xF89FFFFF


/* Definitions for peripheral PS7_INTC_DIST_0 */
#define XPAR_PS7_INTC_DIST_0_S_AXI_BASEADDR 0xF8F01000
#define XPAR_PS7_INTC_DIST_0_S_AXI_HIGHADDR 0xF8F01FFF


/* Definitions for peripheral PS7_IOP_BUS_CONFIG_0 */
#define XPAR_PS7_IOP_BUS_CONFIG_0_S_AXI_BASEADDR 0xE0200000
#define XPAR_PS7_IOP_BUS_CONFIG_0_S_AXI_HIGHADDR 0xE0200FFF


/* Definitions for peripheral PS7_L2CACHEC_0 */
#define XPAR_PS7_L2CACHEC_0_S_AXI_BASEADDR 0xF8F02000
#define XPAR_PS7_L2CACHEC_0_S_AXI_HIGHADDR 0xF8F02FFF


/* Definitions for peripheral PS7_OCMC_0 */
#define XPAR_PS7_OCMC_0_S_AXI_BASEADDR 0xF800C000
#define XPAR_PS7_OCMC_0_S_AXI_HIGHADDR 0xF800CFFF


/* Definitions for peripheral PS7_PL310_0 */
#define XPAR_PS7_PL310_0_S_AXI_BASEADDR 0xF8F02000
#define XPAR_PS7_PL310_0_S_AXI_HIGHADDR 0xF8F02FFF


/* Definitions for peripheral PS7_PMU_0 */
#define XPAR_PS7_PMU_0_S_AXI_BASEADDR 0xF8891000
#define XPAR_PS7_PMU_0_S_AXI_HIGHADDR 0xF8891FFF
#define XPAR_PS7_PMU_0_PMU1_S_AXI_BASEADDR 0xF8893000
#define XPAR_PS7_PMU_0_PMU1_S_AXI_HIGHADDR 0xF8893FFF


/* Definitions for peripheral PS7_RAM_0 */
#define XPAR_PS7_RAM_0_S_AXI_BASEADDR 0x00000000
#define XPAR_PS7_RAM_0_S_AXI_HIGHADDR 0x0003FFFF


/* Definitions for peripheral PS7_RAM_1 */
#define XPAR_PS7_RAM_1_S_AXI_BASEADDR 0xFFFC0000
#define XPAR_PS7_RAM_1_S_AXI_HIGHADDR 0xFFFFFFFF


/* Definitions for peripheral PS7_SCUC_0 */
#define XPAR_PS7_SCUC_0_S_AXI_BASEADDR 0xF8F00000
#define XPAR_PS7_SCUC_0_S_AXI_HIGHADDR 0xF8F000FC


/* Definitions for peripheral PS7_SLCR_0 */
#define XPAR_PS7_SLCR_0_S_AXI_BASEADDR 0xF8000000
#define XPAR_PS7_SLCR_0_S_AXI_HIGHADDR 0xF8000FFF


/******************************************************************/

/* Definitions for driver GPIOPS */
#define XPAR_XGPIOPS_NUM_INSTANCES 1

/* Definitions for peripheral PS7_GPIO_0 */
#define XPAR_PS7_GPIO_0_DEVICE_ID 0
#define XPAR_PS7_GPIO_0_BASEADDR 0xE000A000
#define XPAR_PS7_GPIO_0_HIGHADDR 0xE000AFFF


/******************************************************************/

/* Canonical definitions for peripheral PS7_GPIO_0 */
#define XPAR_XGPIOPS_0_DEVICE_ID XPAR_PS7_GPIO_0_DEVICE_ID
#define XPAR_XGPIOPS_0_BASEADDR 0xE000A000
#define XPAR_XGPIOPS_0_HIGHADDR 0xE000AFFF


/******************************************************************/

/* Definitions for Fabric interrupts connected to ps7_scugic_0 */
#define XPAR_FABRIC_ADC_DMA_S2MM_INTROUT_INTR 61U

/******************************************************************/

/* Canonical definitions for Fabric interrupts connected to ps7_scugic_0 */
#define XPAR_FABRIC_AXIDMA_0_VEC_ID XPAR_FABRIC_ADC_DMA_S2MM_INTROUT_INTR

/******************************************************************/

/* Definitions for driver SCUGIC */
#define XPAR_XSCUGIC_NUM_INSTANCES 1U

/* Definitions for peripheral PS7_SCUGIC_0 */
#define XPAR_PS7_SCUGIC_0_DEVICE_ID 0U
#define XPAR_PS7_SCUGIC_0_BASEADDR 0xF8F00100U
#define XPAR_PS7_SCUGIC_0_HIGHADDR 0xF8F001FFU
#define XPAR_PS7_SCUGIC_0_DIST_BASEADDR 0xF8F01000U


/******************************************************************/

/* Canonical definitions for peripheral PS7_SCUGIC_0 */
#define XPAR_SCUGIC_0_DEVICE_ID 0U
#define XPAR_SCUGIC_0_CPU_BASEADDR 0xF8F00100U
#define XPAR_SCUGIC_0_CPU_HIGHADDR 0xF8F001FFU
#define XPAR_SCUGIC_0_DIST_BASEADDR 0xF8F01000U


/******************************************************************/

/* Definitions for driver SCUTIMER */
#define XPAR_XSCUTIMER_NUM_INSTANCES 1

/* Definitions for peripheral PS7_SCUTIMER_0 */
#define XPAR_PS7_SCUTIMER_0_DEVICE_ID 0
#define XPAR_PS7_SCUTIMER_0_BASEADDR 0xF8F00600
#define XPAR_PS7_SCUTIMER_0_HIGHADDR 0xF8F0061F


/******************************************************************/

/* Canonical definitions for peripheral PS7_SCUTIMER_0 */
#define XPAR_XSCUTIMER_0_DEVICE_ID XPAR_PS7_SCUTIMER_0_DEVICE_ID
#define XPAR_XSCUTIMER_0_BASEADDR 0xF8F00600
#define XPAR_XSCUTIMER_0_HIGHADDR 0xF8F0061F


/******************************************************************/

/* Definitions for driver SCUWDT */
#define XPAR_XSCUWDT_NUM_INSTANCES 1

/* Definitions for peripheral PS7_SCUWDT_0 */
#define XPAR_PS7_SCUWDT_0_DEVICE_ID 0
#define XPAR_PS7_SCUWDT_0_BASEADDR 0xF8F00620
#define XPAR_PS7_SCUWDT_0_HIGHADDR 0xF8F006FF


/******************************************************************/

/* Canonical definitions for peripheral PS7_SCUWDT_0 */
#define XPAR_SCUWDT_0_DEVICE_ID XPAR_PS7_SCUWDT_0_DEVICE_ID
#define XPAR_SCUWDT_0_BASEADDR 0xF8F00620
#define XPAR_SCUWDT_0_HIGHADDR 0xF8F006FF


/******************************************************************/

/* Definitions for driver SPIPS */
#define XPAR_XSPIPS_NUM_INSTANCES 1

/* Definitions for peripheral PS7_SPI_0 */
#define XPAR_PS7_SPI_0_DEVICE_ID 0
#define XPAR_PS7_SPI_0_BASEADDR 0xE0006000
#define XPAR_PS7_SPI_0_HIGHADDR 0xE0006FFF
#define XPAR_PS7_SPI_0_SPI_CLK_FREQ_HZ 160000000


/******************************************************************/

/* Canonical definitions for peripheral PS7_SPI_0 */
#define XPAR_XSPIPS_0_DEVICE_ID XPAR_PS7_SPI_0_DEVICE_ID
#define XPAR_XSPIPS_0_BASEADDR 0xE0006000
#define XPAR_XSPIPS_0_HIGHADDR 0xE0006FFF
#define XPAR_XSPIPS_0_SPI_CLK_FREQ_HZ 160000000


/******************************************************************/

/* Definitions for driver TTCPS */
#define XPAR_XTTCPS_NUM_INSTANCES 3U

/* Definitions for peripheral PS7_TTC_0 */
#define XPAR_PS7_TTC_0_DEVICE_ID 0U
#define XPAR_PS7_TTC_0_BASEADDR 0XF8001000U
#define XPAR_PS7_TTC_0_TTC_CLK_FREQ_HZ 111111115U
#define XPAR_PS7_TTC_0_TTC_CLK_CLKSRC 0U
#define XPAR_PS7_TTC_1_DEVICE_ID 1U
#define XPAR_PS7_TTC_1_BASEADDR 0XF8001004U
#define XPAR_PS7_TTC_1_TTC_CLK_FREQ_HZ 111111115U
#define XPAR_PS7_TTC_1_TTC_CLK_CLKSRC 0U
#define XPAR_PS7_TTC_2_DEVICE_ID 2U
#define XPAR_PS7_TTC_2_BASEADDR 0XF8001008U
#define XPAR_PS7_TTC_2_TTC_CLK_FREQ_HZ 111111115U
#define XPAR_PS7_TTC_2_TTC_CLK_CLKSRC 0U


/******************************************************************/

/* Canonical definitions for peripheral PS7_TTC_0 */
#define XPAR_XTTCPS_0_DEVICE_ID XPAR_PS7_TTC_0_DEVICE_ID
#define XPAR_XTTCPS_0_BASEADDR 0xF8001000U
#define XPAR_XTTCPS_0_TTC_CLK_FREQ_HZ 111111115U
#define XPAR_XTTCPS_0_TTC_CLK_CLKSRC 0U

#define XPAR_XTTCPS_1_DEVICE_ID XPAR_PS7_TTC_1_DEVICE_ID
#define XPAR_XTTCPS_1_BASEADDR 0xF8001004U
#define XPAR_XTTCPS_1_TTC_CLK_FREQ_HZ 111111115U
#define XPAR_XTTCPS_1_TTC_CLK_CLKSRC 0U

#define XPAR_XTTCPS_2_DEVICE_ID XPAR_PS7_TTC_2_DEVICE_ID
#define XPAR_XTTCPS_2_BASEADDR 0xF8001008U
#define XPAR_XTTCPS_2_TTC_CLK_FREQ_HZ 111111115U
#define XPAR_XTTCPS_2_TTC_CLK_CLKSRC 0U


/******************************************************************/

/* Definitions for driver UARTPS */
#define XPAR_XUARTPS_NUM_INSTANCES 1

/* Definitions for peripheral PS7_UART_1 */
#define XPAR_PS7_UART_1_DEVICE_ID 0
#define XPAR_PS7_UART_1_BASEADDR 0xE0001000
#define XPAR_PS7_UART_1_HIGHADDR 0xE0001FFF
#define XPAR_PS7_UART_1_UART_CLK_FREQ_HZ 100000000
#define XPAR_PS7_UART_1_HAS_MODEM 0


/******************************************************************/

/* Canonical definitions for peripheral PS7_UART_1 */
#define XPAR_XUARTPS_0_DEVICE_ID XPAR_PS7_UART_1_DEVICE_ID
#define XPAR_XUARTPS_0_BASEADDR 0xE0001000
#define XPAR_XUARTPS_0_HIGHADDR 0xE0001FFF
#define XPAR_XUARTPS_0_UART_CLK_FREQ_HZ 100000000
#define XPAR_XUARTPS_0_HAS_MODEM 0


/******************************************************************/

/* Definitions for driver XADCPS */
#define XPAR_XADCPS_NUM_INSTANCES 1

/* Definitions for peripheral PS7_XADC_0 */
#define XPAR_PS7_XADC_0_DEVICE_ID 0
#define XPAR_PS7_XADC_0_BASEADDR 0xF8007100
#define XPAR_PS7_XADC_0_HIGHADDR 0xF8007120


/******************************************************************/

/* Canonical definitions for peripheral PS7_XADC_0 */
#define XPAR_XADCPS_0_DEVICE_ID XPAR_PS7_XADC_0_DEVICE_ID
#define XPAR_XADCPS_0_BASEADDR 0xF8007100
#define XPAR_XADCPS_0_HIGHADDR 0xF8007120


/******************************************************************/

/* Xilinx FAT File System Library (XilFFs) User Settings */
#define FILE_SYSTEM_USE_MKFS
#define FILE_SYSTEM_NUM_LOGIC_VOL 2
#define FILE_SYSTEM_USE_STRFUNC 0
#define FILE_SYSTEM_SET_FS_RPATH 0
#define FILE_SYSTEM_WORD_ACCESS
#endif  /* end of protection macro */

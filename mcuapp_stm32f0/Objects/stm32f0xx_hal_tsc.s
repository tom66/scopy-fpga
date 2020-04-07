; generated by Component: ARM Compiler 5.05 update 1 (build 106) Tool: ArmCC [4d0efa]
; commandline ArmCC [--c99 --split_sections --debug -c --asm -o.\objects\stm32f0xx_hal_tsc.o --depend=.\objects\stm32f0xx_hal_tsc.d --cpu=Cortex-M0 --apcs=interwork -O0 --diag_suppress=9931 -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE\Device\STM32F071VBTx -IC:\Keil_v5\ARM\PACK\ARM\CMSIS\5.4.0\CMSIS\Core\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0 -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\CMSIS\Device\ST\STM32F0xx\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc\Legacy -D__UVISION_VERSION=514 -D_RTE_ -DSTM32F071xB --omf_browse=.\objects\stm32f0xx_hal_tsc.crf C:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Src\stm32f0xx_hal_tsc.c]
        THUMB
        REQUIRE8
        PRESERVE8

        AREA ||i.HAL_TSC_ConvCpltCallback||, CODE, READONLY, ALIGN=1

HAL_TSC_ConvCpltCallback PROC
        BX       lr
        ENDP


        AREA ||i.HAL_TSC_DeInit||, CODE, READONLY, ALIGN=1

HAL_TSC_DeInit PROC
        PUSH     {r4,lr}
        MOV      r4,r0
        CMP      r4,#0
        BNE      |L2.12|
        MOVS     r0,#1
|L2.10|
        POP      {r4,pc}
|L2.12|
        MOVS     r1,#2
        MOVS     r0,#0x3c
        STRB     r1,[r0,r4]
        MOV      r0,r4
        BL       HAL_TSC_MspDeInit
        MOVS     r1,#0
        MOVS     r0,#0x3c
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r0,#0x3d
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r0,#0
        B        |L2.10|
        ENDP


        AREA ||i.HAL_TSC_ErrorCallback||, CODE, READONLY, ALIGN=1

HAL_TSC_ErrorCallback PROC
        BX       lr
        ENDP


        AREA ||i.HAL_TSC_GetState||, CODE, READONLY, ALIGN=1

HAL_TSC_GetState PROC
        MOV      r1,r0
        MOVS     r0,#0x3c
        LDRB     r0,[r0,r1]
        CMP      r0,#2
        BNE      |L4.56|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0xc]
        LSLS     r0,r0,#31
        LSRS     r0,r0,#31
        MOVS     r2,#1
        EORS     r0,r0,r2
        EORS     r0,r0,r2
        CMP      r0,#0
        BEQ      |L4.56|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0xc]
        MOVS     r2,#2
        ANDS     r0,r0,r2
        LSRS     r0,r0,#1
        CMP      r0,#0
        BEQ      |L4.50|
        MOVS     r2,#3
        MOVS     r0,#0x3c
        STRB     r2,[r0,r1]
        B        |L4.56|
|L4.50|
        MOVS     r2,#1
        MOVS     r0,#0x3c
        STRB     r2,[r0,r1]
|L4.56|
        MOVS     r0,#0x3c
        LDRB     r0,[r0,r1]
        BX       lr
        ENDP


        AREA ||i.HAL_TSC_GroupGetStatus||, CODE, READONLY, ALIGN=1

HAL_TSC_GroupGetStatus PROC
        PUSH     {r4,lr}
        MOV      r2,r0
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#0x30]
        MOV      r3,r1
        ADDS     r3,r3,#0x10
        MOVS     r4,#1
        LSLS     r4,r4,r3
        ANDS     r0,r0,r4
        MOVS     r4,#1
        LSLS     r4,r4,r3
        CMP      r0,r4
        BNE      |L5.30|
        MOVS     r0,#1
|L5.28|
        POP      {r4,pc}
|L5.30|
        MOVS     r0,#0
        B        |L5.28|
        ENDP


        AREA ||i.HAL_TSC_GroupGetValue||, CODE, READONLY, ALIGN=1

HAL_TSC_GroupGetValue PROC
        MOV      r2,r0
        LDR      r0,[r2,#0]
        ADDS     r0,r0,#0x34
        LSLS     r3,r1,#2
        LDR      r0,[r0,r3]
        BX       lr
        ENDP


        AREA ||i.HAL_TSC_IOConfig||, CODE, READONLY, ALIGN=1

HAL_TSC_IOConfig PROC
        PUSH     {r4-r6,lr}
        MOV      r4,r0
        MOV      r5,r1
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r4]
        CMP      r0,#1
        BNE      |L7.20|
        MOVS     r0,#2
|L7.18|
        POP      {r4-r6,pc}
|L7.20|
        MOVS     r1,#1
        MOVS     r0,#0x3d
        STRB     r1,[r0,r4]
        NOP      
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        MOVS     r1,#2
        BICS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        LDR      r1,[r5,#4]
        LDR      r0,[r5,#0]
        ORRS     r0,r0,r1
        LDR      r1,[r5,#8]
        ORRS     r0,r0,r1
        MVNS     r0,r0
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
        LDR      r1,[r5,#4]
        LDR      r0,[r5,#0]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x28]
        LDR      r0,[r5,#8]
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x20]
        LDR      r0,[r5,#0]
        BL       TSC_extract_groups
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x30]
        NOP      
        MOVS     r1,#0
        MOVS     r0,#0x3d
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r0,#0
        B        |L7.18|
        ENDP


        AREA ||i.HAL_TSC_IODischarge||, CODE, READONLY, ALIGN=1

HAL_TSC_IODischarge PROC
        MOV      r2,r0
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r2]
        CMP      r0,#1
        BNE      |L8.16|
        MOVS     r0,#2
|L8.14|
        BX       lr
|L8.16|
        MOVS     r3,#1
        MOVS     r0,#0x3d
        STRB     r3,[r0,r2]
        NOP      
        CMP      r1,#1
        BNE      |L8.42|
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#0]
        MOVS     r3,#0x10
        BICS     r0,r0,r3
        LDR      r3,[r2,#0]
        STR      r0,[r3,#0]
        B        |L8.54|
|L8.42|
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#0]
        MOVS     r3,#0x10
        ORRS     r0,r0,r3
        LDR      r3,[r2,#0]
        STR      r0,[r3,#0]
|L8.54|
        NOP      
        MOVS     r3,#0
        MOVS     r0,#0x3d
        STRB     r3,[r0,r2]
        NOP      
        MOVS     r0,#0
        B        |L8.14|
        ENDP


        AREA ||i.HAL_TSC_IRQHandler||, CODE, READONLY, ALIGN=1

HAL_TSC_IRQHandler PROC
        PUSH     {r4,lr}
        MOV      r4,r0
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0xc]
        LSLS     r0,r0,#31
        LSRS     r0,r0,#31
        MOVS     r1,#1
        EORS     r0,r0,r1
        EORS     r0,r0,r1
        CMP      r0,#0
        BEQ      |L9.28|
        MOVS     r0,#1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#8]
|L9.28|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0xc]
        MOVS     r1,#2
        ANDS     r0,r0,r1
        LSRS     r0,r0,#1
        CMP      r0,#0
        BEQ      |L9.62|
        MOVS     r0,#2
        LDR      r1,[r4,#0]
        STR      r0,[r1,#8]
        MOVS     r1,#3
        MOVS     r0,#0x3c
        STRB     r1,[r0,r4]
        MOV      r0,r4
        BL       HAL_TSC_ErrorCallback
        B        |L9.74|
|L9.62|
        MOVS     r1,#1
        MOVS     r0,#0x3c
        STRB     r1,[r0,r4]
        MOV      r0,r4
        BL       HAL_TSC_ConvCpltCallback
|L9.74|
        POP      {r4,pc}
        ENDP


        AREA ||i.HAL_TSC_Init||, CODE, READONLY, ALIGN=1

HAL_TSC_Init PROC
        PUSH     {r4,lr}
        MOV      r4,r0
        CMP      r4,#0
        BNE      |L10.12|
        MOVS     r0,#1
|L10.10|
        POP      {r4,pc}
|L10.12|
        MOVS     r0,#0x3c
        LDRB     r0,[r0,r4]
        CMP      r0,#0
        BNE      |L10.26|
        MOVS     r1,#0
        MOVS     r0,#0x3d
        STRB     r1,[r0,r4]
|L10.26|
        MOVS     r1,#2
        MOVS     r0,#0x3c
        STRB     r1,[r0,r4]
        MOV      r0,r4
        BL       HAL_TSC_MspInit
        MOVS     r0,#1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        LDR      r1,[r4,#8]
        LDR      r0,[r4,#4]
        ORRS     r0,r0,r1
        LDRH     r1,[r4,#0x10]
        LSLS     r1,r1,#17
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x14]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x18]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x1c]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x24]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x28]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        LDR      r1,[r1,#0]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        LDR      r0,[r4,#0xc]
        CMP      r0,#1
        BNE      |L10.106|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        MOVS     r1,#1
        LSLS     r1,r1,#16
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
|L10.106|
        LDR      r1,[r4,#0x34]
        LDR      r0,[r4,#0x30]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x38]
        ORRS     r0,r0,r1
        MVNS     r0,r0
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
        LDR      r1,[r4,#0x34]
        LDR      r0,[r4,#0x30]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x28]
        LDR      r1,[r4,#0]
        LDR      r0,[r4,#0x38]
        STR      r0,[r1,#0x20]
        LDR      r0,[r4,#0x30]
        BL       TSC_extract_groups
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x30]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#4]
        LSRS     r0,r0,#2
        LSLS     r0,r0,#2
        LDR      r1,[r4,#0]
        STR      r0,[r1,#4]
        MOVS     r0,#3
        LDR      r1,[r4,#0]
        STR      r0,[r1,#8]
        MOVS     r1,#1
        MOVS     r0,#0x3c
        STRB     r1,[r0,r4]
        MOVS     r0,#0
        B        |L10.10|
        ENDP


        AREA ||i.HAL_TSC_MspDeInit||, CODE, READONLY, ALIGN=1

HAL_TSC_MspDeInit PROC
        BX       lr
        ENDP


        AREA ||i.HAL_TSC_MspInit||, CODE, READONLY, ALIGN=1

HAL_TSC_MspInit PROC
        BX       lr
        ENDP


        AREA ||i.HAL_TSC_PollForAcquisition||, CODE, READONLY, ALIGN=1

HAL_TSC_PollForAcquisition PROC
        PUSH     {lr}
        MOV      r3,r0
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r3]
        CMP      r0,#1
        BNE      |L13.18|
        MOVS     r0,#2
|L13.16|
        POP      {pc}
|L13.18|
        MOVS     r1,#1
        MOVS     r0,#0x3d
        STRB     r1,[r0,r3]
        NOP      
        NOP      
|L13.28|
        MOV      r0,r3
        BL       HAL_TSC_GetState
        CMP      r0,#2
        BEQ      |L13.28|
        NOP      
        MOVS     r1,#0
        MOVS     r0,#0x3d
        STRB     r1,[r0,r3]
        NOP      
        MOVS     r0,#0
        B        |L13.16|
        ENDP


        AREA ||i.HAL_TSC_Start||, CODE, READONLY, ALIGN=1

HAL_TSC_Start PROC
        MOV      r1,r0
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r1]
        CMP      r0,#1
        BNE      |L14.16|
        MOVS     r0,#2
|L14.14|
        BX       lr
|L14.16|
        MOVS     r2,#1
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r2,#2
        MOVS     r0,#0x3c
        STRB     r2,[r0,r1]
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#4]
        LSRS     r0,r0,#2
        LSLS     r0,r0,#2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#4]
        MOVS     r0,#3
        LDR      r2,[r1,#0]
        STR      r0,[r2,#8]
        LDR      r0,[r1,#0x20]
        CMP      r0,#0
        BNE      |L14.68|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#0x10
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        B        |L14.80|
|L14.68|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#0x10
        ORRS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
|L14.80|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#2
        ORRS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        NOP      
        MOVS     r2,#0
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r0,#0
        B        |L14.14|
        ENDP


        AREA ||i.HAL_TSC_Start_IT||, CODE, READONLY, ALIGN=1

HAL_TSC_Start_IT PROC
        MOV      r1,r0
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r1]
        CMP      r0,#1
        BNE      |L15.16|
        MOVS     r0,#2
|L15.14|
        BX       lr
|L15.16|
        MOVS     r2,#1
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r2,#2
        MOVS     r0,#0x3c
        STRB     r2,[r0,r1]
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#4]
        MOVS     r2,#1
        ORRS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#4]
        LDR      r0,[r1,#0x2c]
        CMP      r0,#1
        BNE      |L15.62|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#4]
        MOVS     r2,#2
        ORRS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#4]
        B        |L15.74|
|L15.62|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#4]
        MOVS     r2,#2
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#4]
|L15.74|
        MOVS     r0,#3
        LDR      r2,[r1,#0]
        STR      r0,[r2,#8]
        LDR      r0,[r1,#0x20]
        CMP      r0,#0
        BNE      |L15.100|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#0x10
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        B        |L15.112|
|L15.100|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#0x10
        ORRS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
|L15.112|
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#2
        ORRS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        NOP      
        MOVS     r2,#0
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r0,#0
        B        |L15.14|
        ENDP


        AREA ||i.HAL_TSC_Stop||, CODE, READONLY, ALIGN=1

HAL_TSC_Stop PROC
        MOV      r1,r0
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r1]
        CMP      r0,#1
        BNE      |L16.16|
        MOVS     r0,#2
|L16.14|
        BX       lr
|L16.16|
        MOVS     r2,#1
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#2
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#0x10
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        MOVS     r0,#3
        LDR      r2,[r1,#0]
        STR      r0,[r2,#8]
        MOVS     r2,#1
        MOVS     r0,#0x3c
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r2,#0
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r0,#0
        B        |L16.14|
        ENDP


        AREA ||i.HAL_TSC_Stop_IT||, CODE, READONLY, ALIGN=1

HAL_TSC_Stop_IT PROC
        MOV      r1,r0
        NOP      
        MOVS     r0,#0x3d
        LDRB     r0,[r0,r1]
        CMP      r0,#1
        BNE      |L17.16|
        MOVS     r0,#2
|L17.14|
        BX       lr
|L17.16|
        MOVS     r2,#1
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#2
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#0]
        MOVS     r2,#0x10
        BICS     r0,r0,r2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#0]
        LDR      r0,[r1,#0]
        LDR      r0,[r0,#4]
        LSRS     r0,r0,#2
        LSLS     r0,r0,#2
        LDR      r2,[r1,#0]
        STR      r0,[r2,#4]
        MOVS     r0,#3
        LDR      r2,[r1,#0]
        STR      r0,[r2,#8]
        MOVS     r2,#1
        MOVS     r0,#0x3c
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r2,#0
        MOVS     r0,#0x3d
        STRB     r2,[r0,r1]
        NOP      
        MOVS     r0,#0
        B        |L17.14|
        ENDP


        AREA ||i.TSC_extract_groups||, CODE, READONLY, ALIGN=1

TSC_extract_groups PROC
        PUSH     {r4,lr}
        MOV      r2,r0
        MOVS     r0,#0
        MOVS     r1,#0
        B        |L18.30|
|L18.10|
        LSLS     r4,r1,#2
        MOVS     r3,#0xf
        LSLS     r3,r3,r4
        ANDS     r3,r3,r2
        CMP      r3,#0
        BEQ      |L18.28|
        MOVS     r3,#1
        LSLS     r3,r3,r1
        ORRS     r0,r0,r3
|L18.28|
        ADDS     r1,r1,#1
|L18.30|
        CMP      r1,#8
        BCC      |L18.10|
        POP      {r4,pc}
        ENDP


        AREA ||.arm_vfe_header||, DATA, READONLY, NOALLOC, ALIGN=2

        DCD      0x00000000

;*** Start embedded assembler ***

#line 1 "C:\\Keil_v5\\ARM\\PACK\\Keil\\STM32F0xx_DFP\\2.0.0\\Drivers\\STM32F0xx_HAL_Driver\\Src\\stm32f0xx_hal_tsc.c"
	AREA ||.rev16_text||, CODE
	THUMB
	EXPORT |__asm___19_stm32f0xx_hal_tsc_c_c4cd125f____REV16|
#line 463 "C:\\Keil_v5\\ARM\\PACK\\ARM\\CMSIS\\5.4.0\\CMSIS\\Core\\Include\\cmsis_armcc.h"
|__asm___19_stm32f0xx_hal_tsc_c_c4cd125f____REV16| PROC
#line 464

 rev16 r0, r0
 bx lr
	ENDP
	AREA ||.revsh_text||, CODE
	THUMB
	EXPORT |__asm___19_stm32f0xx_hal_tsc_c_c4cd125f____REVSH|
#line 478
|__asm___19_stm32f0xx_hal_tsc_c_c4cd125f____REVSH| PROC
#line 479

 revsh r0, r0
 bx lr
	ENDP

;*** End   embedded assembler ***

        EXPORT HAL_TSC_ConvCpltCallback [CODE,WEAK]
        EXPORT HAL_TSC_DeInit [CODE]
        EXPORT HAL_TSC_ErrorCallback [CODE,WEAK]
        EXPORT HAL_TSC_GetState [CODE]
        EXPORT HAL_TSC_GroupGetStatus [CODE]
        EXPORT HAL_TSC_GroupGetValue [CODE]
        EXPORT HAL_TSC_IOConfig [CODE]
        EXPORT HAL_TSC_IODischarge [CODE]
        EXPORT HAL_TSC_IRQHandler [CODE]
        EXPORT HAL_TSC_Init [CODE]
        EXPORT HAL_TSC_MspDeInit [CODE,WEAK]
        EXPORT HAL_TSC_MspInit [CODE,WEAK]
        EXPORT HAL_TSC_PollForAcquisition [CODE]
        EXPORT HAL_TSC_Start [CODE]
        EXPORT HAL_TSC_Start_IT [CODE]
        EXPORT HAL_TSC_Stop [CODE]
        EXPORT HAL_TSC_Stop_IT [CODE]

        IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]

        KEEP TSC_extract_groups

        ATTR FILESCOPE
        ATTR SETVALUE Tag_ABI_PCS_wchar_t,2
        ATTR SETVALUE Tag_ABI_enum_size,1
        ATTR SETVALUE Tag_ABI_optimization_goals,6
        ATTR SETSTRING Tag_conformance,"2.06"
        ATTR SETVALUE AV,18,1

        ASSERT {ENDIAN} = "little"
        ASSERT {INTER} = {TRUE}
        ASSERT {ROPI} = {FALSE}
        ASSERT {RWPI} = {FALSE}
        ASSERT {IEEE_FULL} = {FALSE}
        ASSERT {IEEE_PART} = {FALSE}
        ASSERT {IEEE_JAVA} = {FALSE}
        END

; generated by Component: ARM Compiler 5.05 update 1 (build 106) Tool: ArmCC [4d0efa]
; commandline ArmCC [--c99 --split_sections --debug -c --asm -o.\objects\stm32f0xx_hal_flash.o --depend=.\objects\stm32f0xx_hal_flash.d --cpu=Cortex-M0 --apcs=interwork -O0 --diag_suppress=9931 -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE\Device\STM32F071VBTx -IC:\Keil_v5\ARM\PACK\ARM\CMSIS\5.4.0\CMSIS\Core\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0 -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\CMSIS\Device\ST\STM32F0xx\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc\Legacy -D__UVISION_VERSION=514 -D_RTE_ -DSTM32F071xB --omf_browse=.\objects\stm32f0xx_hal_flash.crf C:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Src\stm32f0xx_hal_flash.c]
        THUMB
        REQUIRE8
        PRESERVE8

        AREA ||i.FLASH_Program_HalfWord||, CODE, READONLY, ALIGN=2

FLASH_Program_HalfWord PROC
        MOVS     r2,#0
        LDR      r3,|L1.24|
        STR      r2,[r3,#0x1c]  ; pFlash
        LDR      r2,|L1.28|
        LDR      r2,[r2,#0x10]
        MOVS     r3,#1
        ORRS     r2,r2,r3
        LDR      r3,|L1.28|
        STR      r2,[r3,#0x10]
        STRH     r1,[r0,#0]
        BX       lr
        ENDP

        DCW      0x0000
|L1.24|
        DCD      pFlash
|L1.28|
        DCD      0x40022000

        AREA ||i.FLASH_SetErrorCode||, CODE, READONLY, ALIGN=2

FLASH_SetErrorCode PROC
        MOVS     r0,#0
        LDR      r1,|L2.64|
        LDR      r1,[r1,#0xc]
        MOVS     r2,#0x10
        ANDS     r1,r1,r2
        CMP      r1,#0x10
        BNE      |L2.30|
        LDR      r1,|L2.68|
        LDR      r1,[r1,#0x1c]  ; pFlash
        MOVS     r2,#2
        ORRS     r1,r1,r2
        LDR      r2,|L2.68|
        STR      r1,[r2,#0x1c]  ; pFlash
        MOVS     r1,#0x10
        ORRS     r0,r0,r1
|L2.30|
        LDR      r1,|L2.64|
        LDR      r1,[r1,#0xc]
        MOVS     r2,#4
        ANDS     r1,r1,r2
        CMP      r1,#4
        BNE      |L2.58|
        LDR      r1,|L2.68|
        LDR      r1,[r1,#0x1c]  ; pFlash
        MOVS     r2,#1
        ORRS     r1,r1,r2
        LDR      r2,|L2.68|
        STR      r1,[r2,#0x1c]  ; pFlash
        MOVS     r1,#4
        ORRS     r0,r0,r1
|L2.58|
        LDR      r1,|L2.64|
        STR      r0,[r1,#0xc]
        BX       lr
        ENDP

|L2.64|
        DCD      0x40022000
|L2.68|
        DCD      pFlash

        AREA ||i.FLASH_WaitForLastOperation||, CODE, READONLY, ALIGN=2

FLASH_WaitForLastOperation PROC
        PUSH     {r4-r6,lr}
        MOV      r4,r0
        BL       HAL_GetTick
        MOV      r5,r0
        B        |L3.36|
|L3.12|
        ADDS     r0,r4,#1
        CMP      r0,#0
        BEQ      |L3.36|
        CMP      r4,#0
        BEQ      |L3.32|
        BL       HAL_GetTick
        SUBS     r0,r0,r5
        CMP      r0,r4
        BLS      |L3.36|
|L3.32|
        MOVS     r0,#3
|L3.34|
        POP      {r4-r6,pc}
|L3.36|
        LDR      r0,|L3.100|
        LDR      r0,[r0,#0xc]
        LSLS     r0,r0,#31
        LSRS     r0,r0,#31
        CMP      r0,#0
        BNE      |L3.12|
        LDR      r0,|L3.100|
        LDR      r0,[r0,#0xc]
        MOVS     r1,#0x20
        ANDS     r0,r0,r1
        CMP      r0,#0x20
        BNE      |L3.64|
        LDR      r1,|L3.100|
        STR      r0,[r1,#0xc]
|L3.64|
        LDR      r0,|L3.100|
        LDR      r0,[r0,#0xc]
        MOVS     r1,#0x10
        ANDS     r0,r0,r1
        CMP      r0,#0x10
        BEQ      |L3.88|
        LDR      r0,|L3.100|
        LDR      r0,[r0,#0xc]
        MOVS     r1,#4
        ANDS     r0,r0,r1
        CMP      r0,#4
        BNE      |L3.96|
|L3.88|
        BL       FLASH_SetErrorCode
        MOVS     r0,#1
        B        |L3.34|
|L3.96|
        MOVS     r0,#0
        B        |L3.34|
        ENDP

|L3.100|
        DCD      0x40022000

        AREA ||i.HAL_FLASH_EndOfOperationCallback||, CODE, READONLY, ALIGN=1

HAL_FLASH_EndOfOperationCallback PROC
        BX       lr
        ENDP


        AREA ||i.HAL_FLASH_GetError||, CODE, READONLY, ALIGN=2

HAL_FLASH_GetError PROC
        LDR      r0,|L5.8|
        LDR      r0,[r0,#0x1c]  ; pFlash
        BX       lr
        ENDP

        DCW      0x0000
|L5.8|
        DCD      pFlash

        AREA ||i.HAL_FLASH_IRQHandler||, CODE, READONLY, ALIGN=2

HAL_FLASH_IRQHandler PROC
        PUSH     {r4,lr}
        MOVS     r4,#0
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0xc]
        MOVS     r1,#0x10
        ANDS     r0,r0,r1
        CMP      r0,#0x10
        BEQ      |L6.28|
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0xc]
        MOVS     r1,#4
        ANDS     r0,r0,r1
        CMP      r0,#4
        BNE      |L6.56|
|L6.28|
        LDR      r0,|L6.392|
        LDR      r4,[r0,#8]  ; pFlash
        MOVS     r0,#0
        MVNS     r0,r0
        LDR      r1,|L6.392|
        STR      r0,[r1,#8]  ; pFlash
        BL       FLASH_SetErrorCode
        MOV      r0,r4
        BL       HAL_FLASH_OperationErrorCallback
        MOVS     r0,#0
        LDR      r1,|L6.392|
        STRB     r0,[r1,#0]
|L6.56|
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0xc]
        MOVS     r1,#0x20
        ANDS     r0,r0,r1
        CMP      r0,#0x20
        BNE      |L6.148|
        LDR      r1,|L6.388|
        STR      r0,[r1,#0xc]
        LDR      r0,|L6.392|
        LDRB     r0,[r0,#0]  ; pFlash
        CMP      r0,#0
        BEQ      |L6.148|
        LDR      r0,|L6.392|
        LDRB     r0,[r0,#0]  ; pFlash
        CMP      r0,#1
        BNE      |L6.172|
        LDR      r0,|L6.392|
        LDR      r0,[r0,#4]  ; pFlash
        SUBS     r0,r0,#1
        LDR      r1,|L6.392|
        STR      r0,[r1,#4]  ; pFlash
        MOV      r0,r1
        LDR      r0,[r0,#4]  ; pFlash
        CMP      r0,#0
        BEQ      |L6.150|
        MOV      r0,r1
        LDR      r4,[r0,#8]  ; pFlash
        MOV      r0,r4
        BL       HAL_FLASH_EndOfOperationCallback
        LDR      r0,|L6.392|
        LDR      r0,[r0,#8]  ; pFlash
        MOVS     r1,#1
        LSLS     r1,r1,#11
        ADDS     r4,r0,r1
        LDR      r0,|L6.392|
        STR      r4,[r0,#8]  ; pFlash
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#2
        BICS     r0,r0,r1
        LDR      r1,|L6.388|
        STR      r0,[r1,#0x10]
        MOV      r0,r4
        BL       FLASH_PageErase
|L6.148|
        B        |L6.340|
|L6.150|
        MOVS     r0,#0
        MVNS     r0,r0
        MOV      r4,r0
        LDR      r1,|L6.392|
        STR      r0,[r1,#8]  ; pFlash
        MOVS     r0,#0
        STRB     r0,[r1,#0]
        MOV      r0,r4
        BL       HAL_FLASH_EndOfOperationCallback
        B        |L6.340|
|L6.172|
        LDR      r0,|L6.392|
        LDRB     r0,[r0,#0]  ; pFlash
        CMP      r0,#2
        BNE      |L6.206|
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#4
        BICS     r0,r0,r1
        LDR      r1,|L6.388|
        STR      r0,[r1,#0x10]
        MOVS     r0,#0
        BL       HAL_FLASH_EndOfOperationCallback
        MOVS     r0,#0
        LDR      r1,|L6.392|
        STRB     r0,[r1,#0]
        B        |L6.340|
|L6.206|
        LDR      r0,|L6.392|
        LDR      r0,[r0,#4]  ; pFlash
        SUBS     r0,r0,#1
        LDR      r1,|L6.392|
        STR      r0,[r1,#4]  ; pFlash
        MOV      r0,r1
        LDR      r0,[r0,#4]  ; pFlash
        CMP      r0,#0
        BEQ      |L6.280|
        MOV      r0,r1
        LDR      r0,[r0,#8]  ; pFlash
        ADDS     r0,r0,#2
        STR      r0,[r1,#8]  ; pFlash
        MOV      r0,r1
        LDR      r4,[r0,#8]  ; pFlash
        LDR      r0,[r1,#0x10]  ; pFlash
        LDR      r1,[r1,#0x14]  ; pFlash
        LSLS     r2,r1,#16
        LSRS     r0,r0,#16
        ORRS     r0,r0,r2
        LSRS     r1,r1,#16
        LDR      r2,|L6.392|
        STR      r0,[r2,#0x10]  ; pFlash
        STR      r1,[r2,#0x14]  ; pFlash
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0x10]
        LSRS     r0,r0,#1
        LSLS     r0,r0,#1
        LDR      r1,|L6.388|
        STR      r0,[r1,#0x10]
        LDR      r0,[r2,#0x10]  ; pFlash
        LDR      r2,[r2,#0x14]  ; pFlash
        UXTH     r1,r0
        MOV      r0,r4
        BL       FLASH_Program_HalfWord
        B        |L6.340|
|L6.280|
        LDR      r0,|L6.392|
        LDRB     r0,[r0,#0]  ; pFlash
        CMP      r0,#3
        BNE      |L6.298|
        LDR      r1,|L6.392|
        LDR      r0,[r1,#8]  ; pFlash
        BL       HAL_FLASH_EndOfOperationCallback
        B        |L6.328|
|L6.298|
        LDR      r0,|L6.392|
        LDRB     r0,[r0,#0]  ; pFlash
        CMP      r0,#4
        BNE      |L6.318|
        LDR      r1,|L6.392|
        LDR      r1,[r1,#8]  ; pFlash
        SUBS     r0,r1,#2
        BL       HAL_FLASH_EndOfOperationCallback
        B        |L6.328|
|L6.318|
        LDR      r1,|L6.392|
        LDR      r1,[r1,#8]  ; pFlash
        SUBS     r0,r1,#6
        BL       HAL_FLASH_EndOfOperationCallback
|L6.328|
        MOVS     r0,#0
        MVNS     r0,r0
        LDR      r1,|L6.392|
        STR      r0,[r1,#8]  ; pFlash
        MOVS     r0,#0
        STRB     r0,[r1,#0]
|L6.340|
        LDR      r0,|L6.392|
        LDRB     r0,[r0,#0]  ; pFlash
        CMP      r0,#0
        BNE      |L6.384|
        LDR      r0,|L6.388|
        LDR      r0,[r0,#0x10]
        LSRS     r0,r0,#3
        LSLS     r0,r0,#3
        LDR      r1,|L6.388|
        STR      r0,[r1,#0x10]
        MOV      r0,r1
        LDR      r0,[r0,#0x10]
        MOVS     r1,#5
        LSLS     r1,r1,#10
        BICS     r0,r0,r1
        LDR      r1,|L6.388|
        STR      r0,[r1,#0x10]
        NOP      
        MOVS     r0,#0
        LDR      r1,|L6.392|
        STRB     r0,[r1,#0x18]
        NOP      
|L6.384|
        POP      {r4,pc}
        ENDP

        DCW      0x0000
|L6.388|
        DCD      0x40022000
|L6.392|
        DCD      pFlash

        AREA ||i.HAL_FLASH_Lock||, CODE, READONLY, ALIGN=2

HAL_FLASH_Lock PROC
        LDR      r0,|L7.16|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#0x80
        ORRS     r0,r0,r1
        LDR      r1,|L7.16|
        STR      r0,[r1,#0x10]
        MOVS     r0,#0
        BX       lr
        ENDP

|L7.16|
        DCD      0x40022000

        AREA ||i.HAL_FLASH_OB_Launch||, CODE, READONLY, ALIGN=2

HAL_FLASH_OB_Launch PROC
        PUSH     {r4,lr}
        LDR      r0,|L8.24|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#1
        LSLS     r1,r1,#13
        ORRS     r0,r0,r1
        LDR      r1,|L8.24|
        STR      r0,[r1,#0x10]
        LDR      r0,|L8.28|
        BL       FLASH_WaitForLastOperation
        POP      {r4,pc}
        ENDP

|L8.24|
        DCD      0x40022000
|L8.28|
        DCD      0x0000c350

        AREA ||i.HAL_FLASH_OB_Lock||, CODE, READONLY, ALIGN=2

HAL_FLASH_OB_Lock PROC
        LDR      r0,|L9.20|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#1
        LSLS     r1,r1,#9
        BICS     r0,r0,r1
        LDR      r1,|L9.20|
        STR      r0,[r1,#0x10]
        MOVS     r0,#0
        BX       lr
        ENDP

        DCW      0x0000
|L9.20|
        DCD      0x40022000

        AREA ||i.HAL_FLASH_OB_Unlock||, CODE, READONLY, ALIGN=2

HAL_FLASH_OB_Unlock PROC
        LDR      r0,|L10.36|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#1
        LSLS     r1,r1,#9
        ANDS     r0,r0,r1
        CMP      r0,#0
        BNE      |L10.26|
        LDR      r0,|L10.40|
        LDR      r1,|L10.36|
        STR      r0,[r1,#8]
        LDR      r0,|L10.44|
        STR      r0,[r1,#8]
        B        |L10.30|
|L10.26|
        MOVS     r0,#1
|L10.28|
        BX       lr
|L10.30|
        MOVS     r0,#0
        B        |L10.28|
        ENDP

        DCW      0x0000
|L10.36|
        DCD      0x40022000
|L10.40|
        DCD      0x45670123
|L10.44|
        DCD      0xcdef89ab

        AREA ||i.HAL_FLASH_OperationErrorCallback||, CODE, READONLY, ALIGN=1

HAL_FLASH_OperationErrorCallback PROC
        BX       lr
        ENDP


        AREA ||i.HAL_FLASH_Program||, CODE, READONLY, ALIGN=2

HAL_FLASH_Program PROC
        PUSH     {r4-r7,lr}
        PUSH     {r0-r4}
        SUB      sp,sp,#0x18
        MOV      r7,r0
        MOV      r5,r2
        MOV      r6,r3
        MOVS     r0,#1
        STR      r0,[sp,#0xc]
        MOVS     r4,#0
        MOVS     r0,#0
        STR      r0,[sp,#8]
        NOP      
        LDR      r0,|L12.176|
        LDRB     r0,[r0,#0x18]  ; pFlash
        CMP      r0,#1
        BNE      |L12.38|
        MOVS     r0,#2
|L12.34|
        ADD      sp,sp,#0x2c
        POP      {r4-r7,pc}
|L12.38|
        MOVS     r0,#1
        LDR      r1,|L12.176|
        STRB     r0,[r1,#0x18]
        NOP      
        LDR      r0,|L12.180|
        BL       FLASH_WaitForLastOperation
        STR      r0,[sp,#0xc]
        LDR      r0,[sp,#0xc]
        CMP      r0,#0
        BNE      |L12.160|
        CMP      r7,#1
        BNE      |L12.70|
        MOVS     r0,#1
        STR      r0,[sp,#8]
        B        |L12.84|
|L12.70|
        CMP      r7,#2
        BNE      |L12.80|
        MOVS     r0,#2
        STR      r0,[sp,#8]
        B        |L12.84|
|L12.80|
        MOVS     r0,#4
        STR      r0,[sp,#8]
|L12.84|
        MOVS     r4,#0
        B        |L12.152|
|L12.88|
        LSLS     r2,r4,#4
        MOV      r0,r5
        MOV      r1,r6
        STR      r6,[sp,#0x10]
        STR      r5,[sp,#0x14]
        BL       __aeabi_llsr
        UXTH     r0,r0
        LSLS     r1,r4,#1
        STR      r0,[sp,#4]
        LDR      r0,[sp,#0x1c]
        ADDS     r0,r1,r0
        STR      r0,[sp,#0]
        LDR      r1,[sp,#4]
        BL       FLASH_Program_HalfWord
        LDR      r0,|L12.180|
        BL       FLASH_WaitForLastOperation
        STR      r0,[sp,#0xc]
        LDR      r0,|L12.184|
        LDR      r0,[r0,#0x10]
        LSRS     r0,r0,#1
        LSLS     r0,r0,#1
        LDR      r1,|L12.184|
        STR      r0,[r1,#0x10]
        LDR      r0,[sp,#0xc]
        CMP      r0,#0
        BEQ      |L12.148|
        B        |L12.158|
|L12.148|
        ADDS     r0,r4,#1
        UXTB     r4,r0
|L12.152|
        LDR      r0,[sp,#8]
        CMP      r4,r0
        BLT      |L12.88|
|L12.158|
        NOP      
|L12.160|
        NOP      
        MOVS     r0,#0
        LDR      r1,|L12.176|
        STRB     r0,[r1,#0x18]
        NOP      
        LDR      r0,[sp,#0xc]
        B        |L12.34|
        ENDP

        DCW      0x0000
|L12.176|
        DCD      pFlash
|L12.180|
        DCD      0x0000c350
|L12.184|
        DCD      0x40022000

        AREA ||i.HAL_FLASH_Program_IT||, CODE, READONLY, ALIGN=2

HAL_FLASH_Program_IT PROC
        PUSH     {r3-r7,lr}
        MOV      r6,r0
        MOV      r7,r1
        MOV      r4,r2
        MOV      r5,r3
        MOVS     r0,#0
        STR      r0,[sp,#0]
        NOP      
        LDR      r0,|L13.112|
        LDRB     r0,[r0,#0x18]  ; pFlash
        CMP      r0,#1
        BNE      |L13.28|
        MOVS     r0,#2
|L13.26|
        POP      {r3-r7,pc}
|L13.28|
        MOVS     r0,#1
        LDR      r1,|L13.112|
        STRB     r0,[r1,#0x18]
        NOP      
        LDR      r0,|L13.116|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#5
        LSLS     r1,r1,#10
        ORRS     r0,r0,r1
        LDR      r1,|L13.116|
        STR      r0,[r1,#0x10]
        LDR      r0,|L13.112|
        STR      r7,[r0,#8]  ; pFlash
        STR      r4,[r0,#0x10]  ; pFlash
        STR      r5,[r0,#0x14]  ; pFlash
        CMP      r6,#1
        BNE      |L13.74|
        MOVS     r0,#3
        LDR      r1,|L13.112|
        STRB     r0,[r1,#0]
        MOVS     r0,#1
        STR      r0,[r1,#4]  ; pFlash
        B        |L13.100|
|L13.74|
        CMP      r6,#2
        BNE      |L13.90|
        MOVS     r0,#4
        LDR      r1,|L13.112|
        STRB     r0,[r1,#0]
        MOVS     r0,#2
        STR      r0,[r1,#4]  ; pFlash
        B        |L13.100|
|L13.90|
        MOVS     r0,#5
        LDR      r1,|L13.112|
        STRB     r0,[r1,#0]
        MOVS     r0,#4
        STR      r0,[r1,#4]  ; pFlash
|L13.100|
        UXTH     r1,r4
        MOV      r0,r7
        BL       FLASH_Program_HalfWord
        LDR      r0,[sp,#0]
        B        |L13.26|
        ENDP

|L13.112|
        DCD      pFlash
|L13.116|
        DCD      0x40022000

        AREA ||i.HAL_FLASH_Unlock||, CODE, READONLY, ALIGN=2

HAL_FLASH_Unlock PROC
        LDR      r0,|L14.32|
        LDR      r0,[r0,#0x10]
        MOVS     r1,#0x80
        ANDS     r0,r0,r1
        CMP      r0,#0
        BEQ      |L14.24|
        LDR      r0,|L14.36|
        LDR      r1,|L14.32|
        STR      r0,[r1,#4]
        LDR      r0,|L14.40|
        STR      r0,[r1,#4]
        B        |L14.28|
|L14.24|
        MOVS     r0,#1
|L14.26|
        BX       lr
|L14.28|
        MOVS     r0,#0
        B        |L14.26|
        ENDP

|L14.32|
        DCD      0x40022000
|L14.36|
        DCD      0x45670123
|L14.40|
        DCD      0xcdef89ab

        AREA ||.arm_vfe_header||, DATA, READONLY, NOALLOC, ALIGN=2

        DCD      0x00000000

        AREA ||.bss||, DATA, NOINIT, ALIGN=3

pFlash
        %        32

;*** Start embedded assembler ***

#line 1 "C:\\Keil_v5\\ARM\\PACK\\Keil\\STM32F0xx_DFP\\2.0.0\\Drivers\\STM32F0xx_HAL_Driver\\Src\\stm32f0xx_hal_flash.c"
	AREA ||.rev16_text||, CODE
	THUMB
	EXPORT |__asm___21_stm32f0xx_hal_flash_c_48aa8f3e____REV16|
#line 463 "C:\\Keil_v5\\ARM\\PACK\\ARM\\CMSIS\\5.4.0\\CMSIS\\Core\\Include\\cmsis_armcc.h"
|__asm___21_stm32f0xx_hal_flash_c_48aa8f3e____REV16| PROC
#line 464

 rev16 r0, r0
 bx lr
	ENDP
	AREA ||.revsh_text||, CODE
	THUMB
	EXPORT |__asm___21_stm32f0xx_hal_flash_c_48aa8f3e____REVSH|
#line 478
|__asm___21_stm32f0xx_hal_flash_c_48aa8f3e____REVSH| PROC
#line 479

 revsh r0, r0
 bx lr
	ENDP

;*** End   embedded assembler ***

        EXPORT FLASH_WaitForLastOperation [CODE]
        EXPORT HAL_FLASH_EndOfOperationCallback [CODE,WEAK]
        EXPORT HAL_FLASH_GetError [CODE]
        EXPORT HAL_FLASH_IRQHandler [CODE]
        EXPORT HAL_FLASH_Lock [CODE]
        EXPORT HAL_FLASH_OB_Launch [CODE]
        EXPORT HAL_FLASH_OB_Lock [CODE]
        EXPORT HAL_FLASH_OB_Unlock [CODE]
        EXPORT HAL_FLASH_OperationErrorCallback [CODE,WEAK]
        EXPORT HAL_FLASH_Program [CODE]
        EXPORT HAL_FLASH_Program_IT [CODE]
        EXPORT HAL_FLASH_Unlock [CODE]
        EXPORT pFlash [DATA,SIZE=32]

        IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]
        IMPORT HAL_GetTick [CODE]
        IMPORT __aeabi_llsr [CODE]
        IMPORT FLASH_PageErase [CODE]

        KEEP FLASH_Program_HalfWord
        KEEP FLASH_SetErrorCode

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

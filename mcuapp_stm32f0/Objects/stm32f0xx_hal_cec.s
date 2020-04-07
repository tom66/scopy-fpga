; generated by Component: ARM Compiler 5.05 update 1 (build 106) Tool: ArmCC [4d0efa]
; commandline ArmCC [--c99 --split_sections --debug -c --asm -o.\objects\stm32f0xx_hal_cec.o --depend=.\objects\stm32f0xx_hal_cec.d --cpu=Cortex-M0 --apcs=interwork -O0 --diag_suppress=9931 -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE\Device\STM32F071VBTx -IC:\Keil_v5\ARM\PACK\ARM\CMSIS\5.4.0\CMSIS\Core\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0 -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\CMSIS\Device\ST\STM32F0xx\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc\Legacy -D__UVISION_VERSION=514 -D_RTE_ -DSTM32F071xB --omf_browse=.\objects\stm32f0xx_hal_cec.crf C:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Src\stm32f0xx_hal_cec.c]
        THUMB
        REQUIRE8
        PRESERVE8

        AREA ||i.HAL_CEC_ChangeRxBuffer||, CODE, READONLY, ALIGN=1

HAL_CEC_ChangeRxBuffer PROC
        STR      r1,[r0,#0x28]
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_DeInit||, CODE, READONLY, ALIGN=2

HAL_CEC_DeInit PROC
        PUSH     {r4,lr}
        MOV      r4,r0
        CMP      r4,#0
        BNE      |L2.12|
        MOVS     r0,#1
|L2.10|
        POP      {r4,pc}
|L2.12|
        MOVS     r1,#0x24
        MOVS     r0,#0x35
        STRB     r1,[r0,r4]
        MOV      r0,r4
        BL       HAL_CEC_MspDeInit
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        LSRS     r0,r0,#1
        LSLS     r0,r0,#1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        LDR      r1,|L2.88|
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x14]
        LSRS     r0,r0,#13
        LSLS     r0,r0,#13
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x14]
        MOVS     r0,#0
        STR      r0,[r4,#0x38]
        MOVS     r1,#0
        MOVS     r0,#0x35
        STRB     r1,[r0,r4]
        MOVS     r0,#0x36
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r0,#0x34
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r0,#0
        B        |L2.10|
        ENDP

        DCW      0x0000
|L2.88|
        DCD      0x00001fff

        AREA ||i.HAL_CEC_ErrorCallback||, CODE, READONLY, ALIGN=1

HAL_CEC_ErrorCallback PROC
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_GetError||, CODE, READONLY, ALIGN=1

HAL_CEC_GetError PROC
        MOV      r1,r0
        LDR      r0,[r1,#0x38]
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_GetLastReceivedFrameSize||, CODE, READONLY, ALIGN=1

HAL_CEC_GetLastReceivedFrameSize PROC
        MOV      r1,r0
        LDRH     r0,[r1,#0x32]
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_GetState||, CODE, READONLY, ALIGN=1

HAL_CEC_GetState PROC
        MOV      r1,r0
        MOVS     r2,#0
        MOVS     r3,#0
        MOVS     r0,#0x35
        LDRB     r2,[r0,r1]
        MOVS     r0,#0x36
        LDRB     r3,[r0,r1]
        MOV      r0,r2
        ORRS     r0,r0,r3
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_IRQHandler||, CODE, READONLY, ALIGN=2

HAL_CEC_IRQHandler PROC
        PUSH     {r4-r6,lr}
        MOV      r4,r0
        MOVS     r5,#0
        LDR      r0,[r4,#0]
        LDR      r5,[r0,#0x10]
        MOVS     r0,#0x80
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.34|
        MOVS     r0,#0x80
        STR      r0,[r4,#0x38]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        MOVS     r1,#0x80
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
|L7.34|
        LSLS     r0,r5,#31
        LSRS     r0,r0,#31
        CMP      r0,#0
        BEQ      |L7.80|
        MOVS     r1,#0x22
        MOVS     r0,#0x36
        STRB     r1,[r0,r4]
        LDRH     r0,[r4,#0x32]
        ADDS     r0,r0,#1
        STRH     r0,[r4,#0x32]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0xc]
        UXTB     r2,r0
        LDR      r3,[r4,#0x28]
        ADDS     r0,r3,#1
        STR      r0,[r4,#0x28]
        STRB     r2,[r3,#0]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        MOVS     r1,#1
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
|L7.80|
        MOVS     r0,#2
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.130|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        MOVS     r1,#2
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
        MOVS     r1,#0x20
        MOVS     r0,#0x36
        STRB     r1,[r0,r4]
        MOVS     r0,#0
        STR      r0,[r4,#0x38]
        LDRH     r1,[r4,#0x32]
        LDR      r0,[r4,#0x28]
        SUBS     r1,r0,r1
        STR      r1,[r4,#0x28]
        LDRH     r1,[r4,#0x32]
        MOV      r0,r4
        BL       HAL_CEC_RxCpltCallback
        MOVS     r0,#0
        STRH     r0,[r4,#0x32]
|L7.130|
        MOVS     r0,#0xff
        ADDS     r0,#1
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.204|
        LDRH     r0,[r4,#0x30]
        CMP      r0,#0
        BNE      |L7.172|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        MOVS     r1,#4
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        LDR      r1,[r4,#0x2c]
        ADDS     r0,r1,#1
        STR      r0,[r4,#0x2c]
        LDRB     r0,[r1,#0]
        LDR      r1,[r4,#0]
        STR      r0,[r1,#8]
        B        |L7.190|
|L7.172|
        LDR      r1,[r4,#0x2c]
        ADDS     r0,r1,#1
        STR      r0,[r4,#0x2c]
        LDRB     r0,[r1,#0]
        LDR      r1,[r4,#0]
        STR      r0,[r1,#8]
        LDRH     r0,[r4,#0x30]
        SUBS     r0,r0,#1
        STRH     r0,[r4,#0x30]
|L7.190|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        MOVS     r1,#0xff
        ADDS     r1,#1
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
|L7.204|
        MOVS     r0,#1
        LSLS     r0,r0,#9
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.254|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        MOVS     r1,#1
        LSLS     r1,r1,#9
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
        MOVS     r1,#0x20
        MOVS     r0,#0x35
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r1,#0
        MOVS     r0,#0x34
        STRB     r1,[r0,r4]
        NOP      
        MOVS     r0,#0
        STR      r0,[r4,#0x38]
        MOV      r0,r4
        BL       HAL_CEC_TxCpltCallback
|L7.254|
        LDR      r0,|L7.336|
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.334|
        STR      r5,[r4,#0x38]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x10]
        LDR      r1,|L7.336|
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x10]
        MOVS     r0,#0x7c
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.304|
        LDRH     r1,[r4,#0x32]
        LDR      r0,[r4,#0x28]
        SUBS     r1,r0,r1
        STR      r1,[r4,#0x28]
        MOVS     r0,#0
        STRH     r0,[r4,#0x32]
        MOVS     r1,#0x20
        MOVS     r0,#0x36
        STRB     r1,[r0,r4]
        B        |L7.328|
|L7.304|
        MOVS     r0,#7
        LSLS     r0,r0,#10
        ANDS     r0,r0,r5
        CMP      r0,#0
        BEQ      |L7.328|
        MOVS     r0,#0x80
        ANDS     r0,r0,r5
        CMP      r0,#0
        BNE      |L7.328|
        MOVS     r1,#0x20
        MOVS     r0,#0x35
        STRB     r1,[r0,r4]
|L7.328|
        MOV      r0,r4
        BL       HAL_CEC_ErrorCallback
|L7.334|
        POP      {r4-r6,pc}
        ENDP

|L7.336|
        DCD      0x00001c7c

        AREA ||i.HAL_CEC_Init||, CODE, READONLY, ALIGN=2

HAL_CEC_Init PROC
        PUSH     {r4,lr}
        MOV      r4,r0
        CMP      r4,#0
        BEQ      |L8.14|
        LDR      r0,[r4,#0x28]
        CMP      r0,#0
        BNE      |L8.18|
|L8.14|
        MOVS     r0,#1
|L8.16|
        POP      {r4,pc}
|L8.18|
        MOVS     r0,#0x35
        LDRB     r0,[r0,r4]
        CMP      r0,#0
        BNE      |L8.38|
        MOVS     r1,#0
        MOVS     r0,#0x34
        STRB     r1,[r0,r4]
        MOV      r0,r4
        BL       HAL_CEC_MspInit
|L8.38|
        MOVS     r1,#0x24
        MOVS     r0,#0x35
        STRB     r1,[r0,r4]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        LSRS     r0,r0,#1
        LSLS     r0,r0,#1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        LDR      r1,[r4,#8]
        LDR      r0,[r4,#4]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0xc]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x10]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x14]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x18]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x1c]
        ORRS     r0,r0,r1
        LDRH     r1,[r4,#0x24]
        LSLS     r1,r1,#16
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0x20]
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#4]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0x14]
        LDR      r1,|L8.140|
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0x14]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        MOVS     r1,#1
        ORRS     r0,r0,r1
        LDR      r1,[r4,#0]
        STR      r0,[r1,#0]
        MOVS     r0,#0
        STR      r0,[r4,#0x38]
        MOVS     r1,#0x20
        MOVS     r0,#0x35
        STRB     r1,[r0,r4]
        MOVS     r0,#0x36
        STRB     r1,[r0,r4]
        MOVS     r0,#0
        B        |L8.16|
        ENDP

        DCW      0x0000
|L8.140|
        DCD      0x00001fff

        AREA ||i.HAL_CEC_MspDeInit||, CODE, READONLY, ALIGN=1

HAL_CEC_MspDeInit PROC
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_MspInit||, CODE, READONLY, ALIGN=1

HAL_CEC_MspInit PROC
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_RxCpltCallback||, CODE, READONLY, ALIGN=1

HAL_CEC_RxCpltCallback PROC
        BX       lr
        ENDP


        AREA ||i.HAL_CEC_SetDeviceAddress||, CODE, READONLY, ALIGN=2

HAL_CEC_SetDeviceAddress PROC
        MOV      r2,r0
        MOVS     r0,#0x35
        LDRB     r0,[r0,r2]
        CMP      r0,#0x20
        BNE      |L12.124|
        MOVS     r0,#0x36
        LDRB     r0,[r0,r2]
        CMP      r0,#0x20
        BNE      |L12.124|
        NOP      
        MOVS     r0,#0x34
        LDRB     r0,[r0,r2]
        CMP      r0,#1
        BNE      |L12.32|
        MOVS     r0,#2
|L12.30|
        BX       lr
|L12.32|
        MOVS     r3,#1
        MOVS     r0,#0x34
        STRB     r3,[r0,r2]
        NOP      
        MOVS     r3,#0x24
        MOVS     r0,#0x35
        STRB     r3,[r0,r2]
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#0]
        LSRS     r0,r0,#1
        LSLS     r0,r0,#1
        LDR      r3,[r2,#0]
        STR      r0,[r3,#0]
        CMP      r1,#0
        BEQ      |L12.76|
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#4]
        LSLS     r3,r1,#16
        ORRS     r0,r0,r3
        LDR      r3,[r2,#0]
        STR      r0,[r3,#4]
        B        |L12.88|
|L12.76|
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#4]
        LDR      r3,|L12.128|
        ANDS     r0,r0,r3
        LDR      r3,[r2,#0]
        STR      r0,[r3,#4]
|L12.88|
        MOVS     r3,#0x20
        MOVS     r0,#0x35
        STRB     r3,[r0,r2]
        MOVS     r0,#0
        STR      r0,[r2,#0x38]
        NOP      
        MOVS     r3,#0
        MOVS     r0,#0x34
        STRB     r3,[r0,r2]
        NOP      
        LDR      r0,[r2,#0]
        LDR      r0,[r0,#0]
        MOVS     r3,#1
        ORRS     r0,r0,r3
        LDR      r3,[r2,#0]
        STR      r0,[r3,#0]
        MOVS     r0,#0
        B        |L12.30|
|L12.124|
        MOVS     r0,#2
        B        |L12.30|
        ENDP

|L12.128|
        DCD      0x8000ffff

        AREA ||i.HAL_CEC_Transmit_IT||, CODE, READONLY, ALIGN=1

HAL_CEC_Transmit_IT PROC
        PUSH     {r4-r6,lr}
        MOV      r4,r0
        LDR      r5,[sp,#0x10]
        MOVS     r0,#0x35
        LDRB     r0,[r0,r4]
        CMP      r0,#0x20
        BNE      |L13.114|
        CMP      r3,#0
        BNE      |L13.26|
        CMP      r5,#0
        BEQ      |L13.26|
        MOVS     r0,#1
|L13.24|
        POP      {r4-r6,pc}
|L13.26|
        NOP      
        MOVS     r0,#0x34
        LDRB     r0,[r0,r4]
        CMP      r0,#1
        BNE      |L13.40|
        MOVS     r0,#2
        B        |L13.24|
|L13.40|
        MOVS     r6,#1
        MOVS     r0,#0x34
        STRB     r6,[r0,r4]
        NOP      
        STR      r3,[r4,#0x2c]
        MOVS     r6,#0x21
        MOVS     r0,#0x35
        STRB     r6,[r0,r4]
        MOVS     r0,#0
        STR      r0,[r4,#0x38]
        STRH     r5,[r4,#0x30]
        CMP      r5,#0
        BNE      |L13.78|
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        MOVS     r6,#4
        ORRS     r0,r0,r6
        LDR      r6,[r4,#0]
        STR      r0,[r6,#0]
|L13.78|
        LSLS     r0,r1,#28
        LSRS     r0,r0,#24
        ORRS     r0,r0,r2
        LDR      r6,[r4,#0]
        STR      r0,[r6,#8]
        LDR      r0,[r4,#0]
        LDR      r0,[r0,#0]
        MOVS     r6,#2
        ORRS     r0,r0,r6
        LDR      r6,[r4,#0]
        STR      r0,[r6,#0]
        NOP      
        MOVS     r6,#0
        MOVS     r0,#0x34
        STRB     r6,[r0,r4]
        NOP      
        MOVS     r0,#0
        B        |L13.24|
|L13.114|
        MOVS     r0,#2
        B        |L13.24|
        ENDP


        AREA ||i.HAL_CEC_TxCpltCallback||, CODE, READONLY, ALIGN=1

HAL_CEC_TxCpltCallback PROC
        BX       lr
        ENDP


        AREA ||.arm_vfe_header||, DATA, READONLY, NOALLOC, ALIGN=2

        DCD      0x00000000

;*** Start embedded assembler ***

#line 1 "C:\\Keil_v5\\ARM\\PACK\\Keil\\STM32F0xx_DFP\\2.0.0\\Drivers\\STM32F0xx_HAL_Driver\\Src\\stm32f0xx_hal_cec.c"
	AREA ||.rev16_text||, CODE
	THUMB
	EXPORT |__asm___19_stm32f0xx_hal_cec_c_b6bd8399____REV16|
#line 463 "C:\\Keil_v5\\ARM\\PACK\\ARM\\CMSIS\\5.4.0\\CMSIS\\Core\\Include\\cmsis_armcc.h"
|__asm___19_stm32f0xx_hal_cec_c_b6bd8399____REV16| PROC
#line 464

 rev16 r0, r0
 bx lr
	ENDP
	AREA ||.revsh_text||, CODE
	THUMB
	EXPORT |__asm___19_stm32f0xx_hal_cec_c_b6bd8399____REVSH|
#line 478
|__asm___19_stm32f0xx_hal_cec_c_b6bd8399____REVSH| PROC
#line 479

 revsh r0, r0
 bx lr
	ENDP

;*** End   embedded assembler ***

        EXPORT HAL_CEC_ChangeRxBuffer [CODE]
        EXPORT HAL_CEC_DeInit [CODE]
        EXPORT HAL_CEC_ErrorCallback [CODE,WEAK]
        EXPORT HAL_CEC_GetError [CODE]
        EXPORT HAL_CEC_GetLastReceivedFrameSize [CODE]
        EXPORT HAL_CEC_GetState [CODE]
        EXPORT HAL_CEC_IRQHandler [CODE]
        EXPORT HAL_CEC_Init [CODE]
        EXPORT HAL_CEC_MspDeInit [CODE,WEAK]
        EXPORT HAL_CEC_MspInit [CODE,WEAK]
        EXPORT HAL_CEC_RxCpltCallback [CODE,WEAK]
        EXPORT HAL_CEC_SetDeviceAddress [CODE]
        EXPORT HAL_CEC_Transmit_IT [CODE]
        EXPORT HAL_CEC_TxCpltCallback [CODE,WEAK]

        IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]

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

; generated by Component: ARM Compiler 5.05 update 1 (build 106) Tool: ArmCC [4d0efa]
; commandline ArmCC [--c99 --split_sections --debug -c --asm -o.\objects\hmcad151x.o --depend=.\objects\hmcad151x.d --cpu=Cortex-M0 --apcs=interwork -O0 --diag_suppress=9931 -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE -IC:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\mcuapp_stm32f0\RTE\Device\STM32F071VBTx -IC:\Keil_v5\ARM\PACK\ARM\CMSIS\5.4.0\CMSIS\Core\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0 -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\CMSIS\Device\ST\STM32F0xx\Include -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc -IC:\Keil_v5\ARM\PACK\Keil\STM32F0xx_DFP\2.0.0\Drivers\STM32F0xx_HAL_Driver\Inc\Legacy -D__UVISION_VERSION=514 -D_RTE_ -DSTM32F071xB --omf_browse=.\objects\hmcad151x.crf hmcad151x.c]
        THUMB
        REQUIRE8
        PRESERVE8

        AREA ||i.hmcad151x_init||, CODE, READONLY, ALIGN=2

hmcad151x_init PROC
        PUSH     {r4-r6,lr}
        MOVS     r4,#0
        MOVS     r5,#0
        MOVS     r1,#8
        LDR      r0,|L1.244|
        BL       gpio_set_output
        MOVS     r1,#1
        MOVS     r0,#9
        LSLS     r0,r0,#27
        BL       gpio_set_output
        MOVS     r1,#4
        LDR      r0,|L1.244|
        BL       gpio_set_output
        MOVS     r1,#8
        LDR      r0,|L1.248|
        BL       gpio_set_output
        MOVS     r1,#4
        LDR      r0,|L1.248|
        BL       gpio_set_output
        BL       adc_power_on
        MOVS     r0,#5
        BL       systick_wait
        MOVS     r0,#8
        LDR      r1,|L1.244|
        STR      r0,[r1,#0x28]
        MOVS     r0,#1
        MOVS     r1,#9
        LSLS     r1,r1,#27
        STR      r0,[r1,#0x18]
        MOVS     r0,#4
        LDR      r1,|L1.244|
        STR      r0,[r1,#0x18]
        MOVS     r0,#8
        LDR      r1,|L1.248|
        STR      r0,[r1,#0x28]
        MOVS     r0,#4
        STR      r0,[r1,#0x28]
        MOVS     r0,#1
        BL       systick_wait
        MOVS     r0,#1
        MOVS     r1,#9
        LSLS     r1,r1,#27
        STR      r0,[r1,#0x28]
        MOVS     r0,#0xc8
        BL       arb_delay
        MOVS     r0,#1
        MOVS     r1,#9
        LSLS     r1,r1,#27
        STR      r0,[r1,#0x18]
        MOVS     r0,#8
        LDR      r1,|L1.244|
        STR      r0,[r1,#0x18]
        MOVS     r0,#0xc8
        BL       arb_delay
        MOVS     r0,#8
        LDR      r1,|L1.244|
        STR      r0,[r1,#0x28]
        ADR      r0,|L1.252|
        BL       uart_printf
        MOVS     r1,#1
        MOVS     r0,#0x31
        BL       hmcad151x_write_reg
        MOVS     r1,#0x30
        MOVS     r0,#0x50
        BL       hmcad151x_write_reg
        MOVS     r1,#0xf
        MOVS     r0,#0x30
        BL       hmcad151x_write_reg
        MOVS     r1,#3
        MOVS     r0,#0x56
        BL       hmcad151x_write_reg
        MOVS     r1,#0x20
        MOVS     r0,#0x55
        BL       hmcad151x_write_reg
        MOVS     r1,#0x30
        MOVS     r0,#0x50
        BL       hmcad151x_write_reg
        MOVS     r0,#3
        LDR      r1,|L1.280|
        STRB     r0,[r1,#0]
        STRB     r0,[r1,#1]
        STRB     r0,[r1,#2]
        MOVS     r0,#0
        STRB     r0,[r1,#3]
        STRB     r0,[r1,#4]
        STRB     r0,[r1,#5]
        STRB     r0,[r1,#5]
        STRB     r0,[r1,#6]
        STRB     r0,[r1,#7]
        BL       hmcad151x_sync_lvds_settings
        MOVS     r0,#8
        LDR      r1,|L1.280|
        STRB     r0,[r1,#8]
        MOVS     r1,#8
        LDR      r0,|L1.280|
        STRB     r1,[r0,#9]
        STRB     r1,[r0,#0xa]
        STRB     r1,[r0,#0xb]
        BL       hmcad151x_sync_channel_settings
        ADR      r0,|L1.284|
        BL       uart_printf
        POP      {r4-r6,pc}
        ENDP

|L1.244|
        DCD      0x48001400
|L1.248|
        DCD      0x48000800
|L1.252|
        DCB      "hmcad151x: reset complete\r\n",0
|L1.280|
        DCD      hmcad151x_state
|L1.284|
        DCB      "hmcad151x: register write complete\r\n",0
        DCB      0
        DCB      0
        DCB      0

        AREA ||i.hmcad151x_sync_channel_settings||, CODE, READONLY, ALIGN=2

hmcad151x_sync_channel_settings PROC
        PUSH     {r3-r5,lr}
        MOVS     r4,#0
        B        |L2.44|
|L2.6|
        LDR      r0,|L2.96|
        LDRB     r0,[r0,r4]
        LSLS     r0,r0,#28
        LSRS     r0,r0,#28
        MOV      r1,sp
        STRB     r0,[r1,r4]
        LDRB     r0,[r1,r4]
        BL       __ARM_pop
        CMP      r0,#1
        BLE      |L2.42|
        MOVS     r0,#0
        MOV      r1,sp
        STRB     r0,[r1,r4]
        MOV      r1,r4
        ADR      r0,|L2.100|
        BL       uart_printf
|L2.42|
        ADDS     r4,r4,#1
|L2.44|
        CMP      r4,#4
        BCC      |L2.6|
        MOV      r0,sp
        LDRB     r0,[r0,#0]
        LSLS     r2,r0,#1
        MOV      r0,sp
        LDRB     r0,[r0,#1]
        LSLS     r0,r0,#9
        ORRS     r2,r2,r0
        UXTH     r1,r2
        MOVS     r0,#0x3a
        BL       hmcad151x_write_reg
        MOV      r0,sp
        LDRB     r0,[r0,#2]
        LSLS     r0,r0,#1
        MOV      r2,sp
        LDRB     r2,[r2,#3]
        LSLS     r2,r2,#9
        ORRS     r0,r0,r2
        UXTH     r1,r0
        MOVS     r0,#0x3b
        BL       hmcad151x_write_reg
        POP      {r3-r5,pc}
        ENDP

        DCW      0x0000
|L2.96|
        DCD      hmcad151x_state+0x8
|L2.100|
        DCB      "WARN(hmcad): Multiple channels enabled #%d, disabling a"
        DCB      "ll\r\n",0

        AREA ||i.hmcad151x_sync_lvds_settings||, CODE, READONLY, ALIGN=2

hmcad151x_sync_lvds_settings PROC
        PUSH     {r3-r7,lr}
        MOVS     r7,#0
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#0]  ; hmcad151x_state
        LDR      r1,|L3.180|
        LDRB     r0,[r1,r0]
        LSLS     r4,r0,#29
        LSRS     r4,r4,#29
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#1]  ; hmcad151x_state
        LDRB     r0,[r1,r0]
        LSLS     r5,r0,#29
        LSRS     r5,r5,#29
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#2]  ; hmcad151x_state
        LDRB     r0,[r1,r0]
        LSLS     r6,r0,#29
        LSRS     r6,r6,#29
        LSLS     r0,r5,#4
        ORRS     r0,r0,r4
        LSLS     r2,r6,#8
        ORRS     r0,r0,r2
        MOV      r1,r0
        MOVS     r0,#0x11
        BL       hmcad151x_write_reg
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#3]  ; hmcad151x_state
        LSLS     r4,r0,#29
        LSRS     r4,r4,#29
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#4]  ; hmcad151x_state
        LSLS     r5,r0,#29
        LSRS     r5,r5,#29
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#5]  ; hmcad151x_state
        LSLS     r6,r0,#29
        LSRS     r6,r6,#29
        CMP      r4,#0
        BGT      |L3.88|
        CMP      r5,#0
        BGT      |L3.88|
        CMP      r6,#0
        BLE      |L3.90|
|L3.88|
        MOVS     r7,#1
|L3.90|
        LSLS     r0,r5,#4
        ORRS     r0,r0,r4
        LSLS     r2,r6,#8
        ORRS     r0,r0,r2
        LSLS     r2,r7,#14
        ORRS     r0,r0,r2
        UXTH     r1,r0
        MOVS     r0,#0x12
        BL       hmcad151x_write_reg
        LDR      r1,|L3.176|
        MOVS     r0,#6
        LDRSB    r0,[r1,r0]  ; hmcad151x_state
        ADDS     r0,r0,#1
        CMP      r0,#0
        BNE      |L3.132|
        MOVS     r1,#0x20
        MOVS     r0,#0x53
        BL       hmcad151x_write_reg
        B        |L3.158|
|L3.132|
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#6]  ; hmcad151x_state
        CMP      r0,#1
        BNE      |L3.150|
        MOVS     r1,#0x10
        MOVS     r0,#0x53
        BL       hmcad151x_write_reg
        B        |L3.158|
|L3.150|
        MOVS     r1,#0
        MOVS     r0,#0x53
        BL       hmcad151x_write_reg
|L3.158|
        LDR      r0,|L3.176|
        LDRB     r0,[r0,#7]  ; hmcad151x_state
        LSLS     r0,r0,#30
        LSRS     r1,r0,#25
        MOVS     r0,#0x42
        BL       hmcad151x_write_reg
        POP      {r3-r7,pc}
        ENDP

        DCW      0x0000
|L3.176|
        DCD      hmcad151x_state
|L3.180|
        DCD      hmcad_lvds_current_index

        AREA ||i.hmcad151x_test_mode||, CODE, READONLY, ALIGN=1

hmcad151x_test_mode PROC
        PUSH     {r4-r6,lr}
        MOV      r5,r0
        MOV      r4,r1
        MOVS     r3,r5
        BL       __ARM_common_switch8
        DCB      0x06,0x05,0x16,0x27
        DCB      0x3c,0x4e,0x5f,0x04
        NOP      
        MOVS     r1,#0
        MOVS     r0,#0x25
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x26
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x27
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x45
        BL       hmcad151x_write_reg
        B        |L4.236|
        MOVS     r1,#0x40
        MOVS     r0,#0x25
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x26
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x27
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x45
        BL       hmcad151x_write_reg
        B        |L4.236|
        MOVS     r1,#0x20
        MOVS     r0,#0x25
        BL       hmcad151x_write_reg
        MOVS     r0,#0xff
        LSLS     r0,r0,#8
        ANDS     r0,r0,r4
        MOV      r1,r0
        MOVS     r0,#0x26
        BL       hmcad151x_write_reg
        LSLS     r0,r4,#24
        LSRS     r1,r0,#16
        MOVS     r0,#0x27
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x45
        BL       hmcad151x_write_reg
        B        |L4.236|
        MOVS     r1,#0x10
        MOVS     r0,#0x25
        BL       hmcad151x_write_reg
        LSLS     r0,r4,#24
        LSRS     r1,r0,#16
        MOVS     r0,#0x26
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x27
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x45
        BL       hmcad151x_write_reg
        B        |L4.236|
        MOVS     r1,#0
        MOVS     r0,#0x25
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x26
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x27
        BL       hmcad151x_write_reg
        MOVS     r1,#1
        MOVS     r0,#0x45
        BL       hmcad151x_write_reg
        B        |L4.236|
        MOVS     r1,#0
        MOVS     r0,#0x25
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x26
        BL       hmcad151x_write_reg
        MOVS     r1,#0
        MOVS     r0,#0x27
        BL       hmcad151x_write_reg
        MOVS     r1,#2
        MOVS     r0,#0x45
        BL       hmcad151x_write_reg
        NOP      
|L4.236|
        NOP      
        POP      {r4-r6,pc}
        ENDP


        AREA ||i.hmcad151x_write_reg||, CODE, READONLY, ALIGN=2

hmcad151x_write_reg PROC
        PUSH     {r3-r7,lr}
        MOV      r4,r0
        MOV      r6,r1
        LSLS     r0,r4,#16
        ORRS     r0,r0,r6
        MOV      r7,r0
        MOVS     r0,#4
        LDR      r1,|L5.492|
        STR      r0,[r1,#0x28]
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        MOVS     r5,#0x17
        B        |L5.220|
|L5.102|
        MOVS     r0,#1
        LSLS     r0,r0,r5
        ANDS     r0,r0,r7
        CMP      r0,#0
        BEQ      |L5.120|
        MOVS     r0,#8
        LDR      r1,|L5.496|
        STR      r0,[r1,#0x18]
        B        |L5.126|
|L5.120|
        MOVS     r0,#8
        LDR      r1,|L5.496|
        STR      r0,[r1,#0x28]
|L5.126|
        MOVS     r0,#4
        LDR      r1,|L5.496|
        STR      r0,[r1,#0x28]
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        MOVS     r0,#4
        LDR      r1,|L5.496|
        STR      r0,[r1,#0x18]
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        SUBS     r5,r5,#1
|L5.220|
        CMP      r5,#0
        BGE      |L5.102|
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        MOVS     r0,#4
        LDR      r1,|L5.492|
        STR      r0,[r1,#0x18]
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        MOVS     r0,#8
        LDR      r1,|L5.496|
        STR      r0,[r1,#0x18]
        MOVS     r0,#4
        STR      r0,[r1,#0x18]
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        NOP      
        MOV      r2,r4
        MOV      r1,r6
        ADR      r0,|L5.500|
        BL       uart_printf
        POP      {r3-r7,pc}
        ENDP

|L5.492|
        DCD      0x48001400
|L5.496|
        DCD      0x48000800
|L5.500|
        DCB      "hmcad151x: write 0x%04x to 0x%02x\r\n",0

        AREA ||.arm_vfe_header||, DATA, READONLY, NOALLOC, ALIGN=2

        DCD      0x00000000

        AREA ||.bss||, DATA, NOINIT, ALIGN=0

hmcad151x_state
        %        12

        AREA ||.constdata||, DATA, READONLY, ALIGN=2

hmcad_lvds_current_index
        DCB      0x03,0x02,0x01,0x00
        DCB      0x07,0x06,0x05,0x04
hmcad_lvds_term_lut
        DCW      0xc34f,0x0104
        DCW      0x0096,0x005e
        DCW      0x007d,0x0050
        DCW      0x0042,0x0037
hmcad_lvds_current_lut
        DCFS     0x3f000000 ; 0.5
        DCFS     0x3fc00000 ; 1.5
        DCFS     0x40200000 ; 2.5
        DCFS     0x40600000 ; 3.5
        DCFS     0x40900000 ; 4.5
        DCFS     0x40b00000 ; 5.5
        DCFS     0x40d00000 ; 6.5
        DCFS     0x40f00000 ; 7.5

        AREA ||i.__ARM_pop||, COMGROUP=__ARM_pop, CODE, READONLY, ALIGN=2

__ARM_pop PROC
        MOV      r1,r0
        LDR      r2,|L41.48|
        LSRS     r0,r1,#1
        LDR      r3,|L41.52|
        ANDS     r0,r0,r3
        SUBS     r1,r1,r0
        MOV      r0,r1
        ANDS     r0,r0,r2
        LSRS     r3,r1,#2
        ANDS     r3,r3,r2
        ADDS     r1,r0,r3
        LSRS     r0,r1,#4
        ADDS     r0,r0,r1
        LDR      r3,|L41.56|
        ANDS     r0,r0,r3
        MOV      r1,r0
        LSRS     r0,r0,#8
        ADDS     r1,r0,r1
        LSRS     r0,r1,#16
        ADDS     r1,r0,r1
        LSLS     r0,r1,#26
        LSRS     r0,r0,#26
        BX       lr
        ENDP

        DCW      0x0000
|L41.48|
        DCD      0x33333333
|L41.52|
        DCD      0x55555555
|L41.56|
        DCD      0x0f0f0f0f

        AREA ||i.__ARM_common_switch8||, COMGROUP=__ARM_common_switch8, CODE, READONLY, ALIGN=1

__ARM_common_switch8 PROC
        PUSH     {r4,r5}
        MOV      r4,lr
        SUBS     r4,r4,#1
        LDRB     r5,[r4,#0]
        ADDS     r4,r4,#1
        CMP      r3,r5
        BCC      |L44.24|
|L44.14|
        LDRB     r3,[r4,r5]
        LSLS     r3,r3,#1
        ADDS     r3,r4,r3
        POP      {r4,r5}
        BX       r3
|L44.24|
        MOV      r5,r3
        B        |L44.14|
        ENDP


;*** Start embedded assembler ***

#line 1 "hmcad151x.c"
	AREA ||.rev16_text||, CODE
	THUMB
	EXPORT |__asm___11_hmcad151x_c_567cd2db____REV16|
#line 463 "C:\\Keil_v5\\ARM\\PACK\\ARM\\CMSIS\\5.4.0\\CMSIS\\Core\\Include\\cmsis_armcc.h"
|__asm___11_hmcad151x_c_567cd2db____REV16| PROC
#line 464

 rev16 r0, r0
 bx lr
	ENDP
	AREA ||.revsh_text||, CODE
	THUMB
	EXPORT |__asm___11_hmcad151x_c_567cd2db____REVSH|
#line 478
|__asm___11_hmcad151x_c_567cd2db____REVSH| PROC
#line 479

 revsh r0, r0
 bx lr
	ENDP

;*** End   embedded assembler ***

        EXPORT hmcad151x_init [CODE]
        EXPORT hmcad151x_sync_channel_settings [CODE]
        EXPORT hmcad151x_sync_lvds_settings [CODE]
        EXPORT hmcad151x_test_mode [CODE]
        EXPORT hmcad151x_write_reg [CODE]
        EXPORT hmcad151x_state [DATA,SIZE=12]
        EXPORT hmcad_lvds_current_index [DATA,SIZE=8]
        EXPORT hmcad_lvds_term_lut [DATA,SIZE=16]
        EXPORT hmcad_lvds_current_lut [DATA,SIZE=32]
        EXPORT __ARM_pop [CODE]
        EXPORT __ARM_common_switch8 [CODE]

        IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]
        IMPORT uart_printf [CODE]
        IMPORT gpio_set_output [CODE]
        IMPORT adc_power_on [CODE]
        IMPORT systick_wait [CODE]
        IMPORT arb_delay [CODE]

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
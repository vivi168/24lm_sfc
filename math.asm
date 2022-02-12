; 32 bits add
; input num1: ax(lo), bx(hi)
; input num2: cx(lo), dx(hi)
; result in ax(lo), bx(hi)
Add32:
    php

    .call M8

    .call RESERVE_STACK_FRAME 04
    ; 01/02 03/04 -> result

    .call M16
    ; 32 bits add

    clc
    lda @ax ; num1_lo
    adc @cx ; num2_lo
    sta 01; result_lo

    lda @bx ; num1_hi
    adc @dx ; num2_hi
    sta 03 ; result_hi

    lda 01
    sta @ax
    lda 03
    sta @bx

    .call M8
    .call RESTORE_STACK_FRAME 04

    plp
    rts

; 32 bits LSR
; @ax -> input lo / result lo
; @bx -> input hi / result hi
; @cl -> amount to shift
Lsr32:
    php

lsr_32_loop:
    .call M16
    lsr @bx
    ror @ax

    .call M8
    dec @cl
    bne @lsr_32_loop

    plp
    rts

; 32 bits ASL
; @ax -> input lo / result lo
; @bx -> input hi / result hi
; @cl -> amount to shift
Asl32:
    php

asl_32_loop:
    .call M16
    asl @ax
    rol @bx

    .call M8
    dec @cl
    bne @asl_32_loop

    plp
    rts

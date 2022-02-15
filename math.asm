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

; angle in A:16
; result in A:16
GetSin:
    asl
    bit #0100
    bne @negative_sin

    tax
    lda !binrad_sines_lut,x
    bra @exit_get_sin

negative_sin:
    and #00ff
    tax
    lda !binrad_sines_lut,x
    eor #ffff
    inc

exit_get_sin:

    rts

; angle in A:16
; result in A:16
GetCos:
    clc
    adc #0040
    and #00ff
    jsr @GetSin

    rts



; angle in A:16
; result in A:16
GetSinM7:
    asl
    bit #0100
    bne @negative_m7sin

    tax
    lda !m7_sines_lut,x
    bra @exit_get_m7sin

negative_m7sin:
    and #00ff
    tax
    lda !m7_sines_lut,x
    eor #ffff
    inc

exit_get_m7sin:
    rts

; angle in A:16
; result in A:16
GetCosM7:
    clc
    adc #0040
    and #00ff
    jsr @GetSinM7

    rts

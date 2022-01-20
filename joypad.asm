ReadJoyPad1:
    php
read_joy1_data:
    lda HVBJOY          ; read joypad status
    and #01
    bne @read_joy1_data ; read done when 0

    .call MX16

    ldx @joy1_raw       ; read previous frame raw input
    lda JOY1L           ; read current frame raw input (JOY1L)
    sta @joy1_raw       ; save it
    txa                 ; move previous frame raw input to A
    eor @joy1_raw       ; XOR previous with current, get changes. Held and unpressed become 0
    and @joy1_raw       ; AND previous with current, only pressed left to 1
    sta @joy1_press     ; store pressed
    txa                 ; move previous frame raw input to A
    and @joy1_raw       ; AND with current, only held are left to 1
    sta @joy1_held      ; stored held

    plp
    rts

HandleInput:
    php
    .call M16
    ; press A -> x,y += dx, dy
    ; press right -> angle++
    ; press left -> angle--
    ; angle > 359 ? -> angle = 0
    ; angle < 0 ? -> angle = 359
    ; dx = cos(angle), dy = sin(angle)



    ; TODO -> check left/right AND accelerate
    ; can accelerate AND turn right same frame
    ; first adjust angle if left/right pressed
    lda @joy1_held
    bit #BUTTON_A
    bne @accelerate

check_direction_keys:
    lda @joy1_held
    bit #BUTTON_LEFT
    bne @turn_left

    bit #BUTTON_RIGHT
    bne @turn_right


    jmp @exit_handle_input

accelerate:
    ; X coordinate
    lda @player_fx_lo
    sta @ax
    lda @player_fx_hi
    sta @bx

    stz @dx
    lda @player_dx
    sta @cx

    bpl @add_x_coord
    dec @dx ; wrap dx at 0xffff (negative)
add_x_coord:
    jsr @Add32
    lda @ax
    sta @player_fx_lo
    lda @bx
    sta @player_fx_hi


    ; Y coordinate
    lda @player_fy_lo
    sta @ax
    lda @player_fy_hi
    sta @bx

    stz @dx
    lda @player_dy
    sta @cx

    bpl @add_y_coord
    dec @dx ; wrap dx at 0xffff (negative)
add_y_coord:
    jsr @Add32
    lda @ax
    sta @player_fy_lo
    lda @bx
    sta @player_fy_hi


    bra @check_direction_keys

turn_left:
    lda @player_angle
    dec
    dec
    dec
    sta @player_angle

    bra @keep_angle_in_bound

turn_right:
    lda @player_angle
    inc
    inc
    inc
    sta @player_angle

    bra @keep_angle_in_bound


keep_angle_in_bound:
    lda @player_angle
    bmi @set_angle ; < 0 ? -> 359
    cmp #0168 ; >= 360 ? -> 0
    bcs @reset_angle
    bra @exit_handle_input
reset_angle:
    stz @player_angle
    bra @exit_handle_input
set_angle:
    lda #0167 ; angle = 359
    sta @player_angle

exit_handle_input:
    lda @player_angle
    asl ; entries are two bytes
    tax
    lda !cosines_lut,x
    sta @player_dx
    lda !sines_lut,x
    sta @player_dy

    plp
    rts


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

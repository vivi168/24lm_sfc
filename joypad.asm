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
    dec @player_angle
    bra @keep_angle_in_bound

turn_right:
    inc @player_angle

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

HandleInput2:
    php

    .call M16

    stz @dx

    lda @joy1_held
    bit #BUTTON_LEFT
    bne @go_left

    bit #BUTTON_RIGHT
    bne @go_right

    bit #BUTTON_UP
    bne @go_up

    bit #BUTTON_DOWN
    bne @go_down

    jmp @exit_handle_input2


go_left:
    ;
    lda #fc00
    jmp @add_velocity_x
go_right:
    ;
    lda #0400
    jmp @add_velocity_x
go_up:
    lda #fc00
    jmp @add_velocity_y
go_down:
    lda #0400
    jmp @add_velocity_y


add_velocity_x:
    sta @cx

    bpl @add_x_coord2
    dec @dx ; wrap dx at 0xffff (negative)
add_x_coord2:
    lda @player_fx_lo
    sta @ax
    lda @player_fx_hi
    sta @bx

    jsr @Add32
    lda @ax
    sta @player_fx_lo
    lda @bx
    sta @player_fx_hi
    bra @exit_handle_input2

add_velocity_y:
    sta @cx

    bpl @add_y_coord2
    stz @dx
    dec @dx ; wrap dx at 0xffff (negative)
add_y_coord2:
    lda @player_fy_lo
    sta @ax
    lda @player_fy_hi
    sta @bx

    jsr @Add32
    lda @ax
    sta @player_fy_lo
    lda @bx
    sta @player_fy_hi

exit_handle_input2:

    plp
    rts

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

ronrure:
    lda @joy1_held
    bit #BUTTON_LEFT
    bne @turn_left

    bit #BUTTON_RIGHT
    bne @turn_right


    jmp @exit_handle_input

accelerate:
    lda @player_x
    clc
    adc @player_dx
    sta @player_x

    lda @player_y
    clc
    adc @player_dy
    sta @player_y

    bra @ronrure

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
    .call M8
    ldx @player_angle
    lda !cosines_lut,x
    bpl @isse1
    .call M16
    ora #ff00
    sta @player_dx
    bra @sin_test
isse1:
    .call M16
    and #00ff
    sta @player_dx

sin_test:
    .call M8
    lda !sines_lut,x
    bpl @isse2
    .call M16
    ora #ff00
    sta @player_dy
    bra @sin_end
isse2:
    .call M16
    and #00ff
    sta @player_dy

sin_end:
    plp
    rts

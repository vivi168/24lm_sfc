ClearRegisters:
    stz 2101
    stz 2102
    stz 2103
    stz 2105
    stz 2106
    stz 2107
    stz 2108
    stz 2109
    stz 210a
    stz 210b
    stz 210c

    .call M16

    stz 210d
    stz 210d
    stz 210e
    stz 210e
    stz 210f
    stz 210f
    stz 2110
    stz 2110
    stz 2111
    stz 2111
    stz 2112
    stz 2112
    stz 2113
    stz 2113
    stz 2114
    stz 2114

    .call M8

    lda #80
    sta 2115
    stz 2116
    stz 2117
    stz 211a

    .call M16

    lda #0001
    sta 211b
    stz 211c
    stz 211d
    sta 211e
    stz 211f
    stz 2120

    .call M8

    stz 2121
    stz 2123
    stz 2124
    stz 2125
    stz 2126
    stz 2127
    stz 2128
    stz 2129
    stz 212a
    stz 212b
    lda #01
    sta 212c
    stz 212d
    stz 212e
    stz 212f
    lda #30
    sta 2130
    stz 2131
    lda #e0
    sta 2132
    stz 2133

    stz 4200
    lda #ff
    sta 4201
    stz 4202
    stz 4203
    stz 4204
    stz 4205
    stz 4206
    stz 4207
    stz 4208
    stz 4209
    stz 420a
    stz 420b
    stz 420c
    lda #01
    sta 420d

    ; ---- custom registers

    .call M16
    stz @joy1_raw
    stz @joy1_press
    stz @joy1_held

    stz @next_col_x
    stz @next_row_y

    stz @player_angle
    ldx @player_angle
    lda !cosines_lut,x
    sta @player_dx

    lda !sines_lut,x
    sta @player_dy
    .call M8

    stz @frame_counter
    stz @vblank_disable
    inc @vblank_disable

    rts


InitialSettings:
    php
    .call M16

    stz @need_update

    ; place player on start position (1104, 768)
    ; player X -> 1104
    lda #0450
    sta @player_x
    sta @ax
    stz @bx
    lda #000a ; shift by 10
    sta @cx
    jsr @Asl32
    lda @ax
    sta @player_fx_lo
    lda @bx
    sta @player_fx_hi

    ; player Y -> 768
    lda #0300
    sta @player_y
    sta @ax
    stz @bx
    lda #000a ; shift by 10
    sta @cx
    jsr @Asl32
    lda @ax
    sta @player_fy_lo
    lda @bx
    sta @player_fy_hi

    ; SCREEN_OFFSET_X
    lda #0188 ; 392, constant
    sta @screen_x
    ; SCREEN_OFFSET_Y
    lda #0128 ; 296, constant
    sta @screen_y

    ; camera X = player_x - SCREEN_W / 2
    lda @player_x
    sec
    sbc #0080 ; SCREEN_W / 2
    sta @camera_x
    sbc @screen_x
    ; buffer.x = camera.x - SCREEN_OFFSET_X (screen.x = SCREEN_OFFSET_X at reset)
    sta @ax

    ; camera Y = player_y - SCREEN_H / 2
    lda @player_y
    sec
    sbc #0070 ; SCREEN_H / 2
    sta @camera_y
    sbc @screen_y
    ; buffer.y = camera.y - SCREEN_OFFSET_Y (screen.y = SCREEN_OFFSET_Y at reset)
    sta @bx

    plp
    rts

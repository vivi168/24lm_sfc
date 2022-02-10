;**************************************
; WEC 24H LE MANS
;**************************************
.65816

.include define.inc
.include registers.inc
.include macros.inc
.include var.asm
.include assets.asm

.org 808000
.base 0000

.include vectors.asm
.include clear.asm
.include dma.asm
.include math.asm
.include joypad.asm
.include level.asm
.include object.asm
.include hud.asm
.include music.asm
.include decompress.asm

MainLoop:
    jsr @WaitNextVBlank

    jsr @HandleInput

    jsr @UpdatePlayer
    jsr @UpdatePlayerOAM

    ; jsr @UpdateM7Params

    jmp @MainLoop

UpdatePlayer:
    .call RESERVE_STACK_FRAME 0c
    ; 01/02 -> prev player_x
    ; 03/04 -> prev player_y
    ; 05/06 -> buffer.x / -> @ax ?
    ; 07/08 -> buffer.y / -> @bx ?
    ; 09/0a -> src_x_offset
    ; 0b/0c -> src_y_offset
    .call M16

    ; player_prev_x = player.x;
    lda @player_x
    sta 01
    ; player_prev_y = player.y;
    lda @player_y
    sta 03

    ; X coord
    ; player.x = player.fx >> 10;
    lda @player_fx_lo
    sta @ax
    lda @player_fx_hi
    sta @bx
    lda #000a ; fixed point scale is 1024
    sta @cx
    jsr @Lsr32
    lda @ax
    sta @player_x

    ; Y coord
    ; player.y = player.fy >> 10;
    lda @player_fy_lo
    sta @ax
    lda @player_fy_hi
    sta @bx
    lda #000a ; fixed point scale is 1024
    sta @cx
    jsr @Lsr32
    lda @ax
    sta @player_y


    jsr @CenterCam

    ; buffer.x = camera.x - SCREEN_OFFSET_X;
    lda @camera_x
    sec
    sbc #0188
    sta 05

    ; buffer.y = camera.y - SCREEN_OFFSET_Y;
    lda @camera_y
    sec
    sbc #0128
    sta 07

; ---- Check horizontal offset
    lda @player_x
    bit #000f
    bne @skip_column_update

    cmp 01
    beq @skip_column_update

    bcc @going_left_cc
going_right_cc:
    ; next_col_x = ((screen.x + SCREEN_W + 360) % 1024) // 16;
    lda @screen_x
    clc
    adc #0268 ; SCREEN_W + 360
    and #03ff
    .call LSR3
    sta @next_col_x
    inc
    inc
    and #007f
    sta @next_dst_x

    ; src_x_offset = 1008
    lda #03f0
    sta 09

    bra @end_column_update
going_left_cc:
    ; next_col_x = ((screen.x - 392) % 1024) // 16;
    lda @screen_x
    sec
    sbc #0188
    and #03ff
    .call LSR3
    sta @next_col_x
    sta @next_dst_x

    ; src_x_offset = 0;
    stz 09


end_column_update:
    ; CopyNextCol(buffer_x + src_x_offset,
    ;             buffer_y,
    ;             next_row_y);
    ; buffer_x + src_x_offset,
    lda 05
    and #0fff
    .call LSR4
    sta @next_src_x
    lda 05
    clc
    adc 09
    and #0fff
    .call LSR4
    sta @ax
    ; buffer.y
    lda @next_src_y
    sta @bx
    ; next_row_y
    lda @next_dst_y
    sta @cx
    brk 00
    jsr @CopyNextCol
    lda @need_update
    ora #0001
    sta @need_update

skip_column_update:
; ---- Check vertical offset
    lda @player_y
    bit #000f
    bne @skip_row_update

    cmp 03
    beq @skip_row_update

    bcc @going_up_cc
going_down_cc:
    ; next_row_y = screen.y + (SCREEN_H + 488);
    lda @screen_y
    clc
    adc #02c8
    and #03ff
    .call LSR3
    sta @next_row_y
    inc
    inc
    and #007f
    sta @next_dst_y

    ; src_y_offset = 1008;
    lda #03f0
    sta 0b

    bra @end_row_update
going_up_cc:
    ; next_row_y = screen.y - 296;
    lda @screen_y
    sec
    sbc #128
    and #03ff
    .call LSR3
    sta @next_row_y
    sta @next_dst_y

    ; src_y_offset = 0;
    stz 0b

end_row_update:
    ; CopyNextRow(buffer_x,
    ;             buffer_y + src_y_offset,
    ;             next_col_x);
    ; buffer_x
    lda @next_src_x
    sta @ax
    ; buffer_y + src_y_offset
    lda 07
    and #0fff
    .call LSR4
    sta @next_src_y
    lda 07
    clc
    adc 0b
    and #0fff
    .call LSR4
    sta @bx
    ; next_col_x
    lda @next_dst_x
    sta @cx
    brk 01
    jsr @CopyNextRow
    lda @need_update
    ora #0100
    sta @need_update

skip_row_update:

    .call M8
    .call RESTORE_STACK_FRAME 0c
    rts

CenterCam:
    php

    .call M8
    .call RESERVE_STACK_FRAME 04
    ; 01/02 -> prev camera_x
    ; 03/04 -> prev camera_y
    .call M16

    lda @camera_x
    sta 01
    lda @camera_y
    sta 03

; ---- X coordinate

    ; camera.x = player.x - SCREEN_W/2
    lda @player_x
    sec
    sbc #0080
    sta @camera_x

    ; screen.x += (camera.x - camera.prev_x) % 1024
    sec
    sbc 01
    clc
    adc @screen_x
    and #03ff
    sta @screen_x

; ---- Y coordinate

    ; camera.y = player.y - SCREEN_H/2
    lda @player_y
    sec
    sbc #0070
    sta @camera_y

    ; screen.y += (camera.y - camera.prev_y) % 1024
    sec
    sbc 03
    clc
    adc @screen_y
    and #03ff
    sta @screen_y

    .call M8
    .call RESTORE_STACK_FRAME 04

    plp
    rts

UpdateM7Params:
    php

    .call M16

    brk 00
    ; matrix_angle = - player_angle - 90
    lda @player_angle

    eor #ffff
    inc
    clc
    adc #0168

    sec
    sbc #005a
    ; if angle < 0: angle += 360
    bpl @skip_wrap_angle
    clc
    adc #0168

skip_wrap_angle:
    asl
    tax

    ; A =  cos(matrix_angle) * SCALE
    lda !cosines_lut,x
    beq @store_m7_a
    bpl @skip_cos_neg_lsr

    eor #ffff
    inc
    lsr
    lsr
    eor #ffff
    inc
    bra @store_m7_a

skip_cos_neg_lsr:
    lsr
    lsr
store_m7_a:
    sta @m7_a

    ; D =  cos(matrix_angle) * SCALE
    sta @m7_d

    ; B =  sin(matrix_angle) * SCALE
    lda !sines_lut,x
    beq @store_m7_b
    bpl @skip_sin_neg_lsr

    eor #ffff
    inc
    lsr
    lsr
    eor #ffff
    inc
    bra @store_m7_b

skip_sin_neg_lsr:
    lsr
    lsr
store_m7_b:
    sta @m7_b

    ; C = -sin(matrix_angle) * SCALE
    eor #ffff
    inc
    sta @m7_c

    ; X = screen_x - SCREEN_W/2
    lda @screen_x
    clc
    adc #0080
    sta @m7_x

    ; Y = screen_y - SCREEN_H/2
    lda @screen_y
    clc
    adc #0070
    sta @m7_y


    plp
    rts


.include info.asm

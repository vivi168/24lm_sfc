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
    jsr @CenterCam
    jsr @UpdatePlayerOAM

    jmp @MainLoop

UpdatePlayer:
    .call RESERVE_STACK_FRAME 04
    ; 01/02 -> prev player_x
    ; 03/04 -> prev player_y

    .call M16

    lda @player_x
    sta 01
    lda @player_y
    sta 03

    ; X coord
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
    lda @player_fy_lo
    sta @ax
    lda @player_fy_hi
    sta @bx
    lda #000a ; fixed point scale is 1024
    sta @cx
    jsr @Lsr32
    lda @ax
    sta @player_y

; ---- Check horizontal offset
    lda @player_x
    bit #000f
    bne @skip_column_update

    cmp 01
    beq @skip_column_update
    ; set src_x,y dst_y here
    bcc @going_left_cc
; going right
    ; brk ff
    ; next_col_x = screen.x + 0x268 (SCREEN_W + 360)

    ; copy next col
    ; src_x = buffer.x = camera.x - SCREEN_OFFSET_X + 1008
    ; src_y = buffer.y = camera.y - SCREEN_OFFSET_Y
    ; dst_y = screen.y - SCREEN_OFFSET_Y


    bra @end_column_update
going_left_cc:
; going left
    ; brk 00
    ; next_col_x = screen.x - 0x188 (392)

    ; copy next col
    ; src_x = buffer.x = camera.x - SCREEN_OFFSET_X - 16
    ; src_y = buffer.y = camera.y - SCREEN_OFFSET_Y
    ; dst_y = screen.y - SCREEN_OFFSET_Y


; ---- Check vertical offset
end_column_update:
skip_column_update:
    lda @screen_y
    bit #000f
    bne @skip_row_update

skip_row_update:


    .call M8
    .call RESTORE_STACK_FRAME 04
    rts

CenterCam:
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

    rts

.include info.asm

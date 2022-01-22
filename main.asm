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
    bcc @going_left_cc
; going right
    brk ff
    ; TODO copy column ahead

    bra @end_column_update
going_left_cc:
; going left
    brk 00
    ; TODO copy column behind


; ---- Check vertical offset
end_column_update:
skip_column_update:
    lda @vertical_offset
    bit #000f
    bne @skip_row_update

skip_row_update:


    .call M8
    .call RESTORE_STACK_FRAME 04
    rts

CenterCam:
    .call M16

; ---- X coordinate

    ; camera.x = player.x - SCREEN_W/2
    lda @player_x
    sec
    sbc #0080
    sta @camera_x

    ; screen.x = camera.x % 1024;
    and #03ff
    sta @horizontal_offset

; ---- Y coordinate

    ; camera.y = player.y - SCREEN_H/2
    lda @player_y
    sec
    sbc #0070
    sta @camera_y

    ; screen.y = camera.y % 1024;
    and #03ff
    sta @vertical_offset

    .call M8

    rts

.include info.asm

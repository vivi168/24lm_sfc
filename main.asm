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
.include joypad.asm
.include level.asm
.include object.asm
.include hud.asm
.include music.asm
.include decompress.asm

MainLoop:
    jsr @WaitNextVBlank

    jsr @HandleInput
    ; inc @horizontal_offset
    ; inc @vertical_offset

    jsr @UpdatePlayer
    jsr @CenterCam
    jsr @UpdatePlayerOAM

    jmp @MainLoop

UpdatePlayer:
    .call M16

    lda @player_x
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta @player_sx

    lda @player_y
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta @player_sy

    .call M8
    rts

CenterCam:
    rts

.include info.asm

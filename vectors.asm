ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    cld
    jmp !FastReset
FastReset:
    .call M8
    .call X16

    ldx #STACK_TOP
    txs                 ; set stack pointer to 1fff

    lda #01
    sta MEMSEL

; ---- Forced Blank
    lda #80
    sta INIDISP
    jsr @ClearRegisters

; ---- BG settings
    lda #07             ; bg 3 high prio, mode 1
    sta BGMODE

    lda #11             ; enable BG1 + sprites (0b10001)
    sta TM

;  ---- OBJ settings
    lda #63             ; sprite 16x16 small, 32x32 big
    sta OBJSEL          ; oam start @VRAM[c000]

;  ---- Some initialization

    jsr @InitLzssDecode
    jsr @InitOamBuffer

;  ---- Init tile map
    jsr @InitialSettings
    .call M16
    lda @ax
    .call LSR4
    sta @ax

    lda @bx
    .call LSR4
    sta @bx

    stz @cx
    stz @dx
    .call M8
    jsr @InitTileMap

    lda @screen_x
    sta BG1HOFS
    lda @screen_x+1
    sta BG1HOFS
    lda @screen_y
    sta BG1VOFS
    lda @screen_y+1
    sta BG1VOFS

    ; MODE 7 CENTER/MATRIX PARAMS
    lda @m7_x
    sta M7X
    lda @m7_x+1
    sta M7X
    lda @m7_y
    sta M7Y
    lda @m7_y+1
    sta M7Y

;  ---- DMA Transfers

    ; transfer tilemap (write low byte of VRAM, then inc)
    lda #00
    sta VMAINC
    .call VRAM_DMA_TRANSFER_TEST 0000, bg1_buffer, 4000, 18

    ; transfer tiles (write high byte of VRAM, then inc)
    lda #80
    sta VMAINC
    .call VRAM_DMA_TRANSFER_TEST 0000, bg1_tiles, 4000, 19
    .call VRAM_DMA_TRANSFER 6000, sprites_tiles, SPRITES_TILES_SIZE   ; VRAM[0xc000] (word step)

    .call CGRAM_DMA_TRANSFER 00, bg1_pal, BG1_PALETTE_SIZE
    .call CGRAM_DMA_TRANSFER 80, sprites_pal, SPRITES_PALETTE_SIZE  ; CGRAM[0x100] (word step)

    jsr @TransferOamBuffer

    ; TEST
    ldy #0000 ; src X
    sty @ax
    ldy #0000 ; src Y
    sty @bx
    ldy #0040 ; dst X
    sty @cx
    jsr @CopyNextRow

    ldy #0032 ; src X
    sty @ax
    ldy #0000 ; src Y
    sty @bx
    ldy #0040 ; dst Y
    sty @cx
    jsr @CopyNextCol

; ---- Release Forced Blank
    lda #0f             ; release forced blanking, set screen to full brightness
    sta INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta NMITIMEN
    cli

    jmp @MainLoop

BreakVector:
    rti

WaitNextVBlank:
    stz @vblank_disable
wait_next_vblank:
    lda @vblank_disable
    beq @wait_next_vblank
    stz @vblank_disable
    rts

NmiVector:
    jmp !FastNmi
FastNmi:
    php
    .call MX16
    pha
    phx
    phy

    .call M8
    .call X16

    lda RDNMI

    stz MDMAEN
    stz HDMAEN

    inc @frame_counter

    lda @screen_x
    sta BG1HOFS
    lda @screen_x+1
    sta BG1HOFS
    lda @screen_y
    sta BG1VOFS
    lda @screen_y+1
    sta BG1VOFS

    ; MODE 7 CENTER/MATRIX PARAMS
    lda @m7_x
    sta M7X
    lda @m7_x+1
    sta M7X
    lda @m7_y
    sta M7Y
    lda @m7_y+1
    sta M7Y

    ; TEST
    lda @need_update_row
    bit #01
    beq @check_transfer_next_col

    lda #00
    sta VMAINC
    ; src 0000 should be a register (next_row_y)

    .call M16
    ; next_row_y *= 128
    lda @next_row_y
    pha
    .call ASL3
    .call ASL4
    sta @next_row_y
    .call M8

    .call VRAM_DMA_TRANSFER_TEST2 next_row_y, next_row, 0100, 18
    stz @need_update_row

    plx
    stx @next_row_y

check_transfer_next_col:
    lda @need_update_col
    bit #01
    beq @skip_transfer_next_col

    lda #02
    sta VMAINC
    ; src 0000/0001 should be a register (next_col_x, next_col_x+1)
    .call VRAM_DMA_TRANSFER_TEST2 next_col_x, next_col1, 0080, 18
    inc @next_col_x
    .call VRAM_DMA_TRANSFER_TEST2 next_col_x, next_col2, 0080, 18
    dec @next_col_x
    stz @need_update_col

skip_transfer_next_col:

    jsr @TransferOamBuffer

    jsr @HdmaTest

    jsr @ReadJoyPad1

    inc @vblank_disable

    .call MX16
    ply
    plx
    pla
    plp
    rti


HdmaTest:
    php

    ; m7_a via channel 3
    lda #^m7_a_hdma_table
    sta A1T3B
    ldx #@m7_a_hdma_table
    stx A1T3L

    lda #1B ; via port 21*1B* (M7A)
    sta BBAD3

    lda #02 ; mode 2, transfer 2 bytes
    sta DMAP3

    ; m7_b via channel 4
    lda #^m7_b_hdma_table
    sta A1T4B
    ldx #@m7_b_hdma_table
    stx A1T4L

    lda #1C ; via port 21*1C* (M7B)
    sta BBAD4

    lda #02
    sta DMAP4

    ; m7_b via channel 5
    lda #^m7_c_hdma_table
    sta A1T5B
    ldx #@m7_c_hdma_table
    stx A1T5L

    lda #1D ; via port 21*1D* (M7C)
    sta BBAD5

    lda #02
    sta DMAP5

    ; m7_b via channel 6
    lda #^m7_d_hdma_table
    sta A1T6B
    ldx #@m7_d_hdma_table
    stx A1T6L

    lda #1E ; via port 21*1E* (M7D)
    sta BBAD6

    lda #02
    sta DMAP6

    ; start transfers via channels 3,4,5,6 (0111 1000)
    lda #78
    sta HDMAEN

    plp
    rts

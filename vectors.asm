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

; Writing a <new> byte to one of the write-twice M7'registers does:
; M7_reg = new * 100h + M7_old
; M7_old = new

    ; lda #00
    ; sta M7A
    ; lda #02
    ; sta M7A

    ; lda #80
    ; sta M7C
    ; lda #00
    ; sta M7C

    ; lda #00
    ; sta M7D
    ; lda #01
    ; sta M7D

    jsr @InitLzssDecode
    jsr @InitOamBuffer

;  ---- Init tile map

    ; ldy #0024 ; src X
    ; sty @ax
    ; ldy #0016 ; src Y
    ; sty @bx
    ; ldy #0000 ; dst X
    ; sty @cx
    ; ldy #0000 ; dst Y
    ; sty @dx
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
    ; jsr @CopyRow

    brk 00
    lda @screen_x
    sta BG1HOFS
    lda @screen_x+1
    sta BG1HOFS
    lda @screen_y
    sta BG1VOFS
    lda @screen_y+1
    sta BG1VOFS

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

    inc @frame_counter

    lda @screen_x
    sta BG1HOFS
    lda @screen_x+1
    sta BG1HOFS
    lda @screen_y
    sta BG1VOFS
    lda @screen_y+1
    sta BG1VOFS

    jsr @TransferOamBuffer
    jsr @ReadJoyPad1

    inc @vblank_disable

    .call MX16
    ply
    plx
    pla
    plp
    rti

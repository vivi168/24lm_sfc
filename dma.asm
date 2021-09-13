TransferOamBuffer:
    ldx #0000       ; dest address
    stx OAMADDL

    lda #04         ; OAMDATA 21*04*
    sta BBAD0

    ldx #@oam_buffer
    stx A1T0L
    lda #^oam_buffer
    sta A1T0B

    ; transfer 220 bytes
    ldx #0220
    stx DAS0L

    ; DMA params: A to B
    lda #00
    sta DMAP0
    ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
    lda #01
    sta MDMAEN
    rts

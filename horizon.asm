InitHorizon:

    lda #55
    sta BG12NBA ; BG12 tiles @ VRAM[A000] -> 0b0101_0101

    lda #40
    sta BG1SC ; BG1 MAP @ VRAM[8000] -> 0b10000_00

    lda #45
    sta BG2SC ; BG2 MAP @ VRAM[8800], size 64x32 -> 0b10001_01


    jsr @InitMode2BG1

    rts

InitMode2BG1:
    rts
InitMode2BG2:
    rts

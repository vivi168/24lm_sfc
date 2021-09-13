InitLevel:
    ldx #0000
    ldy #0000
init_level_loop:

    lda #00
    sta !bg1_buffer,x
    inx

    phx
    tyx
    iny
    lda !bg1_tiles,x
    plx
    sta !bg1_buffer,x

    inx
    cpx #8000
    bne @init_level_loop

	rts

CopyInitialColumns:
    rts

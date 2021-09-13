;**************************************
;
; clear oam buffer with off screen sprites
;
;**************************************
InitOamBuffer:
    php
    .call M8
    .call X16

    ldx #0000
set_x_lsb:
    lda #01 ; set sprite to x=-255
    sta !oam_buffer,x

    lda #f0 ; set sprite to y=240
    sta !oam_buffer+1,x

    inx
    inx
    inx
    inx
    cpx #OAML_SIZE
    bne @set_x_lsb

    lda #55         ; 01 01 01 01
set_x_msb:
    sta !oam_buffer,x
    inx
    sta !oam_buffer,x
    inx
    cpx #OAM_SIZE
    bne @set_x_msb

    plp
    rts

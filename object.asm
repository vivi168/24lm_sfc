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


UpdatePlayerOAM:
    .call M16
    ; player.screen_x = player.x - camera.x;
    lda @player_x
    sec
    ; Offset the player to the left (half a sprite wide)
    sbc @camera_x
    sbc #0008
    sta @player_sx

    ; player.screen_y = player.y - camera.y;
    lda @player_y
    sec
    sbc @camera_y
    ; Offset the player to the bottom (match with center of transformation)
    clc
    adc #0040
    sta @player_sy
    .call M8

    lda @player_sx
    sta !oam_buffer     ; x
    lda @player_sy
    sta !oam_buffer+1   ; y

    lda #00
    sta !oam_buffer+2   ; tile number

    lda #30             ; 00110000
    sta !oam_buffer+3   ; vhppcccn

    lda #54
    sta !oam_buffer_hi

    rts

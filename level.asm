; copy each tile data to BG buffer
InitTiles:
    ldx #0000
    ldy #0000
init_level_loop:

    ; lda #00
    ; sta !bg1_buffer,x
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

; copy initial 128x128 tilemap to BG Buffer
; (64x64 portion from circuit)
; input coordinates X, Y in X
InitTileMap:
    .call RESERVE_STACK_FRAME 09
    ; 01 02 03 : bg1_buffer address
    ; 04/05 -> start X
    ; 06/07 -> start Y
    ; 08/09 -> loop counter

    .call M16
    txa
    and #00ff
    sta 06
    txa
    and #ff00
    xba
    sta 04
    stz 08
    .call M8

    ldx #@bg1_buffer
    stx 01
    lda #^bg1_buffer
    sta 03

    lda 06	; Y
    sta @multiplicand
    lda #ff	; map_w - 1
    sta @multiplier

    .call MULTIPLY
    .call M16
    lda RDMPYL
    clc
    adc 06	; Y (add one more time, multiplied by 0xff, we want by 0x100)
    adc 04	; X
    tax     ; initial index. loop from there

    ldy #0000
init_tilemap_loop:
    ; metatile idx
    lda !circuit,x

    ; ---- get metatile info
    phx
    phy
    and #00ff
    asl
    asl
    tax
    .call M8
    ; Y
    lda !metatiles,x
    sta [01],y

    ; Y + 2
    iny
    iny
    lda !metatiles+1,x
    sta [01],y

    ; Y + 256
    .call M16
    tya
    clc
    adc #00fe
    tay
    .call M8
    lda !metatiles+2,x
    sta [01],y

    ; y + 258
    iny
    iny
    lda !metatiles+3,x
    sta [01],y

    .call M16
    ply
    plx

    tya
    clc
    adc #0004
    bit #00ff
    bne @skip_y_wrap
    adc #0100
skip_y_wrap:
    tay
    ; ----

    inx
    inc 08
    lda 08
    bit #003f
    bne @skip_wrap_row
    txa
    clc
    adc #00c0
    tax
    lda 08
skip_wrap_row:
    cmp #1000
    bne @init_tilemap_loop

    .call M8
    .call RESTORE_STACK_FRAME 09
    rts

; update one column of tilemap
CopyColumn:
    rts

; update one row of tilemap
CopyRow:
    rts

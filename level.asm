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
    adc 06	; Y (add one more time, multiplied by 0xff, we want Y * 0x100)
    adc 04	; add X (I = X + W * Y)
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

    ; Y + 1
    iny
    lda !metatiles+1,x
    sta [01],y

    ; Y + 128
    .call M16
    tya
    clc
    adc #007f
    tay
    .call M8
    lda !metatiles+2,x
    sta [01],y

    ; y + 129
    iny
    lda !metatiles+3,x
    sta [01],y

    .call M16
    ply
    plx

    tya
    inc
    inc
    bit #007f
    bne @skip_y_wrap
    adc #0080
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
; ax -> src_x
; bx -> src_y
; cx -> dst_x
; dx -> dst_y
CopyColumn:
    .call RESERVE_STACK_FRAME 08
    ; 01/02    -> src_i
    ; 03/04    -> dst_i
    ; 05       -> mi
    ; 06/07/08 -> bg_buffer addr

    ldx #@bg1_buffer
    stx 06
    lda #^bg1_buffer
    sta 08

    .call M16
    lda @bx
    .call ASL3
    .call ASL5 ; bx *= 256 (MAP_W)
    clc
    adc @ax
    sta 01

    lda @dx
    .call ASL3
    .call ASL4 ; dx *= 128 (BUF_W)
    clc
    adc @cx
    sta 03
    .call M8

    ; loop counter
    stz @al
copy_column_loop:

    ; uint8_t mi = circuit[src_i];
    ldx 01
    lda !circuit,x
    .call M16
    and #00ff
    ; mi *= 4
    asl
    asl
    tax
    .call M8

    ; bg1_buffer[dst_i]         = metatiles[mi * 4]
    lda !metatiles,x
    ldy 03
    sta [06],y

    ; bg1_buffer[dst_i+1]       = metatiles[mi * 4 + 1]
    iny
    inx
    lda !metatiles,x
    sta [06],y

    ; bg1_buffer[dst_i+BUF_W]   = metatiles[mi * 4 + 2]
    .call M16
    lda 03
    clc
    adc #0080 ; += BUF_W
    tay
    .call M8

    inx
    lda !metatiles,x
    sta [06],y

    ; bg1_buffer[dst_i+BUF_W+1] = metatiles[mi * 4 + 3]
    iny
    inx
    lda !metatiles,x
    sta [06],y

    ; // next src idx
    ; src_i += MAP_W
    .call M16
    lda 01
    clc
    adc #0100 ; MAP_W
    sta 01

    ; // next dst idx
    ; dst_i = (dst_i + BUF_W + BUF_W) % 16384;
    lda 03
    clc
    adc #0100 ; BUF_W + BUF_W
    and #3fff
    sta 03

    .call M8

    inc @al
    lda @al
    cmp #40 ; 64 x2 tiles columns
    bne @copy_column_loop

    .call RESTORE_STACK_FRAME 08
    rts

; update one row of tilemap
CopyRow:
    rts

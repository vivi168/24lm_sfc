; copy initial 128x128 tilemap to BG Buffer
; (64x64 portion from circuit, circuit is composed of 2x2 metatiles)
; ax -> src_x
; bx -> src_y
; cx -> dst_x
; dx -> dst_y
InitTileMap:
    ldy #0000 ; loop counter
init_tilemap_loop:
    phy
    jsr @CopyColumn
    ply

    .call M16
    inc @ax ; src_x ++
    lda @cx ; dst_x += 2
    inc
    inc
    and #007f ; wrap dst_x at 0
    sta @cx
    .call M8

    iny
    cpy #0040 ; 64 x2 tiles columns (BUF_W / 2)
    bne @init_tilemap_loop

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
    ; 05       -> loop counter
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
    stz 05
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

    inc 05
    lda 05
    cmp #40 ; 64 x2 tiles columns (BUF_H / 2)
    bne @copy_column_loop

    .call RESTORE_STACK_FRAME 08
    rts

; update one row of tilemap
; ax -> src_x
; bx -> src_y
; cx -> dst_x
; dx -> dst_y
CopyRow:
    .call RESERVE_STACK_FRAME 08
    ; 01/02    -> src_i
    ; 03/04    -> dst_i
    ; 05       -> loop counter
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
    stz 05
copy_row_loop:

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
    ; src_i ++
    .call M16
    inc 01
    ; if src_i > 0 and src_i % MAP_W == 0: src_i -= MAP_W
    lda 01
    beq @skip_row_wrap1
    bit #00ff
    bne @skip_row_wrap1
    sec
    sbc #0100
    sta 01

skip_row_wrap1:

    ; // next dst idx
    ; dst_i += 2
    inc 03
    inc 03
    ; if dst_i > 0 and dst_i % BUF_W == 0: dst_i -= BUF_W
    lda 03
    beq @skip_row_wrap2
    bit #007f
    bne @skip_row_wrap2
    sec
    sbc #0080
    sta 03

skip_row_wrap2:
    .call M8

    inc 05
    lda 05
    cmp #40 ; 64 x2 tiles rows
    bne @copy_row_loop

    .call RESTORE_STACK_FRAME 08
    rts

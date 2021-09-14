InitLzssDecode:
    ldx #NF
    stx @r

    stz @buf
    stz @mask
    .call M16
    stz @infile_idx
    stz @outfile_idx
    lda #COMPRESSED_CIRCUIT_SIZE
    sta @infile_siz
    .call M8

    ldx #@circuit_zip
    stx @infile
    lda #^circuit_zip
    sta @infile+2

    ldx #@decompression_buffer
    stx @decompression_buffer_addr
    lda #^decompression_buffer
    sta @decompression_buffer_addr+2

    ldx #@circuit
    stx @outfile_addr
    lda #^circuit
    sta @outfile_addr+2

    jsr @LzssDecode

    rts

; get n bits from infile
; n in Y
; result in X
GetBit:
    ldx #0000

getbit_loop:
    lda @mask
    bne @skip_fgetc

    phy

    ldy @infile_idx
    cpy @infile_siz
    bcc @continue_getbit_loop
    ldx #ffff           ; we return 0xffff (EOF) if infile_idx >= infile_siz
    ply
    bra @end_getbit

continue_getbit_loop:
    lda [<infile],y

    sta @buf
    lda #80
    sta @mask

    iny
    sty @infile_idx
    ply

skip_fgetc:
    rep #20
    txa
    asl
    tax
    sep #20

    lda @mask
    and @buf
    beq @skip_inx

    inx

skip_inx:
    lsr @mask

    dey
    bne @getbit_loop

end_getbit:
    rts

LzssDecode:
    lda #20
    ldy @r
    iny
clear_buffer_loop:
    dey
    sta [<decompression_buffer_addr],y
    bne @clear_buffer_loop

decode_loop:
    ldy #0001
    jsr @GetBit         ; c = getbit(1)

    cpx #ffff
    beq @decode_done    ; if (c == EOF)

    cpx #0001
    beq @bit_is_one     ; if (c == 1)

    ; ---- c == 0
    ldy #EI
    jsr @GetBit
    cpx #ffff
    beq @decode_done
    stx @i

    ldy #EJ
    jsr @GetBit
    cpx #ffff
    beq @decode_done
    stx @j

    jsr @BufferLoop

    bra @decode_loop

bit_is_one:
    ; ---- c == 1
    ldy #0008
    jsr @GetBit
    cpx #ffff
    beq @decode_done

    txa
    ldy @outfile_idx
    sta [<outfile_addr],y

    ldy @r
    sta [<decompression_buffer_addr],y

    rep #20
    ; r = (r + 1) & (N - 1)
    inc @r
    lda #N
    dec
    and @r
    sta @r

    inc @outfile_idx
    sep #20

    bra @decode_loop

decode_done:
    rts


BufferLoop:
    inx
    inx
    stx @k
    ldy #0000
buffer_loop:
    phy

    rep #20
    tya
    clc
    adc @i
    pha
    lda #N
    dec
    and 01,s
    tay
    pla
    sep #20

    lda [<decompression_buffer_addr],y
    ldy @outfile_idx
    sta [<outfile_addr],y

    ldy @r
    sta [<decompression_buffer_addr],y

    rep #20
    ; r = (r + 1) & (N - 1)
    inc @r
    lda #N
    dec
    and @r
    sta @r

    inc @outfile_idx
    sep #20

    ply
    iny
    cpy @k

    bne @buffer_loop

    rts

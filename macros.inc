.macro M8
    sep #20
.endm

.macro X8
    sep #10
.endm

.macro M16
    rep #20
.endm

.macro X16
    rep #10
.endm

.macro MX8
    sep #30
.endm

.macro MX16
    rep #30
.endm

; multiply by 8
.macro ASL3
    asl
    asl
    asl
.endm

; multiply by 16
.macro ASL4
    asl
    asl
    asl
    asl
.endm

; multiply by 32
.macro ASL5
    asl
    asl
    asl
    asl
    asl
.endm

; divide by 8
.macro LSR3
    lsr
    lsr
    lsr
.endm

; divide by 16
.macro LSR4
    lsr
    lsr
    lsr
    lsr
.endm

.macro CLEAR_VRAM_DMA dest_addr, nb_bytes
    ldx #%dest_addr
    stx VMADDL

    lda #18             ; VMDATAL 21*18*
    sta BBAD0

    ldx #@null_byte
    stx A1T0L
    lda #^null_byte
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    ; 765 43 210
    ; 000 01 001
    lda #09
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro VRAM_DMA_TRANSFER dest_addr, src_addr, nb_bytes
    ldx #%dest_addr
    stx VMADDL

    lda #18             ; VMDATAL 21*18*
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    lda #01
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro VRAM_DMA_TRANSFER_TEST dest_addr, src_addr, nb_bytes, vmdata
    ldx #%dest_addr
    stx VMADDL

    lda #%vmdata
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro VRAM_DMA_TRANSFER_TEST2 dest_addr, src_addr, nb_bytes, vmdata
    ldx @%dest_addr
    stx VMADDL

    lda #%vmdata
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro CGRAM_DMA_TRANSFER dest_addr, src_addr, nb_bytes
    lda #%dest_addr
    sta CGADD

    lda #22             ; CGDATA 21*22*
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    rep #20
    lda #%nb_bytes
    sta DAS0L
    sep #20

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro WRAM_DMA_TRANSFER upper, dest_addr, src_addr, nb_bytes
    ldx #%dest_addr
    stx WMADDL

    lda #%upper
    sta WMADDH

    lda #80             ; WMDATA 21*80*
    sta BBAD0

    ldx #@%src_addr
    stx A1T0L
    lda #^%src_addr
    sta A1T0B

    ldx #%nb_bytes
    stx DAS0L

    lda #00
    sta DMAP0

    lda #01
    sta MDMAEN
.endm

.macro RESET_OFFSET bghofs, bgvofs
    lda #00         ; first write = lower byte
    sta %bghofs     ; horizontal scroll ;
    sta %bghofs     ; second write = upper 2 bits
    lda #ff         ; vertical scroll. caution, offset by -1
    sta %bgvofs
    lda #00
    sta %bgvofs
.endm

.macro RESERVE_STACK_FRAME size
    phd

    tsc
    sec
    sbc #%size
    tcs
    tcd
.endm

.macro RESTORE_STACK_FRAME size
    tsc
    clc
    adc #%size
    tcs

    pld
.endm

.macro MULTIPLY
    lda @multiplicand
    sta WRMPYA  ; Multiplicand
    lda @multiplier
    sta WRMPYB  ; Multiplier
    nop         ; wait 8 cycles
    nop
    nop
    nop
    ; lda RDMPYL  ; Mul Product, lower byte
    ; lda RDMPYH  ; Mul Product, higher byte
.endm


.macro WAIT8
    nop         ; wait 8 cycles
    nop
    nop
    nop
.endm

.macro ASR8
    cmp #80
    ror
.endm

.macro ASR16
    cmp #8000
    ror
.endm

SpcUploadRoutine:
    php

    sep #20 ; a 8
    rep #10 ; i 16

    ldy #0000       ; retry counter

    ;  1. Wait for a 16-bit read on APUIO0-1 to return $BBAA.
retry_ack:
    ldx #bbaa
    cpx APUIO0
    beq @upload_spc ; wait until [APUIO0] == bbaa (means spc700 is ready)
    dey
    bne @retry_ack
    bra @exit_spc_upl

    ; 2. Write the target address to APUIO2-3.
upload_spc:
    ldx #0600       ; target spc700 ram address
    stx APUIO2        ; [APUIO2] = dest_addr (spc700 ram address)

    ; 3. Write non-zero to APUIO1.
    lda #01
    sta APUIO1        ; start command. can be any non zero value

    ; 4. Write $CC to APUIO0.
    ; 5. Wait until reading APUIO0 returns $CC.
write_cc:
    lda #cc
    sta APUIO0
    cmp APUIO0
    bne @write_cc ; wait until [APUIO0] == cc (kick command)

    ldx #SPC_ROM_SIZE ; data length (program size)
    ldy #0000         ; loop counter (index)

transfer_spc:
    lda @DummySpcData,y      ; src_addr[y]
    ; 6. Set your first byte to APUIO1.
    sta APUIO1        ; send data byte
    tya
    ; 7. Set your byte index ($00 for the first byte) to APUIO0.
wait_echo_idx:
    sta APUIO0        ; send index.lsb
    cmp APUIO0
    ; 8. Wait for APUIO0 to echo your byte index.
    bne @wait_echo_idx ; wait until [APUIO0] == index.lsb
    iny
    dex
    ; 9. Go back to step 6 with your next byte and ++index until you're done.
    bne @transfer_spc

    ; jump to uploaded code
    ; Put the target address in APUIO2-3
jmp_upload:
    ldx #0600           ; Execute from address 600
    stx APUIO2
    ; Put $00 in APUIO1
    lda #00
    sta APUIO1
    ; Put index+2 in APUIO0
    tya
    inc
    inc
    ; wait for the echo
    sta APUIO0
    cmp APUIO0
    bne @jmp_upload
    ; Shortly afterwards, your code will be executing.

exit_spc_upl:
    plp
    rts

DummySpcData:
    .incbin music/music.spc

;**************************************
; ROM registration data
;**************************************
.org ffb0
.base 7fb0

; zero bytes
    .db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
; game title "WEC 24H LE MANS      "
    .db 57,45,43,20,32,34,48,20,4c,45,20,4d,41,4e,53,20,20,20,20,20,20
; map mode
    .db 30
; cartridge type
    .db 00
; ROM size
    .db 09
; RAM size
    .db 01
; destination code
    .db 00
; fixed value
    .db 33
; mask ROM version
    .db 00
; checksum complement
    .db 00,00
; checksum
    .db 00,00

;**************************************
; Vectors
;**************************************
.org ffe0
.base 7fe0

; zero bytes
    .db 00,00,00,00
; 65816 mode
    .db 00,00           ; COP
    .db @BreakVector    ; BRK
    .db 00,00
    .db @NmiVector      ; NMI
    .db 00,00
    .db 00,00           ; IRQ

; zero bytes
    .db 00,00,00,00
; 6502 mode
    .db 00,00           ; COP
    .db 00,00
    .db 00,00
    .db 00,00           ; NMI
    .db @ResetVector    ; RESET
    .db 00,00           ; IRQ/BRK

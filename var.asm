.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2

frame_counter:            .rb 1
vblank_disable:           .rb 1

horizontal_offset:        .rb 2
vertical_offset:          .rb 2

multiplicand:             .rb 1
multiplier:               .rb 1

hex_to_dec_in:            .rb 2
hex_to_dec_out:           .rb 3

next_column_read:         .rb 2
next_column_write:        .rb 2
next_row_read:            .rb 2
next_row_write:           .rb 2

; ---- for decompression
r:                      .rb 2
i:                      .rb 2
j:                      .rb 2
k:                      .rb 2

buf:                    .rb 1
mask:                   .rb 1

infile:                 .rb 3   ; address of file to decompress
infile_idx:             .rb 2   ; index to current infile byte
infile_siz:             .rb 2

decompression_buffer_addr: .rb 3   ; address of decompression buffer
outfile_addr:              .rb 3   ; address of outfile
outfile_idx:               .rb 2   ; index to current outfile byte
; ----

.org 7e2000

bg1_buffer:               .rb 8000
oam_buffer:               .rb 200
oam_buffer_hi:            .rb 20
decompression_buffer:     .rb 1000 ; decompression buffer

.org 7f0000

circuit:                  .rb 10000

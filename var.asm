.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2

frame_counter:            .rb 1
vblank_disable:           .rb 1

horizontal_offset:        .rb 2
vertical_offset:          .rb 2

hex_to_dec_in:            .rb 2
hex_to_dec_out:           .rb 3

next_column_read:         .rb 2
next_column_write:        .rb 2
next_row_read:            .rb 2
next_row_write:           .rb 2

.org 7e2000

bg1_buffer:               .rb 8000
oam_buffer:               .rb 200
oam_buffer_hi:            .rb 20

.org 7f0000

circuit:                  .rb 10000

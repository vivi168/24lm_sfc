.org 7e0000

; scratch memory
ax:
al:                       .rb 1
ah:                       .rb 1

bx:
bl:                       .rb 1
bh:                       .rb 1

cx:
cl:                       .rb 1
ch:                       .rb 1

dx:
dl:                       .rb 1
dh:                       .rb 1

; var
joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2

frame_counter:            .rb 1
vblank_disable:           .rb 1

screen_x:        .rb 2
screen_y:          .rb 2

multiplicand:             .rb 1
multiplier:               .rb 1

hex_to_dec_in:            .rb 2
hex_to_dec_out:           .rb 3

; next col/row offset
next_col_x:               .rb 2
next_row_y:               .rb 2

; struct point player
player_fx:
player_fx_lo:             .rb 2 ; fixed point value (1 = 64), 32 bits
player_fx_hi:             .rb 2
player_fy:
player_fy_lo:             .rb 2 ; fixed point value (1 = 64), 32 bits
player_fy_hi:             .rb 2

player_angle:             .rb 2 ; angle * 4 (for calculation)
player_dx:                .rb 2 ; velocity
player_dy:                .rb 2 ; velocity

player_x:                 .rb 2 ; position on map (4096 * 4096)
player_y:                 .rb 2 ; position on map

player_sx:                .rb 2 ; position on screen (optional ?)
player_sy:                .rb 2 ; position on screen

; struct point camera
camera_x:                 .rb 2
camera_y:                 .rb 2

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

bg1_buffer:               .rb 4000
next_col:                 .rb 100
next_row:                 .rb 100
oam_buffer:               .rb 200
oam_buffer_hi:            .rb 20
decompression_buffer:     .rb 1000 ; decompression buffer

.org 7f0000

circuit:                  .rb 10000

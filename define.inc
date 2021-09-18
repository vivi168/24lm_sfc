.define STACK_TOP 1fff

; assets
.define BG1_TILES_SIZE       4000
.define BG1_PALETTE_SIZE     0100
.define BG1_BUFFER_SIZE      8000
.define SPRITES_TILES_SIZE   0800
.define SPRITES_PALETTE_SIZE 0020
.define COMPRESSED_CIRCUIT_SIZE 205f

; decompression
.define EI 000b
.define EJ 0004
.define N  0800
.define F  11
.define NF 07ef ; N - F

; joypad
.define BUTTON_A     0080
.define BUTTON_LEFT  0200
.define BUTTON_RIGHT 0100

; OAM
.define OAML_SIZE   0200
.define OAM_SIZE    0220

.define SPC_ROM_SIZE 0002

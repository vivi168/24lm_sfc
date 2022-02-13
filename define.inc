.define STACK_TOP 1fff

; assets
.define BG1_TILES_SIZE       4000
.define BG1_PALETTE_SIZE     00c0
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
.define BUTTON_DOWN  0400
.define BUTTON_UP    0800

; OAM
.define OAML_SIZE   0200
.define OAM_SIZE    0220

.define SPC_ROM_SIZE 0002



;;;;;


; Game level calculations
.define WORLD_W 1000
.define WORLD_H 1000

.define MAP_W 100
.define MAP_H 100
.define MAP_SIZE 10000
.define MAP_CELL_SIZE 10

; mode 7 tilemap buffer (1024x1024 px)
.define BUF_W 80
.define BUF_H 80
.define BUF_SIZE 4000
.define BUF_CELL_SIZE 8

.define METATILES_SIZE 400

.define SCREEN_W 100
.define SCREEN_H e0

.define SPRITE_W 10
.define SPRITE_H 10

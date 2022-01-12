# 24LM

## next steps

- implement following code

```c
// metatile map (4096x4096 px)
#define WORLD_W 4096
#define WORLD_H 4096

#define MAP_W 256
#define MAP_H 256
#define MAP_SIZE 65536
#define MAP_CELL_SIZE 16

// mode 7 tilemap buffer (1024x1024 px)
#define BUF_W 128
#define BUF_H 128
#define BUF_SIZE 16384
#define BUF_CELL_SIZE 8

#define METATILES_SIZE (256 * 4)

#define SCREEN_W 256
#define SCREEN_H 224

#define SPRITE_W 16
#define SPRITE_H 16

/*
    x1x2
0   [dst_i][dst_i + 1]
1   [dst_i+BUF_W][dst_i+BUF_W+1]

2   [dst_i+(BUF_W*2)][]
3   [][]
	...
    ...
126 [][]
127 [][]

*/

struct point {

	uint16_t x, y;
};


static struct point player;
static struct point camera;
static struct point screen; // camera position on tilemap

static uint8_t bg1_buffer[BUF_SIZE];
static uint8_t circuit[MAP_SIZE];
static uint8_t metatiles[METATILES_SIZE];

void copy_column(uint8_t src_x, uint8_t src_y, uint8_t dst_x, uint8_t dst_y)
{
	uint16_t src_i = MAP_W * src_y + src_x;
	uint16_t dst_i = BUF_W * dst_y + dst_x;

	for (uint8_t i = 0; i < BUF_H; i++) {
		uint8_t mi = circuit[src_i];

		// maybe need to wrap here as well ? not if always alined to 16
		bg1_buffer[dst_i]         = metatiles[mi * 4];
		bg1_buffer[dst_i+1]       = metatiles[mi * 4 + 1];
		bg1_buffer[dst_i+BUF_W]   = metatiles[mi * 4 + 2];
		bg1_buffer[dst_i+BUF_W+1] = metatiles[mi * 4 + 3];

		// next src idx
		src_i += MAP_W; // next column idx (idx is uint16_t so wrap by modulo MAP_SIZE is optional)

		// next dst idx
		dst_i = (dst_i + BUF_W + BUF_W) % 16384;
	}


}

/*
    0 1 2 3  126 127
y1  [][][][]...[][]
y2  [][][][]...[][]

*/


void copy_row(int src_x, int src_y, int dst_x, int dst_y)
{
	uint16_t src_i = MAP_W * src_y + src_x
	uint16_t dst_i = BUF_W * dst_y + dst_x;

	for (uint8_t i = 0; i < BUF_H; i++) {
		uint8_t mi = circuit[src_i];

		// maybe need to wrap here as well ? not if always alined to 16
		bg1_buffer[dst_i]         = metatiles[mi * 4];
		bg1_buffer[dst_i+1]       = metatiles[mi * 4 + 1];
		bg1_buffer[dst_i+BUF_W]   = metatiles[mi * 4 + 2];
		bg1_buffer[dst_i+BUF_W+1] = metatiles[mi * 4 + 3];

		// next row idx
		src_i ++;
		if (src_i % MAP_W == 0) src_i -= MAP_W; // wrap row

		// next dst_i
		dst_i += 2
		if (dst_i % BUF_W == 0) dst_i -= BUF_W; // wrap row
	}
}


void MainLoop()
{

	handleInput();
	centerCam(player);
	updateOAM(player);

}

void handleInput()
{
	uint16_t prev_x = player.x;
	uint16_t prev_y = player.y;

	if (UP) {
		player.y -= dy;
	} else if (DOWN) {
		player.y += dy;
	} else if (LEFT) {
		player.x -= dx;
	} else if (RIGHT) {
		player.x += dx;
	}

	// keep player in bound
	if (player.x < 0 || player.x + SPRITE_W > WORLD_H) {
		player.x = prev_x;
	}
	if (player.y < 0 || player.y + SPRITE_H > WORLD_W) {
		player.y = prev_y;
	}

	if (horizontal_offset % 16 == 0) {
		if (prev_x < player.x) {  // going right
			copy_column(camera.x / 16 + SCREEN_W + READ_X_OFFSET,
						camera.y / 16 - READ_X_OFFSET,
						screen.x / 8 + SCREEN_W + WRITE_X_OFFSET,
						screen.y / 8 - WRITE_Y_OFFSET);
		} else if (prev_x > player.x) { // going left
			copy_column(camera.x / 16 - READ_X_OFFSET,
						camera.y / 16 - READ_Y_OFFSET,
						screen.x / 8 - WRITE_X_OFFSET,
						screen.y / 8 - WRITE_Y_OFFSET);
		}

	}

	if (vertical_offset % 16 == 0) {
		if (prev_y < player.y) // going down
			copy_row(...);
		else if (prev_y > player.y) // going up
			copy_row(...);
	}
}

void centerCam(struct point actor)
{
	uint16_t px = actor.x;
	uint16_t py = actor.y;

	camera.x = px - SCREEN_W/2 + SPRITE_W/2;
	camera.y = py - SCREEN_H/2 + SPRITE_H/2;

	if (camera.x < 0) camera.x = 0;
	else if (camera.x + SCREEN_W > WORLD_W) camera.x = WORLD_W - SCREEN_W;
	if (camera.y < 0) camera.y = 0;
	else if (camera.y + SCREEN_H > WORLD_H) camera.y = WORLD_H - SCREEN_H;

	screen.x = camera.x % 1024;
	screen.y = camera.y % 1024;
}

void updateOAM(struct point actor)
{
	uint16_t screen_x = actor.x - camera.x;
	uint16_t screen_y = actor.y - camera.y;

	// keep off screen
	if (screen_x < 0 || screen_x + SPRITE_W > SCREEN_W) {
		screen_x = 257;
		screen_y = 257;
	}
	if (screen_y < 0 || screen_y + SPRITE_H > SCREEN_H) {
		screen_x = 257;
		screen_y = 257;
	}
}
```

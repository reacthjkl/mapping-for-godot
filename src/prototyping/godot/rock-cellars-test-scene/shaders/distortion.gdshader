shader_type canvas_item;

// The screen texture we want to deform
uniform sampler2D screen_texture: hint_screen_texture;

// A 17×9 grid of control-point offsets (17 columns, 9 rows = 153 points)
uniform vec2 offsets[153];

void fragment() {
    // Base UV and grid dimensions
    vec2 uv = SCREEN_UV;
    const ivec2 GRID = ivec2(16, 8);
    const int COLS = 17;

    // Determine which cell we're in and our local blend factor
    vec2 cell_pos = uv * vec2(GRID);
    ivec2 cell = ivec2(floor(cell_pos));
    cell = clamp(cell, ivec2(0), GRID - ivec2(1));
    vec2 f = fract(cell_pos);

    // Compute indices into the 17×9 offsets array
    int row = cell.y;
    int col = cell.x;
    int i_tl = row * COLS   + col;
    int i_tr = row * COLS   + (col + 1);
    int i_bl = (row + 1) * COLS + col;
    int i_br = (row + 1) * COLS + (col + 1);

    // Fetch the four corner offsets
    vec2 tl = offsets[i_tl];
    vec2 tr = offsets[i_tr];
    vec2 bl = offsets[i_bl];
    vec2 br = offsets[i_br];

    // Bilinearly interpolate the warp offset
    vec2 top    = mix(tl, tr, f.x);
    vec2 bottom = mix(bl, br, f.x);
    vec2 warp   = mix(top, bottom, f.y);

    // Apply the warp and sample
	warp.x *= -1.0;
	warp.y *= -1.0;
    vec2 warped_uv = uv + warp;
    COLOR = texture(screen_texture, warped_uv);

}

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float time   = 0.0;
uniform float speed  = 1.0;
uniform float width  = 0.1;
uniform float amp    = 0.03;
uniform vec2  center = vec2(0.5, 0.5);

void fragment() {
    // UV into the screen texture
    vec2 uv = SCREEN_UV;
    vec4 base_col = texture(screen_texture, uv);

    // compute current radius of wave
    float radius = time * speed;

    // vector from center → this pixel
    vec2 diff = uv - center;
    float dist = length(diff);

    // how far from the wave front we are
    float delta = dist - radius;

    // only distort pixels near the wave front
    // smoothstep gives us a nice falloff inside the 'width' band
    float band = smoothstep(width, 0.0, abs(delta));

    // wave oscillation (one full sine wave across the band)
    float wave = sin((delta / width) * PI) * amp * band;

    // push the UV radially outward/inward
    if (dist > 0.0) {
        uv += normalize(diff) * wave;
    }

    // finally sample the (distorted) screen
    COLOR = texture(screen_texture, uv);
}

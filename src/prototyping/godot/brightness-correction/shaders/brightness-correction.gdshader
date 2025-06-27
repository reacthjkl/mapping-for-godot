shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D wall_texture;
uniform float correction_strength : hint_range(0.0, 2.0) = 1.0;

// Converts sRGB to linear
vec3 to_linear(vec3 srgb) {
    return pow(srgb, vec3(2.2));
}

// Converts linear to sRGB
vec3 to_srgb(vec3 linear) {
    return pow(linear, vec3(1.0 / 2.2));
}

void fragment() {
    vec2 screen_uv = SCREEN_UV;

    vec4 scene_color = texture(SCREEN_TEXTURE, screen_uv);
    float wall_brightness = texture(wall_texture, screen_uv).r;

    // Invert wall brightness and scale
    float correction = 1.0 + (0.5 - wall_brightness) * 2.0 * correction_strength;
    correction = clamp(correction, 0.5, 2.0);

    // Apply correction in linear space for better perceptual results
    vec3 linear_color = to_linear(scene_color.rgb);
    vec3 corrected = linear_color * correction;
    COLOR = vec4(to_srgb(clamp(corrected, 0.0, 1.0)), scene_color.a);
}

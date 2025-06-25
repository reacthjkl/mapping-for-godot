shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D wall_texture;
uniform float correction_strength : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec2 screen_uv = SCREEN_UV;

    // Get the pixel color from the screen (the rendered 3D scene)
    vec4 scene_color = texture(SCREEN_TEXTURE, screen_uv);

    // Sample wall brightness from aligned grayscale image
    float wall_brightness = texture(wall_texture, screen_uv).r;

    // Compute brightness correction factor
    float correction = 1.0 + correction_strength * (0.5 - wall_brightness);

    // Apply brightness correction
    vec3 corrected = scene_color.rgb * correction;

    COLOR = vec4(corrected, scene_color.a);
}

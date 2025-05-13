shader_type spatial;
// render_mode unshaded; // Optional: Wenn du keine Beleuchtung willst

uniform sampler2D albedo_texture;
uniform float emission_strength : hint_range(0.0, 5.0) = 0.1;

void fragment() {
    vec2 uv = UV;

    vec3 tex_color = texture(albedo_texture, uv).rgb;

    ALBEDO = tex_color;
    // Entferne oder setze die Emission auf 0, wenn du keine Leuchtkraft möchtest:
    EMISSION = vec3(0.0);
}
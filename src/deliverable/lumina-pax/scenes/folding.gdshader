 shader_type spatial;
//render_mode unshaded;
//render_mode  ;

uniform sampler2D albedo_texture;
uniform float emission_strength : hint_range(0.0, 5.0) = 0.0;

void fragment() {
    vec2 uv = UV;

    // 270°-Drehung um die Mitte (90° gegen den Uhrzeigersinn)
    uv -= vec2(0.5);
    uv = vec2(-uv.y, uv.x);
    uv += vec2(0.5);

    vec3 tex_color = texture(albedo_texture, uv).rgb;

    ALBEDO = tex_color;
    EMISSION = tex_color * emission_strength;
}
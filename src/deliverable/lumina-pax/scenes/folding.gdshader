shader_type spatial;
// unshaded, doppelseitig ohne Culling,
// aktiviert Alpha-Blending im Mix-Modus,
// schreibt nie in den Depth-Buffer,
// deaktiviert den Depth-Test komplett
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never, depth_test_disabled;

uniform sampler2D albedo_texture;  // im Material-Inspector zuweisen

uniform float emission_strength = 0.0;  // Emission
uniform float curvature_amount  = -0.27;  // Wölbung in Blattmitte
uniform float corner_radius     = 0.045; // Radius der abgerundeten Ecken
uniform float corner_softness   = 0.02; // Weiche Kantenübergänge

void vertex() {
    // UV: [0..1] → [-1..1]
    vec2 c = UV * 2.0 - vec2(1.0);
    // Bulge-Funktion: Maximum in der Mitte, 0 am Rand
    float bulge = (1.0 - c.x*c.x) * (1.0 - c.y*c.y);
    VERTEX += NORMAL * bulge * curvature_amount;
}

void fragment() {
    // 90° CCW um die UV-Mitte rotieren
    vec2 uv = UV - vec2(0.5);
    uv = vec2(-uv.y, uv.x) + vec2(0.5);

    // Abstand zur nächsten Kante
    float d = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    // Weiche Maske statt harte Ausstanzung
    float mask = smoothstep(corner_radius, corner_radius + corner_softness, d);

    // Textur abfragen
    vec4 col = texture(albedo_texture, uv);
    ALBEDO   = col.rgb;
    ALPHA    = col.a * mask;
    EMISSION = col.rgb * emission_strength;
}


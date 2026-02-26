// shader_type spatial;

// void vertex() {
// 	// Called for every vertex the material is visible on.
// }

// void fragment() {
// 	// Called for every pixel the material is visible on.
// }

// //void light() {
// //	// Called for every pixel for every light affecting the material.
// //	// Uncomment to replace the default light processing function with this one.
// //}

shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;

uniform vec4 base_color : source_color = vec4(0.3, 0.9, 0.4, 1.0);
uniform float pulse_speed = 1.5;
uniform float pulse_strength = 0.25;
uniform float radius = 0.5;
uniform float edge_softness = 0.2;

void fragment() {
    // UV center
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);

    // Radial mask
    float circle = smoothstep(radius, radius - edge_softness, dist);

    // Pulse
    float pulse = sin(TIME * pulse_speed);
	float intensity = 1.0 + pulse * pulse_strength;

    ALBEDO = base_color.rgb * intensity;
    EMISSION = base_color.rgb * 0.6 * intensity;

    ALPHA = circle * 0.35;
}
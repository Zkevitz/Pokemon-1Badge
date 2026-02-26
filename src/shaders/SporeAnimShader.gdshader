shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

uniform float rotation_speed = 1.5;
uniform float radius = 0.05;
uniform float random_strength = 0.02;
uniform float random_speed = 2.0;
uniform float seed = 0.0;

void fragment() {
    vec2 uv = UV;

    float t = TIME + seed;

    // ===== ROTATION CIRCULAIRE =====
	vec2 circular_offset = vec2(
	    cos(t * rotation_speed) * radius,
	    sin(t * rotation_speed) * radius * 0.2   // ← réduit vertical
	);
	float random_vertical = sin(t * random_speed + cos(t * 1.37))
                 		* random_strength;

    uv += circular_offset;
	uv.y += random_vertical;

    vec4 tex = texture(TEXTURE, fract(uv));
	tex.rgb = mix(tex.rgb, flash_color.rgb, flash_amount);

    COLOR = tex;
}
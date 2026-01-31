shader_type canvas_item;

uniform sampler2D boost_texture : source_color, repeat_enable;
uniform sampler2D drop_texture : source_color, repeat_enable;
uniform float boost_speed = 1.0;
uniform float boost_strength : hint_range(0.0, 1.0) = 0.5;

uniform float drop_speed = 1.0;
uniform float drop_strength : hint_range(0.0, 1.0) = 0.5;

uniform float white_amount : hint_range(0.0, 1.0) = 1.0;
uniform float sink_in_ground : hint_range(0.0, 1.0) = 0.0; // 0 = normal, 1 = disparu

void fragment() {
	vec2 uv = UV;

	// Disparition par le bas (après flip)
	if (uv.y > (1.2 - sink_in_ground)) {
		discard;
	}

	// Enfoncement
	uv.y = mix(uv.y, 0.0, sink_in_ground * 0.4);

	// Texture principale
	vec4 base_tex = texture(TEXTURE, uv);
	base_tex.a *= (1.0 - sink_in_ground);

	// ===== BOOST TEXTURE =====
	vec2 boost_uv = uv;
	boost_uv.y = fract(uv.y + TIME * boost_speed);

	vec4 boost = texture(boost_texture, boost_uv);

	// ===== DROP TEXTURE =====
	vec2 drop_uv = uv;
	drop_uv.y = fract(uv.y - TIME * drop_speed);

	vec4 drop = texture(drop_texture, drop_uv);

	// ===== COMBINAISON =====
	vec3 combined = base_tex.rgb;

	combined = mix(combined, boost.rgb, boost.a * boost_strength);
	combined = mix(combined, drop.rgb,  drop.a  * drop_strength);

	// Flash blanc
	combined = mix(combined, vec3(1.0), white_amount);

	COLOR = vec4(combined, base_tex.a);
}
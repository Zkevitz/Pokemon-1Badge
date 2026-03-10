shader_type canvas_item;

uniform sampler2D boost_texture : source_color, repeat_enable;
uniform sampler2D drop_texture : source_color, repeat_enable;
uniform sampler2D heal_up_texture : source_color, repeat_enable;

uniform float boost_speed = 1.0;
uniform float boost_strength : hint_range(0.0, 1.0) = 0.5;

uniform float drop_speed = 1.0;
uniform float drop_strength : hint_range(0.0, 1.0) = 0.5;

uniform float heal_speed = 1.0;
uniform float heal_strength : hint_range(0.0, 1.0) = 0.5;

//uniform float white_amount : hint_range(0.0, 1.0) = 1.0;
//uniform float red_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

uniform float sink_in_ground : hint_range(0.0, 1.0) = 0.0; // 0 = normal, 1 = disparu

uniform float shake_strength : hint_range(0.0, 20.0) = 4.0;
uniform float shake_speed = 30.0;
uniform float shake_vertical_amount : hint_range(0.0, 1.0) = 0.0;

uniform float wave_frequency = 10.0;
uniform float wave_speed = 2.0;
uniform float wave_strength : hint_range(0.0, 0.5) = 0.0;

float rand(float x) {
	return fract(sin(x) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;

	float wave_x = sin(uv.y * wave_frequency + TIME * wave_speed);
	float wave_y = cos(uv.x * wave_frequency * 0.5 + TIME * wave_speed * 0.8);
	uv.x += wave_x * wave_strength;
	uv.y += wave_y * wave_strength * 0.3;
	
	// Disparition par le bas
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
	
	// === HEAL TEXTURE ====
	vec2 heal_uv = uv;
	heal_uv.y = fract(uv.y + TIME * boost_speed);
	
	vec4 heal = texture(heal_up_texture, heal_uv);
	
	// ===== DROP TEXTURE =====
	vec2 drop_uv = uv;
	drop_uv.y = fract(uv.y - TIME * drop_speed);

	vec4 drop = texture(drop_texture, drop_uv);

	// ===== COMBINAISON =====
	vec3 combined = base_tex.rgb;

	combined = mix(combined, boost.rgb, boost.a * boost_strength);
	combined = mix(combined, drop.rgb,  drop.a  * drop_strength);
	combined = mix(combined, heal.rgb, heal.a * heal_strength);
	
	// Flash de couleur
	combined = mix(combined.rgb, flash_color.rgb, flash_amount);
	COLOR = vec4(combined, base_tex.a);
}

void vertex() {
	float t = TIME * shake_speed;


	// EFFET VIBRAQUA
	//float shake_y = sin(TIME * shake_speed) 
              //* shake_strength 
              //* shake_vertical_amount;
	float shake_y = (rand(t) * 2.0 - 1.0);
	shake_y *= shake_strength * shake_vertical_amount;

	VERTEX.y += shake_y;
}
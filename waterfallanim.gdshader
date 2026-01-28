shader_type canvas_item;


uniform vec4 tint_color : source_color;
uniform float speed = 2;
uniform float wave_strength = 0.02;
uniform float wave_frequency = 7.0;
uniform float wave_speed = 2.0;
uniform float shake_strength = 0.01;
uniform float shake_speed = 10.0;

float rand(float x) {
	return fract(sin(x) * 43758.5453123);
}

float smooth_rand(float t) {
	float i = floor(t);
	float f = fract(t);
	float a = rand(i);
	float b = rand(i + 1.0);
	return mix(a, b, smoothstep(0.0, 1.0, f));
}


void fragment() {
	vec2 uv = UV;

	float shake = smooth_rand(TIME * shake_speed) * 2.0 - 1.0;
	uv.x += shake * shake_strength;
	// Défilement vers le bas (axe Y)
	uv.y = fract(uv.y - TIME * speed);
	uv.y += sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
	uv.x += sin(uv.y * wave_frequency + TIME * wave_speed)
      * sin(TIME) * wave_strength;
	// Application de la texture
	COLOR = texture(TEXTURE, uv);
}
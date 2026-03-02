shader_type canvas_item;

uniform float speed = 2.0;
uniform float intensity = 1.0;
uniform float scale = 10.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    float wave = sin((UV.x + UV.y) * scale + TIME * speed);
    
    vec3 psychedelic;
    psychedelic.r = sin(TIME * speed + UV.x * scale) * 0.5 + 0.5;
    psychedelic.g = sin(TIME * speed + UV.y * scale + 2.0) * 0.5 + 0.5;
    psychedelic.b = sin(TIME * speed + (UV.x + UV.y) * scale + 4.0) * 0.5 + 0.5;

    vec3 final_color = mix(tex.rgb, psychedelic, intensity);

    COLOR = vec4(final_color, tex.a);
}
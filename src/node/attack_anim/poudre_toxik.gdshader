shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec4 base_tex = texture(TEXTURE, UV);

    vec3 flashed = mix(base_tex.rgb, flash_color.rgb, flash_amount);

    COLOR = vec4(flashed, base_tex.a) * COLOR;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);

    float circle = smoothstep(0.5, 0.45, dist);

    COLOR = vec4(0.478, 0.0, 1.0, circle);
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

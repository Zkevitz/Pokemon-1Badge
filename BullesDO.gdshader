shader_type canvas_item;

void fragment() {
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);

    float thickness = 0.05;
    float radius = 0.45;

    float ring = abs(dist - radius);
    float alpha = smoothstep(thickness, 0.0, ring);

    COLOR.a *= alpha;
}
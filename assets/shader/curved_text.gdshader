shader_type canvas_item;

uniform float curve_amount : hint_range(0.000, 0.05) = 0.005; 
uniform float center_offset : hint_range(0.0, 1.0) = 0.5;     

void fragment() {
    vec2 uv_norm = UV;

    float dist_from_center = uv_norm.x - center_offset;

    float curve = dist_from_center * dist_from_center * curve_amount * 10.0;

    vec2 new_uv = uv_norm;
    new_uv.y += curve;

    COLOR = texture(TEXTURE, new_uv);
}
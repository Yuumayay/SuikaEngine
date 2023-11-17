shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = texture(SCREEN_TEXTURE, uv);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = mix(col, vec4(grey,grey,grey, col.a), strength);
}
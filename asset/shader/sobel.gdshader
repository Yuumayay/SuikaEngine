shader_type canvas_item;

uniform float strength;
uniform float intensity;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);
    vec2 resFactor = (1.0 / TEXTURE_PIXEL_SIZE.xy) * intensity;

    if (strength <= 0.0) {
        COLOR = col;
    }

    vec4 topLeft = texture(SCREEN_TEXTURE, vec2(uv.x - resFactor.x, uv.y - resFactor.y));
    vec4 topMiddle = texture(SCREEN_TEXTURE, vec2(uv.x, uv.y - resFactor.y));
    vec4 topRight = texture(SCREEN_TEXTURE, vec2(uv.x + resFactor.x, uv.y - resFactor.y));

    vec4 midLeft = texture(SCREEN_TEXTURE, vec2(uv.x - resFactor.x, uv.y));
    vec4 midRight = texture(SCREEN_TEXTURE, vec2(uv.x + resFactor.x, uv.y));

    vec4 bottomLeft = texture(SCREEN_TEXTURE, vec2(uv.x - resFactor.x, uv.y + resFactor.y));
    vec4 bottomMiddle = texture(SCREEN_TEXTURE, vec2(uv.x, uv.y + resFactor.y));
    vec4 bottomRight = texture(SCREEN_TEXTURE, vec2(uv.x + resFactor.x, uv.y + resFactor.y));

    vec4 Gx = (topLeft) + (2.0 * midLeft) + (bottomLeft) - (topRight) - (2.0 * midRight) - (bottomRight);
    vec4 Gy = (topLeft) + (2.0 * topMiddle) + (topRight) - (bottomLeft) - (2.0 * bottomMiddle) - (bottomRight);
    vec4 G = sqrt((Gx * Gx) + (Gy * Gy));

    COLOR = mix(col, G, strength);
}
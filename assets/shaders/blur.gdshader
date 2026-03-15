shader_type canvas_item;

// Allows us to pick up the screen texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    // textureLod allows us to use mipmaps for a faster blur
    vec4 blurred_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    COLOR = blurred_color;
}

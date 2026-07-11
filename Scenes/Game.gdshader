shader_type canvas_item;
render_mode unshaded;

uniform sampler2D gradient_texture : source_color;
uniform vec2 region_size = vec2(100.0, 100.0); // Pass your label's size here
varying vec2 text_uv;

void vertex() {
    text_uv = VERTEX.xy / region_size;
}

void fragment() {
    vec4 gradient_color = texture(gradient_texture, text_uv);
 
    vec4 text_shape = texture(TEXTURE, UV);
    COLOR = vec4(gradient_color.rgb, text_shape.a * gradient_color.a);
}

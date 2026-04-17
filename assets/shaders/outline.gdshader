shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0.0, 100.0) = 2.0;
uniform int pattern : hint_range(0, 2) = 1; // 0 diamond, 1 circle, 2 square
uniform bool inside = false;

float shape_distance(vec2 offset) {
    if (pattern == 0) {
        // diamond (Manhattan distance)
        return abs(offset.x) + abs(offset.y);
    } else if (pattern == 1) {
        // circle (Euclidean distance)
        return length(offset);
    } else {
        // square (Chebyshev distance)
        return max(abs(offset.x), abs(offset.y));
    }
}

void fragment() {
    vec2 texel = TEXTURE_PIXEL_SIZE;
    float base_alpha = texture(TEXTURE, UV).a;

    float min_dist = width;

    // sample neighborhood with subpixel precision
    for (float x = -width; x <= width; x += 1.0) {
        for (float y = -width; y <= width; y += 1.0) {
            vec2 offset = vec2(x, y);
            float dist = shape_distance(offset);

            if (dist > width) continue;

            float a = texture(TEXTURE, UV + offset * texel).a;

            // detect edge transition
            if ((a > 0.0) != (base_alpha > 0.0)) {
                min_dist = min(min_dist, dist);
            }
        }
    }

    float edge = smoothstep(width, width - 1.0, min_dist);

    vec4 tex_color = texture(TEXTURE, UV);

    if ((base_alpha > 0.0) == inside) {
        vec3 final_rgb = mix(tex_color.rgb, color.rgb, edge * color.a);
        float final_alpha = max(tex_color.a, edge * color.a);

        COLOR = vec4(final_rgb, final_alpha);
    } else {
        COLOR = tex_color;
    }
}
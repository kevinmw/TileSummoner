shader_type canvas_item;

// 内凹效果 Shader
// 为地块背景创建凹陷阴影效果，增加视觉深度

// 内凹阴影参数
uniform float inset_size : hint_range(0.0, 30.0) = 15.0;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 0.05);
uniform float corner_radius : hint_range(0.0, 20.0) = 4.0;

// 光源方向（左上角照射）
uniform vec2 light_direction = vec2(-1.0, -1.0);

// 计算圆角矩形的 SDF（有符号距离场）
float rounded_rect_sdf(vec2 p, vec2 half_size, float radius) {
    vec2 q = abs(p) - half_size + vec2(radius);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

void fragment() {
    // 获取纹理颜色
    vec4 tex_color = texture(TEXTURE, UV);

    // 转换到以中心为原点的坐标系
    vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 half_size = size * 0.5;
    vec2 center_uv = (UV - 0.5) * size;

    // 计算内凹边缘的距离
    float outer_dist = rounded_rect_sdf(center_uv, half_size, corner_radius);
    float inner_dist = rounded_rect_sdf(center_uv, half_size - vec2(inset_size), corner_radius);

    // 归一化光源方向
    vec2 light_dir = normalize(light_direction);

    // 计算阴影和高光强度
    // 阴影出现在与光源相对的边缘（右下）
    float shadow_factor = max(0.0, dot(normalize(center_uv), -light_dir));
    // 高光出现在光源方向的边缘（左上）
    float highlight_factor = max(0.0, dot(normalize(center_uv), light_dir));

    // 在内凹区域边缘应用效果
    float edge_factor = smoothstep(0.0, inset_size, -inner_dist) * smoothstep(-inset_size, 0.0, outer_dist);

    // 混合阴影
    float shadow_intensity = edge_factor * shadow_factor * shadow_color.a;
    vec3 final_color = mix(tex_color.rgb, shadow_color.rgb, shadow_intensity);

    // 混合高光
    float highlight_intensity = edge_factor * highlight_factor * highlight_color.a;
    final_color = mix(final_color, highlight_color.rgb, highlight_intensity);

    COLOR = vec4(final_color, tex_color.a);
}

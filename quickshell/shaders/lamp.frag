#version 310 es
precision mediump float;

layout(location = 0) out vec4 fragColor;
layout(location = 0) in vec2 v_TexCoord0;

layout(std140, binding = 0) uniform buf {
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 texColor = texture(source, v_TexCoord0);
    
    vec2 lampPos = vec2(0.5, 0.5);
    float radius = 0.4;
    float dist = distance(v_TexCoord0, lampPos);
    float intensity = smoothstep(radius, 0.0, dist);
    
    vec4 lightColor = vec4(1.0, 0.0, 0.0, 1.0); // Red glow
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}

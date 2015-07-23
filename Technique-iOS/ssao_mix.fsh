uniform sampler2D colorSampler;
uniform sampler2D aoSampler;

varying vec2 uv;
uniform vec2 size;

void main() {
    float ao = texture2D(aoSampler,uv).r;
    gl_FragColor.a = 1.0;
    vec3 color = texture2D(colorSampler,uv).rgb;
    vec3 ambient = vec3(0.5);
    gl_FragColor.rgb = mix(color*0.5,color,ao);
}
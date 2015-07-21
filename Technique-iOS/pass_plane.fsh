uniform sampler2D colorSampler;


void main() {
    vec2 uv = gl_FragCoord.xy / vec2(640.0,1136.0);
    gl_FragColor.rgb = mix(vec3(0.1,0.3,0.6),texture2D(colorSampler,vec2(uv.x,1.0-uv.y)).rgb,0.5);
}
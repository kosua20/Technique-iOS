uniform sampler2D colorSampler;

varying vec2 uv;
uniform vec2 size;

void main() {
    
    vec3 col = texture2D(colorSampler,uv).rgb;
    gl_FragColor.rgb = vec3(col.r*col.g*col.b);
}
uniform sampler2D colorSampler;

varying vec3 normal;

void main() {
    gl_FragColor.rgb = normal;//vec3(0.0,1.0,1.0);
}
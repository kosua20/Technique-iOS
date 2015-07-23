
varying vec3 normal;
uniform vec2 size;

void main() {
    gl_FragColor.rgb = (normalize(normal) + 1.0) * 0.5;
    gl_FragColor.a = 1.0;
}
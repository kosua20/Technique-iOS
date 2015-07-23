
varying vec3 pos;
uniform vec2 size;

void main() {
    gl_FragColor.rgb = (pos + 60.0)*0.5/100.0;
    gl_FragColor.a = 1.0;
}
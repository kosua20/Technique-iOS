attribute vec4 a_position;
uniform mat4 mvp;

void main() {
    gl_Position = mvp * a_position;
}
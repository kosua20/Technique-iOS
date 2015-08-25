attribute vec4 a_position;
attribute vec4 a_normal;
uniform mat4 mvp;
uniform mat4 nor_mat;

varying vec3 normal;

void main() {
    gl_Position = mvp*a_position;
    normal = (nor_mat * a_normal).xyz;
}
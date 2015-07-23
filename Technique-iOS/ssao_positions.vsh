attribute vec4 a_position;
attribute vec4 a_normal;
uniform mat4 mvp;
uniform mat4 mv;

varying vec3 pos;

void main() {
   
    gl_Position = mvp*a_position;
    pos = (mv * a_position).xyz;
}
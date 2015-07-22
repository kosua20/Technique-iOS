attribute vec4 a_position;
uniform mat4 mvp;
attribute vec2 a_texcoord;
varying vec2 uv;

void main() {
    gl_Position = mvp * a_position;
    uv = (a_texcoord);
    
}
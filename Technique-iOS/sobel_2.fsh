uniform sampler2D colorSampler;
uniform vec2 size;
varying vec2 uv;

void main() {
    //Compute the second pass of Gx : [1 2 1]^T
    float t_x_0 = 1.0 * texture2D(colorSampler,uv+vec2(0.0,-1.0)/size).r;
    float t_x_1 = 2.0 * texture2D(colorSampler,uv+vec2(0.0,0.0)/size).r;
    float t_x_2 = 1.0 * texture2D(colorSampler,uv+vec2(0.0,1.0)/size).r;
    float gx2 = t_x_0 + t_x_1 + t_x_2;
    //Compute the second pass of Gy : [1 0 -1]^T
    float t_y_0 = 1.0 * texture2D(colorSampler,uv+vec2(-1.0,0.0)/size).g;
    float t_y_2 = -1.0 * texture2D(colorSampler,uv+vec2(1.0,0.0)/size).g;
    float gy2 = t_y_0 + t_y_2;
    float mag = sqrt(gx2*gx2 + gy2 * gy2);
    gl_FragColor.rgb = vec3(mag);
}
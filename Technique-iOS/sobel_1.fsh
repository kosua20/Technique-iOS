uniform sampler2D colorSampler;

varying vec2 uv;
uniform vec2 size;

float rgb_2_luma(vec3 c){ return .3*c[0] + .59*c[1] + .11*c[2]; }

void main() {
    //Compute the first pass of Gx : [1 0 -1]
    float t_x_0 = 1.0 * rgb_2_luma(texture2D(colorSampler,uv+vec2(-1.0,0.0)/size).rgb);
    float t_x_2 = -1.0 * rgb_2_luma(texture2D(colorSampler,uv+vec2(1.0,0.0)/size).rgb);
    float gx1 = t_x_0 + t_x_2;
    //Compute the first pass of Gy : [1 2 1]
    float t_y_0 = 1.0 * rgb_2_luma(texture2D(colorSampler,uv+vec2(0.0,-1.0)/size).rgb);
    float t_y_1 = 2.0 * rgb_2_luma(texture2D(colorSampler,uv+vec2(0.0,0.0)/size).rgb);
    float t_y_2 = 1.0 * rgb_2_luma(texture2D(colorSampler,uv+vec2(0.0,1.0)/size).rgb);
    float gy1 = t_y_0 + t_y_1 + t_y_2;
   
    gl_FragColor.rg = vec2(gx1,gy1);
}
#extension GL_OES_standard_derivatives : enable

uniform sampler2D colorSampler;
uniform sampler2D normalSampler;

varying vec2 uv;
uniform vec2 size;
uniform float u_time;

void main() {
    vec2 new_uv = fract((uv - 0.5)/(vec2(1.775,1.0)*1.8) + 0.5 + vec2(0.0,u_time*0.1));
    vec3 normal = texture2D(normalSampler,vec2(new_uv.x,1.0-new_uv.y)).rgb;
    normal = normal * 2.0 - 1.0;
    gl_FragColor.rgb = texture2D(colorSampler,fract(uv + normal.xy*0.1)).rgb;
    gl_FragColor.a = 1.0;
}
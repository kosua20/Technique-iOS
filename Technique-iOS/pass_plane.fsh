uniform sampler2D colorSampler;
uniform sampler2D normalSampler;
uniform vec2 size;

varying vec2 uv;
uniform float u_time;

void main() {
    
    vec2 uv_1 = gl_FragCoord.xy / size.xy;
    vec3 normal = texture2D(normalSampler,uv+vec2(0.0,fract(u_time*0.1))).rgb * 2.0 - 1.0;
    gl_FragColor.rgb = mix(vec3(0.1,0.3,0.6),texture2D(colorSampler,vec2(uv_1.x,1.0-uv_1.y)+normal.xy*0.1).rgb,0.5);
   //gl_FragColor.rgb = vec3(u_time*0.01,u_time*0.1,u_time);//texture2D(normalSampler,uv+vec2(0.0,fract(time))).rgb;
}
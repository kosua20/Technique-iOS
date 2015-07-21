uniform sampler2D colorSampler;
uniform sampler2D normalSampler;

varying vec2 uv;

void main() {
    
    vec3 nor = texture2D(normalSampler,uv).rgb;
    
    if(nor.rgb == vec3(0.0,0.0,0.0)){
        gl_FragColor = texture2D(colorSampler,uv);
    } else {
        nor = nor * 2.0 - 1.0;
        gl_FragColor = texture2D(colorSampler,uv-nor.xy*0.08);
    }
    //gl_FragColor.rgb = texture2D(normalSampler,uv).rgb;
     // gl_FragColor = texture2D(colorSampler,uv);
}
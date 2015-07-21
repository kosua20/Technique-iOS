uniform sampler2D sampler_color_scene;
uniform sampler2D sampler_depth_scene;
uniform sampler2D sampler_color_plane;
uniform sampler2D sampler_depth_plane;

varying vec2 uv;

void main() {
    float depth = texture2D(sampler_depth_scene,uv).r;
    if (depth == 1.0){
        float depth_plane = texture2D(sampler_depth_plane,uv).r;
        if (depth_plane == 1.0) {
            gl_FragColor = texture2D(sampler_color_scene,uv);
        } else {
            gl_FragColor = texture2D(sampler_color_plane,uv);
        }
    } else {
        //Scene
        gl_FragColor = texture2D(sampler_color_scene,uv);
    }
   
    
    /*if(uv.y <0.5){
        gl_FragColor = texture2D(colorSampler2,vec2(uv.x,1.0-uv.y*2.0));
    } else {
        gl_FragColor = texture2D(colorSampler,(uv-vec2(0.0,0.5))*vec2(1.0,2.0));
    }*/
    //gl_FragColor.rgb = texture2D(normalSampler,uv).rgb;
     // gl_FragColor = texture2D(colorSampler,uv);
}
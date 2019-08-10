uniform sampler2D sampler_color_scene;
uniform sampler2D sampler_depth_scene;
uniform sampler2D sampler_color_plane;
uniform sampler2D sampler_depth_plane;
uniform float u_time;

varying vec2 uv;

void main() {
    float depth = texture2D(sampler_depth_scene,uv).r;
    float depth_plane = texture2D(sampler_depth_plane,uv).r;
    if (depth == 1.0 && depth_plane == 1.0){
        //Special case: if both depths are 1, we show the scene
        gl_FragColor = texture2D(sampler_color_scene,uv);
    } else if (depth == 1.0){
        //depth_plane < depth_scene = 1.0, we show the plane
        gl_FragColor = texture2D(sampler_color_plane,uv);
    } else if (depth_plane <= depth){
        //depth_plane <= depth_scene, we show the plane
        gl_FragColor = texture2D(sampler_color_plane,uv);
    } else {
        //else we show the scene
        gl_FragColor = texture2D(sampler_color_scene,uv);
    }
	
}

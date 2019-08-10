uniform sampler2D depthSampler;
uniform vec2 size;
varying vec2 uv;

void main() {
    float d = texture2D(depthSampler,uv).r;
    // Create gradient from depth.
	gl_FragColor.rgb = mix(vec3(1.0,0.5,0.0), vec3(0.0,0.5,1.0), d*d*d);
}


uniform sampler2D colorSampler1;
uniform sampler2D colorSampler2;
uniform sampler2D colorSampler3;
uniform vec2 size;
varying vec2 uv;

void main() {
    vec3 col = texture2D(colorSampler2,uv).rgb;
    float grey = texture2D(colorSampler1,uv).r;
    vec3 initcol = texture2D(colorSampler3,uv).rgb;
    // Mix gradient color and initial color based on the r*g*b product.
	gl_FragColor.rgb = mix(initcol, col, grey);
}

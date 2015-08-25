uniform sampler2D normalSampler;
uniform sampler2D noiseSampler;
uniform sampler2D depthSampler;
uniform sampler2D colorSampler;
varying vec2 uv;
uniform vec2 size;

const float thfov = 0.5773502692;
const float projA = 1.0101010101;

const float g_scale = 1.0;
const float g_bias = 0.2;
const float g_sample_rad = 0.001;
const float g_intensity = 1.1;

vec3 getPosition(vec2 uv_c) {
    vec2 ndc = uv_c * 2.0 - 1.0;
    float aspect = size.x / size.y;
    vec3 viewray = vec3(ndc.x * thfov * aspect,ndc.y * thfov,-1.0);
    float linear_depth = -projA/(texture2D(depthSampler,uv_c).r - projA);
    vec3 pos = linear_depth / 100.0 * viewray;
    return pos;//*0.8;
}

float computeAO(vec2 uv, vec2 shift, vec3 origin, vec3 normal) {
    vec3 diff = getPosition(uv + shift) - origin;
    vec3 n_diff = normalize(diff);
    float d = length(diff)*g_scale;
    return (1.0-n_diff.z*0.9)*max(0.0,dot(normal,n_diff)-g_bias)*(1.0/(1.0+d))*g_intensity;
}

vec2 pseudoSampleArray(int index){
    if(index==0){
        return vec2(1.0,0.0);
    } else if (index==1) {
        return vec2(-1.0,0.0);
    } else if (index == 3) {
        return vec2(0.0,1.0);
    } else {
        return vec2(0.0,-1.0);
    }
}

void main() {
    vec3 normal = texture2D(normalSampler,uv).rgb * 2.0 - 1.0;
    normal = normalize(normal);
    vec3 position = getPosition(uv);
    vec2 random_normal = texture2D(noiseSampler, uv  * size / vec2(64.0,64.0)).xy * 2.0 - 1.0;
    random_normal = normalize(random_normal);
    
    float ao = 0.0;
    float radius = g_sample_rad/abs(position.z);
    int iter = 4;
    for(int i = 0;i < iter;i++){
        vec2 coord1 = reflect(pseudoSampleArray(i),random_normal) * radius;
        vec2 coord2 = vec2(0.707 * coord1.x - 0.707 * coord1.y, 0.707 * coord1.x + 0.707 * coord1.y);
        ao += computeAO(uv,coord1 * 0.25, position,normal);
        ao += computeAO(uv,coord2 * 0.5, position,normal);
        ao += computeAO(uv,coord1 * 0.75, position,normal);
        ao += computeAO(uv,coord2, position,normal);
    }
    
    ao /= (float(iter) * 4.0);
    gl_FragColor.rgb = vec3(1.0-ao)*texture2D(colorSampler,uv).rgb;
    gl_FragColor.a = 1.0;
}

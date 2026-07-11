shader_type spatial;


uniform vec3 primary_color : source_color; 
uniform vec3 secondary_color : source_color;
uniform vec3 third_color : source_color;
uniform int cn; 
uniform int n;

uniform bool rotation = false;
uniform float mixdeg = 0.5;


uniform sampler2D voronoi;
uniform sampler2D noise;


uniform vec3 i_p = vec3(0, 1, 0);

const float TWO_HALVES = 1./1.;

vec3 color_ramp(float p, float positions[4], vec3 colors[3]) {
    for (int i = 0; i < 4; i++) {
        if (p >= positions[i] && p <= positions[i + 1]) {
            return colors[i];
        }
    }

    return colors[1]; // fallback
}



void vertex() {
	COLOR.xyz = VERTEX.xyz;
}


float sawtooth(float y) {
    int ret =  int(float(cn) * y) % n;
    return float(ret);
}


void fragment() {
    vec4 vorotex = texture(voronoi, UV);
    vec4 simtex = texture(noise, UV);
    // ALBEDO.xyz = COLOR.xyz;
    float dx = 0.5;
    float acc = 0.;
    float value = mix(
            vorotex.y* simtex.y, 
            sawtooth(UV.y+0.08*simtex.y+TIME*0.01),
            mixdeg
            );
    ALBEDO.rgb = color_ramp(value, {0., 0.33, 0.666, 1.0}, {primary_color, secondary_color, third_color});

    ALPHA = 1.;
    ROUGHNESS = 0.;
    ANISOTROPY = 0.9;

}

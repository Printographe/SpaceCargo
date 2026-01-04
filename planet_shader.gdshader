shader_type spatial;


uniform vec3 basecolor = vec3(0, 1, 0);
uniform uint island_count = 1;
uniform bool rotation = false;


uniform vec3 i_p = vec3(0, 1, 0);

const vec4 I = vec4(1,1,1,1);
const float TWO_HALVES = 1./1.;


float f(float x, float y) {
	x = 3.*x;
	y = 3.*y;
	float a = 1.2;
	return pow(pow(x, 2.) + pow(y, 2.) - a*x, 2.) - pow(a, 2.)*(pow(x, 2.)+pow(y, 2.));
}


void vertex() {
	COLOR.xyz = VERTEX.xyz;
}

float shape(float d) {
	return sin(d);
}


void fragment() {

	ALBEDO.xyz = COLOR.xyz;
	vec3 normal_i_p = normalize(i_p);
	vec3 w;
	if (rotation)
		{
			w = vec3(normal_i_p.x*cos(TIME) - normal_i_p.y*sin(TIME),
							normal_i_p.x * sin(TIME) + normal_i_p.y * cos(TIME),
							normal_i_p.z);
		}
	else w = normal_i_p;
	vec3 dir = normalize(COLOR.xyz);

	vec3 rel = w - dir;

	vec3 up = abs(w.y) < 0.99 ? vec3(0, 1, 0): vec3(1, 0, 0);
	vec3 u = normalize(cross(w, up));
	vec3 v = cross(w, u);



	float x = dot(dir, u);
	float y = dot(dir, v);
	//float d = distance(n_color, drifted);
	if (f(x, y) <= 0.1 ) {
		ALBEDO.rgb = vec3(1, 0, 0);
	} else {
		ALBEDO.xyz = basecolor;
	}

	ALPHA = 1.0;

}

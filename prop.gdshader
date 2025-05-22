shader_type spatial;
render_mode unshaded;
render_mode world_vertex_coords;

#include "hue2rgb.gdshaderinc"

global uniform float depth; // max depth of meshes
global uniform float fog_power;
global uniform vec3 fog_color;
uniform sampler2D tex : source_color, filter_nearest;
uniform float hue;
uniform float bias;
uniform float alpha;

void vertex() {
	COLOR.rgb = hue2rgb(hue, bias);
	float fog_ratio = pow(VERTEX.z / (depth + 1.0), fog_power);
	COLOR.rgb *= max(vec3(0.0), (COLOR.rgb * (1.0 - fog_ratio)) + (fog_color * fog_ratio));
}

void fragment() {
	vec4 color = texture(tex, UV);
	ALBEDO = color.rgb * COLOR.rgb;
	ALPHA = color.a * alpha;
}
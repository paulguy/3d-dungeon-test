shader_type spatial;
render_mode unshaded;
render_mode skip_vertex_transform;

#include "hue2rgb.gdshaderinc"

global uniform float depth; // max depth of meshes
global uniform float fog_power;
global uniform vec3 fog_color;
global uniform vec2 sky_mul;
uniform int count; // count of meshes
uniform sampler2D world_positions;
uniform ivec2 view_pos; // position in map
uniform sampler2D map_positions; // Coordinate offsets for looking up data in textures
uniform mat3 mesh_transform;
uniform float eye_height;
uniform int lookup_tex_width;

// r - ceiling top
// g - ceiling bottom
// b - floor top
// a - floor bottom
uniform sampler2D face_heights;
uniform sampler2D face_offsets;
// r = ceiling hue
// g = ceiling bias
// b = floor hue
// a = floor bias
uniform sampler2D face_hues_and_biases;
// r - north top
// g - north bottom
// b - south top
// a - south bottom
uniform sampler2D floor_north_south_hues;
uniform sampler2D floor_north_south_biases;
uniform sampler2D floor_east_west_hues;
uniform sampler2D floor_east_west_biases;
// r - north
// g - east
// b - south
// a - west
uniform sampler2D floor_side_texture_offsets;
uniform sampler2D ceiling_north_south_hues;
uniform sampler2D ceiling_north_south_biases;
uniform sampler2D ceiling_east_west_hues;
uniform sampler2D ceiling_east_west_biases;
uniform sampler2D ceiling_side_texture_offsets;
uniform sampler2D albedo_texture : filter_nearest;

void vertex() {
	int id = INSTANCE_ID % count;
	bool ceiling_mesh = (INSTANCE_ID / count) != 0;
	vec2 world_pos = texelFetch(world_positions, ivec2(id % lookup_tex_width, id / lookup_tex_width), 0).rg;
	ivec2 map_pos = ivec2(texelFetch(map_positions, ivec2(id % lookup_tex_width, id / lookup_tex_width), 0).rg) + view_pos;

	vec3 tnormal = NORMAL * mesh_transform;
	vec3 tvertex = VERTEX * mesh_transform;

	bool top_face = NORMAL.y > 0.1;
	bool bottom_face = NORMAL.y < -0.1;
	bool north_face = tnormal.z > 0.1;
	bool east_face = tnormal.x < -0.1;
	bool south_face = tnormal.z < -0.1;

	bool top_vert = VERTEX.y > 0.0;

	vec4 face_colors = texelFetch(face_hues_and_biases, map_pos, 0);
	vec4 floor_ns_hues = texelFetch(floor_north_south_hues, map_pos, 0);
	vec4 floor_ns_biases = texelFetch(floor_north_south_biases, map_pos, 0);
	vec4 floor_ew_hues = texelFetch(floor_east_west_hues, map_pos, 0);
	vec4 floor_ew_biases = texelFetch(floor_east_west_biases, map_pos, 0);
	vec4 ceil_ns_hues = texelFetch(ceiling_north_south_hues, map_pos, 0);
	vec4 ceil_ns_biases = texelFetch(ceiling_north_south_biases, map_pos, 0);
	vec4 ceil_ew_hues = texelFetch(ceiling_east_west_hues, map_pos, 0);
	vec4 ceil_ew_biases = texelFetch(ceiling_east_west_biases, map_pos, 0);

	COLOR.a = 1.0;
	if(top_face) { // top (floor) face
		COLOR.rgb = hue2rgb(abs(face_colors.b), face_colors.a);
		COLOR.a = 1.0 - min(1.0, face_colors.a);
		UV2.x = face_colors.b;
	} else if(bottom_face) { // bottom (ceiling) face
		COLOR.rgb = hue2rgb(abs(face_colors.r), face_colors.g);
		COLOR.a = 1.0 - min(1.0, face_colors.g);
		UV2.x = face_colors.r;
	} else if(ceiling_mesh) {
		if(north_face) {
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(ceil_ns_hues.r), ceil_ns_biases.r);
				COLOR.a = 1.0 - min(1.0, ceil_ns_biases.r);
				UV2.x = ceil_ns_hues.r;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(ceil_ns_hues.g), ceil_ns_biases.g);
				COLOR.a = 1.0 - min(1.0, ceil_ns_biases.g);
				UV2.x = ceil_ns_hues.g;
			}
		} else if(east_face) {
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(ceil_ew_hues.r), ceil_ew_biases.r);
				COLOR.a = 1.0 - min(1.0, ceil_ew_biases.g);
				UV2.x = ceil_ew_hues.r;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(ceil_ew_hues.g), ceil_ew_biases.g);
				COLOR.a = 1.0 - min(1.0, ceil_ew_biases.g);
				UV2.x = ceil_ew_hues.g;
			}
		} else if(south_face) {
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(ceil_ns_hues.b), ceil_ns_biases.b);
				COLOR.a = 1.0 - min(1.0, ceil_ns_biases.b);
				UV2.x = ceil_ns_hues.b;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(ceil_ns_hues.a), ceil_ns_biases.a);
				COLOR.a = 1.0 - min(1.0, ceil_ns_biases.a);
				UV2.x = ceil_ns_hues.a;
			}
		} else { // west face
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(ceil_ew_hues.b), ceil_ew_biases.b);
				COLOR.a = 1.0 - min(1.0, ceil_ew_biases.b);
				UV2.x = ceil_ew_hues.b;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(ceil_ew_hues.a), ceil_ew_biases.a);
				COLOR.a = 1.0 - min(1.0, ceil_ew_biases.a);
				UV2.x = ceil_ew_hues.a;
			}
		}
	} else { // floor mesh
		if(north_face) {
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(floor_ns_hues.r), floor_ns_biases.r);
				COLOR.a = 1.0 - min(1.0, floor_ns_biases.r);
				UV2.x = floor_ns_hues.r;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(floor_ns_hues.g), floor_ns_biases.g);
				COLOR.a = 1.0 - min(1.0, floor_ns_biases.g);
				UV2.x = floor_ns_hues.g;
			}
		} else if(east_face) {
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(floor_ew_hues.r), floor_ew_biases.r);
				COLOR.a = 1.0 - min(1.0, floor_ew_biases.r);
				UV2.x = floor_ew_hues.r;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(floor_ew_hues.g), floor_ew_biases.g);
				COLOR.a = 1.0 - min(1.0, floor_ew_biases.g);
				UV2.x = floor_ew_hues.g;
			}
		} else if(south_face) {
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(floor_ns_hues.b), floor_ns_biases.b);
				COLOR.a = 1.0 - min(1.0, floor_ns_biases.b);
				UV2.x = floor_ns_hues.b;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(floor_ns_hues.a), floor_ns_biases.a);
				COLOR.a = 1.0 - min(1.0, floor_ns_biases.a);
				UV2.x = floor_ns_hues.a;
			}
		} else { // west face
			if(top_vert) {
				COLOR.rgb = hue2rgb(abs(floor_ew_hues.b), floor_ew_biases.b);
				COLOR.a = 1.0 - min(1.0, floor_ew_biases.b);
				UV2.x = floor_ew_hues.b;
			} else { // bottom vert
				COLOR.rgb = hue2rgb(abs(floor_ew_hues.a), floor_ew_biases.a);
				COLOR.a = 1.0 - min(1.0, floor_ew_biases.a);
				UV2.x = floor_ew_hues.a;
			}
		}
	}

	if(UV2.x >= 0.0) {
		/* Only apply fog to non-sky surfaces. */
		float fog_ratio = pow(-world_pos.y / (depth + 1.0), fog_power);

		COLOR.rgb *= max(vec3(0.0), (COLOR.rgb * (1.0 - fog_ratio)) + (fog_color * fog_ratio));
	}

	vec4 mesh_face_heights = texelFetch(face_heights, map_pos, 0);

	vec4 mesh_face_offsets = texelFetch(face_offsets, map_pos, 0);
	vec4 floor_tex_offsets = texelFetch(floor_side_texture_offsets, map_pos, 0);
	vec4 ceiling_tex_offsets = texelFetch(ceiling_side_texture_offsets, map_pos, 0);
	ivec2 tex_size = textureSize(albedo_texture, 0);
	vec2 uv_scale = vec2(1.0, float(tex_size.y / tex_size.x));

	if(ceiling_mesh) {
		if(top_face) {
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.r)) / uv_scale);
			UV2.y = mesh_face_offsets.r;
		} else if(bottom_face) {
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.g)) / uv_scale);
			UV2.y = mesh_face_offsets.g;
		} else if(north_face) {
			if(top_vert) {
				UV = vec2(tvertex.x + 0.5,
						  ceiling_tex_offsets.r - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.x + 0.5,
						  ceiling_tex_offsets.r) /
					 uv_scale;
			}
			UV2.y = ceiling_tex_offsets.r;
		} else if(east_face) {
			if(top_vert) {
				UV = vec2(tvertex.z + 0.5,
						  ceiling_tex_offsets.g - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.z + 0.5,
						  ceiling_tex_offsets.g) /
					 uv_scale;
			}
			UV2.y = ceiling_tex_offsets.g;
		} else if(south_face) {
			if(top_vert) {
				UV = vec2(-tvertex.x + 0.5,
						  ceiling_tex_offsets.b - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.x + 0.5,
						  ceiling_tex_offsets.b) /
					 uv_scale;
			}
			UV2.y = ceiling_tex_offsets.b;
		} else { // west face
			if(top_vert) {
				UV = vec2(-tvertex.z + 0.5,
						  ceiling_tex_offsets.a - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.z + 0.5,
						  ceiling_tex_offsets.a) /
					 uv_scale;
			}
			UV2.y = ceiling_tex_offsets.a;
		}
	} else { // floor mesh
		if(top_face) {
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.b)) / uv_scale);
			UV2.y = mesh_face_offsets.b;
		} else if(bottom_face) {
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.a)) / uv_scale);
			UV2.y = mesh_face_offsets.a;
		} else if(north_face) {
			if(top_vert) {
				UV = vec2(tvertex.x + 0.5,
						  floor_tex_offsets.r) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.x + 0.5,
						  floor_tex_offsets.r + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
			UV2.y = floor_tex_offsets.r;
		} else if(east_face) {
			if(top_vert) {
				UV = vec2(tvertex.z + 0.5,
						  floor_tex_offsets.g) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.z + 0.5,
						  floor_tex_offsets.g + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
			UV2.y = floor_tex_offsets.g;
		} else if(south_face) {
			if(top_vert) {
				UV = vec2(-tvertex.x + 0.5,
						  floor_tex_offsets.b) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.x + 0.5,
						  floor_tex_offsets.b + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
			UV2.y = floor_tex_offsets.b;
		} else { // west face
			if(top_vert) {
				UV = vec2(-tvertex.z + 0.5,
						  floor_tex_offsets.a) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.z + 0.5,
						  floor_tex_offsets.a + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
			UV2.y = floor_tex_offsets.a;
		}
	}

	if(ceiling_mesh) {
		if(top_vert) {
			VERTEX.y = mesh_face_heights.r - eye_height;
		} else {
			VERTEX.y = mesh_face_heights.g - eye_height;
		}
	} else {
		if(top_vert) {
			VERTEX.y = mesh_face_heights.b - eye_height;
		} else {
			VERTEX.y = mesh_face_heights.a - eye_height;
		}
	}
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
	TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
}

void fragment() {
	vec2 uv = UV;
	if (UV2.x < 0.0) {
		uv = vec2(0.0, UV2.y * sky_mul.y) + (SCREEN_UV * sky_mul);
	}
	vec3 color = texture(albedo_texture, uv).rgb;
	color.r = pow(color.r, COLOR.a + 1.0);
	color.g = pow(color.g, COLOR.a + 1.0);
	color.b = pow(color.b, COLOR.a + 1.0);
	ALBEDO = (color - (COLOR.a / 2.0)) * COLOR.rgb;
	//ALBEDO = vec3(UV, 1.0) * COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

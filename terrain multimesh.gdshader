shader_type spatial;
render_mode unshaded;
render_mode skip_vertex_transform;

#include "hue2rgb.gdshaderinc"

global uniform float depth; // max depth of meshes
global uniform float fog_power;
global uniform vec3 fog_color;
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
	int ceiling_mesh = INSTANCE_ID / count;
	int floor_mesh = -(ceiling_mesh - 1);
	float fceiling_mesh = float(ceiling_mesh);
	float ffloor_mesh = float(floor_mesh);
	vec2 world_pos = texelFetch(world_positions, ivec2(id % lookup_tex_width, id / lookup_tex_width), 0).rg;
	ivec2 map_pos = ivec2(texelFetch(map_positions, ivec2(id % lookup_tex_width, id / lookup_tex_width), 0).rg) + view_pos;

	vec3 tnormal = NORMAL * mesh_transform;
	vec3 tvertex = VERTEX * mesh_transform;

	float top_vert = max(VERTEX.y, 0.0) * 2.0;
	float bottom_vert = min(VERTEX.y, 0.0) * -2.0;

	vec4 face_colors = texelFetch(face_hues_and_biases, map_pos, 0);
	vec4 floor_ns_hues = texelFetch(floor_north_south_hues, map_pos, 0);
	vec4 floor_ns_biases = texelFetch(floor_north_south_biases, map_pos, 0);
	vec4 floor_ew_hues = texelFetch(floor_east_west_hues, map_pos, 0);
	vec4 floor_ew_biases = texelFetch(floor_east_west_biases, map_pos, 0);
	vec4 ceil_ns_hues = texelFetch(ceiling_north_south_hues, map_pos, 0);
	vec4 ceil_ns_biases = texelFetch(ceiling_north_south_biases, map_pos, 0);
	vec4 ceil_ew_hues = texelFetch(ceiling_east_west_hues, map_pos, 0);
	vec4 ceil_ew_biases = texelFetch(ceiling_east_west_biases, map_pos, 0);

	if(NORMAL.y > 0.1) { // top (floor) face
		COLOR.rgb = hue2rgb(face_colors.b, face_colors.a);
	} else if(NORMAL.y < -0.1) { // bottom (ceiling) face
		COLOR.rgb = hue2rgb(face_colors.r, face_colors.g);
	} else if(ceiling_mesh > 0) {
		if(tnormal.z > 0.1) { // north face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(ceil_ns_hues.r, ceil_ns_biases.r);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(ceil_ns_hues.g, ceil_ns_biases.g);
			}
		} else if(tnormal.x < -0.1) { // east face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(ceil_ew_hues.r, ceil_ew_biases.r);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(ceil_ew_hues.g, ceil_ew_biases.g);
			}
		} else if(tnormal.z < -0.1) { // south face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(ceil_ns_hues.b, ceil_ns_biases.b);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(ceil_ns_hues.a, ceil_ns_biases.a);
			}
		} else { // west face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(ceil_ew_hues.b, ceil_ew_biases.b);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(ceil_ew_hues.a, ceil_ew_biases.a);
			}
		}
	} else { // floor mesh
		if(tnormal.z > 0.1) { // north face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(floor_ns_hues.r, floor_ns_biases.r);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(floor_ns_hues.g, floor_ns_biases.g);
			}
		} else if(tnormal.x < -0.1) { // east face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(floor_ew_hues.r, floor_ew_biases.r);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(floor_ew_hues.g, floor_ew_biases.g);
			}
		} else if(tnormal.z < -0.1) { // south face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(floor_ns_hues.b, floor_ns_biases.b);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(floor_ns_hues.a, floor_ns_biases.a);
			}
		} else { // west face
			if(VERTEX.y > 0.0) { // top vert
				COLOR.rgb = hue2rgb(floor_ew_hues.b, floor_ew_biases.b);
			} else { // bottom vert
				COLOR.rgb = hue2rgb(floor_ew_hues.a, floor_ew_biases.a);
			}
		}
	}

	float fog_ratio = pow(-world_pos.y / (depth + 1.0), fog_power);

	COLOR.rgb *= max(vec3(0.0), (COLOR.rgb * (1.0 - fog_ratio)) + (fog_color * fog_ratio));

	ivec2 tex_size = textureSize(albedo_texture, 0);
	vec4 mesh_face_heights = texelFetch(face_heights, map_pos, 0);
	vec4 mesh_face_offsets = texelFetch(face_offsets, map_pos, 0);
	vec4 floor_tex_offsets = texelFetch(floor_side_texture_offsets, map_pos, 0);
	vec4 ceiling_tex_offsets = texelFetch(ceiling_side_texture_offsets, map_pos, 0);
	vec2 uv_scale = vec2(1.0, float(tex_size.y / tex_size.x));

	if(ceiling_mesh > 0) {
		if(NORMAL.y > 0.1) { // top face
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.r)) / uv_scale);
		} else if(NORMAL.y < -0.1) { // bottom face
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.g)) / uv_scale);
		} else if(tnormal.z > 0.1) { // north face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(tvertex.x + 0.5,
						  ceiling_tex_offsets.r - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.x + 0.5,
						  ceiling_tex_offsets.r) /
					 uv_scale;
			}
		} else if(tnormal.x < -0.1) { // east face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(tvertex.z + 0.5,
						  ceiling_tex_offsets.g - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.z + 0.5,
						  ceiling_tex_offsets.g) /
					 uv_scale;
			}
		} else if(tnormal.z < -0.1) { // south face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(-tvertex.x + 0.5,
						  ceiling_tex_offsets.b - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.x + 0.5,
						  ceiling_tex_offsets.b) /
					 uv_scale;
			}
		} else { // west face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(-tvertex.z + 0.5,
						  ceiling_tex_offsets.a - (mesh_face_heights.r - mesh_face_heights.g)) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.z + 0.5,
						  ceiling_tex_offsets.a) /
					 uv_scale;
			}
		}
	} else { // floor mesh
		if(NORMAL.y > 0.1) { // top face
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.b)) / uv_scale);
		} else if(NORMAL.y < -0.1) { // bottom face
			UV = (((tvertex.zx + 0.5) + vec2(0.0, mesh_face_offsets.a)) / uv_scale);
		} else if(tnormal.z > 0.1) { // north face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(tvertex.x + 0.5,
						  floor_tex_offsets.r) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.x + 0.5,
						  floor_tex_offsets.r + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
		} else if(tnormal.x < -0.1) { // east face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(tvertex.z + 0.5,
						  floor_tex_offsets.g) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(tvertex.z + 0.5,
						  floor_tex_offsets.g + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
		} else if(tnormal.z < -0.1) { // south face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(-tvertex.x + 0.5,
						  floor_tex_offsets.b) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.x + 0.5,
						  floor_tex_offsets.b + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
		} else { // west face
			if(VERTEX.y > 0.0) { // top vert
				UV = vec2(-tvertex.z + 0.5,
						  floor_tex_offsets.a) /
					 uv_scale;
			} else { // bottom vert
				UV = vec2(-tvertex.z + 0.5,
						  floor_tex_offsets.a + (mesh_face_heights.b - mesh_face_heights.a)) /
					 uv_scale;
			}
		}
	}

	VERTEX.y = ((top_vert * fceiling_mesh) * mesh_face_heights.r) +
			   ((bottom_vert * fceiling_mesh) * mesh_face_heights.g) +
			   ((top_vert * ffloor_mesh) * mesh_face_heights.b) +
			   ((bottom_vert * ffloor_mesh) * mesh_face_heights.a) - eye_height;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
	TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * COLOR.rgb;
	//ALBEDO = vec3(UV, 1.0) * COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

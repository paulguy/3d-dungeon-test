shader_type spatial;
render_mode unshaded;
render_mode skip_vertex_transform;
uniform float max_depth; // max depth of meshes
uniform int count; // count of meshes
uniform sampler2D world_positions : filter_nearest;
uniform vec2 view_pos; // position in map
uniform sampler2D map_positions : filter_nearest; // Coordinate offsets for looking up data in textures

// r = floor height
// b = floor texture offset
// g = ceiling height
// a = ceiling texture_offset
uniform sampler2D heights_and_face_offsets : filter_nearest;
// r = floor hue
// g = floor bias
// b = ceiling hue
// a = ceiling bias
uniform sampler2D face_hues_and_biases : filter_nearest;
uniform sampler2D floor_north_south_hues : filter_nearest;
uniform sampler2D floor_north_south_biases : filter_nearest;
uniform sampler2D floor_east_west_hues : filter_nearest;
uniform sampler2D floor_east_west_biases : filter_nearest;
uniform sampler2D floor_side_texture_offsets : filter_nearest;
uniform sampler2D ceiling_north_south_hues : filter_nearest;
uniform sampler2D ceiling_north_south_biases : filter_nearest;
uniform sampler2D ceiling_east_west_hues : filter_nearest;
uniform sampler2D ceiling_east_west_biases : filter_nearest;
uniform sampler2D ceiling_side_texture_offsets : filter_nearest;

vec3 hue2rgb(float val) {
	// in theory, each color starts at 1.0, then a notch is cut out
	// W     R     Y     G     C     B     M 
	// 0.00  0.16  0.33  0.49  0.67  0.84  1.00
	// _|_  _|_   _|     |     |     |    _|_
	//  |    |     |  \ _|_   _|_   _|_ /  |
	
	// |_    |    _|_   _|_   _|_    |     |
	// |  \ _|_ /  |     |     |  \ _|_   _|_
	
	// |_    |     |     |    _|_   _|_   _|_
	// |  \ _|_   _|_   _|_ /  |     |     |
	return vec3(1.0 - (((clamp(val, 0.33, 0.49) - 0.33) - (max(val, 0.84) - 0.84)) / 0.16),
				1.0 - ((min(val, 0.16) - (clamp(val, 0.16, 0.32) - 0.16)) / 0.16) - ((clamp(val, 0.67, 0.83) - 0.67) / 0.16),
				1.0 - ((min(val, 0.16) - (clamp(val, 0.49, 0.67) - 0.49)) / 0.16));
}

void vertex() {
	int id = INSTANCE_ID % count;
	int ceiling_mesh = INSTANCE_ID / count;
	int floor_mesh = -(ceiling_mesh - 1);
	vec2 world_pos = texelFetch(world_positions, ivec2(id, 0), 0).rg;
	vec2 map_pos = texelFetch(map_positions, ivec2(id, 0), 0).rg + view_pos;

	float horiz_face = abs(NORMAL.y); // will be 1.0 on top and bottom
	float north_face = min(0.0, NORMAL.z);
	float south_face = -max(0.0, NORMAL.z);
	float west_face = min(0.0, NORMAL.x);
	float east_face = -max(0.0, NORMAL.x);
	float vert_face = abs(NORMAL.x) + abs(NORMAL.z); // will be 1.0 on the sides
	float top_vert = max(VERTEX.y, 0.0) * 2.0;
	float bottom_vert = min(VERTEX.y, 0.0) * -2.0;

/*
	COLOR.rgb = ((top_vert * vert_face) * (hue2rgb(COLOR.r) * COLOR.g) + // ceiling
				 (bottom_vert * vert_face) * (hue2rgb(COLOR.b) * COLOR.a) + // floor
				 (hue2rgb(INSTANCE_CUSTOM.r) * horiz_face * INSTANCE_CUSTOM.g)) *
				(1.0 - (world_pos.y / (max_depth + 1.0)));
*/
	vec4 face_colors = texelFetch(face_hues_and_biases, ivec2(map_pos), 0);
	COLOR.rgb = (((horiz_face * float(floor_mesh)) * (hue2rgb(face_colors.r) * face_colors.g)) +
				 ((horiz_face * float(ceiling_mesh)) * (hue2rgb(face_colors.b) * face_colors.a))) *
				(1.0 - (world_pos.y / (max_depth + 1.0)));

	vec2 heights = texelFetch(heights_and_face_offsets, ivec2(map_pos), 0).rb;
	VERTEX.y += heights[ceiling_mesh];
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
	TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
}

void fragment() {
	ALBEDO = COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

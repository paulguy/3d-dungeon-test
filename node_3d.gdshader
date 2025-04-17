shader_type spatial;
render_mode unshaded;
render_mode skip_vertex_transform;
uniform int grid_width;
uniform int grid_depth;

vec3 hue2rgb(float val) {
	// this probably doesn't work
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
				1.0 - (((clamp(val, 0.16, 0.33) - 0.16) - (clamp(val, 0.49, 0.67) - 0.49)) / 0.16));
}

void vertex() {
	int id = INSTANCE_ID % (grid_width * grid_depth);
	float depth = float(id / grid_width);
	VERTEX.x += float((id % grid_width) - (grid_width / 2));
	VERTEX.z += depth;

	float horiz_face = abs(NORMAL.y); // will be 1.0 on top and bottom
	float vert_face = abs(NORMAL.x) + abs(NORMAL.z); // will be 1.0 on the sides
	float top_vert = max(VERTEX.y, 0.0) * 2.0;
	float bottom_vert = min(VERTEX.y, 0.0) * -2.0;

	COLOR.rgb = ((hue2rgb(COLOR.r) * (top_vert * vert_face) * COLOR.g) +
				 (hue2rgb(COLOR.b) * (bottom_vert * vert_face) * COLOR.a) +
				 (hue2rgb(INSTANCE_CUSTOM.r) * horiz_face * INSTANCE_CUSTOM.g)) *
				pow(1.0 - (depth / float(grid_depth)), 2.0);

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

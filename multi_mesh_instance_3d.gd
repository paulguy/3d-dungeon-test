extends MultiMeshInstance3D

var grid_depth : int
var grid_width : int

func set_view_dimensions(width : int, depth : int):
	grid_width = width
	grid_depth = depth
	multimesh.instance_count = grid_width * grid_depth * 2

func refresh(floor_height : Array[float],
			 floor_top_hue : Array[float],
			 floor_top_bias : Array[float],
			 floor_bottom_hue : Array[float],
			 floor_bottom_bias : Array[float],
			 floor_face_hue : Array[float],
			 floor_face_bias : Array[float],
			 floor_side_texture_offset : Array[float],
			 floor_face_texture_offset : Array[float],
			 ceiling_height : Array[float],
			 ceiling_top_hue : Array[float],
			 ceiling_top_bias : Array[float],
			 ceiling_bottom_hue : Array[float],
			 ceiling_bottom_bias : Array[float],
			 ceiling_face_hue : Array[float],
			 ceiling_face_bias : Array[float],
			 ceiling_side_texture_offset : Array[float],
			 ceiling_face_texture_offset : Array[float],
			 dims : Vector2i,
			 pos : Vector2i):
	# color.r - top hue
	# color.g - top bias
	# color.b - bottom hue
	# color.a - bottom bias
	# custom.r - face hue
	# custom.g - face bias
	# custom.b - side texture.v
	# custom.a - face texture.v

	# TODO: Try to prevent adding tiles which will never be in view
	var time : int = Time.get_ticks_usec()
	var half_width : int = grid_width / 2
	var half_array : int = multimesh.instance_count / 2
	var i : int
	for y in grid_depth:
		if pos.y + y < 0 or pos.y + y >= dims.y:
			for x in grid_width:
				i = y * grid_width + x
				multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(x - half_width, -1000, y)))
				multimesh.set_instance_transform(half_array + i, Transform3D(Basis(), Vector3(x - half_width, 1000, y)))
		else:
			for x in grid_width:
				i = y * grid_width + x
				if pos.x + x < 0 or pos.x + x >= dims.x:
					multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(x - half_width, -1000, y)))
					multimesh.set_instance_transform(half_array + i, Transform3D(Basis(), Vector3(x - half_width, 1000, y)))
				else:
					var ai : int = ((pos.y + y) * dims.x) + (pos.x + x)
					multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(0.0, floor_height[ai], 0.0)))
					multimesh.set_instance_color(i, Color(floor_top_hue[ai], floor_top_bias[ai], floor_bottom_hue[ai], floor_bottom_bias[ai]))
					multimesh.set_instance_custom_data(i, Color(floor_face_hue[ai], floor_face_bias[ai], floor_side_texture_offset[ai], floor_face_texture_offset[ai]))
					multimesh.set_instance_transform(half_array + i, Transform3D(Basis(), Vector3(0.0, ceiling_height[ai], 0.0)))
					multimesh.set_instance_color(half_array + i, Color(ceiling_top_hue[ai], ceiling_top_bias[ai], ceiling_bottom_hue[ai], ceiling_bottom_bias[ai]))
					multimesh.set_instance_custom_data(half_array + i, Color(ceiling_face_hue[ai], ceiling_face_bias[ai], ceiling_side_texture_offset[ai], ceiling_face_texture_offset[ai]))
	time = Time.get_ticks_usec() - time
	print("%d us Refresh time " % time)

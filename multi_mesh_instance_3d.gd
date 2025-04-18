extends MultiMeshInstance3D

func set_view_positions(positions : int):
	multimesh.instance_count = positions * 2

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
			 positions : Array[Vector2i],
			 pos : Vector2i):
	# color.r - top hue
	# color.g - top bias
	# color.b - bottom hue
	# color.a - bottom bias
	# custom.r - face hue
	# custom.g - face bias
	# custom.b - side texture.v
	# custom.a - face texture.v

	var time : int = Time.get_ticks_usec()
	var half_array : int = multimesh.instance_count / 2
	for i in half_array:
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(positions[i].x, floor_height[i], positions[i].y)))
		multimesh.set_instance_color(i, Color(floor_top_hue[i], floor_top_bias[i], floor_bottom_hue[i], floor_bottom_bias[i]))
		multimesh.set_instance_custom_data(i, Color(floor_face_hue[i], floor_face_bias[i], floor_side_texture_offset[i], floor_face_texture_offset[i]))
		multimesh.set_instance_transform(half_array + i, Transform3D(Basis(), Vector3(positions[i].x, ceiling_height[i], positions[i].y)))
		multimesh.set_instance_color(half_array + i, Color(ceiling_top_hue[i], ceiling_top_bias[i], ceiling_bottom_hue[i], ceiling_bottom_bias[i]))
		multimesh.set_instance_custom_data(half_array + i, Color(ceiling_face_hue[i], ceiling_face_bias[i], ceiling_side_texture_offset[i], ceiling_face_texture_offset[i]))
	time = Time.get_ticks_usec() - time
	print("%d us Refresh time " % time)

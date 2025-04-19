extends MultiMeshInstance3D

var _face_heights : Image
var _face_offsets : Image
var _face_hues_and_biases : Image
var _floor_north_south_hues : Image
var _floor_north_south_biases : Image
var _floor_east_west_hues : Image
var _floor_east_west_biases : Image
var _floor_side_texture_offsets : Image
var _ceiling_north_south_hues : Image
var _ceiling_north_south_biases : Image
var _ceiling_east_west_hues : Image
var _ceiling_east_west_biases : Image
var _ceiling_side_texture_offsets : Image
var face_heights_tex : ImageTexture
var face_offsets_tex : ImageTexture
var face_hues_and_biases_tex : ImageTexture
var floor_north_south_hues_tex : ImageTexture
var floor_north_south_biases_tex : ImageTexture
var floor_east_west_hues_tex : ImageTexture
var floor_east_west_biases_tex : ImageTexture
var floor_side_texture_offsets_tex : ImageTexture
var ceiling_north_south_hues_tex : ImageTexture
var ceiling_north_south_biases_tex : ImageTexture
var ceiling_east_west_hues_tex : ImageTexture
var ceiling_east_west_biases_tex : ImageTexture
var ceiling_side_texture_offsets_tex : ImageTexture

var _mesh : MeshInstance3D
var positions_north : ImageTexture
var positions_east : ImageTexture
var positions_south : ImageTexture
var positions_west : ImageTexture

func set_view_parameters(mesh : MeshInstance3D, fov : float, depth : int,
						 texture : CompressedTexture2D, face_heights : Image,
						 face_offsets : Image, face_hues_and_biases : Image,
						 floor_north_south_hues : Image, floor_north_south_biases : Image,
						 floor_east_west_hues : Image, floor_east_west_biases : Image,
						 floor_side_texture_offsets : Image,
						 ceiling_north_south_hues : Image, ceiling_north_south_biases : Image,
						 ceiling_east_west_hues : Image, ceiling_east_west_biases : Image,
						 ceiling_side_texture_offsets : Image):
	_mesh = mesh
	_mesh.mesh.material.set_shader_parameter(&'albedo_texture', texture)
	var positions : Array[Vector2i] = Array([], TYPE_VECTOR2I, "", null)
	var count : int = 0
	for i in depth:
		var width = ((int(ceil(atan(fov / 180 * PI) * (i + 1))) - 1) * 2) + 1
		count += width
		for j in width:
			positions.append(Vector2i(j - (width / 2), i))
	# get the smallest power of 2 it'll fit
	# probably not needed but it doesn't hurt
	var image_w : int = int(round(pow(2, ceil(log(count) / log(2)))))
	# TODO: positions may need a 0.5 bias
	var positions_north_image : Image = Image.create_empty(image_w, 1, false, Image.FORMAT_RGBAF)
	var positions_east_image : Image = Image.create_empty(image_w, 1, false, Image.FORMAT_RGBAF)
	var positions_south_image : Image = Image.create_empty(image_w, 1, false, Image.FORMAT_RGBAF)
	var positions_west_image : Image = Image.create_empty(image_w, 1, false, Image.FORMAT_RGBAF)
	for i in len(positions):
		positions_north_image.set_pixel(i, 0, Color(positions[i].x, positions[i].y, 0.0, 1.0))
		positions_east_image.set_pixel(i, 0, Color(positions[i].y, -positions[i].x, 0.0, 1.0))
		positions_south_image.set_pixel(i, 0, Color(-positions[i].x, -positions[i].y, 0.0, 1.0))
		positions_west_image.set_pixel(i, 0, Color(-positions[i].y, positions[i].x, 0.0, 1.0))
	positions_north = ImageTexture.create_from_image(positions_north_image)
	positions_east = ImageTexture.create_from_image(positions_north_image)
	positions_south = ImageTexture.create_from_image(positions_north_image)
	positions_west = ImageTexture.create_from_image(positions_north_image)
	_mesh.mesh.material.set_shader_parameter(&'world_positions', positions_north)
	_mesh.mesh.material.set_shader_parameter(&'max_depth', depth)
	_mesh.mesh.material.set_shader_parameter(&'count', count)

	multimesh.instance_count = len(positions) * 2
	for i in len(positions):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(positions[i].x, 0.0, positions[i].y)))
		multimesh.set_instance_transform(len(positions) + i, Transform3D(Basis(), Vector3(positions[i].x, 0.0, positions[i].y)))
	_face_heights = face_heights
	_face_offsets = face_offsets
	_face_hues_and_biases = face_hues_and_biases
	_floor_north_south_hues = floor_north_south_hues
	_floor_north_south_biases = floor_north_south_biases
	_floor_east_west_hues = floor_east_west_hues
	_floor_east_west_biases = floor_east_west_biases
	_floor_side_texture_offsets = floor_side_texture_offsets
	_ceiling_north_south_hues = ceiling_north_south_hues
	_ceiling_north_south_biases = ceiling_north_south_biases
	_ceiling_east_west_hues = ceiling_east_west_hues
	_ceiling_east_west_biases = ceiling_east_west_biases
	_ceiling_side_texture_offsets = ceiling_side_texture_offsets
	face_heights_tex = ImageTexture.create_from_image(face_heights)
	face_offsets_tex = ImageTexture.create_from_image(face_offsets)
	face_hues_and_biases_tex = ImageTexture.create_from_image(face_hues_and_biases)
	floor_north_south_hues_tex = ImageTexture.create_from_image(floor_north_south_hues)
	floor_north_south_biases_tex = ImageTexture.create_from_image(floor_north_south_biases)
	floor_east_west_hues_tex = ImageTexture.create_from_image(floor_east_west_hues)
	floor_east_west_biases_tex = ImageTexture.create_from_image(floor_east_west_biases)
	floor_side_texture_offsets_tex = ImageTexture.create_from_image(floor_side_texture_offsets)
	ceiling_north_south_hues_tex = ImageTexture.create_from_image(ceiling_north_south_hues)
	ceiling_north_south_biases_tex = ImageTexture.create_from_image(ceiling_north_south_biases)
	ceiling_east_west_hues_tex = ImageTexture.create_from_image(ceiling_east_west_hues)
	ceiling_east_west_biases_tex = ImageTexture.create_from_image(ceiling_east_west_biases)
	ceiling_side_texture_offsets_tex = ImageTexture.create_from_image(ceiling_side_texture_offsets)
	_mesh.mesh.material.set_shader_parameter(&'face_heights', face_heights_tex)
	_mesh.mesh.material.set_shader_parameter(&'face_offsets', face_offsets_tex)
	_mesh.mesh.material.set_shader_parameter(&'face_hues_and_biases',
											face_hues_and_biases_tex)
	_mesh.mesh.material.set_shader_parameter(&'face_hues_and_biases',
											face_hues_and_biases_tex)
	_mesh.mesh.material.set_shader_parameter(&'floor_north_south_hues',
											floor_north_south_hues_tex)
	_mesh.mesh.material.set_shader_parameter(&'floor_north_south_biases',
											floor_north_south_biases_tex)
	_mesh.mesh.material.set_shader_parameter(&'floor_east_west_hues',
											floor_east_west_hues_tex)
	_mesh.mesh.material.set_shader_parameter(&'floor_east_west_biases',
											floor_east_west_biases_tex)
	_mesh.mesh.material.set_shader_parameter(&'floor_side_texture_offsets',
											floor_side_texture_offsets_tex)
	_mesh.mesh.material.set_shader_parameter(&'ceiling_north_south_hues',
											ceiling_north_south_hues_tex)
	_mesh.mesh.material.set_shader_parameter(&'ceiling_north_south_biases',
											ceiling_north_south_biases_tex)
	_mesh.mesh.material.set_shader_parameter(&'ceiling_east_west_hues',
											ceiling_east_west_hues_tex)
	_mesh.mesh.material.set_shader_parameter(&'ceiling_east_west_biases',
											ceiling_east_west_biases_tex)
	_mesh.mesh.material.set_shader_parameter(&'ceiling_side_texture_offsets',
											ceiling_side_texture_offsets_tex)

func refresh(face_heights : Image, face_offsets : Image,
			 face_hues_and_biases : Image,
			 floor_north_south_hues : Image, floor_north_south_biases : Image,
			 floor_east_west_hues : Image, floor_east_west_biases : Image,
			 floor_side_texture_offsets : Image,
			 ceiling_north_south_hues : Image, ceiling_north_south_biases : Image,
			 ceiling_east_west_hues : Image, ceiling_east_west_biases : Image,
			 ceiling_side_texture_offsets : Image,
			 pos : Vector2i, dir : int):
	# TODO: texture updates

	_mesh.mesh.material.set_shader_parameter(&'view_pos', pos)

	match dir:
		0:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_north)
		0:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_east)
		0:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_south)
		_:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_west)

extends MultiMeshInstance3D

# just some random "safe" value
const LOOKUP_TEX_WIDTH : int = 1024

var max_depth : int

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
var transform_north : Basis = Basis(Vector3(0.0, 1.0, 0.0), 0.0)
var transform_east : Basis = Basis(Vector3(0.0, 1.0, 0.0), PI * 0.5)
var transform_south : Basis = Basis(Vector3(0.0, 1.0, 0.0), PI)
var transform_west : Basis = Basis(Vector3(0.0, 1.0, 0.0), PI * 1.5)

var depth_counts : Array[int] = Array([], TYPE_INT, "", null)

func set_view_parameters(mesh : MeshInstance3D, fov : float, depth : int, eye_height : float,
						 fog_power : float, fog_color : Color,
						 texture : CompressedTexture2D, face_heights : Image,
						 face_offsets : Image, face_hues_and_biases : Image,
						 floor_north_south_hues : Image, floor_north_south_biases : Image,
						 floor_east_west_hues : Image, floor_east_west_biases : Image,
						 floor_side_texture_offsets : Image,
						 ceiling_north_south_hues : Image, ceiling_north_south_biases : Image,
						 ceiling_east_west_hues : Image, ceiling_east_west_biases : Image,
						 ceiling_side_texture_offsets : Image):
	max_depth = depth
	depth_counts.resize(max_depth)
	_mesh = mesh
	_mesh.mesh.material.set_shader_parameter(&'albedo_texture', texture)
	var positions : Array[Vector2i] = Array([], TYPE_VECTOR2I, "", null)
	var count : int = 0
	for i in max_depth:
		var width = ((int(ceil(atan(fov / 180 * PI) * (i + 1))) - 1) * 2) + 1
		count += width
		depth_counts[i] = count
		for j in width:
			positions.append(Vector2i(j - (width / 2), i))
	var lookup_height : int = count / LOOKUP_TEX_WIDTH;
	if count % LOOKUP_TEX_WIDTH > 0:
		lookup_height += 1

	# get the smallest power of 2 it'll fit
	# probably not needed but it doesn't hurt
	var image_h : int = int(round(pow(2, ceil(log(lookup_height) / log(2)))))
	var positions_north_image : Image = Image.create_empty(LOOKUP_TEX_WIDTH, image_h, false, Image.FORMAT_RGBAF)
	var positions_east_image : Image = Image.create_empty(LOOKUP_TEX_WIDTH, image_h, false, Image.FORMAT_RGBAF)
	var positions_south_image : Image = Image.create_empty(LOOKUP_TEX_WIDTH, image_h, false, Image.FORMAT_RGBAF)
	var positions_west_image : Image = Image.create_empty(LOOKUP_TEX_WIDTH, image_h, false, Image.FORMAT_RGBAF)
	for i in len(positions):
		positions_north_image.set_pixel(i % LOOKUP_TEX_WIDTH,
										i / LOOKUP_TEX_WIDTH,
										Color(-positions[i].x, -positions[i].y, 0.0, 1.0))
		positions_east_image.set_pixel(i % LOOKUP_TEX_WIDTH,
									   i / LOOKUP_TEX_WIDTH,
									   Color(positions[i].y, -positions[i].x, 0.0, 1.0))
		positions_south_image.set_pixel(i % LOOKUP_TEX_WIDTH,
										i / LOOKUP_TEX_WIDTH,
										Color(positions[i].x, positions[i].y, 0.0, 1.0))
		positions_west_image.set_pixel(i % LOOKUP_TEX_WIDTH,
									   i / LOOKUP_TEX_WIDTH,
									   Color(-positions[i].y, positions[i].x, 0.0, 1.0))
	positions_north = ImageTexture.create_from_image(positions_north_image)
	positions_east = ImageTexture.create_from_image(positions_east_image)
	positions_south = ImageTexture.create_from_image(positions_south_image)
	positions_west = ImageTexture.create_from_image(positions_west_image)
	_mesh.mesh.material.set_shader_parameter(&'world_positions', positions_north)
	_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_north)
	_mesh.mesh.material.set_shader_parameter(&'mesh_transform', transform_north)
	_mesh.mesh.material.set_shader_parameter(&'max_depth', max_depth)
	_mesh.mesh.material.set_shader_parameter(&'count', count)
	_mesh.mesh.material.set_shader_parameter(&'view_height_bias', eye_height)
	_mesh.mesh.material.set_shader_parameter(&'lookup_tex_width', LOOKUP_TEX_WIDTH)
	_mesh.mesh.material.set_shader_parameter(&'fog_power', fog_power)
	_mesh.mesh.material.set_shader_parameter(&'fog_color', fog_color)

	multimesh.instance_count = len(positions) * 2
	for i in len(positions):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(positions[i].x, 0.0, positions[i].y)))
		multimesh.set_instance_transform(len(positions) + i, Transform3D(Basis(), Vector3(positions[i].x, 0.0, positions[i].y)))
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

func update(face_heights : Image, face_offsets : Image,
			face_hues_and_biases : Image,
			floor_north_south_hues : Image, floor_north_south_biases : Image,
			floor_east_west_hues : Image, floor_east_west_biases : Image,
			floor_side_texture_offsets : Image,
			ceiling_north_south_hues : Image, ceiling_north_south_biases : Image,
			ceiling_east_west_hues : Image, ceiling_east_west_biases : Image,
			ceiling_side_texture_offsets : Image):
	# TODO: figure out some way that isn't a full texture upload to update these
	if face_heights != null:
		face_heights_tex.update(face_heights)
	if face_offsets != null:
		face_offsets_tex.update(face_offsets)
	if face_hues_and_biases != null:
		face_hues_and_biases_tex.update(face_hues_and_biases)
	if floor_north_south_hues != null:
		floor_north_south_hues_tex.update(floor_north_south_hues)
	if floor_north_south_biases != null:
		floor_north_south_biases_tex.update(floor_north_south_biases)
	if floor_east_west_hues != null:
		floor_east_west_hues_tex.update(floor_east_west_hues)
	if floor_east_west_biases != null:
		floor_east_west_biases_tex.update(floor_east_west_biases)
	if floor_side_texture_offsets != null:
		floor_side_texture_offsets_tex.update(floor_side_texture_offsets)
	if ceiling_north_south_hues != null:
		ceiling_north_south_hues_tex.update(ceiling_north_south_hues)
	if ceiling_north_south_biases != null:
		ceiling_north_south_biases_tex.update(ceiling_north_south_biases)
	if ceiling_east_west_hues != null:
		ceiling_east_west_hues_tex.update(ceiling_east_west_hues)
	if ceiling_east_west_biases != null:
		ceiling_east_west_biases_tex.update(ceiling_east_west_biases)
	if ceiling_side_texture_offsets != null:
		ceiling_side_texture_offsets_tex.update(ceiling_side_texture_offsets)

func set_pos(pos : Vector2i):
	_mesh.mesh.material.set_shader_parameter(&'view_pos', pos)

func set_dir(dir : int):
	match dir:
		0:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_north)
			_mesh.mesh.material.set_shader_parameter(&'mesh_transform', transform_north)
		1:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_east)
			_mesh.mesh.material.set_shader_parameter(&'mesh_transform', transform_east)
		2:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_south)
			_mesh.mesh.material.set_shader_parameter(&'mesh_transform', transform_south)
		_:
			_mesh.mesh.material.set_shader_parameter(&'map_positions', positions_west)
			_mesh.mesh.material.set_shader_parameter(&'mesh_transform', transform_west)

func set_view_height(height : float):
	_mesh.mesh.material.set_shader_parameter(&'view_height_bias', height)

func set_depth(depth : float):
	depth = min(depth, max_depth)
	_mesh.mesh.material.set_shader_parameter(&'max_depth', depth)
	_mesh.mesh.material.set_shader_parameter(&'count', depth_counts[depth])

func set_fog_power(val : float):
	_mesh.mesh.material.set_shader_parameter(&'fog_power', val)

func set_fog_color(val : Color):
	_mesh.mesh.material.set_shader_parameter(&'fog_color', val)

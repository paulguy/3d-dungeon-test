extends MultiMeshInstance3D

# just some random "safe" value
const LOOKUP_TEX_WIDTH : int = 1024

var max_depth : int = 0

var images : Dictionary[StringName, Image]
var textures : Dictionary[StringName, ImageTexture]

var _mesh : Mesh
var positions_north : ImageTexture
var positions_east : ImageTexture
var positions_south : ImageTexture
var positions_west : ImageTexture
var transform_north : Basis = Basis(Vector3(0.0, 1.0, 0.0), 0.0)
var transform_east : Basis = Basis(Vector3(0.0, 1.0, 0.0), PI * 0.5)
var transform_south : Basis = Basis(Vector3(0.0, 1.0, 0.0), PI)
var transform_west : Basis = Basis(Vector3(0.0, 1.0, 0.0), PI * 1.5)

var depth_counts : Array[int] = Array([], TYPE_INT, "", null)

func _ready():
	_mesh = multimesh.mesh

func set_texture(texture : Texture2D):
	_mesh.material.set_shader_parameter(&'albedo_texture', texture)

func set_view(depth : int, fov : float):
	if max_depth == 0:
		max_depth = depth
		depth_counts.resize(max_depth)
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
		_mesh.material.set_shader_parameter(&'world_positions', positions_north)
		_mesh.material.set_shader_parameter(&'lookup_tex_width', LOOKUP_TEX_WIDTH)

		multimesh.instance_count = len(positions) * 2
		for i in len(positions):
			multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(positions[i].x, 0.0, positions[i].y)))
			multimesh.set_instance_transform(len(positions) + i, Transform3D(Basis(), Vector3(positions[i].x, 0.0, positions[i].y)))
	else:
		depth = min(depth, max_depth)

	_mesh.material.set_shader_parameter(&'max_depth', depth)
	_mesh.material.set_shader_parameter(&'count', depth_counts[depth - 1])

func set_image(image_name : StringName, image : Image):
	if image_name not in images:
		images[image_name] = image
		textures[image_name] = ImageTexture.create_from_image(image)
		_mesh.material.set_shader_parameter(image_name, textures[image_name])
	else:
		if image != images[image_name]:
			textures[image_name].set_image(image)
			images[image_name] = image
		else:
			textures[image_name].update(image)

func set_map(face_heights : Image, face_offsets : Image,
			 face_hues_and_biases : Image,
			 floor_north_south_hues : Image, floor_north_south_biases : Image,
			 floor_east_west_hues : Image, floor_east_west_biases : Image,
			 floor_side_texture_offsets : Image,
			 ceiling_north_south_hues : Image, ceiling_north_south_biases : Image,
			 ceiling_east_west_hues : Image, ceiling_east_west_biases : Image,
			 ceiling_side_texture_offsets : Image):
	set_image(&'face_heights', face_heights)
	set_image(&'face_offsets', face_offsets)
	set_image(&'face_hues_and_biases', face_hues_and_biases)
	set_image(&'floor_north_south_hues', floor_north_south_hues)
	set_image(&'floor_north_south_biases', floor_north_south_biases)
	set_image(&'floor_east_west_hues', floor_east_west_hues)
	set_image(&'floor_east_west_biases', floor_east_west_biases)
	set_image(&'floor_side_texture_offsets', floor_side_texture_offsets)
	set_image(&'ceiling_north_south_hues', ceiling_north_south_hues)
	set_image(&'ceiling_north_south_biases', ceiling_north_south_biases)
	set_image(&'ceiling_east_west_hues', ceiling_east_west_hues)
	set_image(&'ceiling_east_west_biases', ceiling_east_west_biases)
	set_image(&'ceiling_side_texture_offsets', ceiling_side_texture_offsets)

func set_eye_height(eye_height : float):
	_mesh.material.set_shader_parameter(&'eye_height', eye_height)

func set_fog_color(val : Color):
	_mesh.material.set_shader_parameter(&'fog_color', val)

func set_fog_power(val : float):
	_mesh.material.set_shader_parameter(&'fog_power', val)

func set_pos(pos : Vector2i):
	_mesh.material.set_shader_parameter(&'view_pos', pos)

func set_dir(dir : int):
	match dir:
		0:
			_mesh.material.set_shader_parameter(&'map_positions', positions_north)
			_mesh.material.set_shader_parameter(&'mesh_transform', transform_north)
		1:
			_mesh.material.set_shader_parameter(&'map_positions', positions_east)
			_mesh.material.set_shader_parameter(&'mesh_transform', transform_east)
		2:
			_mesh.material.set_shader_parameter(&'map_positions', positions_south)
			_mesh.material.set_shader_parameter(&'mesh_transform', transform_south)
		_:
			_mesh.material.set_shader_parameter(&'map_positions', positions_west)
			_mesh.material.set_shader_parameter(&'mesh_transform', transform_west)

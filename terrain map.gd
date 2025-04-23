extends Node3D

@onready var terrain : MultiMeshInstance3D = $'Terrain Multimesh'

var face_heights : Image
var face_offsets : Image
var face_hues_and_biases : Image
var floor_north_south_hues : Image
var floor_north_south_biases : Image
var floor_east_west_hues : Image
var floor_east_west_biases : Image
var floor_side_texture_offsets : Image
var ceiling_north_south_hues : Image
var ceiling_north_south_biases : Image
var ceiling_east_west_hues : Image
var ceiling_east_west_biases : Image
var ceiling_side_texture_offsets : Image

func clear_init(_face_heights : Image, _face_offsets : Image,
				_face_hues_and_biases : Image,
				_floor_north_south_hues : Image, _floor_north_south_biases : Image,
				_floor_east_west_hues : Image, _floor_east_west_biases : Image,
				_floor_side_texture_offsets : Image,
				_ceiling_north_south_hues : Image, _ceiling_north_south_biases : Image,
				_ceiling_east_west_hues : Image, _ceiling_east_west_biases : Image,
				_ceiling_side_texture_offsets : Image):
	_face_heights.fill(Color(2.0, 1.0, 0.0, -1.0))
	_face_offsets.fill(Color(0.0, 0.0, 0.0, 0.0))
	_face_hues_and_biases.fill(Color(0.0, 1.0, 0.0, 1.0))
	_floor_side_texture_offsets.fill(Color(1.0, 1.0, 1.0, 1.0))
	_floor_north_south_hues.fill(Color(0.0, 0.0, 0.0, 0.0))
	_floor_north_south_biases.fill(Color(1.0, 1.0, 1.0, 1.0))
	_floor_east_west_hues.fill(Color(0.0, 0.0, 0.0, 0.0))
	_floor_east_west_biases.fill(Color(1.0, 1.0, 1.0, 1.0))
	_ceiling_north_south_hues.fill(Color(0.0, 0.0, 0.0, 0.0))
	_ceiling_north_south_biases.fill(Color(1.0, 1.0, 1.0, 1.0))
	_ceiling_east_west_hues.fill(Color(0.0, 0.0, 0.0, 0.0))
	_ceiling_east_west_biases.fill(Color(1.0, 1.0, 1.0, 1.0))
	_ceiling_side_texture_offsets.fill(Color(3.0, 3.0, 3.0, 3.0))

func test_init(width : int, height : int,
			   _face_heights : Image, _face_offsets : Image,
			   _face_hues_and_biases : Image,
			   _floor_north_south_hues : Image, _floor_north_south_biases : Image,
			   _floor_east_west_hues : Image, _floor_east_west_biases : Image,
			   _floor_side_texture_offsets : Image,
			   _ceiling_north_south_hues : Image, _ceiling_north_south_biases : Image,
			   _ceiling_east_west_hues : Image, _ceiling_east_west_biases : Image,
			   _ceiling_side_texture_offsets : Image):
	_floor_side_texture_offsets.fill(Color(1.0, 0.0, 1.0, 3.0))
	_floor_north_south_hues.fill(Color(0.2, 0.4, 0.6, 0.8))
	_floor_north_south_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	_floor_east_west_hues.fill(Color(0.1, 0.3, 0.5, 0.7))
	_floor_east_west_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	_ceiling_north_south_hues.fill(Color(0.5, 0.6, 0.8, 1.0))
	_ceiling_north_south_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	_ceiling_east_west_hues.fill(Color(0.3, 0.5, 0.7, 0.9))
	_ceiling_east_west_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	_ceiling_side_texture_offsets.fill(Color(0.0, 2.0, 3.0, 2.0))
	_face_offsets.fill(Color(0.0, 3.0, 0.0, 0.0))

	for y in width:
		for x in height:
			var div : float = ((y * width) + x) % 2 + 1
			_face_hues_and_biases.set_pixel(x, y, Color(0.5,
														0.5 / div,
														0.0,
														1.0 / div))
			_face_heights.set_pixel(x, y, Color(21.0,
												(sin(x / 10.0) * cos(y / 10.0)) * 10.0 + 10.5,
												-(sin(x / 10.0) * cos(y / 10.0)) * 10.0 - 10.5,
												-21.0))

func rescale_colors(width : int, height : int,
					_face_heights : Image,
					_face_hues_and_biases : Image,
					_floor_north_south_hues : Image,
					_floor_north_south_biases : Image,
					_floor_east_west_hues : Image,
					_floor_east_west_biases : Image,
					_ceiling_north_south_hues : Image,
					_ceiling_north_south_biases : Image,
					_ceiling_east_west_hues : Image,
					_ceiling_east_west_biases : Image):
	# this function is for testing and throws a lot of out of bounds errors.
	# it's not super useful on its own but parts of it can be useful later.
	for y in width:
		for x in height:
			var heights : Color = _face_heights.get_pixel(x, y)
			var n_height : Color = _face_heights.get_pixel(x, y - 1)
			var e_height : Color = _face_heights.get_pixel(x + 1, y)
			var s_height : Color = _face_heights.get_pixel(x, y + 1)
			var w_height : Color = _face_heights.get_pixel(x - 1, y)
			var f_ns_hue : Color = _floor_north_south_hues.get_pixel(x, y)
			var f_ns_bias : Color = _floor_north_south_biases.get_pixel(x, y)
			var f_ew_hue : Color = _floor_east_west_hues.get_pixel(x, y)
			var f_ew_bias : Color = _floor_east_west_biases.get_pixel(x, y)
			var c_ns_hue : Color = _ceiling_north_south_hues.get_pixel(x, y)
			var c_ns_bias : Color = _ceiling_north_south_biases.get_pixel(x, y)
			var c_ew_hue : Color = _ceiling_east_west_hues.get_pixel(x, y)
			var c_ew_bias : Color = _ceiling_east_west_biases.get_pixel(x, y)

			f_ns_hue.g = f_ns_hue.r + ((f_ns_hue.g - f_ns_hue.r) * ((heights.b - heights.a) / (n_height.b - heights.b)))
			f_ns_hue.a = f_ns_hue.b + ((f_ns_hue.a - f_ns_hue.b) * ((heights.b - heights.a) / (s_height.b - heights.b)))
			_floor_north_south_hues.set_pixel(x, y, f_ns_hue)
			f_ns_bias.g = f_ns_bias.r + ((f_ns_bias.g - f_ns_bias.r) * ((heights.b - heights.a) / (n_height.b - heights.b)))
			f_ns_bias.a = f_ns_bias.b + ((f_ns_bias.a - f_ns_bias.b) * ((heights.b - heights.a) / (s_height.b - heights.b)))
			_floor_north_south_biases.set_pixel(x, y, f_ns_bias)
			f_ew_hue.g = f_ew_hue.r + ((f_ew_hue.g - f_ew_hue.r) * ((heights.b - heights.a) / (e_height.b - heights.b)))
			f_ew_hue.a = f_ew_hue.b + ((f_ew_hue.a - f_ew_hue.b) * ((heights.b - heights.a) / (w_height.b - heights.b)))
			_floor_east_west_hues.set_pixel(x, y, f_ew_hue)
			f_ew_bias.g = f_ew_bias.r + ((f_ew_bias.g - f_ew_bias.r) * ((heights.b - heights.a) / (e_height.b - heights.b)))
			f_ew_bias.a = f_ew_bias.b + ((f_ew_bias.a - f_ew_bias.b) * ((heights.b - heights.a) / (w_height.b - heights.b)))
			_floor_east_west_biases.set_pixel(x, y, f_ew_bias)
			c_ns_hue.r = c_ns_hue.g + ((c_ns_hue.r - c_ns_hue.g) * ((heights.r - heights.g) / (heights.g - n_height.g)))
			c_ns_hue.b = c_ns_hue.a + ((c_ns_hue.b - c_ns_hue.a) * ((heights.r - heights.g) / (heights.g - s_height.g)))
			_ceiling_north_south_hues.set_pixel(x, y, c_ns_hue)
			c_ns_bias.r = c_ns_bias.g + ((c_ns_bias.r - c_ns_bias.g) * ((heights.r - heights.g) / (heights.g - n_height.g)))
			c_ns_bias.b = c_ns_bias.a + ((c_ns_bias.b - c_ns_bias.a) * ((heights.r - heights.g) / (heights.g - s_height.g)))
			_ceiling_north_south_biases.set_pixel(x, y, c_ns_bias)
			c_ew_hue.r = c_ew_hue.g + ((c_ew_hue.r - c_ew_hue.g) * ((heights.r - heights.g) / (heights.g - e_height.g)))
			c_ew_hue.b = c_ew_hue.a + ((c_ew_hue.b - c_ew_hue.a) * ((heights.r - heights.g) / (heights.g - w_height.g)))
			_ceiling_east_west_hues.set_pixel(x, y, c_ew_hue)
			c_ew_bias.r = c_ew_bias.g + ((c_ew_bias.r - c_ew_bias.g) * ((heights.r - heights.g) / (heights.g - e_height.g)))
			c_ew_bias.b = c_ew_bias.a + ((c_ew_bias.b - c_ew_bias.a) * ((heights.r - heights.g) / (heights.g - w_height.g)))
			_ceiling_east_west_biases.set_pixel(x, y, c_ew_bias)

func init_empty_world(width : int, height : int, fov : int,
					  eye_height : int, max_depth : int,
					  fog_power : float, fog_color : Color):
	face_heights = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	face_offsets = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	face_hues_and_biases = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	floor_north_south_hues = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	floor_north_south_biases = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	floor_east_west_hues = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	floor_east_west_biases = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	floor_side_texture_offsets = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	ceiling_north_south_hues = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	ceiling_north_south_biases = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	ceiling_east_west_hues = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	ceiling_east_west_biases = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)
	ceiling_side_texture_offsets = Image.create_empty(width, height, false, Image.FORMAT_RGBAF)

	clear_init(face_heights,
			   face_offsets,
			   face_hues_and_biases,
			   floor_north_south_hues,
			   floor_north_south_biases,
			   floor_east_west_hues,
			   floor_east_west_biases,
			   floor_side_texture_offsets,
			   ceiling_north_south_hues,
			   ceiling_north_south_biases,
			   ceiling_east_west_hues,
			   ceiling_east_west_biases,
			   ceiling_side_texture_offsets)

	terrain.set_view_parameters($'Pillar', fov, max_depth, eye_height,
								fog_power, fog_color,
								load("res://textures.png"),
								face_heights,
								face_offsets,
								face_hues_and_biases,
								floor_north_south_hues,
								floor_north_south_biases,
								floor_east_west_hues,
								floor_east_west_biases,
								floor_side_texture_offsets,
								ceiling_north_south_hues,
								ceiling_north_south_biases,
								ceiling_east_west_hues,
								ceiling_east_west_biases,
								ceiling_side_texture_offsets)

func set_pos(pos):
	terrain.set_pos(pos)

func set_dir(dir):
	terrain.set_dir(dir)

func set_view_height(height):
	terrain.set_view_height(height)

# properties
# heights
#  ceiling top
#  ceiling bottom
#  floor top
#  floor bottom
# hues
#  top face
#  bottom face
#  ceiling north top
#  ceiling north bottom
#  ceiling east top
#  ceiling east bottom
#  ceiling south top
#  ceiling south bottom
#  ceiling west top
#  ceiling west bottom
#  floor north top
#  floor north bottom
#  floor east top
#  floor east bottom
#  floor south top
#  floor south bottom
#  floor west top
#  floor west bottom
# color biases
#  top face
#  bottom face
#  ceiling north top
#  ceiling north bottom
#  ceiling east top
#  ceiling east bottom
#  ceiling south top
#  ceiling south bottom
#  ceiling west top
#  ceiling west bottom
#  floor north top
#  floor north bottom
#  floor east top
#  floor east bottom
#  floor south top
#  floor south bottom
#  floor west top
#  floor west bottom
# texture offsets
#  top face
#  bottom face
#  ceiling north top
#  ceiling north bottom
#  ceiling east top
#  ceiling east bottom
#  ceiling south top
#  ceiling south bottom
#  ceiling west top
#  ceiling west bottom
#  floor north top
#  floor north bottom
#  floor east top
#  floor east bottom
#  floor south top
#  floor south bottom
#  floor west top
#  floor west bottom

func change_ceiling_top_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.r += val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func change_ceiling_bottom_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.g += val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func change_floor_top_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.b += val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func change_floor_bottom_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.a += val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func change_ceiling_top_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.r += val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func change_ceiling_bottom_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.g += val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func change_floor_top_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.b += val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func change_floor_bottom_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.a += val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func change_top_hue(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.r += val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func change_top_bias(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.g += val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func change_bottom_hue(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.b += val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func change_bottom_bias(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.a += val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func change_floor_north_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.r += val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func change_floor_north_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.g += val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func change_floor_south_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.b += val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func change_floor_south_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.a += val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func change_floor_north_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.r += val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func change_floor_north_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.g += val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func change_floor_south_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.b += val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func change_floor_south_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.a += val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func change_floor_east_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.r += val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func change_floor_east_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.g += val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func change_floor_west_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.b += val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func change_floor_west_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.a += val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func change_floor_east_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.r += val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func change_floor_east_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.g += val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func change_floor_west_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.b += val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func change_floor_west_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.a += val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func change_floor_north_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.r += val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func change_floor_east_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.g += val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func change_floor_south_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.b += val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func change_floor_west_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.a += val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func change_ceiling_north_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.r += val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func change_ceiling_north_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.g += val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func change_ceiling_south_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.b += val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func change_ceiling_south_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.a += val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func change_ceiling_north_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.r += val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func change_ceiling_north_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.g += val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func change_ceiling_south_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.b += val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func change_ceiling_south_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.a += val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func change_ceiling_east_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.r += val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func change_ceiling_east_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.g += val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func change_ceiling_west_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.b += val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func change_ceiling_west_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.a += val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func change_ceiling_east_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.r += val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func change_ceiling_east_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.g += val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func change_ceiling_west_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.b += val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func change_ceiling_west_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.a += val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func change_ceiling_north_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.r += val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func change_ceiling_east_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.g += val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func change_ceiling_south_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.b += val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func change_ceiling_west_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.a += val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func set_ceiling_top_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.r = val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func set_ceiling_bottom_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.g = val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func set_floor_top_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.b = val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func set_floor_bottom_height(pos : Vector2i, val : float):
	var col : Color = face_heights.get_pixelv(pos)
	col.a = val
	face_heights.set_pixelv(pos, col)
	terrain.update(face_heights,
				   null, null, null, null, null, null, null, null, null, null, null, null)

func set_ceiling_top_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.r = val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func set_ceiling_bottom_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.g = val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func set_floor_top_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.b = val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func set_floor_bottom_offset(pos : Vector2i, val : float):
	var col : Color = face_offsets.get_pixelv(pos)
	col.a = val
	face_offsets.set_pixelv(pos, col)
	terrain.update(null,
				   face_offsets,
				   null, null, null, null, null, null, null, null, null, null, null)

func set_top_hue(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.r = val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func set_top_bias(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.g = val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func set_bottom_hue(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.b = val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func set_bottom_bias(pos : Vector2i, val : float):
	var col : Color = face_hues_and_biases.get_pixelv(pos)
	col.a = val
	face_hues_and_biases.set_pixelv(pos, col)
	terrain.update(null, null,
				   face_hues_and_biases,
				   null, null, null, null, null, null, null, null, null, null)

func set_floor_north_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.r = val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func set_floor_north_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.g = val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func set_floor_south_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.b = val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func set_floor_south_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_north_south_hues.get_pixelv(pos)
	col.a = val
	floor_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null,
				   floor_north_south_hues,
				   null, null, null, null, null, null, null, null, null)

func set_floor_north_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.r = val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func set_floor_north_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.g = val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func set_floor_south_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.b = val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func set_floor_south_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_north_south_biases.get_pixelv(pos)
	col.a = val
	floor_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null,
				   floor_north_south_biases,
				   null, null, null, null, null, null, null, null)

func set_floor_east_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.r = val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func set_floor_east_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.g = val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func set_floor_west_top_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.b = val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func set_floor_west_bottom_hue(pos : Vector2i, val : float):
	var col : Color = floor_east_west_hues.get_pixelv(pos)
	col.a = val
	floor_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null,
				   floor_east_west_hues,
				   null, null, null, null, null, null, null)

func set_floor_east_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.r = val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func set_floor_east_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.g = val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func set_floor_west_top_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.b = val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func set_floor_west_bottom_bias(pos : Vector2i, val : float):
	var col : Color = floor_east_west_biases.get_pixelv(pos)
	col.a = val
	floor_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null,
				   floor_east_west_biases,
				   null, null, null, null, null, null)

func set_floor_north_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.r = val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func set_floor_east_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.g = val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func set_floor_south_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.b = val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func set_floor_west_offset(pos : Vector2i, val : float):
	var col : Color = floor_side_texture_offsets.get_pixelv(pos)
	col.a = val
	floor_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null,
				   floor_side_texture_offsets,
				   null, null, null, null, null)

func set_ceiling_north_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.r = val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func set_ceiling_north_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.g = val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func set_ceiling_south_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.b = val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func set_ceiling_south_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_hues.get_pixelv(pos)
	col.a = val
	ceiling_north_south_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null,
				   ceiling_north_south_hues,
				   null, null, null, null)

func set_ceiling_north_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.r = val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func set_ceiling_north_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.g = val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func set_ceiling_south_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.b = val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func set_ceiling_south_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_north_south_biases.get_pixelv(pos)
	col.a = val
	ceiling_north_south_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null,
				   ceiling_north_south_biases,
				   null, null, null)

func set_ceiling_east_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.r = val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func set_ceiling_east_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.g = val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func set_ceiling_west_top_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.b = val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func set_ceiling_west_bottom_hue(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_hues.get_pixelv(pos)
	col.a = val
	ceiling_east_west_hues.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_hues,
				   null, null)

func set_ceiling_east_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.r = val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func set_ceiling_east_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.g = val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func set_ceiling_west_top_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.b = val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func set_ceiling_west_bottom_bias(pos : Vector2i, val : float):
	var col : Color = ceiling_east_west_biases.get_pixelv(pos)
	col.a = val
	ceiling_east_west_biases.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_east_west_biases,
				   null)

func set_ceiling_north_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.r = val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func set_ceiling_east_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.g = val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func set_ceiling_south_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.b = val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func set_ceiling_west_offset(pos : Vector2i, val : float):
	var col : Color = ceiling_side_texture_offsets.get_pixelv(pos)
	col.a = val
	ceiling_side_texture_offsets.set_pixelv(pos, col)
	terrain.update(null, null, null, null, null, null, null, null, null, null, null, null,
				   ceiling_side_texture_offsets)

func get_ceiling_top_height(pos : Vector2i) -> float:
	return face_heights.get_pixelv(pos).r

func get_ceiling_bottom_height(pos : Vector2i) -> float:
	return face_heights.get_pixelv(pos).g

func get_floor_top_height(pos : Vector2i) -> float:
	return face_heights.get_pixelv(pos).b

func get_floor_bottom_height(pos : Vector2i) -> float:
	return face_heights.get_pixelv(pos).a

func get_ceiling_top_offset(pos : Vector2i) -> float:
	return face_offsets.get_pixelv(pos).r

func get_ceiling_bottom_offset(pos : Vector2i) -> float:
	return face_offsets.get_pixelv(pos).g

func get_floor_top_offset(pos : Vector2i) -> float:
	return face_offsets.get_pixelv(pos).b

func get_floor_bottom_offset(pos : Vector2i) -> float:
	return face_offsets.get_pixelv(pos).a

func get_top_hue(pos : Vector2i) -> float:
	return face_hues_and_biases.get_pixelv(pos).r

func get_top_bias(pos : Vector2i) -> float:
	return face_hues_and_biases.get_pixelv(pos).g

func get_bottom_hue(pos : Vector2i) -> float:
	return face_hues_and_biases.get_pixelv(pos).b

func get_bottom_bias(pos : Vector2i) -> float:
	return face_hues_and_biases.get_pixelv(pos).a

func get_floor_north_top_hue(pos : Vector2i) -> float:
	return floor_north_south_hues.get_pixelv(pos).r

func get_floor_north_bottom_hue(pos : Vector2i) -> float:
	return floor_north_south_hues.get_pixelv(pos).g

func get_floor_south_top_hue(pos : Vector2i) -> float:
	return floor_north_south_hues.get_pixelv(pos).b

func get_floor_south_bottom_hue(pos : Vector2i) -> float:
	return floor_north_south_hues.get_pixelv(pos).a

func get_floor_north_top_bias(pos : Vector2i) -> float:
	return floor_north_south_biases.get_pixelv(pos).r

func get_floor_north_bottom_bias(pos : Vector2i) -> float:
	return floor_north_south_biases.get_pixelv(pos).g

func get_floor_south_top_bias(pos : Vector2i) -> float:
	return floor_north_south_biases.get_pixelv(pos).b

func get_floor_south_bottom_bias(pos : Vector2i) -> float:
	return floor_north_south_biases.get_pixelv(pos).a

func get_floor_east_top_hue(pos : Vector2i) -> float:
	return floor_east_west_hues.get_pixelv(pos).r

func get_floor_east_bottom_hue(pos : Vector2i) -> float:
	return floor_east_west_hues.get_pixelv(pos).g

func get_floor_west_top_hue(pos : Vector2i) -> float:
	return floor_east_west_hues.get_pixelv(pos).b

func get_floor_west_bottom_hue(pos : Vector2i) -> float:
	return floor_east_west_hues.get_pixelv(pos).a

func get_floor_east_top_bias(pos : Vector2i) -> float:
	return floor_east_west_biases.get_pixelv(pos).r

func get_floor_east_bottom_bias(pos : Vector2i) -> float:
	return floor_east_west_biases.get_pixelv(pos).g

func get_floor_west_top_bias(pos : Vector2i) -> float:
	return floor_east_west_biases.get_pixelv(pos).b

func get_floor_west_bottom_bias(pos : Vector2i) -> float:
	return floor_east_west_biases.get_pixelv(pos).a

func get_floor_north_offset(pos : Vector2i) -> float:
	return floor_side_texture_offsets.get_pixelv(pos).r

func get_floor_east_offset(pos : Vector2i) -> float:
	return floor_side_texture_offsets.get_pixelv(pos).g

func get_floor_south_offset(pos : Vector2i) -> float:
	return floor_side_texture_offsets.get_pixelv(pos).b

func get_floor_west_offset(pos : Vector2i) -> float:
	return floor_side_texture_offsets.get_pixelv(pos).a

func get_ceiling_north_top_hue(pos : Vector2i) -> float:
	return ceiling_north_south_hues.get_pixelv(pos).r

func get_ceiling_north_bottom_hue(pos : Vector2i) -> float:
	return ceiling_north_south_hues.get_pixelv(pos).g

func get_ceiling_south_top_hue(pos : Vector2i) -> float:
	return ceiling_north_south_hues.get_pixelv(pos).b

func get_ceiling_south_bottom_hue(pos : Vector2i) -> float:
	return ceiling_north_south_hues.get_pixelv(pos).a

func get_ceiling_north_top_bias(pos : Vector2i) -> float:
	return ceiling_north_south_biases.get_pixelv(pos).r

func get_ceiling_north_bottom_bias(pos : Vector2i) -> float:
	return ceiling_north_south_biases.get_pixelv(pos).g

func get_ceiling_south_top_bias(pos : Vector2i) -> float:
	return ceiling_north_south_biases.get_pixelv(pos).b

func get_ceiling_south_bottom_bias(pos : Vector2i) -> float:
	return ceiling_north_south_biases.get_pixelv(pos).a

func get_ceiling_east_top_hue(pos : Vector2i) -> float:
	return ceiling_east_west_hues.get_pixelv(pos).r

func get_ceiling_east_bottom_hue(pos : Vector2i) -> float:
	return ceiling_east_west_hues.get_pixelv(pos).g

func get_ceiling_west_top_hue(pos : Vector2i) -> float:
	return ceiling_east_west_hues.get_pixelv(pos).b

func get_ceiling_west_bottom_hue(pos : Vector2i) -> float:
	return ceiling_east_west_hues.get_pixelv(pos).a

func get_ceiling_east_top_bias(pos : Vector2i) -> float:
	return ceiling_east_west_biases.get_pixelv(pos).r

func get_ceiling_east_bottom_bias(pos : Vector2i) -> float:
	return ceiling_east_west_biases.get_pixelv(pos).g

func get_ceiling_west_top_bias(pos : Vector2i) -> float:
	return ceiling_east_west_biases.get_pixelv(pos).b

func get_ceiling_west_bottom_bias(pos : Vector2i) -> float:
	return ceiling_east_west_biases.get_pixelv(pos).a

func get_ceiling_north_offset(pos : Vector2i) -> float:
	return ceiling_side_texture_offsets.get_pixelv(pos).r

func get_ceiling_east_offset(pos : Vector2i) -> float:
	return ceiling_side_texture_offsets.get_pixelv(pos).g

func get_ceiling_south_offset(pos : Vector2i) -> float:
	return ceiling_side_texture_offsets.get_pixelv(pos).b

func get_ceiling_west_offset(pos : Vector2i) -> float:
	return ceiling_side_texture_offsets.get_pixelv(pos).a

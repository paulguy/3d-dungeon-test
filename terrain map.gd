extends Node3D

# TODO: movement
#       editing parameters

const VIEW_DEPTH : int = 39
const VIEW_HEIGHT : float = 0.5
const TEST_WORLD_WIDTH : int = 128
const TEST_WORLD_HEIGHT : int = 128

@onready var terrain : MultiMeshInstance3D = $'Terrain Multimesh'

var pos : Vector2i = Vector2i(64, 64)
var dir : int = 0

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

func test_init(face_heights : Image, face_offsets : Image,
			   face_hues_and_biases : Image,
			   floor_north_south_hues : Image, floor_north_south_biases : Image,
			   floor_east_west_hues : Image, floor_east_west_biases : Image,
			   floor_side_texture_offsets : Image,
			   ceiling_north_south_hues : Image, ceiling_north_south_biases : Image,
			   ceiling_east_west_hues : Image, ceiling_east_west_biases : Image,
			   ceiling_side_texture_offsets : Image):
	floor_side_texture_offsets.fill(Color(1.0, 0.0, 1.0, 3.0))
	floor_north_south_hues.fill(	Color(0.2, 0.4, 0.6, 0.8))
	floor_north_south_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	floor_east_west_hues.fill(Color(0.1, 0.3, 0.5, 0.7))
	floor_east_west_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	ceiling_north_south_hues.fill(Color(0.5, 0.6, 0.8, 1.0))
	ceiling_north_south_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	ceiling_east_west_hues.fill(Color(0.3, 0.5, 0.7, 0.9))
	ceiling_east_west_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	ceiling_side_texture_offsets.fill(Color(0.0, 2.0, 3.0, 2.0))
	face_offsets.fill(Color(0.0, 3.0, 0.0, 0.0))

	for y in TEST_WORLD_WIDTH:
		for x in TEST_WORLD_HEIGHT:
			var div : float = ((y * TEST_WORLD_WIDTH) + x) % 2 + 1
			face_hues_and_biases.set_pixel(x, y, Color(0.5,
													   0.5 / div,
													   0.0,
													   1.0 / div))
			face_heights.set_pixel(x, y, Color(21.0,
											   (sin(x / 10.0) * cos(y / 10.0)) * 10.0 + 10.5,
											   -(sin(x / 10.0) * cos(y / 10.0)) * 10.0 - 10.5,
											   -21.0))

func rescale_colors(face_heights : Image,
					face_hues_and_biases : Image,
					floor_north_south_hues : Image,
					floor_north_south_biases : Image,
					floor_east_west_hues : Image,
					floor_east_west_biases : Image,
					ceiling_north_south_hues : Image,
					ceiling_north_south_biases : Image,
					ceiling_east_west_hues : Image,
					ceiling_east_west_biases : Image):
	for y in TEST_WORLD_WIDTH:
		for x in TEST_WORLD_HEIGHT:
			var height : Color = face_heights.get_pixel(x, y)
			var n_height : Color = face_heights.get_pixel(x, y - 1)
			var e_height : Color = face_heights.get_pixel(x + 1, y)
			var s_height : Color = face_heights.get_pixel(x, y + 1)
			var w_height : Color = face_heights.get_pixel(x - 1, y)
			var f_ns_hue : Color = floor_north_south_hues.get_pixel(x, y)
			var f_ns_bias : Color = floor_north_south_biases.get_pixel(x, y)
			var f_ew_hue : Color = floor_east_west_hues.get_pixel(x, y)
			var f_ew_bias : Color = floor_east_west_biases.get_pixel(x, y)
			var c_ns_hue : Color = ceiling_north_south_hues.get_pixel(x, y)
			var c_ns_bias : Color = ceiling_north_south_biases.get_pixel(x, y)
			var c_ew_hue : Color = ceiling_east_west_hues.get_pixel(x, y)
			var c_ew_bias : Color = ceiling_east_west_biases.get_pixel(x, y)

			f_ns_hue.g = f_ns_hue.r + ((f_ns_hue.g - f_ns_hue.r) * ((height.b - height.a) / (n_height.b - height.b)))
			f_ns_hue.a = f_ns_hue.b + ((f_ns_hue.a - f_ns_hue.b) * ((height.b - height.a) / (s_height.b - height.b)))
			floor_north_south_hues.set_pixel(x, y, f_ns_hue)
			f_ns_bias.g = f_ns_bias.r + ((f_ns_bias.g - f_ns_bias.r) * ((height.b - height.a) / (n_height.b - height.b)))
			f_ns_bias.a = f_ns_bias.b + ((f_ns_bias.a - f_ns_bias.b) * ((height.b - height.a) / (s_height.b - height.b)))
			floor_north_south_biases.set_pixel(x, y, f_ns_bias)
			f_ew_hue.g = f_ew_hue.r + ((f_ew_hue.g - f_ew_hue.r) * ((height.b - height.a) / (e_height.b - height.b)))
			f_ew_hue.a = f_ew_hue.b + ((f_ew_hue.a - f_ew_hue.b) * ((height.b - height.a) / (w_height.b - height.b)))
			floor_east_west_hues.set_pixel(x, y, f_ew_hue)
			f_ew_bias.g = f_ew_bias.r + ((f_ew_bias.g - f_ew_bias.r) * ((height.b - height.a) / (e_height.b - height.b)))
			f_ew_bias.a = f_ew_bias.b + ((f_ew_bias.a - f_ew_bias.b) * ((height.b - height.a) / (w_height.b - height.b)))
			floor_east_west_biases.set_pixel(x, y, f_ew_bias)
			c_ns_hue.r = c_ns_hue.g + ((c_ns_hue.r - c_ns_hue.g) * ((height.r - height.g) / (height.g - n_height.g)))
			c_ns_hue.b = c_ns_hue.a + ((c_ns_hue.b - c_ns_hue.a) * ((height.r - height.g) / (height.g - s_height.g)))
			ceiling_north_south_hues.set_pixel(x, y, c_ns_hue)
			c_ns_bias.r = c_ns_bias.g + ((c_ns_bias.r - c_ns_bias.g) * ((height.r - height.g) / (height.g - n_height.g)))
			c_ns_bias.b = c_ns_bias.a + ((c_ns_bias.b - c_ns_bias.a) * ((height.r - height.g) / (height.g - s_height.g)))
			ceiling_north_south_biases.set_pixel(x, y, c_ns_bias)
			c_ew_hue.r = c_ew_hue.g + ((c_ew_hue.r - c_ew_hue.g) * ((height.r - height.g) / (height.g - e_height.g)))
			c_ew_hue.b = c_ew_hue.a + ((c_ew_hue.b - c_ew_hue.a) * ((height.r - height.g) / (height.g - w_height.g)))
			ceiling_east_west_hues.set_pixel(x, y, c_ew_hue)
			c_ew_bias.r = c_ew_bias.g + ((c_ew_bias.r - c_ew_bias.g) * ((height.r - height.g) / (height.g - e_height.g)))
			c_ew_bias.b = c_ew_bias.a + ((c_ew_bias.b - c_ew_bias.a) * ((height.r - height.g) / (height.g - w_height.g)))
			ceiling_east_west_biases.set_pixel(x, y, c_ew_bias)

func _ready():
	face_heights = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	face_offsets = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	face_hues_and_biases = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	floor_north_south_hues = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	floor_north_south_biases = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	floor_east_west_hues = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	floor_east_west_biases = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	floor_side_texture_offsets = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	ceiling_north_south_hues = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	ceiling_north_south_biases = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	ceiling_east_west_hues = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	ceiling_east_west_biases = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
	ceiling_side_texture_offsets = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)

	test_init(face_heights,
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

	rescale_colors(face_heights,
				  face_hues_and_biases,
				  floor_north_south_hues,
				  floor_north_south_biases,
				  floor_east_west_hues,
				  floor_east_west_biases,
				  ceiling_north_south_hues,
				  ceiling_north_south_biases,
				  ceiling_east_west_hues,
				  ceiling_east_west_biases)

	terrain.set_view_parameters($'Pillar', $'Camera3D'.fov, VIEW_DEPTH, VIEW_HEIGHT,
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
	terrain.set_pos(pos)
	terrain.set_dir(dir)

func _process(_delta : float):
	var update_pos : bool = false
	var update_dir : bool = false

	if Input.is_action_just_pressed(&'forward'):
		match dir:
			0: # north
				pos.y += 1
			1: # east
				pos.x -= 1
			2: # south
				pos.y -= 1
			_: # west
				pos.x += 1
		update_pos = true

	if Input.is_action_just_pressed(&'back'):
		match dir:
			0: # north
				pos.y -= 1
			1: # east
				pos.x += 1
			2: # south
				pos.y += 1
			_: # west
				pos.x -= 1
		update_pos = true

	if Input.is_action_just_pressed(&'turn left'):
		dir -= 1
		update_dir = true

	if Input.is_action_just_pressed(&'turn right'):
		dir += 1
		update_dir = true

	if update_pos:
		terrain.set_pos(pos)

	if update_dir:
		if dir < 0:
			dir = 3
		elif dir > 3:
			dir = 0
		terrain.set_dir(dir)

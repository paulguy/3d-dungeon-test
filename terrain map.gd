extends Node3D

# TODO: movement
#       editing parameters

const VIEW_DEPTH : int = 39
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

	floor_north_south_hues.fill(Color(0.2, 0.4, 0.6, 0.8))
	floor_north_south_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	floor_east_west_hues.fill(Color(0.1, 0.3, 0.5, 0.7))
	floor_east_west_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	floor_side_texture_offsets.fill(Color(1.0, 1.0, 1.0, 1.0))
	ceiling_north_south_hues.fill(Color(0.5, 0.6, 0.8, 1.0))
	ceiling_north_south_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	ceiling_east_west_hues.fill(Color(0.3, 0.5, 0.7, 0.9))
	ceiling_east_west_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	ceiling_side_texture_offsets.fill(Color(2.0, 2.0, 2.0, 2.0))
	face_offsets.fill(Color(0.0, 3.0, 0.0, 0.0))

	for y in TEST_WORLD_WIDTH:
		for x in TEST_WORLD_HEIGHT:
			var div : float = ((y * TEST_WORLD_WIDTH) + x) % 2 + 1
			face_hues_and_biases.set_pixel(x, y, Color(0.5,
													   0.0,
													   0.5 / div,
													   1.0 / div))
			face_heights.set_pixel(x, y, Color(3.0,
											   (sin(x / 2.0) * cos(y / 2.0)) / 2.0 + 1.5,
											   (sin(x / 2.0) + cos(y / 2.0)) / 2.0 - 1.5,
											   -3.0))

	terrain.set_view_parameters($'Pillar', $'Camera3D'.fov, VIEW_DEPTH,
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
	pass

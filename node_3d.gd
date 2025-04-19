extends Node3D

const VIEW_DEPTH : int = 39
const TEST_WORLD_WIDTH : int = 128
const TEST_WORLD_HEIGHT : int = 128

var pos : Vector2i

var heights_and_face_offsets : Image
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
	heights_and_face_offsets = Image.create_empty(TEST_WORLD_WIDTH, TEST_WORLD_HEIGHT, false, Image.FORMAT_RGBAF)
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

	pos = Vector2i(64, 64)
	# heights_and_face_offsets.fill(Color(-1.0, 0.0, 1.0, 0.0))

	for y in TEST_WORLD_WIDTH:
		for x in TEST_WORLD_HEIGHT:
			var div : float = ((y * TEST_WORLD_WIDTH) + x) % 2 + 1
			face_hues_and_biases.set_pixel(x, y, Color(0.5,
													   1.0 / div,
													   0.0,
													   0.5 / div))
			heights_and_face_offsets.set_pixel(x, y, Color((sin(x / 2.0) * cos(y / 2.0)) / 20.0 - 1.05,
														   0.0,
														   (sin(x / 2.0) + cos(y / 2.0)) / 20.0 + 1.05,
														   0.0))

	$'MultiMeshInstance3D'.set_view_parameters($'Pillar', $'Camera3D'.fov, VIEW_DEPTH,
											   heights_and_face_offsets,
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
	$'MultiMeshInstance3D'.refresh(
		heights_and_face_offsets,
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
		ceiling_side_texture_offsets,
		pos, 0)

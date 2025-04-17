extends Node3D

const TEST_DEPTH : int = 39

var floor_height : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_top_hue : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_top_bias : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_bottom_hue : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_bottom_bias : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_face_hue : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_face_bias : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_side_texture_offset : Array[float] = Array([], TYPE_FLOAT, "", null)
var floor_face_texture_offset : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_height : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_top_hue : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_top_bias : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_bottom_hue : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_bottom_bias : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_face_hue : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_face_bias : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_side_texture_offset : Array[float] = Array([], TYPE_FLOAT, "", null)
var ceiling_face_texture_offset : Array[float] = Array([], TYPE_FLOAT, "", null)
var dims : Vector2i = Vector2i.ZERO
var pos : Vector2i = Vector2i.ZERO

func _ready():
	var width : float = atan($'Camera3D'.fov / 180.0 * PI) * TEST_DEPTH * 2.0
	$'Pillar'.mesh.material.set_shader_parameter(&"grid_width", width)
	$'Pillar'.mesh.material.set_shader_parameter(&"grid_depth", TEST_DEPTH)
	floor_height.resize(width * TEST_DEPTH)
	floor_top_hue.resize(width * TEST_DEPTH)
	floor_top_bias.resize(width * TEST_DEPTH)
	floor_bottom_hue.resize(width * TEST_DEPTH)
	floor_bottom_bias.resize(width * TEST_DEPTH)
	floor_face_hue.resize(width * TEST_DEPTH)
	floor_face_bias.resize(width * TEST_DEPTH)
	floor_side_texture_offset.resize(width * TEST_DEPTH)
	floor_face_texture_offset.resize(width * TEST_DEPTH)
	ceiling_height.resize(width * TEST_DEPTH)
	ceiling_top_hue.resize(width * TEST_DEPTH)
	ceiling_top_bias.resize(width * TEST_DEPTH)
	ceiling_bottom_hue.resize(width * TEST_DEPTH)
	ceiling_bottom_bias.resize(width * TEST_DEPTH)
	ceiling_face_hue.resize(width * TEST_DEPTH)
	ceiling_face_bias.resize(width * TEST_DEPTH)
	ceiling_side_texture_offset.resize(width * TEST_DEPTH)
	ceiling_face_texture_offset.resize(width * TEST_DEPTH)
	dims = Vector2i(width, TEST_DEPTH)
	pos = Vector2i(0, 0)
	floor_height.fill(-1.5)
	floor_top_bias.fill(1.0)
	floor_bottom_hue.fill(0.16)
	floor_bottom_bias.fill(0.5)
	for i in len(floor_face_bias):
		floor_face_bias[i] = (i % 2) + 1.0 / 2.0
	floor_face_hue.fill(0.0)
	for i in len(ceiling_face_bias):
		ceiling_face_bias[i] = ((i + 1) % 2) + 1.0 / 2.0
	ceiling_face_hue.fill(0.6)
	ceiling_height.fill(1.5)

	$'MultiMeshInstance3D'.set_view_dimensions(width, TEST_DEPTH)
	$'MultiMeshInstance3D'.refresh(
		floor_height,
		floor_top_hue,
		floor_top_bias,
		floor_bottom_hue,
		floor_bottom_bias,
		floor_face_hue,
		floor_face_bias,
		floor_side_texture_offset,
		floor_face_texture_offset,
		ceiling_height,
		ceiling_top_hue,
		ceiling_top_bias,
		ceiling_bottom_hue,
		ceiling_bottom_bias,
		ceiling_face_hue,
		ceiling_face_bias,
		ceiling_side_texture_offset,
		ceiling_face_texture_offset,
		dims, pos)

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
var pos : Vector2i = Vector2i.ZERO

func _ready():
	var fov = $'Camera3D'.fov
	var positions : Array[Vector2i] = Array([], TYPE_VECTOR2I, "", null)
	var count : int = 0
	for i in TEST_DEPTH:
		var width = ((int(ceil(atan(fov / 180 * PI) * (i + 1))) - 1) * 2) + 1
		count += width
		for j in width:
			positions.append(Vector2i(j - (width / 2), i))
	# get the smallest power of 2 it'll fit
	# probably not needed but it doesn't hurt
	var image_w : int = int(round(pow(2, ceil(log(count) / log(2)))))
	var pos_image : Image = Image.create_empty(image_w, 1, false, Image.FORMAT_RGBAF)
	for i in len(positions):
		pos_image.set_pixel(i, 0, Color(positions[i].x, positions[i].y, 0.0, 1.0))
	var pos_tex : ImageTexture = ImageTexture.create_from_image(pos_image)
	$'Pillar'.mesh.material.set_shader_parameter(&'positions', pos_tex)
	$'Pillar'.mesh.material.set_shader_parameter(&'depth', TEST_DEPTH)
	$'Pillar'.mesh.material.set_shader_parameter(&'count', count)
	floor_height.resize(count)
	floor_top_hue.resize(count)
	floor_top_bias.resize(count)
	floor_bottom_hue.resize(count)
	floor_bottom_bias.resize(count)
	floor_face_hue.resize(count)
	floor_face_bias.resize(count)
	floor_side_texture_offset.resize(count)
	floor_face_texture_offset.resize(count)
	ceiling_height.resize(count)
	ceiling_top_hue.resize(count)
	ceiling_top_bias.resize(count)
	ceiling_bottom_hue.resize(count)
	ceiling_bottom_bias.resize(count)
	ceiling_face_hue.resize(count)
	ceiling_face_bias.resize(count)
	ceiling_side_texture_offset.resize(count)
	ceiling_face_texture_offset.resize(count)
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

	$'MultiMeshInstance3D'.set_view_positions(len(positions))
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
		positions, pos)

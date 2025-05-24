extends RefCounted
class_name Prop

var def : PropDef
var sprite : MeshInstance3D
var material : ShaderMaterial
var map_pos : Vector2i
var pos : Vector3 = Vector3.ZERO
var view_pos : Vector3 = Vector3.ZERO
var angle : float = 0.0
var view_angle : float = 0.0
var billboard : bool = false
var one_sided : bool = false
var ceiling_attach : bool = false
var horizontal_mode : bool = false
var scale : Vector2 = Vector2.ONE
var hue : float = 0.0
var bias : float = 1.0
var alpha : float = 1.0
var mesh_arrays : Array = []

const CHANGE_SPEEDS : Array[float] = [0.01, 0.1, 1.0]

enum {
	BILLBOARD = 0,
	ONE_SIDED = 1,
	ATTACHMENT = 2,
	H_MODE = 3,
	SCALE_H = 4,
	SCALE_V = 5,
	COLOR_HUE = 6,
	COLOR_BIAS = 7,
	COLOR_ALPHA = 8,
	POS_X = 9,
	POS_Y = 10,
	POS_Z = 11,
	ANGLE = 12,
	MAX_PARAMETER = 13
}

const SCALAR_PARAMETER : Array[bool] = [
	false,
	false,
	false,
	false,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true
]

static func parameter_string(val : int) -> String:
	match val:
		BILLBOARD:
			return "billboard"
		ONE_SIDED:
			return "one-sided"
		ATTACHMENT:
			return "attachment"
		H_MODE:
			return "horizontal mode"
		SCALE_H:
			return "horizontal scale"
		SCALE_V:
			return "vertical scale"
		COLOR_HUE:
			return "color hue"
		COLOR_BIAS:
			return "color bias"
		COLOR_ALPHA:
			return "color alpha"
		POS_X:
			return "position x"
		POS_Y:
			return "position y"
		POS_Z:
			return "position z"
		ANGLE:
			return "angle"

	return "invalid"

static func attachment_string(ceiling_attach : bool) -> String:
	if ceiling_attach:
		return "ceiling"

	return "floor"

static func horizontal_mode_string(horizontal_mode : bool) -> String:
	if horizontal_mode:
		return "flat"

	return "standing"

static func value_string(parameter : int, val : Variant) -> String:
	match parameter:
		BILLBOARD:
			return "%s" % val
		ONE_SIDED:
			return "%s" % val
		ATTACHMENT:
			return attachment_string(val)
		H_MODE:
			return horizontal_mode_string(val)
		SCALE_H:
			return "%.2f" % val
		SCALE_V:
			return "%.2f" % val
		COLOR_HUE:
			return "%.2f" % val
		COLOR_BIAS:
			return "%.2f" % val
		COLOR_ALPHA:
			return "%.2f" % val
		POS_X:
			return "%.2f" % val
		POS_Y:
			return "%.2f" % val
		POS_Z:
			return "%.2f" % val
		ANGLE:
			return "%.2f" % val

	return "%s" % val

func set_mesh_one_sided():
	var mesh : PlaneMesh = PlaneMesh.new()
	mesh.size = def.sizemul
	mesh.center_offset = Vector3(0.0, 0.5, 0.0)
	mesh.orientation = PlaneMesh.FACE_Z
	mesh.material = material

	sprite.mesh = mesh

func set_mesh_two_sided():
	var sizemul : Vector2 = Vector2(def.sizemul)
	sizemul.x /= 2.0

	#Инициализируйте ArrayMesh.
	mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(-sizemul.x, sizemul.y, 0.0),
		Vector3(sizemul.x, sizemul.y, 0.0),
		Vector3(-sizemul.x, 0.0, 0.0),

		Vector3(-sizemul.x, 0.0, 0.0),
		Vector3(sizemul.x, sizemul.y, 0.0),
		Vector3(sizemul.x, 0.0, 0.0),

		Vector3(sizemul.x, sizemul.y, 0.0),
		Vector3(-sizemul.x, sizemul.y, 0.0),
		Vector3(sizemul.x, 0.0, 0.0),

		Vector3(sizemul.x, 0.0, 0.0),
		Vector3(-sizemul.x, sizemul.y, 0.0),
		Vector3(-sizemul.x, 0.0, 0.0)
	])

	# Создать сетку.
	var mesh : ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	mesh.surface_set_material(0, material)

	sprite.mesh = mesh

func set_mesh_horizontal():
	var sizemul : Vector2 = Vector2(def.sizemul) / 2.0

	#Инициализируйте ArrayMesh.
	mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(sizemul.x, 0.0, sizemul.y),
		Vector3(-sizemul.x, 0.0, sizemul.y),
		Vector3(sizemul.x, 0.0, -sizemul.y),

		Vector3(sizemul.x, 0.0, -sizemul.y),
		Vector3(-sizemul.x, 0.0, sizemul.y),
		Vector3(-sizemul.x, 0.0, -sizemul.y),

		Vector3(-sizemul.x, 0.0, sizemul.y),
		Vector3(sizemul.x, 0.0, sizemul.y),
		Vector3(-sizemul.x, 0.0, -sizemul.y),

		Vector3(-sizemul.x, 0.0, -sizemul.y),
		Vector3(sizemul.x, 0.0, sizemul.y),
		Vector3(sizemul.x, 0.0, -sizemul.y)
	])

	# Создать сетку.
	var mesh : ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	mesh.surface_set_material(0, material)

	sprite.mesh = mesh

func set_mesh():
	if billboard or one_sided:
		set_mesh_one_sided()
	elif horizontal_mode:
		set_mesh_horizontal()
	else:
		set_mesh_two_sided()

func _init(p_def : PropDef,
		   p_map_pos : Vector2i):
	def = p_def
	map_pos = p_map_pos

	material = ShaderMaterial.new()
	var shader : Shader = load("res://prop.gdshader")
	material.shader = shader
	material.set_shader_parameter(&'tex', def.image)
	material.set_shader_parameter(&'hue', hue)
	material.set_shader_parameter(&'bias', bias)
	material.set_shader_parameter(&'alpha', alpha)

	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([
		Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0)
	])
	mesh_arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([
		Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0),
		Vector2(0.0, 1.0), Vector2(1.0, 0.0), Vector2(1.0, 1.0),
		Vector2(1.0, 0.0), Vector2(0.0, 0.0), Vector2(1.0, 1.0),
		Vector2(1.0, 1.0), Vector2(0.0, 0.0), Vector2(0.0, 1.0)
	])

	sprite = MeshInstance3D.new()
	set_mesh()

func update_pos():
	sprite.position = view_pos + pos.rotated(Vector3.UP, view_angle)

func set_pos(p_pos : Vector3):
	pos = p_pos
	update_pos()

func set_view_pos(p_view_pos : Vector3):
	view_pos = p_view_pos
	update_pos()

func update_angle():
	if billboard:
		sprite.rotation.y = angle + PI
	else:
		sprite.rotation.y = view_angle + angle

func set_angle(val : float):
	angle = val
	update_angle()

func set_view_angle(val : float):
	view_angle = val
	update_angle()
	update_pos()

func toggle_billboard():
	billboard = not billboard
	set_mesh()
	update_angle()

func toggle_one_sided():
	one_sided = not one_sided
	set_mesh()

func toggle_ceiling_attach(ceiling_height : float, floor_height : float):
	ceiling_attach = not ceiling_attach
	if ceiling_attach:
		pos.y = -((ceiling_height - floor_height) - pos.y)
	else:
		pos.y = (ceiling_height - floor_height) + pos.y
	update_pos()

func toggle_horizontal_mode():
	horizontal_mode = not horizontal_mode
	set_mesh()

func set_scale(p_scale : Vector2):
	scale = p_scale
	sprite.scale = Vector3(scale.x, scale.y, 1.0)

func set_hue(p_hue : float):
	hue = p_hue
	material.set_shader_parameter(&'hue', hue)

func set_bias(p_bias : float):
	bias = p_bias
	material.set_shader_parameter(&'bias', bias)

func set_alpha(p_alpha : float):
	alpha = p_alpha
	material.set_shader_parameter(&'alpha', alpha)

func get_all() -> Dictionary:
	return {
		&'name': def.name,
		&'pos': pos,
		&'angle': angle,
		&'billboard': billboard,
		&'one-sided': one_sided,
		&'ceiling-attach': ceiling_attach,
		&'horizontal-mode': horizontal_mode,
		&'scale': scale,
		&'hue': hue,
		&'bias': bias,
		&'alpha': alpha
	}

func set_all(s_prop : Dictionary, heights : Color):
	# these all execute many of the same functions so just set the
	# values then run all the functions to update everything once
	pos = s_prop[&'pos']
	angle = s_prop[&'angle']
	billboard = s_prop[&'billboard']
	one_sided = s_prop[&'one-sided']
	horizontal_mode = s_prop[&'horizontal-mode']

	if s_prop[&'ceiling-attach']:
		# this calls update_pos
		toggle_ceiling_attach(heights.g, heights.b)
	else:
		update_pos()
	set_mesh()
	update_angle()

	# these don't cascade any additional unnecessary updates
	set_scale(s_prop[&'scale'])
	set_hue(s_prop[&'hue'])
	set_bias(s_prop[&'bias'])
	set_alpha(s_prop[&'alpha'])

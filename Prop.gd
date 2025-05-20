extends RefCounted
class_name Prop

var def : PropDef
var sprite : MeshInstance3D
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
var color : Color = Color.WHITE

const CHANGE_SPEEDS : Array[float] = [0.01, 0.1, 1.0]

enum {
	BILLBOARD = 0,
	ONE_SIDED = 1,
	ATTACHMENT = 2,
	H_MODE = 3,
	SCALE_H = 4,
	SCALE_V = 5,
	COLOR_MOD_R = 6,
	COLOR_MOD_G = 7,
	COLOR_MOD_B = 8,
	COLOR_MOD_A = 9,
	POS_X = 10,
	POS_Y = 11,
	POS_Z = 12,
	ANGLE = 13,
	MAX_PARAMETER = 14
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
		COLOR_MOD_R:
			return "color mod r"
		COLOR_MOD_G:
			return "color mod g"
		COLOR_MOD_B:
			return "color mod b"
		COLOR_MOD_A:
			return "color mod a"
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
		COLOR_MOD_R:
			return "%.2f" % val
		COLOR_MOD_G:
			return "%.2f" % val
		COLOR_MOD_B:
			return "%.2f" % val
		COLOR_MOD_A:
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

func set_mesh():
	if billboard or one_sided:
		sprite.mesh = def.one_side_mesh
	else:
		sprite.mesh = def.two_side_mesh

func _init(p_def : PropDef,
		   p_map_pos : Vector2i):
	def = p_def
	map_pos = p_map_pos

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
	# TODO: implement this
	horizontal_mode = not horizontal_mode

func set_scale(p_scale : Vector2):
	scale = p_scale
	sprite.scale = Vector3(scale.x, scale.y, 1.0)

func set_color(p_color : Color):
	color = p_color
	# TODO: Need to create a mesh + material for each prop to modify colors..

extends RefCounted
class_name Prop

var def : PropDef
var map_pos : Vector2i
var pos : Vector3 = Vector3.ZERO
var view_pos : Vector3 = Vector3.ZERO
var angle : float = 0.0
var view_angle : float = 0.0
var sprite : MeshInstance3D
var billboard : bool = false
var one_sided : bool = false
var ceiling_attach : bool = false

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

func toggle_billboard() -> bool:
	billboard = not billboard
	set_mesh()
	update_angle()
	return billboard

func toggle_one_sided() -> bool:
	one_sided = not one_sided
	set_mesh()
	return one_sided

func toggle_ceiling_attach(ceiling_height : float, floor_height : float) -> bool:
	ceiling_attach = not ceiling_attach
	if ceiling_attach:
		pos.y = -((ceiling_height - floor_height) - pos.y)
	else:
		pos.y = (ceiling_height - floor_height) + pos.y
	update_pos()
	return ceiling_attach

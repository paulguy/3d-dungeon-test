extends RefCounted
class_name Prop

var def : PropDef
var map_pos : Vector2i
var pos : Vector3 = Vector3.ZERO
var view_pos : Vector3 = Vector3.ZERO
var sprite : MeshInstance3D

func _init(p_def : PropDef,
		   p_map_pos : Vector2i):
	def = p_def
	map_pos = p_map_pos

	sprite = MeshInstance3D.new()
	var mesh : PrimitiveMesh = PlaneMesh.new()
	mesh.size = Vector2(1.0, 1.0)
	#mesh.center_offset = Vector3(0.0, 0.5, 0.0)
	mesh.orientation = PlaneMesh.FACE_Z
	mesh.flip_faces = true
	mesh.material = def.material
	sprite.mesh = mesh

func update_pos():
	sprite.position = view_pos + pos

func set_pos(p_pos : Vector3):
	pos = p_pos
	update_pos()

func set_view_pos(p_view_pos : Vector3):
	view_pos = p_view_pos
	update_pos()

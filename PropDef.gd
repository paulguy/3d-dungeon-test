extends RefCounted
class_name PropDef

var name : StringName
var source : String
var image : Texture2D
var one_side_mesh : Mesh
var two_side_mesh : Mesh

func _init(p_name : StringName, p_source : String, p_image : Texture2D):
	name = p_name
	source = p_source
	image = p_image

	var material : StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = image
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	one_side_mesh = PlaneMesh.new()
	one_side_mesh.size = Vector2(1.0, 1.0)
	one_side_mesh.center_offset = Vector3(0.0, 0.5, 0.0)
	one_side_mesh.orientation = PlaneMesh.FACE_Z
	one_side_mesh.material = material

	#Инициализируйте ArrayMesh.
	var mesh_arrays = []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(-0.5, 1.0, 0.0), Vector3(0.5, 1.0, 0.0), Vector3(-0.5, 0.0, 0.0),
		Vector3(-0.5, 0.0, 0.0), Vector3(0.5, 1.0, 0.0), Vector3(0.5, 0.0, 0.0),
		Vector3(0.5, 1.0, 0.0), Vector3(-0.5, 1.0, 0.0), Vector3(0.5, 0.0, 0.0),
		Vector3(0.5, 0.0, 0.0), Vector3(-0.5, 1.0, 0.0), Vector3(-0.5, 0.0, 0.0),
	])
	mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([
		Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0),
	])
	mesh_arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([
		Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0),
		Vector2(0.0, 1.0), Vector2(1.0, 0.0), Vector2(1.0, 1.0),
		Vector2(1.0, 0.0), Vector2(0.0, 0.0), Vector2(1.0, 1.0),
		Vector2(1.0, 1.0), Vector2(0.0, 0.0), Vector2(0.0, 1.0)
	])

	# Создать сетку.
	two_side_mesh = ArrayMesh.new()
	two_side_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	two_side_mesh.surface_set_material(0, material)

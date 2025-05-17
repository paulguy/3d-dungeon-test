extends RefCounted
class_name PropDef

var name : StringName
var source : String
var image : Texture2D
var material : Material

func _init(p_name : StringName, p_source : String, p_image : Texture2D):
	name = p_name
	source = p_source
	image = p_image

	material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = image
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

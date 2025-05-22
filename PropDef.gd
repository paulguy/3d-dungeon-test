extends RefCounted
class_name PropDef

var name : StringName
var source : String
var image : Texture2D
var sizemul : Vector2 = Vector2.ONE

func _init(p_name : StringName, p_source : String, p_image : Texture2D):
	name = p_name
	source = p_source
	image = p_image
	var imagesize : Vector2i = image.get_size()

	if imagesize.y > imagesize.x:
		sizemul.y = imagesize.y / imagesize.x
	elif imagesize.x > imagesize.y:
		sizemul.x = imagesize.x / imagesize.y
	sizemul.x /= 2.0

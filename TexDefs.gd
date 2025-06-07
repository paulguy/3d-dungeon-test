extends RefCounted
class_name TexDefs

var width : int = 0
var texdefs : Array[TexDef] = []

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for texdef in texdefs:
			texdef.free()

func append(texdef : TexDef):
	texdefs.append(texdef)

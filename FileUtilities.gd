extends Object
class_name FileUtilities

const TEMPCHARS : String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const TEMPNUMCHARS : int = 6
const TRUTHY_NAMES : Array[String] = [
	'true',
	'yes',
	'on'
]

static func make_temp_filename(template : String) -> String:
	var tempname : String = String(template)
	for i in TEMPNUMCHARS:
		tempname = "%s%s" % [tempname, TEMPCHARS[randi_range(0, len(TEMPCHARS) - 1)]]

	return tempname

static func write_string(writer : ZIPPacker, out : String) -> Error:
	return writer.write_file(out.to_utf8_buffer())

static func update_dict_from_line(dict : Dictionary, #[StringName, Variant],
								  key : StringName,
								  line : String,
								  type : int):
	var parts : PackedStringArray = line.split(' ', true, 1)
	var vals : PackedStringArray

	if len(parts) == 0:
		return

	var got_key : String = parts[0].strip_edges().to_lower()
	if got_key != key:
		return

	if len(parts) == 1:
		if type == TYPE_BOOL:
			dict[key] = true
		return

	match type:
		TYPE_INT:
			if parts[1].is_valid_int():
				dict[key] = parts[1].to_int()
		TYPE_FLOAT:
			if parts[1].is_valid_float():
				dict[key] = parts[1].to_float()
		TYPE_BOOL:
			if parts[1].is_valid_int():
				if parts[1].to_int():
					dict[key] = true
				else:
					dict[key] = false
			else:
				if parts[1].strip_edges().to_lower() in TRUTHY_NAMES:
					dict[key] = true
				else:
					dict[key] = false
		TYPE_VECTOR2I:
			vals = parts[1].split(' ', true)
			if len(vals) >= 2 and \
			   vals[0].is_valid_int() and \
			   vals[1].is_valid_int():
				dict[key] = Vector2i(vals[0].to_int(), vals[1].to_int())
		TYPE_VECTOR2:
			vals = parts[1].split(' ', true)
			if len(vals) >= 2 and \
			   vals[0].is_valid_float() and \
			   vals[1].is_valid_float():
				dict[key] = Vector2(vals[0].to_float(), vals[1].to_float())
		TYPE_VECTOR3:
			vals = parts[1].split(' ', true)
			if len(vals) >= 3 and \
			   vals[0].is_valid_float() and \
			   vals[1].is_valid_float() and \
			   vals[2].is_valid_float():
				dict[key] = Vector3(vals[0].to_float(),
									vals[1].to_float(),
									vals[2].to_float())
		TYPE_COLOR:
			vals = parts[1].split(' ', true)
			if len(vals) >= 3 and \
			   vals[0].is_valid_float() and \
			   vals[1].is_valid_float() and \
			   vals[2].is_valid_float():
				dict[key] = Color(vals[0].to_float(),
								  vals[1].to_float(),
								  vals[2].to_float())
		TYPE_STRING:
			dict[key] = parts[1].strip_edges()

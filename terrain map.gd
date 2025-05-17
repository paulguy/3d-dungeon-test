extends Node3D

const DEFAULT_TEXTURES : String = "res://textures.png"

const MAP_VERSION : int = 1
const MAP_LAYERS : Array[StringName] = [
	&'face_heights',
	&'face_offsets',
	&'face_hues_and_biases',
	&'floor_side_texture_offsets',
	&'floor_north_south_hues',
	&'floor_north_south_biases',
	&'floor_east_west_hues',
	&'floor_east_west_biases',
	&'ceiling_north_south_hues',
	&'ceiling_north_south_biases',
	&'ceiling_east_west_hues',
	&'ceiling_east_west_biases',
	&'ceiling_side_texture_offsets'
]

@onready var terrain : MultiMeshInstance3D = $'Terrain Multimesh'

var dims : Vector2i = Vector2i.ZERO
var images : Dictionary[StringName, Image]
var clear_color : Dictionary[StringName, Color] = {
	&'face_heights': Color(2.0, 1.0, 0.0, -1.0),
	&'face_offsets': Color(0.0, 0.0, 0.0, 0.0),
	&'face_hues_and_biases': Color(0.0, 1.0, 0.0, 1.0),
	&'floor_side_texture_offsets': Color(1.0, 1.0, 1.0, 1.0),
	&'floor_north_south_hues': Color(0.0, 0.0, 0.0, 0.0),
	&'floor_north_south_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'floor_east_west_hues': Color(0.0, 0.0, 0.0, 0.0),
	&'floor_east_west_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'ceiling_north_south_hues': Color(0.0, 0.0, 0.0, 0.0),
	&'ceiling_north_south_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'ceiling_east_west_hues': Color(0.0, 0.0, 0.0, 0.0),
	&'ceiling_east_west_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'ceiling_side_texture_offsets': Color(3.0, 3.0, 3.0, 3.0)
}

func init_clear_texture(texname : StringName):
	images[texname] = Image.create_empty(dims.x, dims.y, false, Image.FORMAT_RGBAF)
	images[texname].fill(clear_color[texname])
	terrain.set_image(texname, images[texname])

func test_init(width : int, height : int,
			   _face_heights : Image, _face_offsets : Image,
			   _face_hues_and_biases : Image,
			   _floor_north_south_hues : Image, _floor_north_south_biases : Image,
			   _floor_east_west_hues : Image, _floor_east_west_biases : Image,
			   _floor_side_texture_offsets : Image,
			   _ceiling_north_south_hues : Image, _ceiling_north_south_biases : Image,
			   _ceiling_east_west_hues : Image, _ceiling_east_west_biases : Image,
			   _ceiling_side_texture_offsets : Image):
	_floor_side_texture_offsets.fill(Color(1.0, 0.0, 1.0, 3.0))
	_floor_north_south_hues.fill(Color(0.2, 0.4, 0.6, 0.8))
	_floor_north_south_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	_floor_east_west_hues.fill(Color(0.1, 0.3, 0.5, 0.7))
	_floor_east_west_biases.fill(Color(1.5, 0.5, 1.5, 0.5))
	_ceiling_north_south_hues.fill(Color(0.5, 0.6, 0.8, 1.0))
	_ceiling_north_south_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	_ceiling_east_west_hues.fill(Color(0.3, 0.5, 0.7, 0.9))
	_ceiling_east_west_biases.fill(Color(0.5, 1.5, 0.5, 1.5))
	_ceiling_side_texture_offsets.fill(Color(0.0, 2.0, 3.0, 2.0))
	_face_offsets.fill(Color(0.0, 3.0, 0.0, 0.0))

	for y in width:
		for x in height:
			var div : float = ((y * width) + x) % 2 + 1
			_face_hues_and_biases.set_pixel(x, y, Color(0.5,
														0.5 / div,
														0.0,
														1.0 / div))
			_face_heights.set_pixel(x, y, Color(21.0,
												(sin(x / 10.0) * cos(y / 10.0)) * 10.0 + 10.5,
												-(sin(x / 10.0) * cos(y / 10.0)) * 10.0 - 10.5,
												-21.0))

func rescale_colors(width : int, height : int,
					_face_heights : Image,
					_face_hues_and_biases : Image,
					_floor_north_south_hues : Image,
					_floor_north_south_biases : Image,
					_floor_east_west_hues : Image,
					_floor_east_west_biases : Image,
					_ceiling_north_south_hues : Image,
					_ceiling_north_south_biases : Image,
					_ceiling_east_west_hues : Image,
					_ceiling_east_west_biases : Image):
	# this function is for testing and throws a lot of out of bounds errors.
	# it's not super useful on its own but parts of it can be useful later.
	for y in width:
		for x in height:
			var heights : Color = _face_heights.get_pixel(x, y)
			var n_height : Color = _face_heights.get_pixel(x, y - 1)
			var e_height : Color = _face_heights.get_pixel(x + 1, y)
			var s_height : Color = _face_heights.get_pixel(x, y + 1)
			var w_height : Color = _face_heights.get_pixel(x - 1, y)
			var f_ns_hue : Color = _floor_north_south_hues.get_pixel(x, y)
			var f_ns_bias : Color = _floor_north_south_biases.get_pixel(x, y)
			var f_ew_hue : Color = _floor_east_west_hues.get_pixel(x, y)
			var f_ew_bias : Color = _floor_east_west_biases.get_pixel(x, y)
			var c_ns_hue : Color = _ceiling_north_south_hues.get_pixel(x, y)
			var c_ns_bias : Color = _ceiling_north_south_biases.get_pixel(x, y)
			var c_ew_hue : Color = _ceiling_east_west_hues.get_pixel(x, y)
			var c_ew_bias : Color = _ceiling_east_west_biases.get_pixel(x, y)

			f_ns_hue.g = f_ns_hue.r + ((f_ns_hue.g - f_ns_hue.r) * ((heights.b - heights.a) / (n_height.b - heights.b)))
			f_ns_hue.a = f_ns_hue.b + ((f_ns_hue.a - f_ns_hue.b) * ((heights.b - heights.a) / (s_height.b - heights.b)))
			_floor_north_south_hues.set_pixel(x, y, f_ns_hue)
			f_ns_bias.g = f_ns_bias.r + ((f_ns_bias.g - f_ns_bias.r) * ((heights.b - heights.a) / (n_height.b - heights.b)))
			f_ns_bias.a = f_ns_bias.b + ((f_ns_bias.a - f_ns_bias.b) * ((heights.b - heights.a) / (s_height.b - heights.b)))
			_floor_north_south_biases.set_pixel(x, y, f_ns_bias)
			f_ew_hue.g = f_ew_hue.r + ((f_ew_hue.g - f_ew_hue.r) * ((heights.b - heights.a) / (e_height.b - heights.b)))
			f_ew_hue.a = f_ew_hue.b + ((f_ew_hue.a - f_ew_hue.b) * ((heights.b - heights.a) / (w_height.b - heights.b)))
			_floor_east_west_hues.set_pixel(x, y, f_ew_hue)
			f_ew_bias.g = f_ew_bias.r + ((f_ew_bias.g - f_ew_bias.r) * ((heights.b - heights.a) / (e_height.b - heights.b)))
			f_ew_bias.a = f_ew_bias.b + ((f_ew_bias.a - f_ew_bias.b) * ((heights.b - heights.a) / (w_height.b - heights.b)))
			_floor_east_west_biases.set_pixel(x, y, f_ew_bias)
			c_ns_hue.r = c_ns_hue.g + ((c_ns_hue.r - c_ns_hue.g) * ((heights.r - heights.g) / (heights.g - n_height.g)))
			c_ns_hue.b = c_ns_hue.a + ((c_ns_hue.b - c_ns_hue.a) * ((heights.r - heights.g) / (heights.g - s_height.g)))
			_ceiling_north_south_hues.set_pixel(x, y, c_ns_hue)
			c_ns_bias.r = c_ns_bias.g + ((c_ns_bias.r - c_ns_bias.g) * ((heights.r - heights.g) / (heights.g - n_height.g)))
			c_ns_bias.b = c_ns_bias.a + ((c_ns_bias.b - c_ns_bias.a) * ((heights.r - heights.g) / (heights.g - s_height.g)))
			_ceiling_north_south_biases.set_pixel(x, y, c_ns_bias)
			c_ew_hue.r = c_ew_hue.g + ((c_ew_hue.r - c_ew_hue.g) * ((heights.r - heights.g) / (heights.g - e_height.g)))
			c_ew_hue.b = c_ew_hue.a + ((c_ew_hue.b - c_ew_hue.a) * ((heights.r - heights.g) / (heights.g - w_height.g)))
			_ceiling_east_west_hues.set_pixel(x, y, c_ew_hue)
			c_ew_bias.r = c_ew_bias.g + ((c_ew_bias.r - c_ew_bias.g) * ((heights.r - heights.g) / (heights.g - e_height.g)))
			c_ew_bias.b = c_ew_bias.a + ((c_ew_bias.b - c_ew_bias.a) * ((heights.r - heights.g) / (heights.g - w_height.g)))
			_ceiling_east_west_biases.set_pixel(x, y, c_ew_bias)

func init_empty_world(dimensions : Vector2i):
	dims = dimensions
	for layer in MAP_LAYERS:
		init_clear_texture(layer)

func set_texture(texturename, reader = null, mapname = null):
	var filename : String = "%s.png" % texturename
	var image : Image = Image.new()
	var err : Error

	if reader != null:
		if reader.file_exists(filename):
			err = image.load_png_from_buffer(reader.read_file(filename))
			if err != Error.OK:
				# just continue...
				print_debug("File %s exists in %s.zip but failed to load!" % [filename, mapname])
				image = Image.new()

		if image.get_data_size() == 0:
			err = image.load("user://mods".path_join(mapname).path_join(filename))
			if err != Error.OK:
				image = Image.new()

	if image.get_data_size() == 0:
		terrain.set_texture(load("res://".path_join(filename)))
	else:
		terrain.set_texture(ImageTexture.create_from_image(image))

func set_view(depth, fov):
	return terrain.set_view(depth, fov)

func set_eye_height(height):
	terrain.set_eye_height(height)

func set_fog_color(color):
	terrain.set_fog_color(color)

func set_fog_power(power):
	terrain.set_fog_power(power)

func set_pos(pos):
	terrain.set_pos(pos)

func set_dir(dir):
	terrain.set_dir(dir)

# properties
# heights
#  ceiling top
#  ceiling bottom
#  floor top
#  floor bottom
# hues
#  top face
#  bottom face
#  ceiling north top
#  ceiling north bottom
#  ceiling east top
#  ceiling east bottom
#  ceiling south top
#  ceiling south bottom
#  ceiling west top
#  ceiling west bottom
#  floor north top
#  floor north bottom
#  floor east top
#  floor east bottom
#  floor south top
#  floor south bottom
#  floor west top
#  floor west bottom
# color biases
#  top face
#  bottom face
#  ceiling north top
#  ceiling north bottom
#  ceiling east top
#  ceiling east bottom
#  ceiling south top
#  ceiling south bottom
#  ceiling west top
#  ceiling west bottom
#  floor north top
#  floor north bottom
#  floor east top
#  floor east bottom
#  floor south top
#  floor south bottom
#  floor west top
#  floor west bottom
# texture offsets
#  top face
#  bottom face
#  ceiling north top
#  ceiling north bottom
#  ceiling east top
#  ceiling east bottom
#  ceiling south top
#  ceiling south bottom
#  ceiling west top
#  ceiling west bottom
#  floor north top
#  floor north bottom
#  floor east top
#  floor east bottom
#  floor south top
#  floor south bottom
#  floor west top
#  floor west bottom

func lookup_name(mesh : int, face : int, dir : int, parameter : int) -> StringName:
	if parameter == MapParameters.HEIGHT:
		return &'face_heights'
	elif parameter == MapParameters.HUE:
		if face == 0: # horiz
			return &'face_hues_and_biases'
		else: # vert/wall/side
			if mesh == 0: # ceiling
				if dir % 2 == 0: # north, south
					return &'ceiling_north_south_hues'
				else: # east west
					return &'ceiling_east_west_hues'
			else: # floor
				if dir % 2 == 0:
					return &'floor_north_south_hues'
				else:
					return &'floor_east_west_hues'
	elif parameter == MapParameters.BIAS:
		if face == 0:
			return &'face_hues_and_biases'
		else:
			if mesh == 0:
				if dir % 2 == 0:
					return &'ceiling_north_south_biases'
				else:
					return &'ceiling_east_west_biases'
			else:
				if dir % 2 == 0:
					return &'floor_north_south_biases'
				else:
					return &'floor_east_west_biases'
	elif parameter == MapParameters.OFFSET:
		if face == 0:
			return &'face_offsets'
		else:
			if mesh == 0:
				return &'ceiling_side_texture_offsets'
			else:
				return &'floor_side_texture_offsets'

	return &''
 
func lookup_offset(mesh : int, face : int, dir : int, topbottom : int, parameter : int) -> int:
	if parameter == MapParameters.HEIGHT:
		return mesh * 2 + topbottom
	elif parameter == MapParameters.HUE:
		if face == 0: # horiz
			return mesh * 2
		else: # vert/wall/side
			if dir % 2 == 0: # north in 0, out 0  south in 2, out 2
				return MapParameters.get_opp_dir(dir) + topbottom
			else: # east in 1, out 0  west in 3 out 2
				return MapParameters.get_opp_dir(dir) - 1 + topbottom
	elif parameter == MapParameters.BIAS:
		if face == 0:
			return mesh * 2 + 1
		else:
			if dir % 2 == 0:
				return MapParameters.get_opp_dir(dir) + topbottom
			else:
				return MapParameters.get_opp_dir(dir) - 1 + topbottom
	elif parameter == MapParameters.OFFSET:
		if face == 0:
			return mesh * 2 + topbottom
		else:
			if mesh == 0:
				return MapParameters.get_opp_dir(dir)
			else:
				return MapParameters.get_opp_dir(dir)

	return -1

func change(mesh : int, face : int, dir : int, topbottom : int, parameter : int,
			val : float, pos : Vector2i, size : Vector2i = Vector2i.ZERO):
	var imagename : StringName = lookup_name(mesh, face, dir, parameter)
	var image : Image = images[imagename]
	var col : Color = image.get_pixelv(pos)
	col[lookup_offset(mesh, face, dir, topbottom, parameter)] += val
	if size == Vector2i.ZERO:
		image.set_pixelv(pos, col)
	else:
		image.fill_rect(Rect2i(pos, size), col)
	terrain.set_image(imagename, image)

func set_val(mesh : int, face : int, dir : int, topbottom : int, parameter : int,
			 val : float, pos : Vector2i, size : Vector2i = Vector2i.ZERO):
	var imagename : StringName = lookup_name(mesh, face, dir, parameter)
	var image : Image = images[imagename]
	var col : Color = image.get_pixelv(pos)
	col[lookup_offset(mesh, face, dir, topbottom, parameter)] = val
	if size == Vector2i.ZERO:
		image.set_pixelv(pos, col)
	else:
		image.fill_rect(Rect2i(pos, size), col)
	terrain.set_image(imagename, image)

func get_val(mesh : int, face : int, dir : int, topbottom : int, parameter : int,
			pos : Vector2i) -> float:
	var imagename : StringName = lookup_name(mesh, face, dir, parameter)
	var image : Image = images[imagename]
	return image.get_pixelv(pos)[lookup_offset(mesh, face, dir, topbottom, parameter)]

func write_string(writer : ZIPPacker, out : String) -> Error:
	return writer.write_file(out.to_utf8_buffer())

func write_image(writer : ZIPPacker, layername : StringName) -> Error:
	var err : Error = writer.start_file("%s.bin" % layername)
	if err != Error.OK:
		return err

	err = writer.write_file(images[layername].get_data())
	if err != Error.OK:
		return err

	err = writer.close_file()
	if err != Error.OK:
		return err

	return Error.OK

const TEMPCHARS : String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const TEMPNUMCHARS : int = 6

func make_temp_filename(template : String) -> String:
	var tempname : String = String(template)
	for i in TEMPNUMCHARS:
		tempname = "%s%s" % [tempname, TEMPCHARS[randi_range(0, len(TEMPCHARS) - 1)]]

	return tempname

func save_map(mapname : String, textures = null,
			  pos = null, dir = null,
			  fog_color = null, fog_power = null,
			  eye_height = null) -> Error:
	var tempname : String = make_temp_filename("%s-" % mapname)
	var writer : ZIPPacker = ZIPPacker.new()
	var err : Error = writer.open("user://%s.zip" % tempname)
	if err != Error.OK:
		return err

	err = writer.start_file("info.txt")
	if err != Error.OK:
		return err

	err = write_string(writer, ("version %d\n" % MAP_VERSION))
	if err != Error.OK:
		return err

	err = write_string(writer, ("width %d\n" % dims.x))
	if err != Error.OK:
		return err

	err = write_string(writer, ("height %d\n" % dims.y))
	if err != Error.OK:
		return err

	if pos != null:
		err = write_string(writer, ("pos %d %d\n" % [pos.x, pos.y]))
		if err != Error.OK:
			return err

	if dir != null:
		err = write_string(writer, ("dir %d\n" % dir))
		if err != Error.OK:
			return err

	if fog_color != null:
		err = write_string(writer, ("fog_color %f %f %f\n" % [fog_color.r,
															 fog_color.g,
															 fog_color.b]))
		if err != Error.OK:
			return err

	if fog_power != null:
		err = write_string(writer, ("fog_power %f\n" % fog_power))
		if err != Error.OK:
			return err

	if eye_height != null:
		err = write_string(writer, ("eye_height %f\n" % eye_height))
		if err != Error.OK:
			return err

	if textures != null:
		err = write_string(writer, ("textures %s\n" % textures))
		if err != Error.OK:
			return err

	err = writer.close_file()
	if err != Error.OK:
		return err

	for layer in MAP_LAYERS:
		err = write_image(writer, layer)
		if err != Error.OK:
			return err

	writer.close()

	var userdir : DirAccess = DirAccess.open("user://")
	userdir.rename("%s.zip" % tempname, "%s.zip" % mapname)

	return Error.OK

func load_layer(reader : ZIPReader, layername : String, loaded : Dictionary[StringName, Image],
				pixelsize : int, size : Vector2i) -> Error:
	var data : PackedByteArray = reader.read_file("%s.bin" % layername)

	if len(data) / pixelsize != size.x * size.y:
		return Error.ERR_FILE_CORRUPT

	loaded[layername] = Image.create_from_data(size.x, size.y, false, Image.FORMAT_RGBAF, data)

	return Error.OK

const TRUTHY_NAMES : Array[String] = [
	'true',
	'yes',
	'on'
]

func update_dict_from_line(dict : Dictionary[StringName, Variant],
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
		TYPE_VECTOR2I:
			vals = parts[1].split(' ', true)
			if len(vals) >= 2 and \
			   vals[0].is_valid_int() and \
			   vals[1].is_valid_int():
				dict[key] = Vector2i(vals[0].to_int(), vals[1].to_int())
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

func load_map(mapname : String) -> Dictionary:
	var pixelsize : int = Image.create_empty(1, 1, false, Image.FORMAT_RGBAF).get_data_size()

	var reader = ZIPReader.new()
	var err = reader.open("user://%s.zip" % mapname)
	if err != OK:
		return {&'error': err}

	var size : Vector2i
	var pos : Vector2i

	var info : Dictionary[StringName, Variant] = {&'error': Error.OK}
	var info_file : String = reader.read_file("info.txt").get_string_from_utf8()

	for line in info_file.split('\n', false):
		update_dict_from_line(info, &'version', line, TYPE_INT)
		update_dict_from_line(info, &'size', line, TYPE_VECTOR2I)
		update_dict_from_line(info, &'pos', line, TYPE_VECTOR2I)
		update_dict_from_line(info, &'dir', line, TYPE_INT)
		update_dict_from_line(info, &'fog_color', line, TYPE_COLOR)
		update_dict_from_line(info, &'fog_power', line, TYPE_FLOAT)
		update_dict_from_line(info, &'eye_height', line, TYPE_FLOAT)
		update_dict_from_line(info, &'textures', line, TYPE_STRING)

	if (&'version' not in info or info[&'version'] != MAP_VERSION) or \
	   (&'size' not in info):
		return {&'error': Error.ERR_FILE_UNRECOGNIZED}

	size = info[&'size']
	if size.x < 1 or size.y < 1:
		return {&'error': Error.ERR_FILE_UNRECOGNIZED}

	var loaded : Dictionary[StringName, Image] = {}
	for layer in MAP_LAYERS:
		err = load_layer(reader, layer, loaded, pixelsize, size)
		if err != Error.OK:
			return {&'error': err}

	images = loaded
	for layer in MAP_LAYERS:
		terrain.set_image(layer, images[layer])

	if &'pos' in info:
		pos = info[&'pos']
		if pos.x >= 0 and pos.x < size.x and \
		   pos.y >= 0 and pos.y < size.y:
			set_pos(pos)
		else:
			info.erase(&'pos')
	if &'dir' in info:
		set_dir(info[&'dir'])
	if &'fog_power' in info:
		set_fog_power(info[&'fog_power'])
	if &'fog_color' in info:
		set_fog_color(info[&'fog_color'])
	if &'eye_height' in info and &'pos' in info:
		set_eye_height(get_val(MapParameters.FLOOR,
							   MapParameters.HORIZ,
							   0, # don't care about direction
							   MapParameters.TOP,
							   MapParameters.HEIGHT,
							   pos) + info[&'eye_height'])
	else:
		info.erase(&'eye_height')
	if &'textures' in info:
		set_texture(info[&'textures'], reader, mapname)

	reader.close()

	return info

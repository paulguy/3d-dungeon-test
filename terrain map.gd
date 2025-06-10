extends Node3D

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

const MINIMUM_HUE : float = 0.0001
const PARAM_MIN : Array[float] = [-1.79769e308, MINIMUM_HUE, 0.0, 0.0]

const DEFAULT_TEX_PATH : String = "textures"
const DEFAULT_TEX_FILE : String = "textures.txt"

var dims : Vector2i = Vector2i.ZERO
var images : Dictionary[StringName, Image]
var staging_images : Dictionary[StringName, Image]
var staging_texture
var texdefs : TexDefs
var staging_texdefs
var clear_color : Dictionary[StringName, Color] = {
	&'face_heights': Color(2.0, 1.0, 0.0, -1.0),
	&'face_offsets': Color(0.0, 0.0, 0.0, 0.0),
	&'face_hues_and_biases': Color(MINIMUM_HUE, 1.0, MINIMUM_HUE, 1.0),
	&'floor_side_texture_offsets': Color(1.0, 1.0, 1.0, 1.0),
	&'floor_north_south_hues': Color(MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE),
	&'floor_north_south_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'floor_east_west_hues': Color(MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE),
	&'floor_east_west_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'ceiling_north_south_hues': Color(MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE),
	&'ceiling_north_south_biases': Color(1.0, 1.0, 1.0, 1.0),
	&'ceiling_east_west_hues': Color(MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE, MINIMUM_HUE),
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

func read_tex_defs(texdefstr : String, reader = null) -> TexDefs:
	var new_texdefs : TexDefs = TexDefs.new()

	var info : Dictionary[StringName, Variant] = {}

	for line in texdefstr.split('\n', false):
		FileUtilities.update_dict_from_line(info, &'width', line, TYPE_INT)
		FileUtilities.update_dict_from_line(info, &'texture', line, TYPE_STRING)
		# TODO: Animations?

		if new_texdefs.width <= 0 and &'width' in info:
			new_texdefs.width = info[&'width']

		if &'texture' in info:
			if new_texdefs.width <= 0:
				return TexDefs.new()

			var texpath : String = DEFAULT_TEX_PATH.path_join(info[&'texture'])
			var restexpath : String = "res://%s" % texpath

			if reader != null and reader.file_exists(texpath):
				# texture from ZIP
				new_texdefs.append(TexDef.new(texpath))
			elif FileAccess.file_exists(restexpath):
				# texture from built in resources
				new_texdefs.append(TexDef.new(restexpath))
				# TODO: Textures from user dir
			else:
				# texture not found
				return TexDefs.new()

			info.erase(&'texture')

	return new_texdefs

func set_textures(reader = null, mapname = null) -> bool:
	var texdefstr : String

	var texdefpath : String = DEFAULT_TEX_PATH.path_join(DEFAULT_TEX_FILE)

	if reader == null or not reader.file_exists(texdefpath):
		# don't check for errors, if the defualt is missing, something is broken
		var infile : FileAccess = FileAccess.open("res://%s" % texdefpath, FileAccess.READ)
		texdefstr = infile.get_as_text()
		infile.close()
	else:
		texdefstr = reader.read_file(texdefpath).get_string_from_utf8()

	staging_texdefs = read_tex_defs(texdefstr)
	if staging_texdefs.width <= 0 or len(staging_texdefs.texdefs) == 0:
		return false

	var teximages : Array[Image] = []
	var totalheight : int = 0

	for texdef in staging_texdefs.texdefs:
		var image : Image = Image.new()

		var texfilename : String = texdef.texnames[0]

		if texfilename.begins_with("res://") or texfilename.begins_with("user://"):
			image.load_png_from_buffer(FileAccess.get_file_as_bytes(texdef.texnames[0]))
		else:
			image.load_png_from_buffer(reader.read_file(texdef.texnames[0]))

		if image.get_width() != staging_texdefs.width:
			return false

		teximages.append(image)
		totalheight += image.get_height()

	staging_texture = Image.create_empty(staging_texdefs.width, totalheight, true, Image.FORMAT_RGBA8)

	var cur_y : int = 0
	for image in teximages:
		image.generate_mipmaps()
		staging_texture.blit_rect(image,
								  Rect2i(Vector2i.ZERO, image.get_size()),
								  Vector2i(0, cur_y))
		cur_y += image.get_height()

	return true

func init_default_world(dimensions : Vector2i):
	set_textures()
	texdefs = staging_texdefs
	staging_texdefs = null
	terrain.set_texture(ImageTexture.create_from_image(staging_texture))
	staging_texture = null

	dims = dimensions
	for layer in MAP_LAYERS:
		init_clear_texture(layer)

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

func set_depth(depth):
	return terrain.set_depth(depth)

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
				return DirParameters.get_opp_dir(dir) + topbottom
			else: # east in 1, out 0  west in 3 out 2
				return DirParameters.get_opp_dir(dir) - 1 + topbottom
	elif parameter == MapParameters.BIAS:
		if face == 0:
			return mesh * 2 + 1
		else:
			if dir % 2 == 0:
				return DirParameters.get_opp_dir(dir) + topbottom
			else:
				return DirParameters.get_opp_dir(dir) - 1 + topbottom
	elif parameter == MapParameters.OFFSET:
		if face == 0:
			return mesh * 2 + topbottom
		else:
			if mesh == 0:
				return DirParameters.get_opp_dir(dir)
			else:
				return DirParameters.get_opp_dir(dir)

	return -1

func change(mesh : int, face : int, dir : int, topbottom : int, parameter : int,
			val : float, pos : Vector2i):
	var imagename : StringName = lookup_name(mesh, face, dir, parameter)
	var image : Image = images[imagename]
	var col : Color = image.get_pixelv(pos)
	var offset : int = lookup_offset(mesh, face, dir, topbottom, parameter)
	col[offset] = max(col[offset] + val, PARAM_MIN[parameter])
	image.set_pixelv(pos, col)
	terrain.set_image(imagename, image)

func set_val(mesh : int, face : int, dir : int, topbottom : int, parameter : int,
			 val : float, pos : Vector2i):
	var imagename : StringName = lookup_name(mesh, face, dir, parameter)
	var image : Image = images[imagename]
	var col : Color = image.get_pixelv(pos)
	col[lookup_offset(mesh, face, dir, topbottom, parameter)] = max(val, PARAM_MIN[parameter])
	image.set_pixelv(pos, col)
	terrain.set_image(imagename, image)

func get_val(mesh : int, face : int, dir : int, topbottom : int, parameter : int,
			pos : Vector2i) -> float:
	var imagename : StringName = lookup_name(mesh, face, dir, parameter)
	var image : Image = images[imagename]
	var val : float = image.get_pixelv(pos)[lookup_offset(mesh, face, dir, topbottom, parameter)]
	if val < 0.0 and parameter == MapParameters.HUE:
		val *= -1.0
	return val

func toggle_sky_draw(mesh : int, face : int, dir : int, topbottom : int,
					 pos : Vector2i):
	var imagename : StringName = lookup_name(mesh, face, dir, MapParameters.HUE)
	var image : Image = images[imagename]
	var col : Color = image.get_pixelv(pos)
	col[lookup_offset(mesh, face, dir, topbottom, MapParameters.HUE)] *= -1.0
	image.set_pixelv(pos, col)
	terrain.set_image(imagename, image)

func set_sky_draw(mesh : int, face : int, dir : int, topbottom : int,
				  val : bool, pos : Vector2i):
	var imagename : StringName = lookup_name(mesh, face, dir, MapParameters.HUE)
	var image : Image = images[imagename]
	var col : Color = image.get_pixelv(pos)
	var offset : int = lookup_offset(mesh, face, dir, topbottom, MapParameters.HUE)
	col[offset] = abs(col[offset]) * (-1.0 if val else 1.0)
	image.set_pixelv(pos, col)
	terrain.set_image(imagename, image)

func get_sky_draw(mesh : int, face : int, dir : int, topbottom : int, pos : Vector2i):
	var imagename : StringName = lookup_name(mesh, face, dir, MapParameters.HUE)
	var image : Image = images[imagename]
	return image.get_pixelv(pos)[lookup_offset(mesh, face, dir, topbottom, MapParameters.HUE)] < 0.0

func write_tex_defs(writer : ZIPPacker) -> Error:
	var err : Error = writer.start_file(DEFAULT_TEX_PATH.path_join(DEFAULT_TEX_FILE))
	if err != Error.OK:
		return err

	err = FileUtilities.write_line(writer, ("width %d" % texdefs.width))
	if err != Error.OK:
		return err

	for texdef in texdefs.texdefs:
		err = FileUtilities.write_line(writer, ("texture %s" % texdef.texnames[0].get_file()))
		if err != Error.OK:
			return err

	err = writer.close_file()
	if err != Error.OK:
		return err

	return Error.OK

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

func save_map(writer : ZIPPacker) -> Error:
	var err : Error

	err = write_tex_defs(writer)
	if err != Error.OK:
		return err

	for layer in MAP_LAYERS:
		err = write_image(writer, layer)
		if err != Error.OK:
			return err

	return Error.OK

func load_layer(reader : ZIPReader, layername : StringName,
				pixelsize : int, size : Vector2i,
				version : int) -> Error:
	var data : PackedByteArray = reader.read_file("%s.bin" % layername)

	if len(data) / pixelsize != size.x * size.y:
		return Error.ERR_FILE_CORRUPT

	if version < 2:
		# add flag to hue parameter
		if layername == &'face_hues_and_biases':
			var fdata : PackedFloat32Array = data.to_float32_array()
			for i in len(fdata) / 2:
				fdata[i * 2] = max(fdata[i * 2], MINIMUM_HUE)
			data = fdata.to_byte_array()
		elif layername == &'floor_north_south_hues' or \
			 layername == &'floor_east_west_hues' or \
			 layername == &'ceiling_north_south_hues' or \
			 layername == &'ceiling_east_west_hues':
			var fdata : PackedFloat32Array = data.to_float32_array()
			for i in len(fdata):
				fdata[i] = max(fdata[i], MINIMUM_HUE)
			data = fdata.to_byte_array()

	staging_images[layername] = Image.create_from_data(size.x, size.y, false, Image.FORMAT_RGBAF, data)

	return Error.OK

func load_map(reader : ZIPReader, mapsize : Vector2i, version : int) -> Error:
	var err : Error
	var pixelsize : int = Image.create_empty(1, 1, false, Image.FORMAT_RGBAF).get_data_size()

	staging_images = {}
	for layer in MAP_LAYERS:
		err = load_layer(reader, layer, pixelsize, mapsize, version)
		if err != Error.OK:
			return err

	return Error.OK

func apply_staged():
	texdefs = staging_texdefs
	staging_texdefs = null
	terrain.set_texture(ImageTexture.create_from_image(staging_texture))
	staging_texture = null

	images = staging_images
	for layer in MAP_LAYERS:
		terrain.set_image(layer, images[layer])
	staging_images = {}

func discard_staged():
	staging_texdefs = null
	staging_texture = null
	staging_images = {}

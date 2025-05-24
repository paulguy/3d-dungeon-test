extends Node3D

# TODO: that ugly stripe along left of center (worked around with 2x MSAA, not "fixed")
#       box select/operations

const MAP_VERSION : int = 1

const DEFAULT_EYE_HEIGHT : float = 0.5
const PLAYER_HEIGHT : float = 0.8
const CLIMB_HEIGHT : float = 0.5
const FIT_HEIGHT : float = 0.4
const GRAVITY : float = 0.8

const PROPS_DIR : String = "props"

@onready var terrain : Node3D = $'Terrain Map'
@onready var hud_status : Label = $'HUD/Status'
@onready var props : PropsManager = $'Props'

enum RunMode {
	TERRAIN,
	PROPS,
	EVENTS,
	PLAY
}

var MODE_FUNCS : Dictionary[RunMode, Callable] = {
	RunMode.TERRAIN: terrain_process,
	RunMode.PROPS: props_process,
	RunMode.EVENTS: events_process,
	RunMode.PLAY: play_process
}

const MAX_DEPTH : int = 49
var eye_height : float = DEFAULT_EYE_HEIGHT
var ceiling_attach : bool = false
var world_width : int = 128
var world_height : int = 128
var fog_power : float = 0.5
var fog_color : Color = Color(0.0, 0.0, 0.0)
var depth : int
var textures : String = "textures"

const CHANGE_SPEEDS : Array[Array] = [
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[1.0/64.0, 1.0/8.0, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[1.0, 1.0, 10.0]
]

const ROTATION_SPEEDS : Array[float] = [
	PI / 64.0, PI / 16.0, PI / 2.0
]

func NO_CB(_s : String):
	pass

var mode : RunMode = RunMode.TERRAIN
var last_mode : RunMode = mode
var pos : Vector2i = Vector2i(world_width / 2, world_height / 2)
var dir : int = 0
var stored : float = 0.0
var stored_heights : Array[float] = [2.0, 1.0, 0.0, -1.0]
# top hue, top bias, bottom hue, bottom bias, offset
var stored_ceiling : Array[float] = [0.0, 1.0, 0.0, 1.0, 0.0]
var stored_floor : Array[float] = [0.0, 1.0, 0.0, 1.0, 0.0]
# hue, bias, offset
var stored_face : Array[float] = [0.0, 1.0, 0.0]
var last_mapname : String = "untitled"

var text_entry_prefix : String = ""
var text_entry_text : String = ""
var text_entry_cb : Callable = NO_CB

var play_height : float = 0.0
var floor_height : float = 0.0
var play_fall_vel : float = 0.0

# ceiling, floor
var mesh : int = 0
# horiz, wall
var face : int = 0
# top, bottom (for vert, height)
var topbottom : int = 0
# height, hue, bias, offset, (fog r, g, b, fog power, eye height)
var t_parameter : int = 0

var respropdefs : Dictionary
var userpropdefs : Dictionary
var propdefs : Dictionary[StringName, PropDef]
var propnames : Array[StringName]
var selected_pdef : int = -1
var selected_prop : int = -1
var p_parameter : int = 0

var status_set : bool = false
var status_str : String

# TODO: delete props
func add_prop(p : Dictionary[String, PropDef], pname : String, source : String, image : Texture2D):
	pname = StringName(pname.get_basename())
	p[pname] = PropDef.new(pname, source, image)

func scan_props_dir(source : String, path : String):
	var p : Dictionary[String, PropDef] = {}
	var err : Error
	var image : Image

	if source == 'map':
		# map zip
		var zipfile : ZIPReader = ZIPReader.new()
		err = zipfile.open(path)
		if err != Error.OK:
			return {}
		for filename in zipfile.get_files():
			if filename.get_base_dir() == PROPS_DIR and \
			   filename.get_extension().to_lower() == 'png':
				image = Image.new()
				err = image.load_png_from_buffer(zipfile.read_file(filename))
				if err != Error.OK:
					continue
				add_prop(p, filename.get_file(), source, ImageTexture.create_from_image(image))
		zipfile.close()
	else:
		var propdir : DirAccess = DirAccess.open(path)
		if propdir:
			for filename in propdir.get_files():
				if filename.to_lower().get_extension() == 'png':
					if source == 'user' or source == 'mapuser':
						# user:// paths for global overrides and map overrides
						image = Image.new()
						image.load(path.path_join(filename))
						if err != Error.OK:
							continue
						add_prop(p, filename, source, ImageTexture.create_from_image(image))
					else:
						# res:// paths don't need much
						add_prop(p, filename, source, load(path.path_join(filename)))

	return p

func set_prop_defs(to_add : Array[Dictionary]):
	propdefs = {}
	for item in to_add:
		propdefs.merge(item, true)
	propnames = propdefs.keys()
	if len(propdefs) > 0:
		selected_pdef = 0

func free_map_images():
	var clearlist : Array[String] = []

	for def in propdefs:
		if propdefs[def].source == 'map' or propdefs[def].source == 'mapuser':
			clearlist.append(def)

	for item in clearlist:
		propdefs.erase(item)

func get_relative_to_dir(f_amount : int, s_amount : int):
	var rel : Vector2i = Vector2i.ZERO

	match dir:
		DirParameters.NORTH:
			rel.y -= f_amount
			rel.x += s_amount
		DirParameters.EAST:
			rel.x += f_amount
			rel.y += s_amount
		DirParameters.SOUTH:
			rel.y += f_amount
			rel.x -= s_amount
		_: # west
			rel.x -= f_amount
			rel.y -= s_amount

	return rel

func get_facing_pos():
	return pos + get_relative_to_dir(1, 0)

func change_parameter(amount : float):
	var p : Vector2i = get_facing_pos()
	if t_parameter <= MapParameters.GEOMETRY_PARAMETERS_MAX:
		terrain.change(mesh, face, dir, topbottom, t_parameter, amount, p)
		if t_parameter == MapParameters.HEIGHT and \
		   (mesh == MapParameters.FLOOR and \
			topbottom == MapParameters.TOP) or \
		   (mesh == MapParameters.CEILING and \
			topbottom == MapParameters.FLOOR):
			props.update_height(p)
	elif t_parameter == MapParameters.FOG_COLOR_R:
		fog_color.r += amount
		set_fog_color()
	elif t_parameter == MapParameters.FOG_COLOR_G:
		fog_color.g += amount
		set_fog_color()
	elif t_parameter == MapParameters.FOG_COLOR_B:
		fog_color.b += amount
		set_fog_color()
	elif t_parameter == MapParameters.FOG_POWER:
		fog_power += amount
		set_fog_power()
	elif t_parameter == MapParameters.DEPTH:
		depth += amount
		set_depth()

func set_terrain_parameter(val : float, m : int = -1, f : int = -1, t : int = -1, p : int = -1):
	var fp : Vector2i = get_facing_pos()

	var r_mesh : int = mesh
	var r_face : int = face
	var r_tb : int = topbottom
	var r_param : int = t_parameter
	if m >= 0:
		r_mesh = m
	if f >= 0:
		r_face = f
	if t >= 0:
		r_tb = t
	if p >= 0:
		r_param = p

	if r_param <= MapParameters.GEOMETRY_PARAMETERS_MAX:
		terrain.set_val(r_mesh, r_face, dir, r_tb, r_param, val, fp)
	elif r_param == MapParameters.FOG_COLOR_R:
		fog_color.r = val
		set_fog_color()
	elif r_param == MapParameters.FOG_COLOR_G:
		fog_color.g = val
		set_fog_color()
	elif r_param == MapParameters.FOG_COLOR_B:
		fog_color.b = val
		set_fog_color()
	elif r_param == MapParameters.FOG_POWER:
		fog_power = val
		set_fog_power()
	elif r_param == MapParameters.DEPTH:
		depth = val
		set_depth()

func get_terrain_parameter(m : int = -1, f : int = -1, t : int = -1, p : int = -1, d_pos = null) -> float:
	if d_pos == null:
		d_pos = get_facing_pos()

	var r_mesh : int = mesh
	var r_face : int = face
	var r_tb : int = topbottom
	var r_param : int = t_parameter
	if m >= 0:
		r_mesh = m
	if f >= 0:
		r_face = f
	if t >= 0:
		r_tb = t
	if p >= 0:
		r_param = p

	if r_param <= MapParameters.GEOMETRY_PARAMETERS_MAX:
		return terrain.get_val(r_mesh, r_face, dir, r_tb, r_param, d_pos)
	elif r_param == MapParameters.FOG_COLOR_R:
		return fog_color.r
	elif r_param == MapParameters.FOG_COLOR_G:
		return fog_color.g
	elif r_param == MapParameters.FOG_COLOR_B:
		return fog_color.b
	elif r_param == MapParameters.FOG_POWER:
		return fog_power
	elif r_param == MapParameters.DEPTH:
		return depth
	return 0.0

func get_prop_val(prop_pos : Vector2i) -> Variant:
	if props.has_prop(prop_pos, selected_prop):
		match p_parameter:
			Prop.BILLBOARD:
				return props.props[prop_pos][selected_prop].billboard
			Prop.ONE_SIDED:
				return props.props[prop_pos][selected_prop].one_sided
			Prop.ATTACHMENT:
				return props.props[prop_pos][selected_prop].ceiling_attach
			Prop.H_MODE:
				return props.props[prop_pos][selected_prop].horizontal_mode
			Prop.SCALE_H:
				return props.props[prop_pos][selected_prop].scale.x
			Prop.SCALE_V:
				return props.props[prop_pos][selected_prop].scale.y
			Prop.COLOR_HUE:
				return props.props[prop_pos][selected_prop].hue
			Prop.COLOR_BIAS:
				return props.props[prop_pos][selected_prop].bias
			Prop.COLOR_ALPHA:
				return props.props[prop_pos][selected_prop].alpha
			Prop.POS_X:
				return props.props[prop_pos][selected_prop].pos.x
			Prop.POS_Y:
				return props.props[prop_pos][selected_prop].pos.y
			Prop.POS_Z:
				return props.props[prop_pos][selected_prop].pos.z
			Prop.ANGLE:
				return props.props[prop_pos][selected_prop].angle

	return null

func set_prop_val(prop_pos : Vector2i, prop_val : Variant = null):
	match p_parameter:
		Prop.BILLBOARD:
			props.toggle_billboard(prop_pos, selected_prop)
		Prop.ONE_SIDED:
			props.toggle_one_sided(prop_pos, selected_prop)
		Prop.ATTACHMENT:
			props.toggle_ceiling_attach(prop_pos, selected_prop)
		Prop.H_MODE:
			props.toggle_horizontal_mode(prop_pos, selected_prop)
		Prop.SCALE_H:
			props.set_prop_scale_h(prop_pos, selected_prop, prop_val)
		Prop.SCALE_V:
			props.set_prop_scale_v(prop_pos, selected_prop, prop_val)
		Prop.COLOR_HUE:
			props.set_hue(prop_pos, selected_prop, prop_val)
		Prop.COLOR_BIAS:
			props.set_bias(prop_pos, selected_prop, prop_val)
		Prop.COLOR_ALPHA:
			props.set_alpha(prop_pos, selected_prop, prop_val)
		Prop.POS_X:
			props.set_pos_x(prop_pos, selected_prop, prop_val)
		Prop.POS_Y:
			props.set_pos_y(prop_pos, selected_prop, prop_val)
		Prop.POS_Z:
			props.set_pos_z(prop_pos, selected_prop, prop_val)
		Prop.ANGLE:
			props.set_angle(prop_pos, selected_prop, prop_val)

func status(val : String = ""):
	if len(val) == 0:
		match mode:
			RunMode.TERRAIN:
				status_str = "Terra %d,%d %s %s %s %s %s =%.2f" % [pos.x, pos.y,
																  DirParameters.dir_string(dir),
																  MapParameters.mesh_string(mesh),
																  MapParameters.face_string(face),
																  MapParameters.topbottom_string(topbottom),
																  MapParameters.parameter_string(t_parameter),
																  get_terrain_parameter()]
			RunMode.PROPS:
				if len(propnames) > 0:
					var prop_pos : Vector2i = get_facing_pos()
					if prop_pos in props.props:
						var propval = get_prop_val(prop_pos)
						status_str = "Props %d,%d %s %s-%s %d:%s %s=%s" % [pos.x, pos.y,
																		  DirParameters.dir_string(dir),
																		  propdefs[propnames[selected_pdef]].source,
																		  propnames[selected_pdef],
																		  selected_prop,
																		  props.props[prop_pos][selected_prop].def.name,
																		  Prop.parameter_string(p_parameter),
																		  Prop.value_string(p_parameter, propval)]
					else:
						status_str = "Props %d,%d %s %s-%s %s=" % [pos.x, pos.y,
																  DirParameters.dir_string(dir),
																  propdefs[propnames[selected_pdef]].source,
																  propnames[selected_pdef],
																  Prop.parameter_string(p_parameter)]
				else:
					status_str = "Props %d,%d %s NO PROPDEFS" % [pos.x, pos.y,
																DirParameters.dir_string(dir)]
			RunMode.EVENTS:
				status_str = "Event %d,%d %s" % [pos.x, pos.y,
												 DirParameters.dir_string(dir)]
	else:
		status_str = val
	status_set = true

func apply_status():
	if status_set and hud_status.visible:
		hud_status.text = status_str
	status_set = false

func status_visibility(v : bool):
	if v:
		hud_status.visible = true
	else:
		hud_status.visible = false

func get_eye_height() -> float:
	if ceiling_attach:
		return get_terrain_parameter(MapParameters.CEILING,
									 MapParameters.HORIZ,
									 MapParameters.BOTTOM,
									 MapParameters.HEIGHT,
									 pos) - eye_height

	return get_terrain_parameter(MapParameters.FLOOR,
								 MapParameters.HORIZ,
								 MapParameters.TOP,
								 MapParameters.HEIGHT,
								 pos) + eye_height

func set_pos():
	terrain.set_pos(pos)
	props.set_view_pos(pos)

func set_dir():
	terrain.set_dir(dir)
	props.set_view_dir(dir)

func set_eye_height():
	terrain.set_eye_height(get_eye_height())
	props.set_eye_height(get_eye_height())

func set_env_bg_color():
	# converted from shader
	var fog_ratio : float = pow(MAX_DEPTH / (depth + 1.0), fog_power)
	var bgcolor : Color = (Color.WHITE * (1.0 - fog_ratio)) + (fog_color * fog_ratio)
	bgcolor.r = max(0.0, bgcolor.r)
	bgcolor.g = max(0.0, bgcolor.g)
	bgcolor.b = max(0.0, bgcolor.b)
	$'WorldEnvironment'.environment.background_color = bgcolor

func set_depth():
	depth = terrain.set_depth(depth)
	set_env_bg_color()

func set_fog_color():
	terrain.set_fog_color(fog_color)
	set_env_bg_color()

func set_fog_power():
	terrain.set_fog_power(fog_power)
	set_env_bg_color()

func set_text_entry_mode(cb : Callable, prefix : String = "", def : String = ""):
	text_entry_prefix = prefix
	text_entry_text = String(def)
	text_entry_cb = cb
	update_entry()

func clear_text_entry_mode():
	text_entry_text = ""
	text_entry_cb = NO_CB

func update_entry():
	status("%s>%s" % [text_entry_prefix, text_entry_text])

func _input(event : InputEvent):
	if text_entry_cb != NO_CB:
		if event is InputEventKey and event.is_pressed():
			var key_event : InputEventKey = event
			if key_event.keycode == KEY_ENTER:
				text_entry_cb.call(text_entry_text)
				clear_text_entry_mode()
			elif key_event.keycode == KEY_ESCAPE:
				clear_text_entry_mode()
				status()
			elif key_event.keycode == KEY_BACKSPACE:
				if len(text_entry_text) > 0:
					text_entry_text = text_entry_text.substr(0, len(text_entry_text) - 1)
					update_entry()
			else:
				text_entry_text = "%s%c" % [text_entry_text, key_event.unicode]
				update_entry()

func get_alternate_eye_height() -> float:
	var f_height : float = get_terrain_parameter(MapParameters.FLOOR,
												MapParameters.HORIZ,
												MapParameters.TOP,
												MapParameters.HEIGHT,
												pos)
	var c_height : float = get_terrain_parameter(MapParameters.CEILING,
												MapParameters.HORIZ,
												MapParameters.BOTTOM,
												MapParameters.HEIGHT,
												pos)

	return c_height - f_height - eye_height

func save_global_params(writer : ZIPPacker) -> Error:
	var err : Error

	err = writer.start_file("info.txt")
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("version %d\n" % MAP_VERSION))
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("size %d %d\n" % [terrain.dims.x,
															   terrain.dims.y]))
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("pos %d %d\n" % [pos.x, pos.y]))
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("dir %d\n" % dir))
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("fog_color %f %f %f\n" % [fog_color.r,
																	   fog_color.g,
																	   fog_color.b]))
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("fog_power %f\n" % fog_power))
	if err != Error.OK:
		return err

	# don't store ceiling attachment, but store the eye height as it would
	# be seen
	var real_eye_height = eye_height
	if ceiling_attach:
		real_eye_height = get_alternate_eye_height()
	err = FileUtilities.write_string(writer, ("eye_height %f\n" % real_eye_height))
	if err != Error.OK:
		return err

	err = FileUtilities.write_string(writer, ("textures %s\n" % textures))
	if err != Error.OK:
		return err

	err = writer.close_file()
	if err != Error.OK:
		return err

	return Error.OK

func savemap(mapname : String) -> Error:
	var err : Error
	last_mapname = mapname

	var tempname : String = FileUtilities.make_temp_filename("%s-" % mapname)
	var writer : ZIPPacker = ZIPPacker.new()
	err = writer.open("user://%s.zip" % tempname)
	if err != Error.OK:
		return err

	err = save_global_params(writer)
	if err != Error.OK:
		return err

	err = props.save_props(writer)
	if err != Error.OK:
		return err

	err = terrain.save_map(writer)
	if err != Error.OK:
		return err

	writer.close()

	var userdir : DirAccess = DirAccess.open("user://")
	userdir.rename("%s.zip" % tempname, "%s.zip" % mapname)

	return Error.OK

func do_save(mapname : String):
	var err : Error = savemap(mapname)
	if err != Error.OK:
		status("Save failed: %s" % error_string(err))
	else:
		status("Map %s saved" % mapname)

func loadmap(mapname : String) -> Error:
	var err : Error
	last_mapname = mapname

	var mapsize : Vector2i
	var mappos : Vector2i

	var reader = ZIPReader.new()
	err = reader.open("user://%s.zip" % mapname)
	if err != OK:
		return err

	var info : Dictionary[StringName, Variant] = {}
	var info_file : String = reader.read_file("info.txt").get_string_from_utf8()

	for line in info_file.split('\n', false):
		FileUtilities.update_dict_from_line(info, &'version', line, TYPE_INT)
		FileUtilities.update_dict_from_line(info, &'size', line, TYPE_VECTOR2I)
		FileUtilities.update_dict_from_line(info, &'pos', line, TYPE_VECTOR2I)
		FileUtilities.update_dict_from_line(info, &'dir', line, TYPE_INT)
		FileUtilities.update_dict_from_line(info, &'fog_color', line, TYPE_COLOR)
		FileUtilities.update_dict_from_line(info, &'fog_power', line, TYPE_FLOAT)
		FileUtilities.update_dict_from_line(info, &'eye_height', line, TYPE_FLOAT)
		FileUtilities.update_dict_from_line(info, &'textures', line, TYPE_STRING)

	if (&'version' not in info or info[&'version'] != MAP_VERSION) or \
	   (&'size' not in info):
		return Error.ERR_FILE_UNRECOGNIZED

	mapsize = info[&'size']
	if mapsize.x < 1 or mapsize.y < 1:
		return Error.ERR_FILE_UNRECOGNIZED

	err = terrain.load_map(reader, mapsize)
	if err != Error.OK:
		return err

	err = props.load_props(reader)
	if err != Error.OK:
		terrain.discard_staged()
		return err

	if &'pos' in info:
		mappos = info[&'pos']
		if mappos.x >= 0 and mappos.x < mapsize.x and \
		   mappos.y >= 0 and mappos.y < mapsize.y:
			pos = mappos
			if &'eye_height' in info:
				eye_height = info[&'eye_height']
	if &'dir' in info:
		dir = info[&'dir']
	if &'fog_power' in info:
		fog_power = info[&'fog_power']
		set_fog_power()
	if &'fog_color' in info:
		fog_color = info[&'fog_color']
		set_fog_color()
	if &'textures' in info:
		terrain.set_texture(info[&'textures'], reader, mapname)

	reader.close()

	terrain.apply_staged()

	# load propdefs
	set_prop_defs([respropdefs,
				   userpropdefs,
				   scan_props_dir('map', "user://%s.zip" % mapname),
				   scan_props_dir('mapuser', "user://".path_join(PROPS_DIR).path_join(mapname))])

	# apply this after pos and dir are set so it sets up the initial visible
	# props correctly, also needs the new heightmap
	props.heightmap = terrain.images[&'face_heights']
	props.apply_staged(propdefs)

	# these depend on values in terrain and props being up to date
	set_pos()
	set_dir()
	set_eye_height()

	return Error.OK

func do_load(mapname : String):
	var err : Error = loadmap(mapname)
	if err != Error.OK:
		terrain.discard_staged()
		status("Load failed: %s" % error_string(err))
	else:
		status("Map %s loaded" % mapname)

func do_store(num : String):
	if num.is_valid_float():
		stored = num.to_float()

func phys_move(d_pos : Vector2i):
	var heights : Array[float] = [get_terrain_parameter(MapParameters.CEILING,
												MapParameters.HORIZ,
												MapParameters.TOP,
												MapParameters.HEIGHT,
												pos),
								  get_terrain_parameter(MapParameters.CEILING,
												MapParameters.HORIZ,
												MapParameters.BOTTOM,
												MapParameters.HEIGHT,
												pos),
								  get_terrain_parameter(MapParameters.FLOOR,
												MapParameters.HORIZ,
												MapParameters.TOP,
												MapParameters.HEIGHT,
												pos),
								  get_terrain_parameter(MapParameters.FLOOR,
												MapParameters.HORIZ,
												MapParameters.BOTTOM,
												MapParameters.HEIGHT,
												pos)]
	var d_heights : Array[float] = [get_terrain_parameter(MapParameters.CEILING,
												  MapParameters.HORIZ,
												  MapParameters.TOP,
												  MapParameters.HEIGHT,
												  d_pos),
									get_terrain_parameter(MapParameters.CEILING,
												  MapParameters.HORIZ,
												  MapParameters.BOTTOM,
												  MapParameters.HEIGHT,
												  d_pos),
									get_terrain_parameter(MapParameters.FLOOR,
												  MapParameters.HORIZ,
												  MapParameters.TOP,
												  MapParameters.HEIGHT,
												  d_pos),
									get_terrain_parameter(MapParameters.FLOOR,
												  MapParameters.HORIZ,
												  MapParameters.BOTTOM,
												  MapParameters.HEIGHT,
												  d_pos)]
	# get the destination spot floor height, and whether the player can even traverse to it
	var d_floor = -1
	if play_height > d_heights[0] - CLIMB_HEIGHT:
		d_floor = 0
	elif play_height > d_heights[2] - CLIMB_HEIGHT and \
		 d_heights[1] - d_heights[2] > FIT_HEIGHT and \
		 heights[1] - d_heights[2] > FIT_HEIGHT and \
		 play_height - d_heights[1] > FIT_HEIGHT:
		 # can climb up
		 # can fit in the destination space
		 # can fit through the space between the current ceiling and destination floor
		 # can fit through the space between the current floor and destination ceiling
		d_floor = 2

	if d_floor >= 0:
		floor_height = d_heights[d_floor]
		if play_height < floor_height:
			# if player is coming from a lower level, climb up
			play_height = floor_height
		pos = d_pos

		terrain.set_eye_height(play_height + DEFAULT_EYE_HEIGHT)
		props.set_eye_height(play_height + DEFAULT_EYE_HEIGHT)

func move(f_amount : int, s_amount : int = 0, physics : bool = false):
	var d_pos : Vector2i = pos

	d_pos += get_relative_to_dir(f_amount, s_amount)

	if physics:
		phys_move(d_pos)
	else:
		pos = d_pos

func spin(amount : int):
	dir += amount

	if dir < 0:
		dir = 3
	elif dir > 3:
		dir = 0

func editor_common_process() -> Array[Variant]:
	var update_pos : bool = false
	var update_dir : bool = false
	var update_eye_height : bool = false
	var alternate : bool = false
	var change_speed : int = 1

	if Input.is_action_just_pressed(&'play'):
		last_mode = mode
		mode = RunMode.PLAY
		floor_height = get_terrain_parameter(MapParameters.FLOOR,
									MapParameters.HORIZ,
									MapParameters.TOP,
									MapParameters.HEIGHT,
									pos)
		play_height = floor_height
		status_visibility(false)
		return [false, false, 0]

	if Input.is_action_just_pressed(&'cycle mode'):
		match mode:
			RunMode.TERRAIN:
				mode = RunMode.PROPS
			RunMode.PROPS:
				mode = RunMode.EVENTS
			RunMode.EVENTS:
				mode = RunMode.TERRAIN
		status()
		return [false, false, 0]

	if Input.is_action_pressed(&'alternate function'):
		alternate = true

	if Input.is_action_pressed(&'slower'):
		change_speed -= 1

	if Input.is_action_pressed(&'faster'):
		change_speed += 1

	if Input.is_action_just_pressed(&'forward'):
		move(1)
		update_pos = true

	if Input.is_action_just_pressed(&'back'):
		move(-1)
		update_pos = true

	if Input.is_action_just_pressed(&'strafe left'):
		move(0, -1)
		update_pos = true

	if Input.is_action_just_pressed(&'strafe right'):
		move(0, 1)
		update_pos = true

	if Input.is_action_just_pressed(&'turn left'):
		spin(-1)
		update_dir = true

	if Input.is_action_just_pressed(&'turn right'):
		spin(1)
		update_dir = true

	if Input.is_action_just_pressed(&'up'):
		if ceiling_attach:
			eye_height -= pow(10.0, change_speed - 2)
		else:
			eye_height += pow(10.0, change_speed - 2)
		update_eye_height = true

	if Input.is_action_just_pressed(&'down'):
		if ceiling_attach:
			eye_height += pow(10.0, change_speed - 2)
		else:
			eye_height -= pow(10.0, change_speed - 2)
		update_eye_height = true

	if Input.is_action_just_pressed(&'view attach toggle'):
		eye_height = get_alternate_eye_height()
		ceiling_attach = not ceiling_attach
		update_eye_height = true

	if update_pos:
		set_pos()
		update_eye_height = true
		if len(propnames) > 0:
			selected_prop = 0
		status()

	if update_dir:
		set_dir()
		if len(propnames) > 0:
			selected_prop = 0
		status()

	if update_eye_height:
		set_eye_height()

	if Input.is_action_just_pressed(&'save'):
		set_text_entry_mode(do_save, "Save", last_mapname)

		return [false, false, 0]

	if Input.is_action_just_pressed(&'load'):
		set_text_entry_mode(do_load, "Load", last_mapname)
		return [false, false, 0]

	return [true, alternate, change_speed]

func terrain_process(_delta : float):
	var modifiers : Array[Variant] = editor_common_process()
	if not modifiers[0]:
		return

	var alternate : bool = modifiers[1]
	var change_speed : int = modifiers[2]

	if Input.is_action_just_pressed(&'cycle mesh'):
		if mesh == 0:
			mesh = 1
		else:
			mesh = 0
		status()

	if Input.is_action_just_pressed(&'cycle face'):
		if face == 0:
			face = 1
		else:
			face = 0
		status()

	if Input.is_action_just_pressed(&'cycle tb'):
		if topbottom == 0:
			topbottom = 1
		else:
			topbottom = 0
		status()

	if Input.is_action_just_pressed(&'cycle terrain parameter'):
		if alternate:
			t_parameter -= 1
			if t_parameter < 0:
				t_parameter = MapParameters.MAX_PARAMETER - 1
		else:
			t_parameter += 1
			if t_parameter >= MapParameters.MAX_PARAMETER:
				t_parameter = 0
		status()

	if Input.is_action_just_pressed(&'inc terrain parameter'):
		change_parameter(CHANGE_SPEEDS[t_parameter][change_speed])
		status()

	if Input.is_action_just_pressed(&'dec terrain parameter'):
		change_parameter(-CHANGE_SPEEDS[t_parameter][change_speed])
		status()

	if Input.is_action_just_pressed(&'terrain value'):
		if alternate:
			set_terrain_parameter(stored)
			status("Value applied.")
		else:
			stored = get_terrain_parameter()
			status("Value stored.")

	if Input.is_action_just_pressed(&'ceiling'):
		if alternate:
			set_terrain_parameter(stored_ceiling[0],
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.HUE)
			set_terrain_parameter(stored_ceiling[1],
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.BIAS)
			set_terrain_parameter(stored_ceiling[2],
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.BOTTOM,
								  MapParameters.HUE)
			set_terrain_parameter(stored_ceiling[3],
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.BOTTOM,
								  MapParameters.BIAS)
			set_terrain_parameter(stored_ceiling[4],
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.OFFSET)
			status("Ceiling wall parameters applied.")
		else:
			stored_ceiling = [get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.HUE),
							  get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.BIAS),
							  get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.BOTTOM,
								  MapParameters.HUE),
							  get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.BOTTOM,
								  MapParameters.BIAS),
							  get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.OFFSET)]
			status("Ceiling wall parameters stored.")

	if Input.is_action_just_pressed(&'face'):
		# topbottom only matters for offset but for consistency...
		if alternate:
			set_terrain_parameter(stored_face[0],
								  mesh,
								  MapParameters.HORIZ,
								  topbottom,
								  MapParameters.HUE)
			set_terrain_parameter(stored_face[1],
								  mesh,
								  MapParameters.HORIZ,
								  topbottom,
								  MapParameters.BIAS)
			set_terrain_parameter(stored_face[2],
								  mesh,
								  MapParameters.HORIZ,
								  topbottom,
								  MapParameters.OFFSET)
			status("Face parameters applied.")
		else:
			stored_face = [get_terrain_parameter(mesh,
												 MapParameters.HORIZ,
												 topbottom,
												 MapParameters.HUE),
						   get_terrain_parameter(mesh,
												 MapParameters.HORIZ,
												 topbottom,
												 MapParameters.BIAS),
						   get_terrain_parameter(mesh,
												 MapParameters.HORIZ,
												 topbottom,
												 MapParameters.OFFSET)]
			status("Face parameters stored.")

	if Input.is_action_just_pressed(&"floor"):
		if alternate:
			set_terrain_parameter(stored_floor[0],
								  MapParameters.FLOOR,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.HUE)
			set_terrain_parameter(stored_floor[1],
								  MapParameters.FLOOR,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.BIAS)
			set_terrain_parameter(stored_floor[2],
								  MapParameters.FLOOR,
								  MapParameters.WALL,
								  MapParameters.BOTTOM,
								  MapParameters.HUE)
			set_terrain_parameter(stored_floor[3],
								  MapParameters.FLOOR,
								  MapParameters.WALL,
								  MapParameters.BOTTOM,
								  MapParameters.BIAS)
			set_terrain_parameter(stored_floor[4],
								  MapParameters.FLOOR,
								  MapParameters.WALL,
								  MapParameters.TOP,
								  MapParameters.OFFSET)
			status("Floor wall parameters applied.")
		else:
			stored_floor = [get_terrain_parameter(
								MapParameters.FLOOR,
								MapParameters.WALL,
								MapParameters.TOP,
								MapParameters.HUE),
							get_terrain_parameter(
								MapParameters.FLOOR,
								MapParameters.WALL,
								MapParameters.TOP,
								MapParameters.BIAS),
							get_terrain_parameter(
								MapParameters.FLOOR,
								MapParameters.WALL,
								MapParameters.BOTTOM,
								MapParameters.HUE),
							get_terrain_parameter(
								MapParameters.FLOOR,
								MapParameters.WALL,
								MapParameters.BOTTOM,
								MapParameters.BIAS),
							get_terrain_parameter(
								MapParameters.FLOOR,
								MapParameters.WALL,
								MapParameters.TOP,
								MapParameters.OFFSET)]
			status("Floor wall parameters stored.")

	if Input.is_action_just_pressed(&'heights'):
		if alternate:
			set_terrain_parameter(stored_heights[0],
								  MapParameters.CEILING,
								  MapParameters.HORIZ,
								  MapParameters.TOP,
								  MapParameters.HEIGHT)
			set_terrain_parameter(stored_heights[1],
								  MapParameters.CEILING,
								  MapParameters.HORIZ,
								  MapParameters.BOTTOM,
								  MapParameters.HEIGHT)
			set_terrain_parameter(stored_heights[2],
								  MapParameters.FLOOR,
								  MapParameters.HORIZ,
								  MapParameters.TOP,
								  MapParameters.HEIGHT)
			set_terrain_parameter(stored_heights[3],
								  MapParameters.FLOOR,
								  MapParameters.HORIZ,
								  MapParameters.BOTTOM,
								  MapParameters.HEIGHT)
			status("Cell heights applied.")
		else:
			stored_heights = [get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.HORIZ,
								  MapParameters.TOP,
								  MapParameters.HEIGHT),
							  get_terrain_parameter(
								  MapParameters.CEILING,
								  MapParameters.HORIZ,
								  MapParameters.BOTTOM,
								  MapParameters.HEIGHT),
							  get_terrain_parameter(
								  MapParameters.FLOOR,
								  MapParameters.HORIZ,
								  MapParameters.TOP,
								  MapParameters.HEIGHT),
							  get_terrain_parameter(
								  MapParameters.FLOOR,
								  MapParameters.HORIZ,
								  MapParameters.BOTTOM,
								  MapParameters.HEIGHT)]
			status("Cell heights stored.")

	if Input.is_action_just_pressed(&'terrain value entry'):
		set_text_entry_mode(do_store, "Value", str(stored))

func change_prop_parameter(speed : float):
	var prop_pos : Vector2i = get_facing_pos()
	if Prop.SCALAR_PARAMETER[p_parameter]:
		set_prop_val(prop_pos, get_prop_val(prop_pos) + speed)
	else:
		set_prop_val(prop_pos)

func props_process(_delta : float):
	var modifiers : Array[Variant] = editor_common_process()
	if not modifiers[0]:
		return

	var alternate : bool = modifiers[1]
	var change_speed : int = modifiers[2]

	# TODO: status messages

	if Input.is_action_just_pressed(&'select prop def'):
		if len(propnames) > 0:
			if alternate:
				if selected_pdef == 0:
					selected_pdef = len(propnames) - 1
				else:
					selected_pdef -= 1
			else:
				if selected_pdef == len(propnames) - 1:
					selected_pdef = 0
				else:
					selected_pdef += 1
			status()

	if Input.is_action_just_pressed(&'select prop'):
		var prop_pos : Vector2i = get_facing_pos()
		if prop_pos in props.props:
			if alternate:
				if selected_prop == 0:
					selected_prop = len(props.props[prop_pos]) - 1
				else:
					selected_prop -= 1
			else:
				if selected_prop == len(props.props[prop_pos]) - 1:
					selected_prop = 0
				else:
					selected_prop += 1
			status()

	# TODO: alternate for copy prop as new default (then find a key to reset)
	if Input.is_action_just_pressed(&'place prop'):
		var prop_pos : Vector2i = get_facing_pos()
		props.add_prop(propdefs[propnames[selected_pdef]], prop_pos)
		if selected_prop < 0:
			selected_prop = 0
		status()

	if Input.is_action_just_pressed(&'cycle prop parameter'):
		if alternate:
			p_parameter -= 1
			if p_parameter < 0:
				p_parameter = Prop.MAX_PARAMETER - 1
		else:
			p_parameter += 1
			if p_parameter >= Prop.MAX_PARAMETER:
				p_parameter = 0
		status()

	if Input.is_action_just_pressed(&'dec prop parameter'):
		change_prop_parameter(-Prop.CHANGE_SPEEDS[change_speed])
		status()

	if Input.is_action_just_pressed(&'inc prop parameter'):
		change_prop_parameter(Prop.CHANGE_SPEEDS[change_speed])
		status()

	if Input.is_action_just_pressed(&'prop value'):
		if Prop.SCALAR_PARAMETER[p_parameter]:
			var prop_pos : Vector2i = get_facing_pos()
			if alternate:
				set_prop_val(prop_pos, stored)
				status()
			else:
				stored = get_prop_val(prop_pos)

	if Input.is_action_just_pressed(&'prop value entry'):
		set_text_entry_mode(do_store, "Value", str(stored))

	if Input.is_action_just_pressed(&'move prop up'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_cell_pos : Vector3 = props.get_pos(prop_pos, selected_prop)
		prop_cell_pos.y += pow(10.0, change_speed - 2)
		props.set_pos(prop_pos, selected_prop, prop_cell_pos)

	if Input.is_action_just_pressed(&'move prop down'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_cell_pos : Vector3 = props.get_pos(prop_pos, selected_prop)
		prop_cell_pos.y -= pow(10.0, change_speed - 2)
		props.set_pos(prop_pos, selected_prop, prop_cell_pos)

	if Input.is_action_just_pressed(&'move prop away'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_cell_pos : Vector3 = props.get_pos(prop_pos, selected_prop)
		var move_offset : Vector2 = Vector2(get_relative_to_dir(1, 0)) * pow(10.0, change_speed - 2)
		prop_cell_pos += Vector3(move_offset.x, 0.0, move_offset.y)
		props.set_pos(prop_pos, selected_prop, prop_cell_pos)

	if Input.is_action_just_pressed(&'move prop towards'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_cell_pos : Vector3 = props.get_pos(prop_pos, selected_prop)
		var move_offset : Vector2 = Vector2(get_relative_to_dir(-1, 0)) * pow(10.0, change_speed - 2)
		prop_cell_pos += Vector3(move_offset.x, 0.0, move_offset.y)
		props.set_pos(prop_pos, selected_prop, prop_cell_pos)

	if Input.is_action_just_pressed(&'move prop left'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_cell_pos : Vector3 = props.get_pos(prop_pos, selected_prop)
		var move_offset : Vector2 = Vector2(get_relative_to_dir(0, -1)) * pow(10.0, change_speed - 2)
		prop_cell_pos += Vector3(move_offset.x, 0.0, move_offset.y)
		props.set_pos(prop_pos, selected_prop, prop_cell_pos)

	if Input.is_action_just_pressed(&'move prop right'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_cell_pos : Vector3 = props.get_pos(prop_pos, selected_prop)
		var move_offset : Vector2 = Vector2(get_relative_to_dir(0, 1)) * pow(10.0, change_speed - 2)
		prop_cell_pos += Vector3(move_offset.x, 0.0, move_offset.y)
		props.set_pos(prop_pos, selected_prop, prop_cell_pos)

	if Input.is_action_just_pressed(&'rotate prop counter clockwise'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_angle : float = props.get_angle(prop_pos, selected_prop)
		prop_angle += ROTATION_SPEEDS[change_speed]
		if prop_angle >= TAU:
			prop_angle -= TAU
		props.set_angle(prop_pos, selected_prop, prop_angle)

	if Input.is_action_just_pressed(&'rotate prop clockwise'):
		var prop_pos : Vector2i = get_facing_pos()
		var prop_angle : float = props.get_angle(prop_pos, selected_prop)
		prop_angle -= ROTATION_SPEEDS[change_speed]
		if prop_angle < 0.0:
			prop_angle += TAU
		props.set_angle(prop_pos, selected_prop, prop_angle)

func events_process(_delta : float):
	var modifiers : Array[Variant] = editor_common_process()
	if not modifiers[0]:
		return

	var alternate : bool = modifiers[1]
	var change_speed : int = modifiers[2]

func play_process(delta : float):
	var update_pos : bool = false
	var update_dir : bool = false

	if Input.is_action_just_pressed(&'play'):
		mode = last_mode
		status_visibility(true)
		return

	if play_height > floor_height:
		play_fall_vel += GRAVITY * delta
		play_height -= play_fall_vel * delta
		if play_height <= floor_height:
			play_height = floor_height
			play_fall_vel = 0.0

		terrain.set_eye_height(play_height + DEFAULT_EYE_HEIGHT)
	else:
		if Input.is_action_just_pressed(&'forward'):
			move(1, 0, true)
			update_pos = true

		if Input.is_action_just_pressed(&'back'):
			move(-1, 0, true)
			update_pos = true

		if Input.is_action_just_pressed(&'strafe left'):
			move(0, -1, true)
			update_pos = true

		if Input.is_action_just_pressed(&'strafe right'):
			move(0, 1, true)
			update_pos = true

		if Input.is_action_just_pressed(&'turn left'):
			spin(-1)
			update_dir = true

		if Input.is_action_just_pressed(&'turn right'):
			spin(1)
			update_dir = true

		if update_pos:
			set_pos()

		if update_dir:
			set_dir()

func scan_props():
	respropdefs = scan_props_dir("res", "res://".path_join(PROPS_DIR))
	userpropdefs = scan_props_dir("user", "user://".path_join(PROPS_DIR))

func _ready():
	scan_props()
	set_prop_defs([respropdefs, userpropdefs])

	terrain.set_texture(textures)
	var view_positions : Array[Vector2i] = terrain.set_view(MAX_DEPTH, $'Camera3D'.fov)
	depth = MAX_DEPTH
	terrain.init_empty_world(Vector2i(world_width, world_height))
	terrain.set_eye_height(eye_height)
	set_fog_color()
	set_fog_power()
	terrain.set_pos(pos)
	terrain.set_dir(dir)

	props.set_view_positions(view_positions)
	props.heightmap = terrain.images[&'face_heights']
	props.set_view_pos(pos)
	props.set_view_dir(dir)
	props.set_eye_height(eye_height)

	status()

func _process(delta : float):
	if text_entry_cb == NO_CB:
		# don't do anything if in a text prompt
		MODE_FUNCS[mode].call(delta)

	apply_status()

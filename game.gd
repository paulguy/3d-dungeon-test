extends Node3D

# TODO: that ugly stripe along left of center (worked around with 2x MSAA, not "fixed")
#       box select/operations

const DEFAULT_EYE_HEIGHT : float = 0.5
const PLAYER_HEIGHT : float = 0.8
const CLIMB_HEIGHT : float = 0.5
const FIT_HEIGHT : float = 0.4
const GRAVITY : float = 0.8

@onready var terrain : Node3D = $'Terrain Map'
@onready var hud_status : Label = $'HUD/Status'

var play_mode : bool = false

var view_depth : int = 49
var eye_height : float = DEFAULT_EYE_HEIGHT
var ceiling_attach : bool = false
var world_width : int = 128
var world_height : int = 128
var fog_power : float = 0.5
var fog_color : Color = Color(0.0, 0.0, 0.0)
var textures : String = "textures"

const CHANGE_SPEEDS : Array[Array] = [
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[1.0/64.0, 1.0/8.0, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0],
	[0.01, 0.1, 1.0]
]

func NO_CB(_s : String):
	pass

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
var update_status : bool = false

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
var parameter : int = 0

func status(status_str : String = ""):
	if len(status_str) == 0:
		hud_status.text = "P {},{} D {} M {} F {} T {} P {}".format([pos.x, pos.y,
																	MapParameters.dir_string(dir),
																	MapParameters.mesh_string(mesh),
																	MapParameters.face_string(face),
																	MapParameters.topbottom_string(topbottom),
																	MapParameters.parameter_string(parameter)], "{}")
	else:
		hud_status.text = status_str

func status_visibility(v : bool):
	if v:
		hud_status.visible = true
	else:
		hud_status.visible = false

func set_fog_color():
	$'WorldEnvironment'.environment.background_color = fog_color
	terrain.set_fog_color(fog_color)

func get_facing_pos():
	match dir:
		MapParameters.NORTH:
			return Vector2i(pos.x, pos.y - 1)
		MapParameters.EAST:
			return Vector2i(pos.x + 1, pos.y)
		MapParameters.SOUTH:
			return Vector2i(pos.x, pos.y + 1)
		_: # west
			return Vector2i(pos.x - 1, pos.y)

func change_parameter(amount : float):
	var p : Vector2i = get_facing_pos()
	if parameter <= MapParameters.GEOMETRY_PARAMETERS_MAX:
		terrain.change(mesh, face, dir, topbottom, parameter, amount, p)
	elif parameter == MapParameters.FOG_COLOR_R:
		fog_color.r += amount
		set_fog_color()
	elif parameter == MapParameters.FOG_COLOR_G:
		fog_color.g += amount
		set_fog_color()
	elif parameter == MapParameters.FOG_COLOR_B:
		fog_color.b += amount
		set_fog_color()
	elif parameter == MapParameters.FOG_POWER:
		fog_power += amount
		terrain.set_fog_power(fog_power)

func set_parameter(val : float, m : int = -1, f : int = -1, t : int = -1, p : int = -1):
	var fp : Vector2i = get_facing_pos()

	var r_mesh : int = mesh
	var r_face : int = face
	var r_tb : int = topbottom
	var r_param : int = parameter
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
		terrain.set_fog_power(fog_power)

func get_parameter(m : int = -1, f : int = -1, t : int = -1, p : int = -1, d_pos = null) -> float:
	if d_pos == null:
		d_pos = get_facing_pos()

	var r_mesh : int = mesh
	var r_face : int = face
	var r_tb : int = topbottom
	var r_param : int = parameter
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
	return 0.0

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
				update_status = true
			elif key_event.keycode == KEY_BACKSPACE:
				if len(text_entry_text) > 0:
					text_entry_text = text_entry_text.substr(0, len(text_entry_text) - 1)
					update_entry()
			else:
				text_entry_text = "%s%c" % [text_entry_text, key_event.unicode]
				update_entry()

func do_save(mapname : String):
	last_mapname = mapname

	var err : Error = terrain.save_map(mapname, textures,
									   pos, dir,
									   fog_color, fog_power,
									   eye_height)
	if err != Error.OK:
		status("Save failed: %s" % error_string(err))
	else:
		status("Map %s saved" % mapname)

func get_dict_val(dict : Dictionary, key : StringName) -> Variant:
	if key in dict:
		return dict[key]
	return null

func do_load(mapname : String):
	last_mapname = mapname

	var result : Dictionary = terrain.load_map(mapname)
	if result[&'error'] != Error.OK:
		status("Load failed: %s" % error_string(result[&'error']))
	else:
		var pos_x = get_dict_val(result, &'pos_x')
		var pos_y = get_dict_val(result, &'pos_y')
		var new_dir = get_dict_val(result, &'dir')
		var new_fog_power = get_dict_val(result, &'fog_power')
		var fog_r = get_dict_val(result, &'fog_r')
		var fog_g = get_dict_val(result, &'fog_g')
		var fog_b = get_dict_val(result, &'fog_b')
		var new_eye_height = get_dict_val(result, &'eye_height')
		if pos_x != null and pos_y != null:
			pos = Vector2i(pos_x, pos_y)
		if new_dir != null:
			dir = new_dir
		if new_fog_power != null:
			fog_power = new_fog_power
		if fog_r != null and fog_g != null and fog_b != null:
			fog_color = Color(fog_r, fog_g, fog_b)
		if new_eye_height != null:
			eye_height = new_eye_height
		status("Map %s loaded" % mapname)

func do_store(num : String):
	if num.is_valid_float():
		stored = num.to_float()

func phys_move(d_pos : Vector2i):
	var heights : Array[float] = [get_parameter(MapParameters.CEILING,
												MapParameters.HORIZ,
												MapParameters.TOP,
												MapParameters.HEIGHT,
												pos),
								  get_parameter(MapParameters.CEILING,
												MapParameters.HORIZ,
												MapParameters.BOTTOM,
												MapParameters.HEIGHT,
												pos),
								  get_parameter(MapParameters.FLOOR,
												MapParameters.HORIZ,
												MapParameters.TOP,
												MapParameters.HEIGHT,
												pos),
								  get_parameter(MapParameters.FLOOR,
												MapParameters.HORIZ,
												MapParameters.BOTTOM,
												MapParameters.HEIGHT,
												pos)]
	var d_heights : Array[float] = [get_parameter(MapParameters.CEILING,
												  MapParameters.HORIZ,
												  MapParameters.TOP,
												  MapParameters.HEIGHT,
												  d_pos),
									get_parameter(MapParameters.CEILING,
												  MapParameters.HORIZ,
												  MapParameters.BOTTOM,
												  MapParameters.HEIGHT,
												  d_pos),
									get_parameter(MapParameters.FLOOR,
												  MapParameters.HORIZ,
												  MapParameters.TOP,
												  MapParameters.HEIGHT,
												  d_pos),
									get_parameter(MapParameters.FLOOR,
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

func move(f_amount : int, s_amount : int = 0, physics : bool = false):
	var d_pos : Vector2i = pos

	match dir:
		MapParameters.NORTH:
			d_pos.y -= f_amount
			d_pos.x += s_amount
		MapParameters.EAST:
			d_pos.x += f_amount
			d_pos.y += s_amount
		MapParameters.SOUTH:
			d_pos.y += f_amount
			d_pos.x -= s_amount
		_: # west
			d_pos.x -= f_amount
			d_pos.y -= s_amount

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

func editor_process():
	var update_pos : bool = false
	var update_dir : bool = false
	var update_eye_height : bool = false
	var change_speed : int = 1
	var alternate : bool = false

	if text_entry_cb == NO_CB:
		if Input.is_action_pressed(&'alternate function'):
			alternate = true

		if Input.is_action_just_pressed(&'play'):
			play_mode = true
			floor_height = get_parameter(MapParameters.FLOOR,
										MapParameters.HORIZ,
										MapParameters.TOP,
										MapParameters.HEIGHT,
										pos)
			play_height = floor_height
			status_visibility(false)
			return

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

		if update_pos:
			terrain.set_pos(pos)
			update_eye_height = true
			update_status = true

		if update_dir:
			terrain.set_dir(dir)
			update_status = true

		if Input.is_action_just_pressed(&'cycle mesh'):
			if mesh == 0:
				mesh = 1
			else:
				mesh = 0
			update_status = true

		if Input.is_action_just_pressed(&'cycle face'):
			if face == 0:
				face = 1
			else:
				face = 0
			update_status = true

		if Input.is_action_just_pressed(&'cycle tb'):
			if topbottom == 0:
				topbottom = 1
			else:
				topbottom = 0
			update_status = true

		if Input.is_action_just_pressed(&'cycle parameter'):
			if alternate:
				parameter -= 1
				if parameter < 0:
					parameter = MapParameters.MAX_PARAMETER - 1
			else:
				parameter += 1
				if parameter >= MapParameters.MAX_PARAMETER:
					parameter = 0
			update_status = true

		if Input.is_action_just_pressed(&'inc parameter'):
			change_parameter(CHANGE_SPEEDS[parameter][change_speed])
			update_status = true

		if Input.is_action_just_pressed(&'dec parameter'):
			change_parameter(-CHANGE_SPEEDS[parameter][change_speed])
			update_status = true

		if Input.is_action_just_pressed(&'value'):
			if alternate:
				set_parameter(stored)
				status("Value applied.")
			else:
				stored = get_parameter()
				status("Value stored.")

		if Input.is_action_just_pressed(&'ceiling'):
			if alternate:
				set_parameter(stored_ceiling[0], MapParameters.CEILING, MapParameters.WALL, MapParameters.TOP, MapParameters.HUE)
				set_parameter(stored_ceiling[1], MapParameters.CEILING, MapParameters.WALL, MapParameters.TOP, MapParameters.BIAS)
				set_parameter(stored_ceiling[2], MapParameters.CEILING, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.HUE)
				set_parameter(stored_ceiling[3], MapParameters.CEILING, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.BIAS)
				set_parameter(stored_ceiling[4], MapParameters.CEILING, MapParameters.WALL, MapParameters.TOP, MapParameters.OFFSET)
				status("Ceiling wall parameters applied.")
			else:
				stored_ceiling = [get_parameter(MapParameters.CEILING, MapParameters.WALL, MapParameters.TOP, MapParameters.HUE),
								  get_parameter(MapParameters.CEILING, MapParameters.WALL, MapParameters.TOP, MapParameters.BIAS),
								  get_parameter(MapParameters.CEILING, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.HUE),
								  get_parameter(MapParameters.CEILING, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.BIAS),
								  get_parameter(MapParameters.CEILING, MapParameters.WALL, MapParameters.TOP, MapParameters.OFFSET)]
				status("Ceiling wall parameters stored.")

		if Input.is_action_just_pressed(&'face'):
			# topbottom only matters for offset but for consistency...
			if alternate:
				set_parameter(stored_face[0], mesh, MapParameters.HORIZ, topbottom, MapParameters.HUE)
				set_parameter(stored_face[1], mesh, MapParameters.HORIZ, topbottom, MapParameters.BIAS)
				set_parameter(stored_face[2], mesh, MapParameters.HORIZ, topbottom, MapParameters.OFFSET)
				status("Face parameters applied.")
			else:
				stored_face = [get_parameter(mesh, MapParameters.HORIZ, topbottom, MapParameters.HUE),
							   get_parameter(mesh, MapParameters.HORIZ, topbottom, MapParameters.BIAS),
							   get_parameter(mesh, MapParameters.HORIZ, topbottom, MapParameters.OFFSET)]
				status("Face parameters stored.")

		if Input.is_action_just_pressed(&"floor"):
			if alternate:
				set_parameter(stored_floor[0], MapParameters.FLOOR, MapParameters.WALL, MapParameters.TOP, MapParameters.HUE)
				set_parameter(stored_floor[1], MapParameters.FLOOR, MapParameters.WALL, MapParameters.TOP, MapParameters.BIAS)
				set_parameter(stored_floor[2], MapParameters.FLOOR, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.HUE)
				set_parameter(stored_floor[3], MapParameters.FLOOR, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.BIAS)
				set_parameter(stored_floor[4], MapParameters.FLOOR, MapParameters.WALL, MapParameters.TOP, MapParameters.OFFSET)
				status("Floor wall parameters applied.")
			else:
				stored_floor = [get_parameter(MapParameters.FLOOR, MapParameters.WALL, MapParameters.TOP, MapParameters.HUE),
								get_parameter(MapParameters.FLOOR, MapParameters.WALL, MapParameters.TOP, MapParameters.BIAS),
								get_parameter(MapParameters.FLOOR, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.HUE),
								get_parameter(MapParameters.FLOOR, MapParameters.WALL, MapParameters.BOTTOM, MapParameters.BIAS),
								get_parameter(MapParameters.FLOOR, MapParameters.WALL, MapParameters.TOP, MapParameters.OFFSET)]
				status("Floor wall parameters stored.")

		if Input.is_action_just_pressed(&'heights'):
			if alternate:
				set_parameter(stored_heights[0], MapParameters.CEILING, MapParameters.HORIZ, MapParameters.TOP, MapParameters.HEIGHT)
				set_parameter(stored_heights[1], MapParameters.CEILING, MapParameters.HORIZ, MapParameters.BOTTOM, MapParameters.HEIGHT)
				set_parameter(stored_heights[2], MapParameters.FLOOR, MapParameters.HORIZ, MapParameters.TOP, MapParameters.HEIGHT)
				set_parameter(stored_heights[3], MapParameters.FLOOR, MapParameters.HORIZ, MapParameters.BOTTOM, MapParameters.HEIGHT)
				status("Cell heights applied.")
			else:
				stored_heights = [get_parameter(MapParameters.CEILING, MapParameters.HORIZ, MapParameters.TOP, MapParameters.HEIGHT),
								  get_parameter(MapParameters.CEILING, MapParameters.HORIZ, MapParameters.BOTTOM, MapParameters.HEIGHT),
								  get_parameter(MapParameters.FLOOR, MapParameters.HORIZ, MapParameters.TOP, MapParameters.HEIGHT),
								  get_parameter(MapParameters.FLOOR, MapParameters.HORIZ, MapParameters.BOTTOM, MapParameters.HEIGHT)]
				status("Cell heights stored.")

		if Input.is_action_just_pressed(&'save'):
			set_text_entry_mode(do_save, "Save", last_mapname)

		if Input.is_action_just_pressed(&'load'):
			set_text_entry_mode(do_load, "Load", last_mapname)

		if Input.is_action_just_pressed(&'value_entry'):
			set_text_entry_mode(do_store, "Value", str(stored))

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
			var f_height : float = get_parameter(MapParameters.FLOOR,
												MapParameters.HORIZ,
												MapParameters.TOP,
												MapParameters.HEIGHT,
												pos)
			var c_height : float = get_parameter(MapParameters.CEILING,
												MapParameters.HORIZ,
												MapParameters.BOTTOM,
												MapParameters.HEIGHT,
												pos)

			eye_height = c_height - f_height - eye_height
			ceiling_attach = not ceiling_attach
			update_eye_height = true

		if update_eye_height:
			if ceiling_attach:
				terrain.set_eye_height(get_parameter(MapParameters.CEILING,
													 MapParameters.HORIZ,
													 MapParameters.BOTTOM,
													 MapParameters.HEIGHT,
													 pos) - eye_height)
			else:
				terrain.set_eye_height(get_parameter(MapParameters.FLOOR,
													 MapParameters.HORIZ,
													 MapParameters.TOP,
													 MapParameters.HEIGHT,
													 pos) + eye_height)

		if update_status:
			status()
			update_status = false

func play_process(delta : float):
	var update_pos : bool = false
	var update_dir : bool = false

	if Input.is_action_just_pressed(&'play'):
		play_mode = false
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
			terrain.set_pos(pos)
			update_status = true

		if update_dir:
			terrain.set_dir(dir)
			update_status = true

func _ready():
	terrain.set_texture(textures)
	terrain.set_view(view_depth, $'Camera3D'.fov)
	terrain.init_empty_world(Vector2i(world_width, world_height))
	terrain.set_eye_height(eye_height)
	set_fog_color()
	terrain.set_fog_power(fog_power)
	terrain.set_pos(pos)
	terrain.set_dir(dir)
	status()

func _process(delta : float):
	if play_mode:
		play_process(delta)
	else:
		editor_process()

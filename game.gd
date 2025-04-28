extends Node3D

# TODO: copy/paste face
#       that ugly stripe along left of center (worked around with 2x MSAA, not "fixed")
#       box select/operations

@onready var terrain : Node3D = $'Terrain Map'
@onready var hud_status : Label = $'HUD/Status'

var view_depth : int = 49
var eye_height : float = 0.5
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
var last_mapname : String = "untitled"
var update_status : bool = false

var text_entry_prefix : String = ""
var text_entry_text : String = ""
var text_entry_cb : Callable = NO_CB

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

func set_parameter(val : float):
	var p : Vector2i = get_facing_pos()
	if parameter <= MapParameters.GEOMETRY_PARAMETERS_MAX:
		terrain.set_val(mesh, face, dir, topbottom, parameter, val, p)
	elif parameter == MapParameters.FOG_COLOR_R:
		fog_color.r = val
		set_fog_color()
	elif parameter == MapParameters.FOG_COLOR_G:
		fog_color.g = val
		set_fog_color()
	elif parameter == MapParameters.FOG_COLOR_B:
		fog_color.b = val
		set_fog_color()
	elif parameter == MapParameters.FOG_POWER:
		fog_power = val
		terrain.set_fog_power(fog_power)

func get_parameter() -> float:
	var p : Vector2i = get_facing_pos()
	if parameter <= MapParameters.GEOMETRY_PARAMETERS_MAX:
		return terrain.get_val(mesh, face, dir, topbottom, parameter, p)
	elif parameter == MapParameters.FOG_COLOR_R:
		return fog_color.r
	elif parameter == MapParameters.FOG_COLOR_G:
		return fog_color.g
	elif parameter == MapParameters.FOG_COLOR_B:
		return fog_color.b
	elif parameter == MapParameters.FOG_POWER:
		return fog_power
	return 0.0

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

func move(f_amount : int, s_amount : int = 0):
	match dir:
		MapParameters.NORTH:
			pos.y -= f_amount
			pos.x += s_amount
		MapParameters.EAST:
			pos.x += f_amount
			pos.y += s_amount
		MapParameters.SOUTH:
			pos.y += f_amount
			pos.x -= s_amount
		_: # west
			pos.x -= f_amount
			pos.y -= s_amount

func spin(amount : int):
	dir += amount

	if dir < 0:
		dir = 3
	elif dir > 3:
		dir = 0

func _process(_delta : float):
	var update_pos : bool = false
	var update_dir : bool = false
	var update_eye_height : bool = false
	var change_speed : int = 1

	if text_entry_cb == NO_CB:
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
			parameter += 1
			if parameter == MapParameters.MAX_PARAMETER:
				parameter = 0
			update_status = true

		if Input.is_action_just_pressed(&'inc parameter'):
			change_parameter(CHANGE_SPEEDS[parameter][change_speed])
			update_status = true

		if Input.is_action_just_pressed(&'dec parameter'):
			change_parameter(-CHANGE_SPEEDS[parameter][change_speed])
			update_status = true

		if Input.is_action_just_pressed(&'get value'):
			stored = get_parameter()
			update_status = true

		if Input.is_action_just_pressed(&'put value'):
			set_parameter(stored)
			update_status = true

		if Input.is_action_just_pressed(&'save'):
			set_text_entry_mode(do_save, "Save", last_mapname)

		if Input.is_action_just_pressed(&'load'):
			set_text_entry_mode(do_load, "Load", last_mapname)

		if Input.is_action_just_pressed(&'value_entry'):
			set_text_entry_mode(do_store, "Value", str(stored))

		if Input.is_action_just_pressed(&'up'):
			eye_height += pow(10.0, change_speed - 2)
			update_eye_height = true

		if Input.is_action_just_pressed(&'down'):
			eye_height -= pow(10.0, change_speed - 2)
			update_eye_height = true

		if update_eye_height:
			terrain.set_eye_height(eye_height)

		if update_status:
			status()
			update_status = false

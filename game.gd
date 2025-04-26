extends Node3D

# TODO: Save/load
#       copy/paste face
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

func NO_CB(_s : String):
	pass

var pos : Vector2i = Vector2i(world_width / 2, world_height / 2)
var dir : int = 0
var stored : float = 0.0
var last_mapname : String = "untitled"
var update_status : bool = false

var text_entry_cb : Callable = NO_CB
var text_entry_text : String = ""

# ceiling, floor
var mesh : int = 0
# horiz, wall
var face : int = 0
# top, bottom (for vert, height)
var topbottom : int = 0
# height, hue, bias, offset
var parameter : int = 0

func dir_string(val : int):
	match val:
		0:
			return "north"
		1:
			return "east"
		2:
			return "south"
		_:
			return "west"

func mesh_string(val : int):
	if val == 0:
		return "ceiling"

	return "floor"

func face_string(val : int):
	if val == 0:
		return "horizontal"

	return "wall"

func topbottom_string(val : int):
	if val == 0:
		return "top"

	return "bottom"

func parameter_string(val : int):
	match val:
		0:
			return "height"
		1:
			return "hue"
		2:
			return "bias"
		_:
			return "offset"

func status(status_str : String):
	if len(status_str) == 0:
		hud_status.text = "P {},{} D {} M {} F {} T {} P {}".format([pos.x, pos.y,
																	dir_string(dir),
																	mesh_string(mesh),
																	face_string(face),
																	topbottom_string(topbottom),
																	parameter_string(parameter)], "{}")
	else:
		hud_status.text = status_str

func get_facing_pos():
	match dir:
		0: # north
			return Vector2i(pos.x, pos.y - 1)
		1: # east
			return Vector2i(pos.x + 1, pos.y)
		2: # south
			return Vector2i(pos.x, pos.y + 1)
		_: # west
			pass

	return Vector2i(pos.x - 1, pos.y)

func change_parameter(amount : float):
	var p : Vector2i = get_facing_pos()
	terrain.change(mesh, face, dir, topbottom, parameter, p, amount)

func set_parameter(val : float):
	var p : Vector2i = get_facing_pos()
	terrain.set_val(mesh, face, dir, topbottom, parameter, p, val)

func get_parameter() -> float:
	var p : Vector2i = get_facing_pos()
	return terrain.get_val(mesh, face, dir, topbottom, parameter, p)

func _ready():
	$'WorldEnvironment'.environment.background_color = fog_color
	terrain.set_texture(load("res://textures.png"))
	terrain.set_view(view_depth, $'Camera3D'.fov)
	terrain.init_empty_world(Vector2i(world_width, world_height))
	terrain.set_eye_height(eye_height)
	terrain.set_fog_color(fog_color)
	terrain.set_fog_power(fog_power)
	terrain.set_pos(pos)
	terrain.set_dir(dir)
	status("")

func update_entry(entry : String):
	status(">%s" % entry)

func _input(event : InputEvent):
	if text_entry_cb != NO_CB:
		if event is InputEventKey and event.is_pressed():
			var key_event : InputEventKey = event
			if key_event.keycode == KEY_ENTER:
				text_entry_cb.call(text_entry_text)
				update_status = true
			elif key_event.keycode == KEY_ESCAPE:
				text_entry_cb = NO_CB
				text_entry_text = ""
				update_status = true
			elif key_event.keycode == KEY_BACKSPACE:
				if len(text_entry_text) > 0:
					text_entry_text = text_entry_text.substr(0, len(text_entry_text) - 1)
					update_entry(text_entry_text)
			else:
				text_entry_text = "%s%c" % [text_entry_text, key_event.unicode]
				update_entry(text_entry_text)

func set_text_entry_mode(cb : Callable, def : String = ""):
	text_entry_text = String(def)
	text_entry_cb = cb
	update_entry(def)

func do_save(mapname : String):
	last_mapname = mapname

	var err : Error = terrain.save_map(mapname)
	if err != Error.OK:
		status(error_string(err))
	else:
		status("Map %s saved" % mapname)

func do_load(mapname : String):
	last_mapname = mapname

	var err : Error = terrain.load_map(mapname)
	if err != Error.OK:
		status(error_string(err))
	else:
		status("Map %s loaded" % mapname)

func _process(_delta : float):
	# TODO: height adjust
	#       direct number entry
	#       adjustable fog parameters

	var status_str : String = ""

	var update_pos : bool = false
	var update_dir : bool = false

	if text_entry_cb == NO_CB:
		if Input.is_action_just_pressed(&'forward'):
			match dir:
				0: # north
					pos.y -= 1
				1: # east
					pos.x += 1
				2: # south
					pos.y += 1
				_: # west
					pos.x -= 1
			update_pos = true

		if Input.is_action_just_pressed(&'back'):
			match dir:
				0: # north
					pos.y += 1
				1: # east
					pos.x -= 1
				2: # south
					pos.y -= 1
				_: # west
					pos.x += 1
			update_pos = true

		if Input.is_action_just_pressed(&'strafe left'):
			match dir:
				0: # north
					pos.x -= 1
				1: # east
					pos.y -= 1
				2: # south
					pos.x += 1
				_: # west
					pos.y += 1
			update_pos = true
		elif Input.is_action_just_pressed(&'turn left'):
			dir -= 1
			update_dir = true

		if Input.is_action_just_pressed(&'strafe right'):
			match dir:
				0: # north
					pos.x += 1
				1: # east
					pos.y += 1
				2: # south
					pos.x -= 1
				_: # west
					pos.y -= 1
			update_pos = true
		elif Input.is_action_just_pressed(&'turn right'):
			dir += 1
			update_dir = true

		if update_pos:
			terrain.set_pos(pos)
			update_status = true

		if update_dir:
			if dir < 0:
				dir = 3
			elif dir > 3:
				dir = 0
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
			if parameter == 4:
				parameter = 0
			update_status = true

		if Input.is_action_just_pressed(&'inc parameter'):
			change_parameter(0.1)
			update_status = true

		if Input.is_action_just_pressed(&'dec parameter'):
			change_parameter(-0.1)
			update_status = true

		if Input.is_action_just_pressed(&'get value'):
			stored = get_parameter()
			update_status = true

		if Input.is_action_just_pressed(&'put value'):
			set_parameter(stored)
			update_status = true

		if Input.is_action_just_pressed(&'save'):
			set_text_entry_mode(do_save, last_mapname)

		if Input.is_action_just_pressed(&'load'):
			set_text_entry_mode(do_load, last_mapname)

		if update_status:
			status(status_str)
			update_status = false

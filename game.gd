extends Node3D

@onready var terrain : Node3D = $'Terrain Map'
@onready var status : Label = $'HUD/Status'

var view_depth : int = 49
var eye_height : float = 0.5
var world_width : int = 128
var world_height : int = 128
var fog_power : float = 0.2
var fog_color : Color = Color(1.0, 0.0, 0.0)

var pos : Vector2i = Vector2i(world_width / 2, world_height / 2)
var dir : int = 0
var stored : float = 0.0

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

func update_status():
	status.text = "P {},{} D {} {} M {} {} F {} {} T {} {} P {} {}".format([pos.x, pos.y,
																		   dir, dir_string(dir),
																		   mesh, mesh_string(mesh),
																		   face, face_string(face),
																		   topbottom, topbottom_string(topbottom),
																		   parameter, parameter_string(parameter)], "{}")

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

	match mesh:
		0:
			match face:
				0:
					match topbottom:
						0:
							match parameter:
								0:
									terrain.change_ceiling_top_height(p, amount)
								1:
									terrain.change_top_hue(p, amount)
								2:
									terrain.change_top_bias(p, amount)
								_:
									terrain.change_ceiling_top_offset(p, amount)
						_:
							match parameter:
								0:
									terrain.change_ceiling_bottom_height(p, amount)
								1:
									terrain.change_bottom_hue(p, amount)
								2:
									terrain.change_bottom_bias(p, amount)
								_:
									terrain.change_ceiling_bottom_offset(p, amount)
				_:
					match dir:
						0:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_ceiling_top_height(p, amount)
										1:
											terrain.change_ceiling_south_top_hue(p, amount)
										2:
											terrain.change_ceiling_south_top_bias(p, amount)
										_:
											terrain.change_ceiling_south_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_ceiling_bottom_height(p, amount)
										1:
											terrain.change_ceiling_south_bottom_hue(p, amount)
										2:
											terrain.change_ceiling_south_bottom_bias(p, amount)
										_:
											terrain.change_ceiling_south_offset(p, amount)
						1:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_ceiling_top_height(p, amount)
										1:
											terrain.change_ceiling_west_top_hue(p, amount)
										2:
											terrain.change_ceiling_west_top_bias(p, amount)
										_:
											terrain.change_ceiling_west_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_ceiling_bottom_height(p, amount)
										1:
											terrain.change_ceiling_west_bottom_hue(p, amount)
										2:
											terrain.change_ceiling_west_bottom_bias(p, amount)
										_:
											terrain.change_ceiling_west_offset(p, amount)
						2:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_ceiling_top_height(p, amount)
										1:
											terrain.change_ceiling_north_top_hue(p, amount)
										2:
											terrain.change_ceiling_north_top_bias(p, amount)
										_:
											terrain.change_ceiling_north_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_ceiling_bottom_height(p, amount)
										1:
											terrain.change_ceiling_north_bottom_hue(p, amount)
										2:
											terrain.change_ceiling_north_bottom_bias(p, amount)
										_:
											terrain.change_ceiling_north_offset(p, amount)
						_:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_ceiling_top_height(p, amount)
										1:
											terrain.change_ceiling_east_top_hue(p, amount)
										2:
											terrain.change_ceiling_east_top_bias(p, amount)
										_:
											terrain.change_ceiling_east_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_ceiling_bottom_height(p, amount)
										1:
											terrain.change_ceiling_east_bottom_hue(p, amount)
										2:
											terrain.change_ceiling_east_bottom_bias(p, amount)
										_:
											terrain.change_ceiling_east_offset(p, amount)
		_:
			match face:
				0:
					match topbottom:
						0:
							match parameter:
								0:
									terrain.change_floor_top_height(p, amount)
								1:
									terrain.change_top_hue(p, amount)
								2:
									terrain.change_top_bias(p, amount)
								_:
									terrain.change_floor_top_offset(p, amount)
						_:
							match parameter:
								0:
									terrain.change_floor_bottom_height(p, amount)
								1:
									terrain.change_bottom_hue(p, amount)
								2:
									terrain.change_bottom_bias(p, amount)
								_:
									terrain.change_floor_bottom_offset(p, amount)
				_:
					match dir:
						0:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_floor_top_height(p, amount)
										1:
											terrain.change_floor_south_top_hue(p, amount)
										2:
											terrain.change_floor_south_top_bias(p, amount)
										_:
											terrain.change_floor_south_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_floor_bottom_height(p, amount)
										1:
											terrain.change_floor_south_bottom_hue(p, amount)
										2:
											terrain.change_floor_south_bottom_bias(p, amount)
										_:
											terrain.change_floor_south_offset(p, amount)
						1:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_floor_top_height(p, amount)
										1:
											terrain.change_floor_west_top_hue(p, amount)
										2:
											terrain.change_floor_west_top_bias(p, amount)
										_:
											terrain.change_floor_west_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_floor_bottom_height(p, amount)
										1:
											terrain.change_floor_west_bottom_hue(p, amount)
										2:
											terrain.change_floor_west_bottom_bias(p, amount)
										_:
											terrain.change_floor_west_offset(p, amount)
						2:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_floor_top_height(p, amount)
										1:
											terrain.change_floor_north_top_hue(p, amount)
										2:
											terrain.change_floor_north_top_bias(p, amount)
										_:
											terrain.change_floor_north_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_floor_bottom_height(p, amount)
										1:
											terrain.change_floor_north_bottom_hue(p, amount)
										2:
											terrain.change_floor_north_bottom_bias(p, amount)
										_:
											terrain.change_floor_north_offset(p, amount)
						_:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.change_floor_top_height(p, amount)
										1:
											terrain.change_floor_east_top_hue(p, amount)
										2:
											terrain.change_floor_east_top_bias(p, amount)
										_:
											terrain.change_floor_east_offset(p, amount)
								_:
									match parameter:
										0:
											terrain.change_floor_bottom_height(p, amount)
										1:
											terrain.change_floor_east_bottom_hue(p, amount)
										2:
											terrain.change_floor_east_bottom_bias(p, amount)
										_:
											terrain.change_floor_east_offset(p, amount)

func set_parameter(val : float):
	var p : Vector2i = get_facing_pos()

	match mesh:
		0:
			match face:
				0:
					match topbottom:
						0:
							match parameter:
								0:
									terrain.set_ceiling_top_height(p, val)
								1:
									terrain.set_top_hue(p, val)
								2:
									terrain.set_top_bias(p, val)
								_:
									terrain.set_ceiling_top_offset(p, val)
						_:
							match parameter:
								0:
									terrain.set_ceiling_bottom_height(p, val)
								1:
									terrain.set_bottom_hue(p, val)
								2:
									terrain.set_bottom_bias(p, val)
								_:
									terrain.set_ceiling_bottom_offset(p, val)
				_:
					match dir:
						0:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_ceiling_top_height(p, val)
										1:
											terrain.set_ceiling_south_top_hue(p, val)
										2:
											terrain.set_ceiling_south_top_bias(p, val)
										_:
											terrain.set_ceiling_south_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_ceiling_bottom_height(p, val)
										1:
											terrain.set_ceiling_south_bottom_hue(p, val)
										2:
											terrain.set_ceiling_south_bottom_bias(p, val)
										_:
											terrain.set_ceiling_south_offset(p, val)
						1:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_ceiling_top_height(p, val)
										1:
											terrain.set_ceiling_west_top_hue(p, val)
										2:
											terrain.set_ceiling_west_top_bias(p, val)
										_:
											terrain.set_ceiling_west_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_ceiling_bottom_height(p, val)
										1:
											terrain.set_ceiling_west_bottom_hue(p, val)
										2:
											terrain.set_ceiling_west_bottom_bias(p, val)
										_:
											terrain.set_ceiling_west_offset(p, val)
						2:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_ceiling_top_height(p, val)
										1:
											terrain.set_ceiling_north_top_hue(p, val)
										2:
											terrain.set_ceiling_north_top_bias(p, val)
										_:
											terrain.set_ceiling_north_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_ceiling_bottom_height(p, val)
										1:
											terrain.set_ceiling_north_bottom_hue(p, val)
										2:
											terrain.set_ceiling_north_bottom_bias(p, val)
										_:
											terrain.set_ceiling_north_offset(p, val)
						_:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_ceiling_top_height(p, val)
										1:
											terrain.set_ceiling_east_top_hue(p, val)
										2:
											terrain.set_ceiling_east_top_bias(p, val)
										_:
											terrain.set_ceiling_east_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_ceiling_bottom_height(p, val)
										1:
											terrain.set_ceiling_east_bottom_hue(p, val)
										2:
											terrain.set_ceiling_east_bottom_bias(p, val)
										_:
											terrain.set_ceiling_east_offset(p, val)
		_:
			match face:
				0:
					match topbottom:
						0:
							match parameter:
								0:
									terrain.set_floor_top_height(p, val)
								1:
									terrain.set_top_hue(p, val)
								2:
									terrain.set_top_bias(p, val)
								_:
									terrain.set_floor_top_offset(p, val)
						_:
							match parameter:
								0:
									terrain.set_floor_bottom_height(p, val)
								1:
									terrain.set_bottom_hue(p, val)
								2:
									terrain.set_bottom_bias(p, val)
								_:
									terrain.set_floor_bottom_offset(p, val)
				_:
					match dir:
						0:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_floor_top_height(p, val)
										1:
											terrain.set_floor_south_top_hue(p, val)
										2:
											terrain.set_floor_south_top_bias(p, val)
										_:
											terrain.set_floor_south_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_floor_bottom_height(p, val)
										1:
											terrain.set_floor_south_bottom_hue(p, val)
										2:
											terrain.set_floor_south_bottom_bias(p, val)
										_:
											terrain.set_floor_south_offset(p, val)
						1:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_floor_top_height(p, val)
										1:
											terrain.set_floor_west_top_hue(p, val)
										2:
											terrain.set_floor_west_top_bias(p, val)
										_:
											terrain.set_floor_west_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_floor_bottom_height(p, val)
										1:
											terrain.set_floor_west_bottom_hue(p, val)
										2:
											terrain.set_floor_west_bottom_bias(p, val)
										_:
											terrain.set_floor_west_offset(p, val)
						2:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_floor_top_height(p, val)
										1:
											terrain.set_floor_north_top_hue(p, val)
										2:
											terrain.set_floor_north_top_bias(p, val)
										_:
											terrain.set_floor_north_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_floor_bottom_height(p, val)
										1:
											terrain.set_floor_north_bottom_hue(p, val)
										2:
											terrain.set_floor_north_bottom_bias(p, val)
										_:
											terrain.set_floor_north_offset(p, val)
						_:
							match topbottom:
								0:
									match parameter:
										0:
											terrain.set_floor_top_height(p, val)
										1:
											terrain.set_floor_east_top_hue(p, val)
										2:
											terrain.set_floor_east_top_bias(p, val)
										_:
											terrain.set_floor_east_offset(p, val)
								_:
									match parameter:
										0:
											terrain.set_floor_bottom_height(p, val)
										1:
											terrain.set_floor_east_bottom_hue(p, val)
										2:
											terrain.set_floor_east_bottom_bias(p, val)
										_:
											terrain.set_floor_east_offset(p, val)

func get_parameter() -> float:
	var p : Vector2i = get_facing_pos()

	match mesh:
		0:
			match face:
				0:
					match topbottom:
						0:
							match parameter:
								0:
									return terrain.get_ceiling_top_height(p)
								1:
									return terrain.get_top_hue(p)
								2:
									return terrain.get_top_bias(p)
								_:
									return terrain.get_ceiling_top_offset(p)
						_:
							match parameter:
								0:
									return terrain.get_ceiling_bottom_height(p)
								1:
									return terrain.get_bottom_hue(p)
								2:
									return terrain.get_bottom_bias(p)
								_:
									return terrain.get_ceiling_bottom_offset(p)
				_:
					match dir:
						0:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_ceiling_top_height(p)
										1:
											return terrain.get_ceiling_south_top_hue(p)
										2:
											return terrain.get_ceiling_south_top_bias(p)
										_:
											return terrain.get_ceiling_south_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_ceiling_bottom_height(p)
										1:
											return terrain.get_ceiling_south_bottom_hue(p)
										2:
											return terrain.get_ceiling_south_bottom_bias(p)
										_:
											return terrain.get_ceiling_south_offset(p)
						1:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_ceiling_top_height(p)
										1:
											return terrain.get_ceiling_west_top_hue(p)
										2:
											return terrain.get_ceiling_west_top_bias(p)
										_:
											return terrain.get_ceiling_west_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_ceiling_bottom_height(p)
										1:
											return terrain.get_ceiling_west_bottom_hue(p)
										2:
											return terrain.get_ceiling_west_bottom_bias(p)
										_:
											return terrain.get_ceiling_west_offset(p)
						2:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_ceiling_top_height(p)
										1:
											return terrain.get_ceiling_north_top_hue(p)
										2:
											return terrain.get_ceiling_north_top_bias(p)
										_:
											return terrain.get_ceiling_north_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_ceiling_bottom_height(p)
										1:
											return terrain.get_ceiling_north_bottom_hue(p)
										2:
											return terrain.get_ceiling_north_bottom_bias(p)
										_:
											return terrain.get_ceiling_north_offset(p)
						_:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_ceiling_top_height(p)
										1:
											return terrain.get_ceiling_east_top_hue(p)
										2:
											return terrain.get_ceiling_east_top_bias(p)
										_:
											return terrain.get_ceiling_east_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_ceiling_bottom_height(p)
										1:
											return terrain.get_ceiling_east_bottom_hue(p)
										2:
											return terrain.get_ceiling_east_bottom_bias(p)
										_:
											return terrain.get_ceiling_east_offset(p)
		_:
			match face:
				0:
					match topbottom:
						0:
							match parameter:
								0:
									return terrain.get_floor_top_height(p)
								1:
									return terrain.get_top_hue(p)
								2:
									return terrain.get_top_bias(p)
								_:
									return terrain.get_floor_top_offset(p)
						_:
							match parameter:
								0:
									return terrain.get_floor_bottom_height(p)
								1:
									return terrain.get_bottom_hue(p)
								2:
									return terrain.get_bottom_bias(p)
								_:
									return terrain.get_floor_bottom_offset(p)
				_:
					match dir:
						0:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_floor_top_height(p)
										1:
											return terrain.get_floor_south_top_hue(p)
										2:
											return terrain.get_floor_south_top_bias(p)
										_:
											return terrain.get_floor_south_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_floor_bottom_height(p)
										1:
											return terrain.get_floor_south_bottom_hue(p)
										2:
											return terrain.get_floor_south_bottom_bias(p)
										_:
											return terrain.get_floor_south_offset(p)
						1:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_floor_top_height(p)
										1:
											return terrain.get_floor_west_top_hue(p)
										2:
											return terrain.get_floor_west_top_bias(p)
										_:
											return terrain.get_floor_west_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_floor_bottom_height(p)
										1:
											return terrain.get_floor_west_bottom_hue(p)
										2:
											return terrain.get_floor_west_bottom_bias(p)
										_:
											return terrain.get_floor_west_offset(p)
						2:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_floor_top_height(p)
										1:
											return terrain.get_floor_north_top_hue(p)
										2:
											return terrain.get_floor_north_top_bias(p)
										_:
											return terrain.get_floor_north_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_floor_bottom_height(p)
										1:
											return terrain.get_floor_north_bottom_hue(p)
										2:
											return terrain.get_floor_north_bottom_bias(p)
										_:
											return terrain.get_floor_north_offset(p)
						_:
							match topbottom:
								0:
									match parameter:
										0:
											return terrain.get_floor_top_height(p)
										1:
											return terrain.get_floor_east_top_hue(p)
										2:
											return terrain.get_floor_east_top_bias(p)
										_:
											return terrain.get_floor_east_offset(p)
								_:
									match parameter:
										0:
											return terrain.get_floor_bottom_height(p)
										1:
											return terrain.get_floor_east_bottom_hue(p)
										2:
											return terrain.get_floor_east_bottom_bias(p)
										_:
											return terrain.get_floor_east_offset(p)

func _ready():
	$'WorldEnvironment'.environment.background_color = fog_color
	terrain.init_empty_world(world_width, world_height,
							 $'Camera3D'.fov, eye_height, view_depth,
							 fog_power, fog_color)
	terrain.set_pos(pos)
	terrain.set_dir(dir)
	update_status()

func _process(_delta : float):
	var update_pos : bool = false
	var update_dir : bool = false

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

	if update_dir:
		if dir < 0:
			dir = 3
		elif dir > 3:
			dir = 0
		terrain.set_dir(dir)

	if Input.is_action_just_pressed(&'cycle mesh'):
		if mesh == 0:
			mesh = 1
		else:
			mesh = 0

	if Input.is_action_just_pressed(&'cycle face'):
		if face == 0:
			face = 1
		else:
			face = 0

	if Input.is_action_just_pressed(&'cycle tb'):
		if topbottom == 0:
			topbottom = 1
		else:
			topbottom = 0

	if Input.is_action_just_pressed(&'cycle parameter'):
		parameter += 1
		if parameter == 4:
			parameter = 0

	if Input.is_action_just_pressed(&'inc parameter'):
		change_parameter(0.1)

	if Input.is_action_just_pressed(&'dec parameter'):
		change_parameter(-0.1)

	if Input.is_action_just_pressed(&'get value'):
		stored = get_parameter()

	if Input.is_action_just_pressed(&'put value'):
		set_parameter(stored)

	update_status()

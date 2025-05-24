extends Node3D
class_name PropsManager

var heightmap : Image
var mapsize : Vector2i
var positions : Array[Array]
var offsets : Array[int]
var props : Dictionary[Vector2i, Array] = {}
var view_pos : Vector2i = Vector2i.ZERO
var view_dir : int = 0
var eye_height : float = 0.0

var staging_props : Dictionary[Vector2i, Array] = {}

@onready var visible_node : Node3D = $'Visible'
@onready var invisible_node : Node3D = $'Invisible'

func set_view_positions(p : Array[Vector2i]):
	positions = [[], [], [], []]
	positions[2] = p
	offsets = []
	var last_y : int = p[0].y
	var last_x : int = p[0].x
	for item in p:
		positions[0].append(Vector2i(-item.x, -item.y))
		positions[1].append(Vector2i(item.y, -item.x))
		positions[3].append(Vector2i(-item.y, item.x))
		if item.y != last_y:
			offsets.append(last_x)
			last_y = item.y
		last_x = item.x

func clear_props():
	for p in visible_node.get_children():
		p.queue_free()
	for p in invisible_node.get_children():
		p.queue_free()
	props = {}

func update_view_pos(prop : Prop):
	var prop_view_pos : Vector2i = prop.map_pos - view_pos
	var height : float
	if prop.ceiling_attach:
		# ceiling mesh bottom is green channel
		height = heightmap.get_pixelv(prop.map_pos).g - eye_height
	else:
		# floor mesh top is blue channel
		height = heightmap.get_pixelv(prop.map_pos).b - eye_height

	match view_dir:
		DirParameters.SOUTH:
			# looking down +Z
			prop.set_view_pos(Vector3(prop_view_pos.x, height, prop_view_pos.y))
			prop.set_view_angle(0.0)
		DirParameters.NORTH:
			# looking down -Z
			prop.set_view_pos(Vector3(-prop_view_pos.x, height, -prop_view_pos.y))
			prop.set_view_angle(PI)
		DirParameters.EAST:
			# looking down +X
			prop.set_view_pos(Vector3(-prop_view_pos.y, height, prop_view_pos.x))
			prop.set_view_angle(PI * 1.5)
		_: # WEST
			# looking down -X
			prop.set_view_pos(Vector3(prop_view_pos.y, height, -prop_view_pos.x))
			prop.set_view_angle(PI * 0.5)

func make_visible(prop : Prop):
	update_view_pos(prop)
	prop.sprite.reparent(visible_node)

func execute_each_visible(callable : Callable):
	var pos : Vector2i

	for item in positions[view_dir]:
		pos = view_pos + item
		if pos in props:
			for prop in props[pos]:
				callable.call(prop)

func execute_if_pos_visible(pos : Vector2i,
							callable : Callable,
							prop = null):
	# move position relative to view position
	var prop_view_pos : Vector2i = pos - view_pos

	# if not looking for a particular prop, make sure the position even has
	# props first and return if not
	if prop == null and pos not in props:
		return

	if view_dir == DirParameters.SOUTH:
		# looking down +Z
		for i in len(offsets):
			if prop_view_pos.y == i and \
			   prop_view_pos.x >= -offsets[i] and prop_view_pos.x <= offsets[i]:
				if prop != null:
					callable.call(prop)
				else:
					for p in props[pos]:
						callable.call(p)
				break
	elif view_dir == DirParameters.NORTH:
		# looking down -Z
		for i in len(offsets):
			if prop_view_pos.y == -i and \
			   prop_view_pos.x >= -offsets[i] and prop_view_pos.x <= offsets[i]:
				if prop != null:
					callable.call(prop)
				else:
					for p in props[pos]:
						callable.call(p)
				break
	elif view_dir == DirParameters.EAST:
		# looking down +X
		for i in len(offsets):
			if prop_view_pos.x == i and \
			   prop_view_pos.y >= -offsets[i] and prop_view_pos.y <= offsets[i]:
				if prop != null:
					callable.call(prop)
				else:
					for p in props[pos]:
						callable.call(p)
				break
	else: # WEST
		# looking down -X
		for i in len(offsets):
			if prop_view_pos.x == -i and \
			   prop_view_pos.y >= -offsets[i] and prop_view_pos.y <= offsets[i]:
				if prop != null:
					callable.call(prop)
				else:
					for p in props[pos]:
						callable.call(p)
				break

func execute_if_prop_visible(prop : Prop,
							 callable : Callable):
	execute_if_pos_visible(prop.map_pos, callable, prop)

func add_prop(propdef : PropDef, map_pos : Vector2i) -> int:
	if not map_pos in props:
		# if position has no props, create the array first
		props[map_pos] = []

	var prop : Prop = Prop.new(propdef, map_pos)
	props[map_pos].append(prop)

	# needs some initial parent
	invisible_node.add_child(prop.sprite)

	execute_if_prop_visible(prop, make_visible)

	return len(props[map_pos]) - 1

func delete_prop(map_pos : Vector2i, idx : int) -> int:
	if not has_prop(map_pos, idx):
		return -1

	var cell : Array = props[map_pos]
	var prop : Prop = cell[idx]
	prop.sprite.get_parent().remove_child(prop.sprite)
	cell.remove_at(idx)
	if len(cell) == 0:
		props.erase(map_pos)
		return -1

	if idx == len(cell):
		idx -= 1

	return idx

func update_view():
	# make everything invisible
	# this is pretty inefficient as various nodes might not need to be rescanned
	# especially because it'll happen with _every_ movement
	# but direction changes will always change everything's visibility anyway
	for child in visible_node.get_children():
		child.reparent(invisible_node, false)

	execute_each_visible(make_visible)

func update_height(pos : Vector2i):
	execute_if_pos_visible(pos, update_view_pos)

func set_view_dir(dir : int):
	view_dir = dir
	update_view()

func set_view_pos(pos : Vector2i):
	view_pos = pos
	update_view()

func set_eye_height(height : float):
	eye_height = height
	execute_each_visible(update_view_pos)

func has_prop(prop_pos : Vector2i, idx : int) -> bool:
	return prop_pos in props and idx >= 0 and idx < len(props[prop_pos])

func get_pos(prop_pos : Vector2i, idx : int) -> Vector3:
	if has_prop(prop_pos, idx):
		return props[prop_pos][idx].pos
	return Vector3.ZERO

func set_pos(prop_pos : Vector2i, idx : int, pos : Vector3):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].set_pos(pos)

func set_pos_x(prop_pos : Vector2i, idx : int, pos_x : float):
	if has_prop(prop_pos, idx):
		var prop : Prop = props[prop_pos][idx]
		var pos : Vector3 = prop.pos
		pos.x = pos_x
		prop.set_pos(pos)

func set_pos_y(prop_pos : Vector2i, idx : int, pos_y : float):
	if has_prop(prop_pos, idx):
		var prop : Prop = props[prop_pos][idx]
		var pos : Vector3 = prop.pos
		pos.y = pos_y
		prop.set_pos(pos)

func set_pos_z(prop_pos : Vector2i, idx : int, pos_z : float):
	if has_prop(prop_pos, idx):
		var prop : Prop = props[prop_pos][idx]
		var pos : Vector3 = prop.pos
		pos.z = pos_z
		prop.set_pos(pos)

func get_angle(prop_pos : Vector2i, idx : int) -> float:
	if has_prop(prop_pos, idx):
		return props[prop_pos][idx].angle
	return 0.0

func set_angle(prop_pos : Vector2i, idx : int, pos : float):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].set_angle(pos)

func toggle_billboard(prop_pos : Vector2i, idx : int):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].toggle_billboard()

func toggle_one_sided(prop_pos : Vector2i, idx : int):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].toggle_one_sided()

func toggle_ceiling_attach(prop_pos : Vector2i, idx : int):
	if has_prop(prop_pos, idx):
		var heights : Color = heightmap.get_pixelv(prop_pos)
		props[prop_pos][idx].toggle_ceiling_attach(heights.g, heights.b)
		update_height(prop_pos)

func toggle_horizontal_mode(prop_pos : Vector2i, idx : int):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].toggle_horizontal_mode()

func set_prop_scale(prop_pos : Vector2i, idx : int, prop_scale : Vector2):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].set_scale(prop_scale)

func set_prop_scale_h(prop_pos : Vector2i, idx : int, prop_scale_h : float):
	if has_prop(prop_pos, idx):
		var prop : Prop = props[prop_pos][idx]
		var prop_scale : Vector2 = prop.scale
		prop_scale.x = prop_scale_h
		prop.set_scale(prop_scale)

func set_prop_scale_v(prop_pos : Vector2i, idx : int, prop_scale_v : float):
	if has_prop(prop_pos, idx):
		var prop : Prop = props[prop_pos][idx]
		var prop_scale : Vector2 = prop.scale
		prop_scale.y = prop_scale_v
		prop.set_scale(prop_scale)

func set_hue(prop_pos : Vector2i, idx : int, hue : float):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].set_hue(hue)

func set_bias(prop_pos : Vector2i, idx : int, bias : float):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].set_bias(bias)

func set_alpha(prop_pos : Vector2i, idx : int, alpha : float):
	if has_prop(prop_pos, idx):
		props[prop_pos][idx].set_alpha(alpha)

func get_all(prop_pos : Vector2i, idx : int) -> Dictionary:
	if has_prop(prop_pos, idx):
		return props[prop_pos][idx].get_all()

	return {}

func set_all(prop_pos : Vector2i, idx : int, propdict : Dictionary):
	if has_prop(prop_pos, idx):
		var heights : Color = heightmap.get_pixelv(prop_pos)
		props[prop_pos][idx].set_all(propdict, heights)

func save_props(writer : ZIPPacker):
	var err : Error

	err = writer.start_file("props.txt")
	if err != Error.OK:
		return err

	for loc in props.keys():
		err = FileUtilities.write_line(writer, ("location %d %d" % [loc.x, loc.y]))
		if err != Error.OK:
			return err

		for prop in props[loc]:
			var propdict : Dictionary = prop.get_all()
			for key in propdict.keys():
				err = FileUtilities.write_line(writer,
											   FileUtilities.make_line(key, propdict[key]))
				if err != Error.OK:
					return err

	err = writer.close_file()
	if err != Error.OK:
		return err

	return Error.OK

const PROP_VALUES : Dictionary[StringName, int] = {
	&'name': TYPE_STRING,
	&'pos': TYPE_VECTOR3,
	&'angle': TYPE_FLOAT,
	&'billboard': TYPE_BOOL,
	&'one-sided': TYPE_BOOL,
	&'ceiling-attach': TYPE_BOOL,
	&'horizontal-mode': TYPE_BOOL,
	&'scale': TYPE_VECTOR2,
	&'hue': TYPE_FLOAT,
	&'bias': TYPE_FLOAT,
	&'alpha': TYPE_FLOAT
}

func check_prop_dict(dict : Dictionary) -> bool:
	for key in PROP_VALUES.keys():
		if not key in dict:
			return false
	return true

func try_create_prop(dictbox : Array[Dictionary], location) -> Error:
	var dict : Dictionary = dictbox[0]

	if check_prop_dict(dict):
		if location == null:
			return Error.ERR_FILE_UNRECOGNIZED

		if not location in staging_props:
			staging_props[location] = []
		staging_props[location].append(dict)

		dictbox[0] = {}
		return Error.OK

	return Error.ERR_SKIP

func load_props(reader : ZIPReader) -> Error:
	var err : Error

	var dictbox : Array[Dictionary] = [{}]
	var location : Vector2i
	if not reader.file_exists("props.txt"):
		# nothing to do
		return Error.OK

	var prop_file : String = reader.read_file("props.txt").get_string_from_utf8()

	for line in prop_file.split('\n', false):
		FileUtilities.update_dict_from_line(dictbox[0], &'location', line, TYPE_VECTOR2I)
		if &'location' in dictbox[0]:
			location = dictbox[0][&'location']
		for key in PROP_VALUES.keys():
			FileUtilities.update_dict_from_line(dictbox[0], key, line, PROP_VALUES[key])
			err = try_create_prop(dictbox, location)
			if err == Error.OK:
				break
			elif err == Error.ERR_SKIP:
				continue
			else:
				return err

	if len(dictbox[0]) > 0:
		return Error.ERR_FILE_UNRECOGNIZED

	return Error.OK

func apply_staged(propdefs : Dictionary[StringName, PropDef]):
	clear_props()

	for location in staging_props.keys():
		var heights : Color = heightmap.get_pixelv(location)
		for s_prop in staging_props[location]:
			if not s_prop[&'name'] in propdefs:
				add_prop(propdefs[&'error'], location)
			else:
				add_prop(propdefs[s_prop[&'name']], location)
			var prop : Prop = props[location][-1]
			prop.set_all(s_prop, heights)
		# update various parameters for props in view
		update_height(location)

	staging_props = {}

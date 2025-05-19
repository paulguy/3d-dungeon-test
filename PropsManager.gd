extends Node3D
class_name PropsManager

var heightmap : Image
var mapsize : Vector2i
var positions : Array[Array]
var offsets : Array[int]
var props : Dictionary[Vector2i, Array]
var view_pos : Vector2i = Vector2i.ZERO
var view_dir : int = 0
var view_height : float = 0.0
var depth : int

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

func update_view_pos(prop : Prop):
	var prop_view_pos : Vector2i = prop.map_pos - view_pos
	var height : float
	if prop.ceiling_attach:
		# ceiling mesh bottom is green channel
		height = heightmap.get_pixelv(prop.map_pos).g - view_height
	else:
		# floor mesh top is blue channel
		height = heightmap.get_pixelv(prop.map_pos).b - view_height

	if view_dir == MapParameters.SOUTH:
		# looking down +Z
		prop.set_view_pos(Vector3(prop_view_pos.x, height, prop_view_pos.y))
		prop.set_view_angle(0.0)
	elif view_dir == MapParameters.NORTH:
		# looking down -Z
		prop.set_view_pos(Vector3(-prop_view_pos.x, height, -prop_view_pos.y))
		prop.set_view_angle(PI)
	elif view_dir == MapParameters.EAST:
		# looking down +X
		prop.set_view_pos(Vector3(-prop_view_pos.y, height, prop_view_pos.x))
		prop.set_view_angle(PI * 1.5)
	else: # WEST
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

	if view_dir == MapParameters.SOUTH:
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
	elif view_dir == MapParameters.NORTH:
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
	elif view_dir == MapParameters.EAST:
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

func add_prop(propdef : PropDef, map_pos : Vector2i):
	if not map_pos in props:
		# if position has no props, create the array first
		props[map_pos] = []

	var prop : Prop = Prop.new(propdef, map_pos)
	props[map_pos].append(prop)

	# needs some initial parent
	invisible_node.add_child(prop.sprite)

	execute_if_prop_visible(prop, make_visible)

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

func set_view_height(height : float):
	view_height = height
	execute_each_visible(update_view_pos)

func get_pos(prop_pos : Vector2i, idx : int) -> Vector3:
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		return props[prop_pos][idx].pos
	return Vector3.ZERO

func set_pos(prop_pos : Vector2i, idx : int, pos : Vector3):
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		props[prop_pos][idx].set_pos(pos)

func get_angle(prop_pos : Vector2i, idx : int) -> float:
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		return props[prop_pos][idx].angle
	return 0.0

func set_angle(prop_pos : Vector2i, idx : int, pos : float):
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		props[prop_pos][idx].set_angle(pos)

func toggle_billboard(prop_pos : Vector2i, idx : int):
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		return props[prop_pos][idx].toggle_billboard()

func toggle_one_sided(prop_pos : Vector2i, idx : int):
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		return props[prop_pos][idx].toggle_one_sided()

func toggle_ceiling_attach(prop_pos : Vector2i, idx : int) -> bool:
	if prop_pos in props and idx >= 0 and idx < len(props[prop_pos]):
		var heights : Color = heightmap.get_pixelv(prop_pos)
		var ceiling_attach : bool = props[prop_pos][idx].toggle_ceiling_attach(heights.g, heights.b)
		update_height(prop_pos)
		return ceiling_attach
	return false

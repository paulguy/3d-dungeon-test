extends Node
class_name DirParameters

enum {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

static func dir_string(val : int):
	match val:
		NORTH:
			return "north"
		EAST:
			return "east"
		SOUTH:
			return "south"
		WEST:
			return "west"

	return "invalid"

static func get_opp_dir(dir : int):
	match dir:
		NORTH:
			return SOUTH
		EAST:
			return WEST
		SOUTH:
			return NORTH
		_: # west
			return EAST

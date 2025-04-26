class_name MapParameters

enum {
	HEIGHT = 0,
	HUE = 1,
	BIAS = 2,
	OFFSET = 3,
	FOG_COLOR_R = 4,
	FOG_COLOR_G = 5,
	FOG_COLOR_B = 6,
	FOG_POWER = 7,
	EYE_HEIGHT = 8,
	MAX_PARAMETER = 9
}
const GEOMETRY_PARAMETERS_MAX = OFFSET

static func parameter_string(val : int) -> String:
	match val:
		HEIGHT:
			return "height"
		HUE:
			return "hue"
		BIAS:
			return "bias"
		OFFSET:
			return "offset"
		FOG_COLOR_R:
			return "fog color r"
		FOG_COLOR_G:
			return "fog color g"
		FOG_COLOR_B:
			return "fog color b"
		FOG_POWER:
			return "fog power"
		EYE_HEIGHT:
			return "eye height"

	return "invalid"

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

enum {
	HORIZ = 0,
	WALL = 1
}

static func face_string(val : int):
	match val:
		HORIZ:
			return "horizontal"
		WALL:
			return "wall"

	return "invalid"

enum {
	CEILING = 0,
	FLOOR = 1
}

static func mesh_string(val : int):
	match val:
		CEILING:
			return "ceiling"
		FLOOR:
			return "floor"

	return "invalid"

enum {
	TOP = 0,
	BOTTOM = 1
}

static func topbottom_string(val : int):
	match val:
		TOP:
			return "top"
		BOTTOM:
			return "bottom"

	return "invalid"

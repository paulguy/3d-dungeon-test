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
		MapParameters.HEIGHT:
			return "height"
		MapParameters.HUE:
			return "hue"
		MapParameters.BIAS:
			return "bias"
		MapParameters.OFFSET:
			return "offset"
		MapParameters.FOG_COLOR_R:
			return "fog color r"
		MapParameters.FOG_COLOR_G:
			return "fog color g"
		MapParameters.FOG_COLOR_B:
			return "fog color b"
		MapParameters.FOG_POWER:
			return "fog power"
		MapParameters.EYE_HEIGHT:
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
		_: # west
			return "west"

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
	if val == HORIZ:
		return "horizontal"

	return "wall"

enum {
	CEILING = 0,
	FLOOR = 1
}

static func mesh_string(val : int):
	if val == CEILING:
		return "ceiling"

	return "floor"

enum {
	TOP = 0,
	BOTTOM = 1
}

static func topbottom_string(val : int):
	if val == TOP:
		return "top"

	return "bottom"

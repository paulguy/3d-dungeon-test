class_name MapParameters

enum {
	HEIGHT = 0,
	HUE = 1,
	BIAS = 2,
	OFFSET = 3,
	SKY = 4,
	FOG_COLOR_R = 5,
	FOG_COLOR_G = 6,
	FOG_COLOR_B = 7,
	FOG_POWER = 8,
	DEPTH = 9,
	MAX_PARAMETER = 10
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
		SKY:
			return "draw sky"
		FOG_COLOR_R:
			return "fog color r"
		FOG_COLOR_G:
			return "fog color g"
		FOG_COLOR_B:
			return "fog color b"
		FOG_POWER:
			return "fog power"
		DEPTH:
			return "depth"

	return "invalid"

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

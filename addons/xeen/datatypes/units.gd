extends Object
class_name Units


# Cell/Face
enum FACE {BOTTOM = 1, TOP = 2, NORTH = 4, SOUTH = 8, WEST = 16, EAST = 32, WALLS = 4+8+16+32}
const WALLS = [FACE.NORTH, FACE.EAST, FACE.SOUTH, FACE.WEST]
enum VISIBILITY {AUTO, ALWAYS, NEVER}
enum PASSABILITY {AUTO, ALWAYS, NEVER}
enum ROTATION {NONE, QUARTER, HALF, THREE_THIRDS}

enum TOOL {BRUSH, EYEDROPPER, BOX_SELECT}

static func get_opposite_face(f: int) -> int:
	match f:
		FACE.BOTTOM: return FACE.TOP
		FACE.TOP: return FACE.BOTTOM
		FACE.NORTH: return FACE.SOUTH
		FACE.EAST: return FACE.WEST
		FACE.SOUTH: return FACE.NORTH
		FACE.WEST: return FACE.EAST
		_:
			push_error("Invalid face id: %d" % f)
			return -1

static func visibility2bool(val: int) -> bool: 
    match val:
        VISIBILITY.ALWAYS: return true
        VISIBILITY.NEVER: return false
        VISIBILITY.AUTO:
            push_warning("Cannot handle AUTO case.")
            return false
        _:
            push_error("Invalid value: %d" % val)
            return false


# Spatial stuff
enum ABS_DIR {SOUTH, EAST, NORTH, WEST}
enum REL_DIR {FORWARD, RIGHT, BACK, LEFT}

static func absdir2str(absdir) -> String:
    match absdir:
        ABS_DIR.SOUTH: return "south"
        ABS_DIR.NORTH: return "north"
        ABS_DIR.WEST: return "west"
        ABS_DIR.EAST: return "east"
        _: return "undefined"

static func absdir2face(absdir) -> int:
    match absdir:
        ABS_DIR.SOUTH: return FACE.SOUTH
        ABS_DIR.EAST: return FACE.EAST
        ABS_DIR.NORTH: return FACE.NORTH
        ABS_DIR.WEST: return FACE.WEST
        _:
            push_warning("Invalid ABS_DIR: %d" % absdir)
            return -1

static func reldir2str(absdir) -> String:
    match absdir:
        REL_DIR.FORWARD: return "forward"
        REL_DIR.BACK: return "back"
        REL_DIR.LEFT: return "left"
        REL_DIR.RIGHT: return "right"
        _: return ""

static func move2absdir(move: Vector3) -> int:
    var x = int(move.x)
    var z = int(move.z)
    if x == 0 and z == -1:
        return ABS_DIR.NORTH
    elif x == 0 and z == 1:
        return ABS_DIR.SOUTH
    elif x == 1 and z == 0:
        return ABS_DIR.EAST
    elif x == -1 and z == 0:
        return ABS_DIR.WEST
    else:
        push_error("can only handle cardinal movement vectors.")
        return -1

static func face2str(id: int) -> String:
    match id:
        FACE.TOP: return "top"
        FACE.BOTTOM: return "bottom"
        FACE.NORTH: return "north"
        FACE.EAST: return "east"
        FACE.SOUTH: return "south"
        FACE.WEST: return "west"
        _:
            push_error("Invalid face id: %d" % id)
            return ""
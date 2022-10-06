extends Object
class_name Units

enum ABS_DIR {SOUTH, EAST, NORTH, WEST}
enum REL_DIR {FORWARD, RIGHT, BACK, LEFT}

static func absdir2str(absdir) -> String:
    match absdir:
        ABS_DIR.SOUTH: return "south"
        ABS_DIR.NORTH: return "north"
        ABS_DIR.WEST: return "west"
        ABS_DIR.EAST: return "east"
        _: return "undefined"

static func reldir2str(absdir) -> String:
    match absdir:
        REL_DIR.FORWARD: return "forward"
        REL_DIR.BACK: return "back"
        REL_DIR.LEFT: return "left"
        REL_DIR.RIGHT: return "right"
        _: return "undefined"

static func move2absdir(move: Vector3) -> int:
    var x = int(move.x)
    var z = int(move.z)
    print(x, ", ", z)
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

    #var m = [int(move.x), (move.z)]
    #print("move: ", str(m))
    #match m:
    #    [0, -1]: return ABS_DIR.NORTH
    #    [0,  1]: return ABS_DIR.SOUTH
    #    [1,  0]: return ABS_DIR.EAST
    #    [-1, 0]: return ABS_DIR.WEST
    #    _:
    #        push_error("can only handle cardinal movement vectors.")
    #        return -1
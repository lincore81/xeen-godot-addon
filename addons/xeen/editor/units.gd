extends Object
class_name Units

enum ABS_DIR {NORTH, SOUTH, WEST, EAST}


static func float_equals(a: float, b: float, epsilon := 0.0005) -> bool:
    return abs(a-b) < epsilon

static func get_look_dir(spatial: Spatial, epsilon := 0.0005) -> int:
    var angle = spatial.global_rotation.y
    if float_equals(angle, 0, epsilon):
        return ABS_DIR.EAST
    elif float_equals(angle, PI*0.5, epsilon):
        return ABS_DIR.NORTH
    elif float_equals(angle, PI, epsilon) or float_equals(angle, -PI, epsilon):
        return ABS_DIR.WEST
    elif float_equals(angle, -PI*0.5, epsilon):
        return ABS_DIR.SOUTH
    else:
        push_error("angle is not a cardinal direction: %d" % angle)
        return -1
    


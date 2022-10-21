extends Spatial
class_name GameScene


onready var player := $Player as PlayerSpatial
onready var map := $Map as CellMapNode
var cooldown = 0

var queued_action: String = ""


func _check_and_queue_action(name: String) -> bool:
    #var perform_queued = queued_action == name and progress >= 1
    return Input.is_action_pressed(name)
    #if progress < 1 and progress >= 0.25:
    #	queued_action = name
    #	return false
    #elif pressed or perform_queued:
#		if queued_action != "":
#			print("performing queued action: ", name)
#		queued_action = ""
#		return true
#	else:
#		return false

func _process(d):
    if cooldown > 0:
        cooldown -= d
        return
    else:
        cooldown = 1/30
    if player.move_progress() < 1: return

    var rel_dir := -1
    var rot_left := false
    var rot_right := false
        
    if _check_and_queue_action("move_forward"):
        rel_dir = Units.REL_DIR.FORWARD
    elif _check_and_queue_action("move_back"):
        rel_dir = Units.REL_DIR.BACK
    elif _check_and_queue_action("strafe_left"):
        rel_dir = Units.REL_DIR.LEFT
    elif _check_and_queue_action("strafe_right"):
        rel_dir = Units.REL_DIR.RIGHT
    elif _check_and_queue_action("turn_left"):
        rot_left = true
    elif _check_and_queue_action("turn_right"):
        rot_right = true

    if rel_dir >= 0:
        _move_player(rel_dir)
    elif rot_right or rot_left:
        player.turn(true if rot_right else false)

func _move_player(rel_dir: int):
    var forward := -player.transform.basis.z.normalized()
    var axis := forward.abs().max_axis()
    var cardinal := Vector3.ZERO
    cardinal[axis] = sign(forward[axis])
    var target: Vector3
    match rel_dir:
        Units.REL_DIR.FORWARD:
            target = cardinal
        Units.REL_DIR.BACK:
            target = -cardinal
        Units.REL_DIR.RIGHT:
            target = cardinal.cross(Vector3.UP)
        Units.REL_DIR.LEFT:
            target = -cardinal.cross(Vector3.UP)
        _:
            push_error("Illegal direction: %d" % rel_dir)
            return
    var absdir = Units.move2absdir(target)
    print("Current pos: %s, Move: %s, dir: %s" % [str(player.translation), str(target), Units.absdir2str(absdir)])
    if map.is_wall_passable(player.translation.floor(), absdir):
        player.move(target)
    else:
        print("bump")

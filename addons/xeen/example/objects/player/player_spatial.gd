extends Spatial
class_name PlayerSpatial
"""
Take care of "player" movement, distinct from the player state aka party/characters.
"""

export var turn_speed := 0.2
export var move_speed := 0.3

var tween: Tween
var tween_time: float


func get_map_position() -> Vector3:
    # TODO: consider map translation
    return translation.floor()

func _enter_tree():
    tween = Tween.new()
    add_child(tween)


func is_moving():
    return tween.is_active()

func move(target: Vector3):
    tween_time = move_speed
    var _b = tween.interpolate_property(self, "translation", null, translation + target, tween_time, Tween.TRANS_LINEAR)
    _b = tween.start()

func turn(right := true):
    if is_moving(): return
    var sgn := -1 if right else 1
    var target := global_rotation
    target.y += PI/2 * sgn
    tween_time = turn_speed
    var _b = tween.interpolate_property(self, "global_rotation", null, target, tween_time, Tween.TRANS_LINEAR)
    _b = tween.start()

func move_progress():
    if not is_moving():
        return 1
    elif tween_time > 0:
        return tween.tell() / tween_time
    else:
        return 1

extends Spatial
class_name PlayerSpatial
"""
Take care of "player" movement, distinct from the player state aka party/characters.
"""

var tween: Tween

func get_map_position() -> Vector3:
	# TODO: consider map position
	return translation.floor()

func _enter_tree():
	tween = Tween.new()
	add_child(tween)

func _ready():
	print("Player, direction=%d, position=%s" % [Units.get_look_dir(self), str(get_map_position())])

func is_moving():
	return tween.is_active()

func moveby(m: Vector3):
	if is_moving(): return
	var target := translation + global_transform.basis.xform(m)
	var _b = tween.interpolate_property(self, "translation", null, target, 0.4, Tween.TRANS_LINEAR)
	_b = tween.start()

func turn(right := true):
	if is_moving(): return
	var sgn := -1 if right else 1
	var target := global_rotation
	target.y += PI/2 * sgn
	var _b = tween.interpolate_property(self, "global_rotation", null, target, 0.2)
	_b = tween.start()

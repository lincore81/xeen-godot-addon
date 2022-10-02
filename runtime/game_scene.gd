extends Spatial
class_name GameScene
"""
Manage the runtime game state.
"""


onready var player := $Player as PlayerSpatial
onready var map := $Map as CellMapNode
var cooldown = 0

func _process(d):
	if cooldown > 0: cooldown -= d
	if player.is_moving(): return

	var horiz_input = Input.get_axis("strafe_left", "strafe_right")
	var vert_input = Input.get_axis("move_forward", "move_back")
	var rot_right = Input.get_action_strength("turn_right") > 0.1
	var rot_left = Input.get_action_strength("turn_left") > 0.1

	if horiz_input != 0 or vert_input != 0 and cooldown <= 0:
		var pos := player.get_map_position()
		var dir := Units.get_look_dir(player)
		if map.is_wall_passable(pos, dir):
			player.moveby(Vector3(horiz_input, 0, vert_input))
		else:
			cooldown = 0.2
			print("Bump!")
	elif rot_right or rot_left:
		player.turn(true if rot_right else false)

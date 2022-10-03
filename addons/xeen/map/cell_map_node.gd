tool
extends Spatial
class_name CellMapNode
"""
Maintain references to the cells, allow checking for, iterating over, adding and removing cells.
"""
const ICON: Texture = preload("res://addons/xeen/map/cell_map_node.png")

#FIXME: use setget
export var size := Vector3(100, 1, 100)
var cells: Dictionary = {}
export var data: Resource

func get_bounds() -> AABB:
	var it = AABB()
	it.position = Vector3.ZERO
	it.size = size
	return it

func _enter_tree():
	pass

func _exit_tree():
	pass

func is_wall_passable(pos: Vector3, dir: int):
	var c := cell_at(pos)
	print("cell at %s = %s" % [str(pos), str(c)])
	return c.is_wall_passable(dir) if c != null else false

func serialise():
	var mapdata := data as MapData
	assert(mapdata, "Invalid map resource.")
	mapdata.size = size
	var f = funcref(self, "_serialise_cell")
	iterate_over_area(f, get_bounds(), true)
	MapData.write_to_disk(mapdata)

func _serialise_cell(cell, pos: Vector3, _x) -> bool:
	print("serialising cell %s at %s " % [str(cell), str(pos)])
	MapData.store_cell(data, pos, cell)
	return true
			
func iterate_over_area(callback: FuncRef, bounds: AABB, skip_null = false, context = null):
	"""
		Iterate over all cells within the given AABB (floored) until the
		callback function returns false. Will not exceed map bounds.
		callback signature: (Cell, Vector3, context: Variant) -> bool
	"""
	bounds = bounds.abs()
	var x0 = max(0, bounds.position.x)
	var x1 = min(size.x-1, bounds.end.x)
	var z0 = max(0, bounds.position.z)
	var z1 = min(size.z-1, bounds.end.z)
	for x in range(x0, x1):
		for z in range(z0, z1):
			var v := Vector3(x, 0, z)
			var cell = cell_at(v)
			if not skip_null or cell != null:
				if not callback.call_func(cell, v, context):
					return
	


func get_cardinal_neighbours(pos: Vector3) -> Array:
	return [
		cell_at(pos + Vector3.FORWARD),
		cell_at(pos + Vector3.RIGHT),
		cell_at(pos + Vector3.BACK),
		cell_at(pos + Vector3.LEFT)
	]

func put_cell(pos: Vector3, cell_template: PackedScene, update_faces: bool = true) -> bool:
	pos = pos.floor()
	if data == null:
		push_error("No MapData resource!")
		return false
	var cell = cell_template.instance()
	cell.set_meta("_edit_lock_", true)
	add_child(cell, true)
	cell.name = "Cell (%d,%d,%d)" % [int(pos.x), int(pos.y), int(pos.z)]
	cell.translation = pos
	cell.owner = self.owner
	cells[pos] = cell
	if update_faces: 
		update_cell_faces(pos)
	serialise()
	# FIXME: setting the owner doesn't solve all problems with persistance
	#cell.owner = self.owner
	#emit_signal("cell_changed", pos, cell)
	return true


func clear_cell(pos: Vector3, update_faces := true) -> bool:
	pos = pos.floor()
	if pos in cells:
		var cell = cells[pos]
		cells.erase(pos)
		cell.queue_free()
		if update_faces: 
			update_cell_faces(pos, true)
		serialise()
		return true
	else:
		return false
	   
# TODO: cells should probably update faces themselves, so the behaviour can be changed in subclasses.
func update_cell_faces(pos: Vector3, removed := false):
	var neighbours := get_cardinal_neighbours(pos)
	var face_mask: int = Cell.Face.TOP + Cell.Face.BOTTOM
	var neighbour
	# north
	neighbour = neighbours[0]
	if neighbour != null:
		neighbour.set_face(Cell.Face.SOUTH, removed)
	else:
		face_mask += Cell.Face.NORTH
	# east
	neighbour = neighbours[1]
	if neighbour != null:
		neighbour.set_face(Cell.Face.WEST, removed)
	else:
		face_mask += Cell.Face.EAST
	# south
	neighbour = neighbours[2]
	if neighbour != null:
		neighbour.set_face(Cell.Face.NORTH, removed)
	else:
		face_mask += Cell.Face.SOUTH
	# west
	neighbour = neighbours[3]
	if neighbour != null:
		neighbour.set_face(Cell.Face.EAST, removed)
	else:
		face_mask += Cell.Face.WEST

	if !removed:
		var cell := cell_at(pos)
		if cell == null: return
		cell.set_faces(face_mask)

func cell_at(pos: Vector3) -> Cell:
	pos = pos.floor()
	return cells[pos] if pos in cells else null

func in_bounds(pos: Vector3):
	return pos.x >= 0 && pos.x < size.x && pos.z >= 0 && pos.z < size.z

#func _pos2idx(pos: Vector3) -> int:
#	return int(pos.z) * int(size.x) + int(pos.x)
#
#func _idx2pos(idx: int) -> Vector3:
#	var x := idx % int(size.x)
#	var z := (idx - x) / int(size.x)
#	return Vector3(x, 0, z)
#
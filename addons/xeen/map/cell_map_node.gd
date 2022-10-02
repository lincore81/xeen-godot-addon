tool
extends Spatial
class_name CellMapNode
"""
Maintain references to the cells, allow checking for, iterating over, adding and removing cells.
"""
const ICON: Texture = preload("res://addons/xeen/map/cell_map_node.png")

#FIXME: use setget
export var size := Vector3(100, 1, 100)
export var cells: Array


func get_bounds() -> AABB:
	var it = AABB()
	it.position = Vector3.ZERO
	it.size = size
	return it

func _enter_tree():
	initialise_cells()

func _exit_tree():
	pass

func is_wall_passable(pos: Vector3, dir: int):
	var c := cell_at(pos)
	print("cell at %s = %s" % [str(pos), str(c)])
	return c.is_wall_passable(dir) if c != null else false


func initialise_cells():
	cells = Array()
	cells.resize(size.x)
	for x in range(size.x):
		var zs = Array()
		zs.resize(size.z)
		cells[x] = zs
	#TODO: Find a better way to 'deserialise' the map
	for c in get_children():
		if c is Cell:
			var x := int(c.translation.x)
			var z := int(c.translation.z)
			print("Found cell at %d,%d." % [x, z])
			cells[x][z] = c



func iterate_over_area(callback: FuncRef, bounds: AABB):
	"""
		Iterate over all cells within the given AABB (floored) until the
		callback function returns false. Will not exceed map bounds.
		callback signature: (Cell, Vector3) -> bool
	"""
	bounds = bounds.abs()
	var x0 = max(0, bounds.position.x)
	var x1 = min(size.x-1, bounds.end.x)
	var z0 = max(0, bounds.position.z)
	var z1 = min(size.z-1, bounds.end.z)
	for x in range(x0, x1):
		for z in range(z0, z1):
			var v := Vector3(x, 0, z)
			if not callback.call_func(cell_at(v), v):
				return
	


func get_cardinal_neighbours(pos: Vector3) -> Array:
	return [
		cell_at(pos + Vector3.FORWARD),
		cell_at(pos + Vector3.RIGHT),
		cell_at(pos + Vector3.BACK),
		cell_at(pos + Vector3.LEFT)
	]

func put_cell(pos: Vector3, cell_template: PackedScene, update_faces: bool = true) -> bool:
	var cell := cell_template.instance() as Cell
	assert(cell, "not a cell?")
	cell.set_meta("_edit_lock_", true)
	add_child(cell, true)
	# FIXME: setting the owner doesn't solve all problems with persistance
	cell.owner = self.owner
	cell.name = "Cell (%d,%d,%d)" % [int(pos.x), int(pos.y), int(pos.z)]
	cell.translation = pos
	cells[int(pos.x)][int(pos.z)] = cell
	if update_faces: update_cell_faces(pos)
	#emit_signal("cell_changed", pos, cell)
	return true


func clear_cell(pos: Vector3, update_faces := true) -> bool:
	var x = int(pos.x)
	var z = int(pos.z)
	var cell = cells[x][z]
	if cell != null: 
		cells[x][z] = null
		cell.queue_free()
		if update_faces: 
			update_cell_faces(pos, true)
	#emit_signal("cell_changed", pos, null)
	return true
	   
# TODO: cells should probably update faces themselves, so the behaviour can be changed in subclasses.
func update_cell_faces(pos: Vector3, removed := false):
	var neighbours := get_cardinal_neighbours(pos)
	var face_mask: int = Cell.Face.TOP + Cell.Face.BOTTOM
	var neighbour: Cell 
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
	var x = int(pos.x)
	var z = int(pos.z)
	return cells[x][z] if in_bounds(pos) else null

func in_bounds(pos: Vector3):
	return pos.x >= 0 && pos.x < size.x && pos.z >= 0 && pos.z < size.z

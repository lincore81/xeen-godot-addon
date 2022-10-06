tool
extends Spatial
class_name CellMapNode
"""
Maintain references to the cells, allow checking for, iterating over, adding and removing cells.
"""
const ICON: Texture = preload("res://addons/xeen/map/cell_map_node.png")
var cell_template: PackedScene = preload("res://addons/xeen/map/cells/cell.tscn")

#FIXME: use setget
export var size := Vector3(100, 1, 100)
var cells: Dictionary = {}
export var data: Resource setget _set_map_data, _get_map_data
var marshalling := false

func get_bounds() -> AABB:
	var it = AABB()
	it.position = Vector3.ZERO
	it.size = size
	return it

func _ready():
	var mapdata = data as MapData
	if not mapdata.is_empty():
		deserialise()

func is_wall_passable(pos: Vector3, abs_dir: int):
	var c := cell_at(pos)
	print("cell at %s: %s" % [str(pos), str(c)])
	return c.is_wall_passable(abs_dir) if c != null else false


func deserialise():
	if marshalling: return
	var mapdata := data as MapData
	assert(mapdata, "Invalid map resource.")
	marshalling = true
	cells.clear()
	size = mapdata.size
	var f = funcref(self, "_deserialise_cell")
	MapData.iter_over_cell_data(mapdata, f, mapdata)
	marshalling = false
	print("Deserialised map")

func _deserialise_cell(celldata, pos: Vector3, mapdata: MapData) -> void:
	var cell = put_cell(pos, cell_template, {}, false)
	MapData.restore_cell(mapdata, pos, cell)

func serialise():
	if not Engine.editor_hint: return
	if marshalling: return
	var mapdata := data as MapData
	assert(mapdata, "Invalid map resource.")
	marshalling = true
	mapdata.clear()
	mapdata.size = size
	var f = funcref(self, "_serialise_cell")
	iterate_over_area(f, get_bounds(), true)
	MapData.write_to_disk(mapdata)
	marshalling = false

func _serialise_cell(cell, pos: Vector3, _x) -> bool:
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
	var x1 = min(size.x, bounds.end.x + 1)
	var z0 = max(0, bounds.position.z)
	var z1 = min(size.z, bounds.end.z + 1)
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

func put_cell(pos: Vector3, cell_template: PackedScene, materials: Dictionary = {}, update_faces: bool = true) -> Cell:
	pos = pos.floor()
	if data == null:
		push_error("No MapData resource!")
		return null
	var cell = cell_template.instance()
	cell.set_meta("_edit_lock_", true)
	add_child(cell, true)
	cell.name = "Cell (%d,%d,%d)" % [pos.x, pos.y, pos.z]
	cell.translation = pos
	cells[pos] = cell
	if update_faces: 
		update_cell_faces(pos)
	serialise()
	return cell


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
	var face_mask: int = Cell.FACE.TOP + Cell.FACE.BOTTOM
	var neighbour
	# north
	neighbour = neighbours[0]
	if neighbour != null:
		neighbour.set_face(Cell.FACE.SOUTH, removed)
	else:
		face_mask += Cell.FACE.NORTH
	# east
	neighbour = neighbours[1]
	if neighbour != null:
		neighbour.set_face(Cell.FACE.WEST, removed)
	else:
		face_mask += Cell.FACE.EAST
	# south
	neighbour = neighbours[2]
	if neighbour != null:
		neighbour.set_face(Cell.FACE.NORTH, removed)
	else:
		face_mask += Cell.FACE.SOUTH
	# west
	neighbour = neighbours[3]
	if neighbour != null:
		neighbour.set_face(Cell.FACE.EAST, removed)
	else:
		face_mask += Cell.FACE.WEST

	if !removed:
		var cell := cell_at(pos)
		if cell == null: return
		cell.set_faces(face_mask)

func cell_at(pos: Vector3) -> Cell:
	pos = pos.floor()
	return cells[pos] if pos in cells else null

func in_bounds(pos: Vector3):
	return pos.x >= 0 && pos.x < size.x && pos.z >= 0 && pos.z < size.z

func _set_map_data(v: Resource):
	assert(v is MapData, "Map Node: Wrong resource type, expected MapData.")
	data = v as MapData

func _get_map_data() -> Resource:
	return data

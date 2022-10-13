tool
extends Spatial
class_name CellMapNode
"""
Maintain references to the cells, allow checking for, iterating over, adding and removing cells.
"""
const ICON: Texture = preload("res://addons/xeen/map/cell_map_node.png")


#FIXME: use setget
export var size := Vector3(100, 1, 100) setget , _get_size
export var data: Resource setget _set_map_data, _get_map_data
var cell_template: PackedScene = preload("res://addons/xeen/map/cells/cell.tscn")
var cells: Dictionary = {}

# true while serialising or deserialising the map
var marshalling := false setget , _is_marshalling


signal mapdata_changed(oldpath, newpath)

func set_size(s: Vector3):
	# todo: free cells outside of bounds
	size = s

func _get_size():
	return size

func _is_marshalling():
	return marshalling

func get_bounds() -> AABB:
	var it = AABB()
	it.position = Vector3.ZERO
	it.size = size
	return it

func _ready():
	var mapdata = data as MapData
	if mapdata and not mapdata.is_empty():
		deserialise()

func is_wall_passable(pos: Vector3, abs_dir: int):
	var c := cell_at(pos)
	#print("cell at %s: %s" % [str(pos), str(c)])
	return c.is_wall_passable(abs_dir) if c != null else false

func iterate_over_area(callback: FuncRef, bounds: AABB, skip_null = false, userdata = null):
	"""
		Iterate over all cells within the given AABB (floored) until the
		callback function returns false. Will not exceed map bounds.
		callback signature: (Cell, Vector3, userdata: Variant) -> bool
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
				if not callback.call_func(cell, v, userdata):
					return
	
func get_cardinal_neighbours(pos: Vector3) -> Dictionary:
	return {
		Units.FACE.NORTH: cell_at(pos + Vector3.FORWARD),
		Units.FACE.EAST: cell_at(pos + Vector3.RIGHT),
		Units.FACE.SOUTH: cell_at(pos + Vector3.BACK),
		Units.FACE.WEST: cell_at(pos + Vector3.LEFT),
	}

func put_cell(pos: Vector3, cell_template: PackedScene, update_visibility := true, update_neighbours := true) -> Cell:
	pos = pos.floor()
	if data == null:
		push_error("No MapData resource!")
		return null
	if cell_at(pos) != null:
		push_error("There is already a cell here.")
		return null
	var cell := cell_template.instance() as Cell
	cell.set_meta("_edit_lock_", true)
	add_child(cell, true)
	cell.name = "Cell (%d,%d,%d)" % [pos.x, pos.y, pos.z]
	cell.translation = pos
	cells[pos] = cell
	update_face_visibility(pos, false, update_neighbours)
	return cell

func put_existing_cell(pos: Vector3, cell: Cell, update_visibility := true, update_neighbours := true) -> bool:
	pos = pos.floor()
	if data == null:
		push_error("No MapData resource!")
		return false
	if cell_at(pos) != null:
		push_error("There is already a cell here.")
		return false
	if cell in get_children():
		push_error("Cannot put own child on map")
		return false
	cell.set_meta("_edit_lock_", true)
	add_child(cell, true)
	cell.name = "Cell (%d,%d,%d)" % [pos.x, pos.y, pos.z]
	cell.translation = pos
	cells[pos] = cell
	update_face_visibility(pos, false, update_neighbours)
	return true


func clear_cell(pos: Vector3, update_neighbours := true) -> Cell:
	pos = pos.floor()
	if pos in cells:
		var cell = cells[pos]
		cells.erase(pos)
		remove_child(cell)
		update_face_visibility(pos, true, update_neighbours)
		return cell
	else:
		return null

# TAG:2D
func update_face_visibility(pos: Vector3, removed := false, update_neighbours := true):
	var neighbours := get_cardinal_neighbours(pos)
	var visible := {
		Units.FACE.TOP: true, 
		Units.FACE.BOTTOM: true,
		Units.FACE.NORTH: true,
		Units.FACE.EAST: true,
		Units.FACE.SOUTH: true,
		Units.FACE.WEST: true,
	}
	for face in neighbours.keys():
		var neighbour = neighbours[face]
		if neighbour != null and update_neighbours:
			var opposite = Units.get_opposite_face(face)
			neighbour.update_auto_visibility(opposite, removed)
			visible[face] = false
	if !removed:
		var cell := cell_at(pos)
		if cell:
			for f in visible.keys():
				cell.update_auto_visibility(f, visible[f])

func cell_at(pos: Vector3) -> Cell:
	pos = pos.floor()
	return cells[pos] if pos in cells else null

func in_bounds(pos: Vector3):
	return pos.x >= 0 && pos.x < size.x && pos.z >= 0 && pos.z < size.z

# TODO: add to undo stack, make mapdata private and add ability to change mapdata to editor panel/custom inspector
func _set_map_data(v: Resource):
	var newdata := v as MapData
	if newdata != data:
		var old_path = data.resource_path if data != null else "" 
		var new_path = newdata.resource_path if newdata != null else ""
		emit_signal("mapdata_changed", old_path, new_path)
		data = newdata

func _get_map_data() -> Resource:
	return data

# ~~~~~~~~~~~ SERIALISATION ~~~~~~~~~~~~~~~

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
	var cell = put_cell(pos, cell_template, true, false)
	MapData.restore_cell(mapdata, pos, cell)

# TODO: Only serialise 'dirty' cells by default
func serialise():
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

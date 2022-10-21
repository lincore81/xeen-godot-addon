tool
extends Resource
class_name MapData

export var size: Vector3 = Vector3.ZERO
export var materials: Array = []
export var cells: Dictionary = {}


# TODO: Also store cell templates 

func is_empty() -> bool:
	return cells.empty()


func clear():
	size = Vector3.ZERO
	materials = []
	cells = {}


# Callback function: (celldata: Dictionary, pos: Vector3, context: Variant) -> void
static func iter_over_cell_data(data: MapData, callback: FuncRef, context = null):
	for pos in data.cells.keys():
		var celldata = data.cells[pos]
		if celldata == null:
			push_warning("celldata is null: %s" % str(pos))
		else:
			callback.call_func(celldata, pos, context)


static func write_to_disk(data: MapData):
	var result = ResourceSaver.save(data.resource_path, data)
	#print("Map saved to '%s', result: %d " % [data.resource_path, result])


static func restore_cell(mapdata: MapData, pos: Vector3, cell: Cell):
	if cell == null:
		push_error("Cannot restore empty cell.")
		return 
	var ipos = pos.floor()
	var data = mapdata.cells[ipos]
	for f in data.keys():
		data[f].material = _restore_material(mapdata, data[f].material)
	cell.deserialise(data)


static func store_cell(mapdata: MapData, pos: Vector3, cell):
	if cell == null: 
		push_error("Refusing to store `null` cell.")
	else:
		var result = cell.serialise()
		for f in result.keys():
			result[f].material = _store_material(mapdata, result[f].material)
		mapdata.cells[pos.floor()] = result


static func _store_material(data: MapData, material: Material) -> int:
	if material == null:
		push_warning("Face has no material.")
		return -1
	if material.resource_local_to_scene:
		push_error("Cannot store materials that are local to scene.")
		return -1
	var path = material.resource_path
	var mat_idx: int = data.materials.find(path)
	if mat_idx == -1:
		mat_idx = len(data.materials) 
		data.materials.append(path)
	return mat_idx


static func _restore_material(data: MapData, idx: int) -> Material:
	if idx == -1: # mesh has no material
		return null
	if len(data.materials) <= idx or idx < 0:
		push_error("Material index out of range: %d" % idx)
	var path = data.materials[idx]
	var mat := ResourceLoader.load(path, "Material") as Material
	if not mat:
		push_error("Couldn't load resource at '%s'." % path)
	return mat

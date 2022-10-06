tool
extends Spatial
class_name Cell
"""
	Maintains references to walls, floor and ceiling and their state.
"""

enum FACE {BOTTOM = 1, TOP = 2, NORTH = 4, SOUTH = 8, WEST = 16, EAST = 32, WALLS = 4+8+16+32}

onready var bottom := $Bottom as MeshInstance
onready var top := $Top as MeshInstance
onready var north := $North as MeshInstance
onready var south := $South as MeshInstance
onready var east := $East as MeshInstance
onready var west := $West as MeshInstance

export var face_mask: int = -0xFFFF

func is_wall_passable(dir: int) -> bool:
	var result: bool = false
	match dir:
		Units.ABS_DIR.NORTH: 
			result = not face_mask & FACE.NORTH == FACE.NORTH
			print("North passable? " , result)
		Units.ABS_DIR.EAST: 
			result = not face_mask & FACE.EAST == FACE.EAST
			print("East passable? " , result)
		Units.ABS_DIR.SOUTH: 
			result = not face_mask & FACE.SOUTH == FACE.SOUTH
			print("South passable? ", result)
		Units.ABS_DIR.WEST: 
			result = not face_mask & FACE.WEST == FACE.WEST
			print("West passable? " , result)
		_: 
			push_error("Invalid direction: %d" % dir)
	return result 

func _ready():
	_calc_face_mask()

func _calc_face_mask():
	face_mask = 0
	if bottom.visible: face_mask += FACE.BOTTOM
	if top.visible: face_mask += FACE.TOP
	if north.visible: face_mask += FACE.NORTH
	if east.visible: face_mask += FACE.EAST
	if south.visible: face_mask += FACE.SOUTH
	if west.visible: face_mask += FACE.WEST

func set_faces(mask: int):
	bottom.visible = FACE.BOTTOM & mask == FACE.BOTTOM
	top.visible    = FACE.TOP & mask == FACE.TOP
	north.visible  = FACE.NORTH & mask == FACE.NORTH
	south.visible  = FACE.SOUTH & mask == FACE.SOUTH
	east.visible   = FACE.EAST & mask == FACE.EAST
	west.visible   = FACE.WEST & mask == FACE.WEST
	face_mask = mask


func set_material(f: int, mat: Material, surface: int = 0):
	if f == FACE.BOTTOM:  
		bottom.set_surface_material(surface, mat)
	elif f == FACE.TOP:     
		top.set_surface_material(surface, mat)
	elif f == FACE.NORTH:     
		north.set_surface_material(surface, mat)
	elif f == FACE.SOUTH:     
		south.set_surface_material(surface, mat)
	elif f == FACE.EAST:     
		east.set_surface_material(surface, mat)
	elif f == FACE.WEST:     
		west.set_surface_material(surface, mat)
	elif f == FACE.WALLS:
		north.set_surface_material(surface, mat)
		south.set_surface_material(surface, mat)
		east.set_surface_material(surface, mat)
		west.set_surface_material(surface, mat)
	else:
		push_error("invalid face id: " + str(f))


#func toggle_face_visibility(f: int):
#    set_face_visibility(f, not is_face_visible(f))

func is_face_visible(f: int):
	if f == FACE.BOTTOM:
		return bottom.visible
	elif f == FACE.TOP:
		return top.visible
	elif f == FACE.NORTH:
		return north.visible
	elif f == FACE.EAST:
		return east.visible
	elif f == FACE.SOUTH:
		return south.visible
	elif f == FACE.WEST:
		return west.visible
	elif f == FACE.WALLS:
		return north.visible or west.visible or south.visible or east.visible
	else:
		push_error("invalid face id: " + str(f))

func set_face(f: int, state: bool):
	match f:
		FACE.BOTTOM:
			bottom.visible = state
		FACE.TOP:
			top.visible = state
		FACE.NORTH:
			north.visible = state
		FACE.EAST:
			east.visible = state
		FACE.SOUTH:
			south.visible = state
		FACE.WEST:
			west.visible = state
		FACE.WALLS:
			north.visible = state
			west.visible = state
			south.visible = state
			east.visible = state
		_:
			push_error("invalid face id: " + str(f))
			return
	var has_bit := face_mask & f == f
	if state and not has_bit:
		face_mask += f
	elif not state and has_bit:
		face_mask -= f

func get_face_data() -> Array:
	var faces = [[top, FACE.TOP], [bottom, FACE.BOTTOM], [north, FACE.NORTH],
			[east, FACE.EAST], [west, FACE.WEST], [south, FACE.SOUTH]]
	var result = []
	for f in faces:
		var data = {}
		data.visible = f[0].visible
		data.material = f[0].get_surface_material(0)
		data.id = f[1]
		result.append(data)
	return result
	
func get_child_by_face(id: int) -> MeshInstance:
	match id:
		FACE.BOTTOM: return bottom
		FACE.TOP: return top
		FACE.NORTH: return north
		FACE.SOUTH: return south
		FACE.EAST: return east
		FACE.WEST: return west
		_: return null

func set_face_data(data) -> void:
	if data.id == FACE.WALLS:
		var visible = data.visible if "visible" in data else null
		var material = data.material if "material" in data else null
		set_face_data({"id": FACE.NORTH, "visible": visible, "material": material})
		set_face_data({"id": FACE.SOUTH, "visible": visible, "material": material})
		set_face_data({"id": FACE.WEST, "visible": visible, "material": material})
		set_face_data({"id": FACE.EAST, "visible": visible, "material": material})
	else:
		var child := get_child_by_face(data.id)
		if child == null:
			push_error("cell face is null: %d" % data.id)
		else:
			if "visible" in data and data.visible != null:
				child.visible = data.visible
			if "material" in data and data.material:
				child.set_surface_material(0, data.material)
			_calc_face_mask()

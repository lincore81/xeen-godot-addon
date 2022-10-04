tool
extends Spatial
class_name Cell
"""
	Maintains references to walls, floor and ceiling and their state.
"""

enum Face {BOTTOM = 1, TOP = 2, NORTH = 4, SOUTH = 8, WEST = 16, EAST = 32, WALLS = 4+8+16+32}

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
			result = not face_mask & Face.NORTH == Face.NORTH
			print("North passable? " , result)
		Units.ABS_DIR.EAST: 
			result = not face_mask & Face.EAST == Face.EAST
			print("East passable? " , result)
		Units.ABS_DIR.SOUTH: 
			result = not face_mask & Face.SOUTH == Face.SOUTH
			print("South passable? ", result)
		Units.ABS_DIR.WEST: 
			result = not face_mask & Face.WEST == Face.WEST
			print("West passable? " , result)
		_: 
			push_error("Invalid direction: %d" % dir)
	return result 

func _ready():
	_calc_face_mask()

func _calc_face_mask():
	face_mask = 0
	if bottom.visible: face_mask += Face.BOTTOM
	if top.visible: face_mask += Face.TOP
	if north.visible: face_mask += Face.NORTH
	if east.visible: face_mask += Face.EAST
	if south.visible: face_mask += Face.SOUTH
	if west.visible: face_mask += Face.WEST

func set_faces(mask: int):
	bottom.visible = Face.BOTTOM & mask == Face.BOTTOM
	top.visible    = Face.TOP & mask == Face.TOP
	north.visible  = Face.NORTH & mask == Face.NORTH
	south.visible  = Face.SOUTH & mask == Face.SOUTH
	east.visible   = Face.EAST & mask == Face.EAST
	west.visible   = Face.WEST & mask == Face.WEST
	face_mask = mask


func set_material(f: int, mat: Material, surface: int = 0):
	if f == Face.BOTTOM:  
		bottom.set_surface_material(surface, mat)
	elif f == Face.TOP:     
		top.set_surface_material(surface, mat)
	elif f == Face.NORTH:     
		north.set_surface_material(surface, mat)
	elif f == Face.SOUTH:     
		south.set_surface_material(surface, mat)
	elif f == Face.EAST:     
		east.set_surface_material(surface, mat)
	elif f == Face.WEST:     
		west.set_surface_material(surface, mat)
	elif f == Face.WALLS:
		north.set_surface_material(surface, mat)
		south.set_surface_material(surface, mat)
		east.set_surface_material(surface, mat)
		west.set_surface_material(surface, mat)
	else:
		push_error("invalid face id: " + str(f))


#func toggle_face_visibility(f: int):
#    set_face_visibility(f, not is_face_visible(f))

func is_face_visible(f: int):
	if f == Face.BOTTOM:
		return bottom.visible
	elif f == Face.TOP:
		return top.visible
	elif f == Face.NORTH:
		return north.visible
	elif f == Face.EAST:
		return east.visible
	elif f == Face.SOUTH:
		return south.visible
	elif f == Face.WEST:
		return west.visible
	elif f == Face.WALLS:
		return north.visible or west.visible or south.visible or east.visible
	else:
		push_error("invalid face id: " + str(f))

func set_face(f: int, state: bool):
	#print("set_face: %d=%s" % [f, str(state)])
	if f == Face.BOTTOM:
		bottom.visible = state
	elif f == Face.TOP:
		top.visible = state
	elif f == Face.NORTH:
		north.visible = state
	elif f == Face.EAST:
		east.visible = state
	elif f == Face.SOUTH:
		south.visible = state
	elif f == Face.WEST:
		west.visible = state
	elif f == Face.WALLS:
		north.visible = state
		west.visible = state
		south.visible = state
		east.visible = state
	else:
		push_error("invalid face id: " + str(f))
		return
	var has_bit := face_mask & f == f
	if state and not has_bit:
		face_mask += f
	elif not state and has_bit:
		face_mask -= f

func get_face_data() -> Array:
	var faces = [[top, Face.TOP], [bottom, Face.BOTTOM], [north, Face.NORTH],
			[east, Face.EAST], [west, Face.WEST], [south, Face.SOUTH]]
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
		Face.BOTTOM: return bottom
		Face.TOP: return top
		Face.NORTH: return north
		Face.SOUTH: return south
		Face.EAST: return east
		Face.WEST: return west
		_: return null

func set_face_data(data) -> void:
	var child := get_child_by_face(data.id)
	if child == null:
		push_error("cell face is null")
		return
	else:
		child.visible = data.visible
		if data.material:
			child.set_surface_material(0, data.material)
	_calc_face_mask()

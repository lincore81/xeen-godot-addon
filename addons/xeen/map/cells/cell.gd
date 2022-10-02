tool
extends Spatial
class_name Cell
"""
    Maintains references to walls, floor and ceiling and their state.
"""

enum Face {BOTTOM = 1, TOP = 2, NORTH = 4, SOUTH = 8, WEST = 16, EAST = 32, WALLS = 64, SPECIAL = 128}

onready var bottom := $Bottom as MeshInstance
onready var top := $Top as MeshInstance
onready var north := $North as MeshInstance
onready var south := $South as MeshInstance
onready var east := $East as MeshInstance
onready var west := $West as MeshInstance
onready var special := get_node_or_null("Special") as MeshInstance

export var face_mask: int = -0xFFFF

func is_wall_passable(dir: int) -> bool:
    match dir:
        Units.ABS_DIR.NORTH: 
            return face_mask & Face.NORTH == Face.NORTH
        Units.ABS_DIR.EAST: 
            return face_mask & Face.EAST == Face.EAST
        Units.ABS_DIR.SOUTH: 
            return face_mask & Face.SOUTH == Face.SOUTH
        Units.ABS_DIR.WEST: 
            return face_mask & Face.WEST == Face.WEST
        _: 
            push_error("Invalid direction: %d" % dir)
            return false

func _ready():
    if face_mask >= 0:
        set_faces(face_mask)
    else:
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
    if special != null:
        special.visible = Face.SPECIAL & mask == Face.SPECIAL
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
    elif f == Face.SPECIAL && special != null:     
        special.set_surface_material(surface, mat)
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
    print("set_face: %d=%s" % [f, str(state)])
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

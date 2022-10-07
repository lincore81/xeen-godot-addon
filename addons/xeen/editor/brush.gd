extends Resource
class_name CellBrush

#enum FACE_VISIBILITY {ALWAYS, NEVER, AUTO}
const WALLS = [Cell.FACE.NORTH, Cell.FACE.EAST, Cell.FACE.SOUTH, Cell.FACE.WEST]


export var cell_template: PackedScene = preload("res://addons/xeen/map/cells/cell.tscn")
export var faces: Dictionary = {
    Cell.FACE.TOP:      null,
    Cell.FACE.BOTTOM:   null,
    Cell.FACE.NORTH:    null,
    Cell.FACE.SOUTH:    null,
    Cell.FACE.EAST:     null,
    Cell.FACE.WEST:     null,
    Cell.FACE.WALLS:    null,
}

signal face_changed(face, material)

func is_empty(face := -1):
    if faces.has(face):
        return faces[face] == null
    elif face == -1:
        print(faces)
        for key in faces.keys():
            if faces[key] != null:
                return false
    else:
        push_error("Invalid face id: %d" % face)


func put_cell(pos: Vector3, map: CellMapNode):
    var cell := map.put_cell(pos, cell_template)
    update_cell(cell, map)

func clear_cell(pos: Vector3, map: CellMapNode):
    map.clear_cell(pos)

# FIXME: Circumvents serialisation
func update_cell(cell: Cell, map: CellMapNode):
    for id in faces.keys():
        if id != Cell.FACE.WALLS:
            cell.set_face_data({"id": id, "material": faces[id]})

func restore_cell(cell: Cell, data: Array) -> void:
    cell.restore_face_data(data)


func set_material(face: int, material: Material):
    if face in faces:
        faces[face] = material
        emit_signal("face_changed", face, material)
        if face == Cell.FACE.WALLS:
            for f in WALLS: 
                faces[f] = material
                emit_signal("face_changed", f, material)
    else:
        push_error("Invalid face: %d" % face)

func get_material(face: int) -> Material:
    if face in faces:
        return faces[face]
    else:
        push_error("Invalid face: %d" % face)
        return null
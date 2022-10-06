extends Resource
class_name CellBrush

#enum FACE_VISIBILITY {ALWAYS, NEVER, AUTO}

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

func put_cell(pos: Vector3, map: CellMapNode):
    var cell := map.put_cell(pos, cell_template)
    update_cell(cell, map)

func clear_cell(pos: Vector3, map: CellMapNode):
    map.clear_cell(pos)

func update_cell(cell: Cell, map: CellMapNode):
    for id in faces.keys():
        cell.set_face_data({"id": id, "material": faces[id]})


func set_material(face: int, material: Material):
    if face in faces:
        faces[face] = material
    else:
        push_error("Invalid face: %d" % face)

func get_material(face: int) -> Material:
    if face in faces:
        return faces[face]
    else:
        push_error("Invalid face: %d" % face)
        return null
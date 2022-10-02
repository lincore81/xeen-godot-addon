tool
extends Reference
class_name XeenEditor

#signal selection_changed(from, to, is_empty)
#signal cursor_changed(new_pos, cursor_in_bounds)

#var has_selection := false setget , _get_has_selection 
#var _selection := AABB() 
var cursor := Vector3()
var map: CellMapNode = null setget _setmap, _getmap

var cursor_in_bounds := false
var interface: EditorInterface = null
var cell_template: PackedScene = preload("res://addons/xeen/map/cells/cell.tscn")

#func clear_selection():
#    _selection.position = Vector3.ZERO 
#    _selection.end = Vector3.ZERO 
#    emit_signal("selection_changed", _selection.position, _selection.end, false)
#   
#func set_selection_from(pos: Vector3):
#    _selection.position = pos.floor()
#    _selection.size = Vector3.ZERO
#
#func set_selection_to(pos: Vector3):
#    _selection.end = pos
#
#func _get_has_selection():
#    return _selection.size.x > 0 or _selection.size.z > 0

func try_put_cell(owner: Node, undo: UndoRedo) -> bool:
    if !cursor_in_bounds: return false
    var empty = map.cell_at(cursor) == null
    if empty: 
        undo.create_action("put cell")
        undo.add_do_method(map, "put_cell", cursor, cell_template)
        undo.add_undo_method(map, "clear_cell", cursor)
        undo.commit_action()
    return empty

func try_clear_cell(undo: UndoRedo) -> bool:
    if !cursor_in_bounds: return false
    var empty = map.cell_at(cursor)
    if empty != null:
        undo.create_action("clear cell")
        undo.add_do_method(map, "clear_cell", cursor)
        undo.add_undo_method(map, "clear_cell", cursor, cell_template)
        undo.commit_action()
    return empty != null

func update_cursor(cam: Camera, mouse_pos: Vector2) -> void:
    """
    Determine the position of the cell under the cursor, if any
    """
    var gt := map.global_transform
    var updated := false
    match XeenEditorUtil.pick_cell(gt, cam, mouse_pos):
        [false, _]: 
            updated = cursor_in_bounds
            cursor_in_bounds = false
        [true, var pos]: 
            pos = pos.floor()
            cursor_in_bounds = map.in_bounds(pos)
            cursor = pos
            #emit_signal("cursor_changed", cursor, cursor_in_bounds)
            map.gizmo.redraw()


func _setmap(v: CellMapNode):
    map = v
    #clear_selection()

func _getmap() -> CellMapNode:
    return map
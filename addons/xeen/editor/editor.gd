tool
extends Object
class_name XeenEditor

#signal selection_changed(from, to, is_empty)
#signal cursor_changed(new_pos, cursor_in_bounds)

var cursor := Vector3()
var map:  CellMapNode = null setget _setmap, _getmap
var panel: XeenEditorPanel = null
var brush := CellBrush.new()

var cursor_in_bounds := false
var undo: UndoRedo = null

func on_ready(undo: UndoRedo):
    self.undo = undo 
    set_default_brush_materials()

func try_put_cell() -> bool:
    if !cursor_in_bounds: return false
    var cell := map.cell_at(cursor) 
    if cell == null: 
        undo.create_action("put cell")
        undo.add_do_method(self, "_do_put_cell")
        undo.add_undo_method(self, "_undo_put_cell", cursor)
        undo.commit_action()
    else:
        # cell exists, therefore update it!
        var celldata := cell.serialise()
        undo.create_action("update cell")
        undo.add_do_method(self, "_do_update_cell", cell)
        undo.add_undo_method(self, "_undo_update_cell", cell, celldata)
        undo.commit_action()
    return cell == null

func _do_put_cell():
    var it := map.put_cell(cursor, brush.cell_template)
    brush.paint(it)
    map.serialise()

func _undo_put_cell(pos: Vector3):
    map.clear_cell(pos)
    map.serialise()

func _do_update_cell(cell: Cell):
    brush.paint(cell)
    map.serialise()

func _undo_update_cell(cell: Cell, celldata: Dictionary):
    cell.deserialise(celldata)
    map.serialise()

func try_clear_cell() -> bool:
    if !cursor_in_bounds: return false
    var empty = map.cell_at(cursor)
    if empty != null:
        var cell := map.cell_at(cursor)
        undo.create_action("clear cell")
        undo.add_do_method(self, "_do_clear_cell")
        undo.add_undo_method(self, "_undo_clear_cell", cursor, map, cell)
        undo.commit_action()
    return empty != null

func _do_clear_cell():
    map.clear_cell(cursor)
    map.serialise()

func _undo_clear_cell(pos: Vector3, _map: CellMapNode, _cell: Cell):
    _map.put_existing_cell(pos, _cell)
    map.serialise()

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
    if panel != null:
        panel.update_cursor_pos(cursor, cursor_in_bounds)
            

func set_default_brush_materials():
    var wall_mat = load("res://addons/xeen/assets/materials/urban/graywall.tres")
    var floor_mat = load("res://addons/xeen/assets/materials/wood/creakywood.tres")
    var ceil_mat = load("res://addons/xeen/assets/materials/bricks/bigbricks.tres")
    brush.set_material(Units.FACE.TOP, ceil_mat)
    brush.set_material(Units.FACE.BOTTOM, floor_mat)
    brush.set_material(Units.FACE.WALLS, wall_mat)

func set_brush_material(face: int, mat: Material):
    var old_mat := brush.get_material(face)
    undo.create_action("set_brush_material")
    undo.add_do_method(brush, "set_material", face, mat)
    undo.add_undo_method(brush, "set_material", face, old_mat)
    undo.commit_action()

func _setmap(v: CellMapNode):
    map = v
    #clear_selection()

func _getmap() -> CellMapNode:
    return map

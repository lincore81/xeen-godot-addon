tool
extends Object
class_name XeenEditor

#signal selection_changed(from, to, is_empty)
#signal cursor_changed(new_pos, cursor_in_bounds)
enum DRAW_MODE {PUT, CLEAR}

var cursor := Vector3()
var map:  CellMapNode = null setget _setmap, _getmap
var panel: XeenEditorPanel = null
var brush := CellBrush.new()

var cursor_in_bounds := false
var undo: UndoRedo = null

var is_drawing := false
var draw_mode: int = DRAW_MODE.PUT


func on_ready(undo: UndoRedo):
    self.undo = undo 
    set_default_brush_materials()


func try_put_cell() -> bool:
    if !cursor_in_bounds: return false
    var pos := cursor
    var cell := map.cell_at(pos) 
    if cell == null: 
        undo.create_action("put cell")
        undo.add_do_method(self, "_do_put_cell", pos)
        undo.add_undo_method(self, "_undo_put_cell", pos)
        undo.commit_action()
    elif not brush.matches_cell(cell):
        # cell exists, therefore update it!
        var celldata := cell.serialise()
        undo.create_action("update cell")
        undo.add_do_method(self, "_do_update_cell", cell)
        undo.add_undo_method(self, "_undo_update_cell", cell, celldata)
        undo.commit_action()
    return cell == null

func _do_put_cell(pos: Vector3):
    var it := map.put_cell(pos, brush.cell_template)
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
    var pos := cursor
    var empty = map.cell_at(pos)
    if empty != null:
        var cell := map.cell_at(pos)
        undo.create_action("clear cell")
        undo.add_do_method(self, "_do_clear_cell", pos)
        undo.add_undo_method(self, "_undo_clear_cell", pos, map, cell)
        undo.commit_action()
    return empty != null

func _do_clear_cell(pos: Vector3):
    map.clear_cell(pos)
    map.serialise()

func _undo_clear_cell(pos: Vector3, _map: CellMapNode, _cell: Cell):
    _map.put_existing_cell(pos, _cell)
    map.serialise()

func update_cursor(cam: Camera, mouse_pos: Vector2) -> bool:
    """
    Determine the position of the cell under the cursor, if any
    """
    var gt := map.global_transform
    var updated_and_in_bounds := false
    match XeenEditorUtil.pick_cell(gt, cam, mouse_pos):
        [false, _]: 
            cursor_in_bounds = false
        [true, var pos]: 
            pos = pos.floor()
            cursor_in_bounds = map.in_bounds(pos)
            updated_and_in_bounds = cursor_in_bounds \
                    and hash(pos) != hash(cursor)
            cursor = pos
            #emit_signal("cursor_changed", cursor, cursor_in_bounds)
            map.gizmo.redraw()
    if panel != null:
        panel.update_cursor_pos(cursor, cursor_in_bounds)
    return updated_and_in_bounds 
            
func start_drawing(draw_mode: int) -> bool:
    if not cursor_in_bounds or is_drawing:
        return false
    self.draw_mode = draw_mode
    is_drawing = true
    print("start drawing")
    draw()
    return true

func stop_drawing():
    is_drawing = false
    print("stop drawing")



func draw():
    if not is_drawing or not cursor_in_bounds:
        return
    match(draw_mode):
        DRAW_MODE.PUT:
            print("draw: put")
            try_put_cell()
        DRAW_MODE.CLEAR:
            print("draw: clear")
            try_clear_cell()
        _:
            push_error("draw mode not implemented: %d" % draw_mode)

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

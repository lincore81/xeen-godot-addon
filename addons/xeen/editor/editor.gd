tool
extends Object
class_name XeenEditor

#signal selection_changed(from, to, is_empty)
#signal cursor_changed(new_pos, cursor_in_bounds)

var map:  CellMapNode = null setget _setmap, _getmap
var panel: XeenEditorPanel
var brush := CellBrush.new()
var cursor := Vector3()
var cursor_in_bounds := false
var undo: UndoRedo = null
var is_drawing := false
var draw_mode: bool = true

var selection := AABB()
var draw_start := Vector3()

var current_tool: int = Units.TOOL.BRUSH

func clear_selection():
    selection = AABB()

func fill_selection():
    if selection.size != Vector3.ZERO and current_tool == Units.TOOL.BOX_SELECT:
        var f := funcref(self, "_fill_selected_cell")
        map.iterate_over_area(f, selection, false)

func _fill_selected_cell(_cell, pos: Vector3, _user) -> bool:
    try_put_cell(Maybe.new(pos, false), "fill selection", UndoRedo.MERGE_ALL)
    return true

func on_ready(undo: UndoRedo):
    self.undo = undo 
    set_default_brush_materials()

func is_tool_valid(t: int) -> bool:
    return t == Units.TOOL.BRUSH \
        or t == Units.TOOL.EYEDROPPER \
        or t == Units.TOOL.BOX_SELECT

func set_tool(t: int):
    if is_tool_valid(t):
        current_tool = t
    else:
        push_error("Tool not implemented: %d" % current_tool)
        return false

func try_put_cell(_pos: Maybe = null, action := "", merge_mode := UndoRedo.MERGE_DISABLE) -> bool:
    if !cursor_in_bounds: return false
    var pos := cursor if not _pos or _pos.is_none() else _pos.value()
    var cell := map.cell_at(pos) 
    if cell == null: 
        if action == "": action = "put cell"
        undo.create_action(action, merge_mode)
        undo.add_do_method(self, "_do_put_cell", pos)
        undo.add_undo_method(self, "_undo_put_cell", pos)
        undo.commit_action()
    elif not brush.matches_cell(cell):
        # cell exists, therefore update it!
        var celldata := cell.serialise()
        if action == "": action = "update cell"
        undo.create_action(action, merge_mode)
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

func try_clear_cell(action := "", merge_mode := UndoRedo.MERGE_DISABLE) -> bool:
    if !cursor_in_bounds: return false
    if action == "": action = "clear cell"
    var pos := cursor
    var empty = map.cell_at(pos)
    if empty != null:
        var cell := map.cell_at(pos)
        undo.create_action(action, merge_mode)
        undo.add_do_method(self, "_do_clear_cell", pos)
        undo.add_undo_method(self, "_undo_clear_cell", pos, map, cell)
        undo.commit_action()
    return empty != null

func try_eyedropper():
    if !cursor_in_bounds: return
    var cell := map.cell_at(cursor)
    if cell: 
        for f in cell.get_face_ids():
            var info := cell.get_face_info(f)
            brush.set_face_info(f, info)

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
            
func start_drawing(active := true) -> bool:
    if not cursor_in_bounds or is_drawing:
        return false
    if current_tool != Units.TOOL.BRUSH and current_tool !=\
            Units.TOOL.EYEDROPPER and current_tool != Units.TOOL.BOX_SELECT:
        push_error("Tool not implemented: %d" % current_tool)
        return false
    if current_tool == Units.TOOL.BOX_SELECT:
        selection.position = cursor
        selection.end = cursor
    is_drawing = true
    draw_start = cursor
    draw_mode = active
    draw()
    return true


func stop_drawing():
    is_drawing = false


func draw():
    if not is_drawing or not cursor_in_bounds:
        return
    match current_tool:
        Units.TOOL.BRUSH:
            if draw_mode:
                try_put_cell(null, "draw", UndoRedo.MERGE_ALL)
            else:
                try_clear_cell("erase", UndoRedo.MERGE_ALL)
        Units.TOOL.EYEDROPPER:
            try_eyedropper()
        Units.TOOL.BOX_SELECT:
            selection.position = draw_start
            selection.end = cursor
            selection = selection.abs()
            selection.size += Vector3.ONE
            
            print(selection)
        _:
            push_error("Tool not implemented: %d" % current_tool)

func set_default_brush_materials():
    for f in XeenConfig.DEFAULT_BRUSH_MATERIALS.keys():
        brush.set_material(f, load(XeenConfig.DEFAULT_BRUSH_MATERIALS[f]))

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

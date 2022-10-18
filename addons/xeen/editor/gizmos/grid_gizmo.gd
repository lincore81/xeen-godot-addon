tool
extends EditorSpatialGizmo
class_name XeenMapGridGizmo

const MAJOR_INTERVAL := 8

func redraw():
    clear()
    var global_origin := get_spatial_node().global_transform.origin
    var editor := get_plugin().editor as XeenEditor
    var node = get_spatial_node() as CellMapNode
    draw_grid(node.size, global_origin, editor)
    if editor.cursor_in_bounds:
        draw_cursor(global_origin, editor)
    if editor.current_tool == Units.TOOL.BOX_SELECT:
        draw_selection(editor.selection)


func draw_cursor(origin: Vector3, editor: XeenEditor):
    var p = Vector3(\
        int(editor.cursor.x) + origin.x,\
        int(editor.cursor.y) + origin.y + 0.01,\
        int(editor.cursor.z) + origin.z)
    var lines = XeenEditorUtil.create_wireframe_cube(p)
    var mat = get_plugin().get_material("main", self)
    add_lines(lines, mat, false, Color(1, 1, 1, 1))


func draw_selection(selection: AABB):
    #var volume := selection.size.x * selection.size.y * selection.size.z
    if selection.size != Vector3.ZERO:
        var lines := XeenEditorUtil.create_wireframe_cube(selection.position, selection.size)
        var mat = get_plugin().get_material("main", self)
        add_lines(lines, mat, false, Color(1, 1, 0, 1))
    else:
        return
    

func draw_grid(size: Vector3, origin: Vector3, editor: XeenEditor):
    var minor_lines := PoolVector3Array()
    var major_lines := PoolVector3Array()
    for x in range(size.x + 1):
        var v0 = Vector3(
            origin.x + x, 
            origin.y, 
            origin.z)
        var v1 = Vector3(
            origin.x + x, 
            origin.y, 
            origin.z + size.z)
        if x % MAJOR_INTERVAL != 0:
            minor_lines.push_back(v0)
            minor_lines.push_back(v1)
        else:
            major_lines.push_back(v0)
            major_lines.push_back(v1)

    for z in range(size.z + 1):
        var v0 = Vector3(
            origin.x,
            origin.y, 
            origin.z + z)
        var v1 = Vector3(
            origin.x + size.x,
            origin.y, 
            origin.z + z)
        if z % MAJOR_INTERVAL != 0:
            minor_lines.push_back(v0)
            minor_lines.push_back(v1)
        else:
            major_lines.push_back(v0)
            major_lines.push_back(v1)
        
    var mat = get_plugin().get_material("main")
    #FIXME: why doesn't this work?
    add_lines(minor_lines, mat, true, Color(0.5, 0.5, 0.5))
    add_lines(major_lines, mat, true, Color(1, 1, 0.5))
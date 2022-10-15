tool
extends EditorPlugin
class_name XeenEditorPlugin

var panel = preload("res://addons/xeen/gui/editor_panel/editor_panel.tscn").instance()
var cellmapnode_script: Script = preload("res://addons/xeen/map/cell_map_node.gd")


var editor: XeenEditor = null
var editing = null
var gizmo_plugin: XeenMapGridGizmoPlugin = null
var map_inspector: XeenCellMapInspectorPlugin
var lmb_down := false
var is_dragging := false

func _enter_tree():
    editor = XeenEditor.new()
    editor.panel = panel
    panel.connect("ready", self, "_on_panel_ready")
    gizmo_plugin = XeenMapGridGizmoPlugin.new(editor)
    map_inspector = XeenCellMapInspectorPlugin.new()

    add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, panel)
    add_custom_type("CellMap", "Spatial", cellmapnode_script, CellMapNode.ICON)
    add_spatial_gizmo_plugin(gizmo_plugin)
    add_inspector_plugin(map_inspector)

func _ready():
    editor.on_ready(get_undo_redo())
    panel.connect("brush_material_selected", editor, "set_brush_material")

func _on_panel_ready():
    panel.setup(get_editor_interface().get_resource_previewer(), editor.brush)


func _exit_tree():
    remove_control_from_docks(panel)
    remove_custom_type("CellMap")
    remove_spatial_gizmo_plugin(gizmo_plugin)
    remove_inspector_plugin(map_inspector)

func forward_spatial_gui_input(cam: Camera, ev: InputEvent) -> bool:
    if !editing: return false

    if ev is InputEventMouseMotion:
        if editor.update_cursor(cam, ev.position):
            editor.draw()
    elif ev is InputEventMouseButton:
        return _handle_click(cam, ev as InputEventMouseButton)
    elif ev is InputEventKey:
        return _handle_keyboard_input(ev as InputEventKey)
    return false

func _handle_click(_cam: Camera, ev: InputEventMouseButton) -> bool:
    var is_lmb := ev.button_index == BUTTON_LEFT
    if not is_lmb: 
        return false
    if not ev.pressed:
        editor.stop_drawing()
    elif ev.pressed:
        var mode = XeenEditor.DRAW_MODE.CLEAR if ev.control else XeenEditor.DRAW_MODE.PUT
        editor.start_drawing(mode)
    return true

func _handle_keyboard_input(ev: InputEventKey) -> bool:
    return false 


func unedit():
    editor.map = null
    editing = null

func edit(obj: Object):
    if obj is CellMapNode:
        editing = obj as CellMapNode
        assert(editing, "The given object not a CellMapNode.")
        editor.map = editing
        if not editing.is_connected("tree_exited", self, "unedit"):
            editing.connect("tree_exited", self, "unedit")
        print("Editing %s" % editing.name)

func handles(obj: Object) -> bool:
    return obj is CellMapNode or obj is Cell
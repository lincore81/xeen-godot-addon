tool
extends EditorPlugin
class_name XeenEditorPlugin

const GridGizmoPlugin = preload("res://addons/xeen/editor/gizmos/grid_gizmo_plugin.gd")
var panel = preload("res://addons/xeen/gui/editor_panel.tscn").instance()
var cellmapnode_script: Script = preload("res://addons/xeen/map/cell_map_node.gd")

var editor: XeenEditor = null
var editing: CellMapNode = null
var gizmo_plugin: GridGizmoPlugin = null
var lmb_down := false
var is_dragging := false

func _enter_tree():
    panel.previewer = get_editor_interface().get_resource_previewer()
    editor = XeenEditor.new()
    editor.panel = panel
    gizmo_plugin = GridGizmoPlugin.new(editor)

    add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, panel)
    add_custom_type("CellMap", "Spatial", cellmapnode_script, CellMapNode.ICON)
    add_spatial_gizmo_plugin(gizmo_plugin)

func _exit_tree():
    remove_control_from_docks(panel)
    remove_custom_type("CellMap")
    remove_spatial_gizmo_plugin(gizmo_plugin)

func forward_spatial_gui_input(cam: Camera, ev: InputEvent) -> bool:
    if !editing: return false
    if ev is InputEventMouseMotion:
        editor.update_cursor(cam, ev.position)
    elif ev is InputEventMouseButton:
        return _handle_click(cam, ev as InputEventMouseButton)
    return false

func _handle_click(_cam: Camera, ev: InputEventMouseButton):
    var is_lmb := ev.button_index == BUTTON_LEFT
    var is_released := not ev.pressed
    if is_lmb:
        lmb_down = not is_released
        if is_released and ev.control:
            editor.try_clear_cell(get_undo_redo())
        elif is_released:
            var scene_root = get_editor_interface().get_edited_scene_root()
            editor.try_put_cell(scene_root, get_undo_redo())

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
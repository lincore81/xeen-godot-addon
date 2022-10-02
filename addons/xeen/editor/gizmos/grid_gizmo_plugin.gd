extends EditorSpatialGizmoPlugin
class_name XeenMapGridGizmoPlugin

var editor: XeenEditor = null

func _init(ed: XeenEditor):
    editor = ed
    assert(editor != null)
    create_material("main", Color(0.7, 0.7, 0.7))

func get_name():
    "XeenMapGridGizmoPlugin"

func has_gizmo(spatial):
    return spatial is CellMapNode

func create_gizmo(spatial):
    if not has_gizmo(spatial):
        return null
    else:
        return XeenMapGridGizmo.new() 
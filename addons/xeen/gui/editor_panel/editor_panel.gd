tool
extends PanelContainer
class_name XeenEditorPanel

"""
Handle UI stuff and relay actions upstairs
"""

onready var cursor_label := get_node("%Info") as Label

# shows all face materials currently on the cell brush
onready var brush_view := get_node("%BrushView") as BrushView
onready var material_view := get_node("%MaterialView") as MaterialView

onready var tools := {
    Units.TOOL.BRUSH: $VBoxContainer/TabContainer/Geometry/Toolbar/Brush as Button,
    Units.TOOL.BOX_SELECT: $VBoxContainer/TabContainer/Geometry/Toolbar/Select as Button,
    Units.TOOL.EYEDROPPER: $VBoxContainer/TabContainer/Geometry/Toolbar/Eyedropper as Button,
}

var ready := false

signal brush_material_selected(face, material)
signal tool_selected(tool)

func _ready():
    ready = true
    brush_view.connect("face_selected", self, "_on_brush_face_selected")
    for t in tools.keys():
        tools[t].connect("pressed", self, "_on_tool_selected", [t])

func setup(resource_preview: EditorResourcePreview, brush: CellBrush):
    if ready: 
        material_view.setup(resource_preview)
        brush_view.setup(resource_preview)
        brush_view.set_brush(brush) 
        brush.connect("face_changed", self, "_on_brush_changed")
    else:
        push_error("Panel not ready, call again later.")

func update_cursor_pos(pos: Vector3, in_bounds: bool):
    if in_bounds:
        # TAG: 2D
        cursor_label.text = "x: %d, z: %d" % [int(pos.x), int(pos.z)]
    else:
        cursor_label.text = ""

func _on_brush_changed(face: int, info: FaceInfo):
    var preview := material_view.get_preview(info.material.resource_path)
    brush_view.set_face(face, info, preview)

func _on_brush_face_selected(face: int):
    var path := material_view.get_selection()
    if path != null:
        var mat = ResourceLoader.load(path, "SpatialMaterial")
        emit_signal("brush_material_selected", face, mat)

func _on_tool_selected(t: int):  
    print("Tool selected: %d" % t)
    emit_signal("tool_selected", t)

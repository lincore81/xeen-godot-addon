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

var ready := false

signal brush_material_selected(face, material)

func _ready():
    ready = true
    brush_view.connect("face_selected", self, "_on_brush_face_selected")

func setup(resource_preview: EditorResourcePreview, brush: CellBrush):
    if ready: 
        print("has setup method?: ", material_view.has_method("setup"))
        material_view.setup(resource_preview)
        brush_view.set_brush(brush) 
    else:
        push_error("Panel not ready, call again later.")

func update_cursor_pos(pos: Vector3, in_bounds: bool):
    if in_bounds:
        # TAG: 2D
        cursor_label.text = "x: %d, z: %d" % [int(pos.x), int(pos.z)]
    else:
        cursor_label.text = ""

func _on_brush_face_selected(face: int):
    var path := material_view.get_selection()
    if path != null:
        var mat = ResourceLoader.load(path, "SpatialMaterial")
        emit_signal("brush_material_selected", face, mat)
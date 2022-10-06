tool
extends Control
class_name XeenEditorPanel


onready var cursor_label := $Margin/VBox/Info/CursorPosition as Label
onready var asset_browser := $Margin/VBox/Materials/Browser as AssetBrowser
onready var btn_refresh := $Margin/VBox/Materials/HBox/Refresh as Button

# shows all face materials currently on the cell brush
onready var brush_view: BrushView = $Margin/VBox/Brush as BrushView

signal brush_material_selected(face, material)

func setup(resource_preview: EditorResourcePreview, brush: CellBrush):
    asset_browser.set_resource_preview(resource_preview)
    asset_browser.update()
    brush_view.set_brush(brush) 
    brush_view.connect("face_selected", self, "_on_brush_face_selected")
    btn_refresh.connect("pressed", asset_browser, "update")

func update_cursor_pos(pos: Vector3, in_bounds: bool):
    if in_bounds:
        # TAG: 2D
        cursor_label.text = "x: %d, z: %d" % [int(pos.x), int(pos.z)]
    else:
        cursor_label.text = ""

func _on_brush_face_selected(face: int):
    if asset_browser.selected_resource_path != null:
        var mat = ResourceLoader.load(asset_browser.selected_resource_path,
                asset_browser.resource_class_name)
        emit_signal("brush_material_selected", face, mat)
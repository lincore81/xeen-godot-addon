tool
extends PanelContainer
class_name XeenEditorPanel

onready var cursor_label := get_node("%Info") as Label
onready var brush_panel := get_node("%BrushPanel") as BrushPanel
onready var material_browser := get_node("%MaterialBrowser") as MaterialBrowser

onready var tools := {
	Units.TOOL.BRUSH: $VBoxContainer/TabContainer/Geometry/Toolbar/Brush as Button,
	Units.TOOL.BOX_SELECT: $VBoxContainer/TabContainer/Geometry/Toolbar/Select as Button,
	Units.TOOL.EYEDROPPER: $VBoxContainer/TabContainer/Geometry/Toolbar/Eyedropper as Button,
}

const BRUSH_LAYOUT := [
	{face=Units.FACE.TOP, 	label="top"},
	{face=Units.FACE.NORTH, label="north"},
	{face=-1},
	{face=Units.FACE.WEST, 	label="west"},
	{face=Units.FACE.WALLS, label="walls"},
	{face=Units.FACE.EAST, 	label="east"},
	{face=Units.FACE.BOTTOM,label="bottom"},
	{face=Units.FACE.SOUTH, label="south"},
]

var ready := false

signal brush_material_selected(face, material)
signal tool_selected(tool)

func _ready():
	ready = true
	brush_panel.connect("face_selected", self, "_on_brush_face_selected")
	for t in tools.keys():
		var btn := tools[t] as Button
		var shortcut := XeenKeybinds.TOOL_SELECT.get(t, null) as Dictionary
		btn.connect("pressed", self, "_on_tool_selected", [t])
		if shortcut:
			XeenKeybinds.make_shortcut(shortcut, btn)

func setup(resource_preview: EditorResourcePreview, filesystem: EditorFileSystem, brush: CellBrush):
	if ready: 
		material_browser.setup(resource_preview, filesystem)
		brush_panel.setup(resource_preview, BRUSH_LAYOUT)
		brush_panel.set_brush(brush) 
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
	var preview := material_browser.get_preview(info.material.resource_path)
	brush_panel.set_face(face, info, preview)

func _on_brush_face_selected(face: int):
	var path := material_browser.get_selection()
	if path != null:
		var mat = ResourceLoader.load(path, "SpatialMaterial")
		emit_signal("brush_material_selected", face, mat)

func _on_tool_selected(t: int):  
	print("Tool selected: %d" % t)
	emit_signal("tool_selected", t)

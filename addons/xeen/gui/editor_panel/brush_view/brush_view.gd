tool
extends GridContainer
class_name BrushView

#export var placeholder: Texture = preload("res://addons/xeen/assets/textures/placeholder.png")
export var empty: Texture = preload("res://addons/xeen/assets/textures/empty.png")
export var error: Texture = preload("res://addons/xeen/assets/textures/placeholder.png")


var brush: CellBrush
var ready := false
var previewer: EditorResourcePreview

signal face_selected(face)

onready var buttons := {
    Units.FACE.NORTH: $North_8/Button,
    Units.FACE.EAST:  $East_6/Button,
    Units.FACE.SOUTH: $South_2/Button,
    Units.FACE.WEST:  $West_4/Button,
    Units.FACE.TOP: $Ceiling_7/Button,
    Units.FACE.BOTTOM: $Floor_1/Button,
    Units.FACE.WALLS: $Walls_5/Button,
}

func _ready():
    ready = true
    if brush: 
        _apply_brush()
    for face in buttons.keys():
        buttons[face].connect("pressed", self, "_on_btn_pressed", [face])
    _setup_button_shortcuts()

func setup(previewer: EditorResourcePreview):
    print("setup")
    self.previewer = previewer

func _on_btn_pressed(face: int):
    emit_signal("face_selected", face)

func set_brush(brush: CellBrush):
    assert(brush != null, "Brush must not be null.")
    self.brush = brush
    if ready:
        _apply_brush()


func _apply_brush():
    assert(brush, "No cell brush!")
    for face in buttons.keys():
        var info := brush.get_face_info(face)
        set_face(face, info)


func set_face(face: int, info: FaceInfo, preview: Texture = null):
    assert(buttons.has(face), "Uh oh...")
    if not info.material: 
        buttons[face].icon = empty
    elif preview:
        buttons[face].icon = preview 
    elif previewer:
        previewer.queue_resource_preview(info.material.resource_path, self, "_on_preview_generated", face)
    else:
        push_warning("preview and previewer are null, cannot create material preview")

func _on_preview_generated(_path, texture: Texture, _thumb, face: int):
    buttons[face].icon = texture if texture else error

func _setup_button_shortcuts():
    for face in XeenKeybinds.set_brush_face.keys():
        var def = XeenKeybinds.set_brush_face[face]
        XeenKeybinds.make_shortcut(def, buttons[face])
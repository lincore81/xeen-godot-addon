tool
extends GridContainer
class_name BrushView

#export var placeholder: Texture = preload("res://addons/xeen/assets/textures/placeholder.png")
export var empty: Texture = preload("res://addons/xeen/assets/textures/empty.png")


var brush: CellBrush
var ready := false

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
    if brush: _apply_brush()
    for face in buttons.keys():
        buttons[face].connect("pressed", self, "_on_btn_pressed", [face])
    _setup_button_shortcuts()


func _on_btn_pressed(face: int):
    emit_signal("face_selected", face)


func set_brush(brush: CellBrush):
    assert(brush != null, "Brush must not be null.")
    if self.brush != null and self.brush != brush:
        self.brush.disconnect("face_changed", self, "on_brush_changed")

    brush.connect("face_changed", self, "_on_brush_changed")
    self.brush = brush
    if ready:
        _apply_brush()


func _apply_brush():
    #print("applying brush")
    assert(brush, "No cell brush!")
    if buttons:
        for face in buttons.keys():
            var tex := _get_material_texture(brush.get_material(face))
            # TODO: Shader magic!
            buttons[face].icon = tex


func _get_material_texture(material: SpatialMaterial) -> Texture:
    return material.albedo_texture if material else empty

func _on_brush_changed(face: int, info: FaceInfo):
    assert(buttons.has(face), "Uh oh...")
    var tex := _get_material_texture(info.material)
    buttons[face].icon = tex

func _setup_button_shortcuts():
    for face in XeenKeybinds.set_brush_face.keys():
        var def = XeenKeybinds.set_brush_face[face]
        XeenKeybinds.make_shortcut(def, buttons[face])
tool
extends GridContainer
class_name BrushView

export var placeholder: Texture = preload("res://addons/xeen/assets/textures/placeholder.png")

var brush: CellBrush

signal face_selected(face)

onready var buttons := {
    Cell.FACE.NORTH: $North_8/Button,
    Cell.FACE.EAST:  $East_6/Button,
    Cell.FACE.SOUTH: $South_2/Button,
    Cell.FACE.WEST:  $West_4/Button,
    Cell.FACE.TOP: $Ceiling_7/Button,
    Cell.FACE.BOTTOM: $Floor_1/Button,
    Cell.FACE.WALLS: $Walls_5/Button,
}

func _ready():
    if brush: apply_brush()
    for face in buttons.keys():
        buttons[face].connect("pressed", self, "_on_btn_pressed", [face])


func _on_btn_pressed(face: int):
    emit_signal("face_selected", face)


func set_brush(brush: CellBrush):
    assert(brush != null, "Brush must not be null.")
    brush.connect("face_changed", self, "_on_brush_change")
    self.brush = brush
    apply_brush()


func apply_brush():
    print("applying brush")
    assert(brush, "No cell brush!")
    if buttons:
        print("doing buttons")
        for face in buttons.keys():
            var tex := _get_texture(brush.get_material(face))
            # TODO: Shader magic!
            buttons[face].icon = tex


func _get_texture(material: SpatialMaterial) -> Texture:
    return material.albedo_texture if material else placeholder


func _on_brush_change(face: int, mat: Material):
    print("on brush changed, face=", face)
    assert(buttons.has(face), "Uh oh...")
    var tex := _get_texture(brush.get_material(face))
    buttons[face].icon = tex
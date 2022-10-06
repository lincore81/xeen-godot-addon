tool
extends Control
class_name XeenEditorPanel

onready var cursor_label := $Margin/VBox/Info/CursorPosition as Label
onready var ceiling_btn := $Margin/VBox/Brush/C7/Button
onready var ceiling_texture := $Margin/VBox/Brush/C7/Button/TextureRect as TextureRect
onready var vbox := $Margin/VBox

var mat = preload("res://addons/xeen/assets/materials/ceiling.tres")
var previewer: EditorResourcePreview = null

#func _ready():
    #ceiling_btn.connect("pressed", self, "on_click")
    #var picker := EditorResourcePicker.new()
    #picker.base_type = "Texture"
    #vbox.add_child(picker)
    

func on_click():
    ceiling_texture.texture = mat.albedo_texture
    #previewer.queue_edited_resource_preview(mat, self, "update_preview", [])

func update_cursor_pos(pos: Vector3, in_bounds: bool):
    if in_bounds:
        cursor_label.text = "x: %d, z: %d" % [int(pos.x), int(pos.z)]
    else:
        cursor_label.text = ""

func update_preview(_p, preview: Texture, _t, _u):
    ceiling_texture.texture = preview

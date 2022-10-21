tool
extends PanelContainer
class_name FacePanel

onready var btn_material := get_node("%Button") as Button
onready var label := get_node("%Label") as Label
onready var btn_visible := get_node("%Visible") as Button
onready var btn_passable := get_node("%Passable") as Button

var _is_ready := false

signal material_pressed

func _ready():
    btn_material.connect("pressed", self, "emit_signal", ["material_pressed"])
    _is_ready = true

func setup(label: String, preview: Texture, shortcut: Dictionary):
    if _is_ready:
        set_label(label)
        set_material_preview(preview)
        set_shortcut(shortcut)
    else:
        connect("ready", self, "setup", [label, preview, shortcut])

func set_label(text: String):
    label.text = text

func set_shortcut(def: Dictionary):
    XeenKeybinds.make_shortcut(def, btn_material)

func set_material_preview(preview: Texture):
    btn_material.icon = preview

# TODO: handle flags
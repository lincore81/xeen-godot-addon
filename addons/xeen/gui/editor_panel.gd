tool
extends Control
class_name XeenEditorPanel

onready var cursor_label := $Margin/VBox/Info/CursorPosition as Label

func update_cursor_pos(pos: Vector3, in_bounds: bool):
    if in_bounds:
        cursor_label.text = "x: %d, z: %d" % [int(pos.x), int(pos.z)]
    else:
        cursor_label.text = ""

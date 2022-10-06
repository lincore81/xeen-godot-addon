tool
extends TextureRect

class_name MaterialThumbnail


func _init(tex: Texture, size: Vector2 = Vector2(64, 64)):
    texture = tex
    expand = true
    rect_min_size = size

func set_texture(tex: Texture):
    texture = tex
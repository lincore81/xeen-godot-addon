extends Button
class_name SortButton

var ascending_texture := preload("res://addons/xeen/assets/icons/sort-alphabetical-ascending.png")
var descending_texture := preload("res://addons/xeen/assets/icons/sort-alphabetical-descending.png")

var sort_ascending := true

signal sort_order_changed(new_order)

func _ready():
    if not is_connected("pressed", self, "_on_pressed"):
        connect("pressed", self, "_on_pressed")
    if not sort_ascending:
        sort_ascending = true
        _on_pressed()        

func _on_pressed():
    print("pressed!")
    if sort_ascending:
        icon = descending_texture
    else:
        icon = ascending_texture
    sort_ascending = not sort_ascending
    emit_signal("sort_order_changed", AssetBrowser.SORT.ASCENDING 
            if sort_ascending else AssetBrowser.SORT.DESCENDING)

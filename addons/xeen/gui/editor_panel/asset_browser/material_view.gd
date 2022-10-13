tool
extends VBoxContainer
class_name MaterialView

"""
    Encapsulates the AssetBrowser and related controls.
"""

onready var asset_browser := get_node("%Browser") as AssetBrowser
onready var filter_input := $Menu/Filter 
onready var btn_refresh := $Menu/Refresh 
onready var btn_sort := $Menu/Sort 
onready var btn_folder := $Menu/ChooseFolder
onready var label_path := $Path
onready var file_dialog := $FileDialog

signal material_chosen(path)

var _is_ready := false

func _ready():
    btn_sort.connect("sort_order_changed", self, "_on_sort_order_changed")
    btn_refresh.connect("pressed", self, "_refresh_materials")
    filter_input.connect("text_changed", self, "_set_filter")
    btn_folder.connect("pressed", self, "_choose_folder")
    file_dialog.connect("confirmed", self, "_folder_selected")
    asset_browser.connect("selection_changed", self, "_on_material_chosen")
    asset_browser.connect("directory_changed", self, "_on_dir_changed")
    _is_ready = true
    label_path.text = asset_browser.resource_path


func get_selection() -> String:
    return asset_browser.selected_resource_path

func setup(resource_preview: EditorResourcePreview):
    if _is_ready:
        asset_browser.setup(resource_preview)
        asset_browser.update_browser()
    else:
        push_error("view is not ready yet, call again later.")

func _on_sort_order_changed(order: int):
    asset_browser.change_sort_order(order)

func _refresh_materials():
    asset_browser.update()

func _set_filter(s: String):
    asset_browser.set_filter(s)

func _choose_folder():
    file_dialog.current_dir = asset_browser.resource_path
    file_dialog.popup_centered_minsize(Vector2(600, 400))

func _folder_selected():
    asset_browser.change_directory(file_dialog.current_dir)

func _on_material_chosen(path):
    emit_signal("material_chosen", path)

func _on_dir_changed(dir):
    label_path.text = dir
tool
extends VBoxContainer
class_name MaterialBrowser

onready var asset_browser := get_node("%Browser") as AssetBrowser
onready var filter_input := $Menu/Filter 
onready var btn_refresh := $Menu/Refresh 
onready var btn_sort := $Menu/Sort 
onready var btn_folder := $Menu/ChooseFolder
onready var label_path := $Path
onready var file_dialog := $FileDialog

var _is_ready := false

signal material_chosen(path, preview)


func _ready():
    btn_sort.connect("sort_order_changed", self, "_on_sort_order_changed")
    btn_refresh.connect("pressed", self, "_refresh_materials")
    filter_input.connect("text_changed", self, "_set_filter")
    btn_folder.connect("pressed", self, "_choose_folder")
    file_dialog.connect("confirmed", self, "_folder_selected")
    asset_browser.connect("selection_changed", self, "_on_material_chosen")
    asset_browser.connect("directory_changed", self, "_on_dir_changed")


func get_selection() -> String:
    return asset_browser.selected_resource_path

func get_preview(path: String) -> Texture:
    return asset_browser.previews.get(path)

func setup(resource_preview: EditorResourcePreview, filesystem: EditorFileSystem):
    asset_browser.setup(resource_preview, filesystem)
    # FIXME: find a EditorFileSystem signal to use instead of a timer.
    var timer = Timer.new()
    timer.connect("timeout",self,"_on_timer_timeout") 
    add_child(timer)
    timer.one_shot = true
    timer.start(0.5)

func _on_timer_timeout():
    asset_browser.change_directory(XeenConfig.DEFAULT_MATERIAL_DIR)


func _on_sort_order_changed(order: int):
    asset_browser.change_sort_order(order)

func _refresh_materials():
    asset_browser.update()

func _set_filter(s: String):
    asset_browser.set_filter(s)

func _choose_folder():
    file_dialog.current_dir = asset_browser.resource_path
    file_dialog.popup_centered(Vector2(1024, 600))

func _folder_selected():
    print("New path=%s" % file_dialog.current_dir)
    asset_browser.change_directory(file_dialog.current_dir)

func _on_material_chosen(path, preview):
    emit_signal("material_chosen", path)

func _on_dir_changed(dir):
    label_path.hint_tooltip = dir
    if len(dir) > 40:
        dir = "..." + dir.substr(len(dir)-37)
    label_path.text = dir
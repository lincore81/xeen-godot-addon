tool
extends HFlowContainer
class_name AssetBrowser

enum SORT {ASCENDING, DESCENDING}

export var resource_path := "res://"

# If true, also look in all sub directories of `resource_path`.
export var recursive := true

export var resource_class_name := "SpatialMaterial"

# The texture to use when a preview cannot be generated.
export var placeholder: Texture = preload("res://addons/xeen/assets/textures/base/placeholder.png")

# The size of the grid elements. Can be smaller if the grid is not wide enough.
export var preferred_item_size := Vector2(96, 96)


export(SORT) var _sort_order := SORT.ASCENDING 

var actual_item_size := preferred_item_size
var selected_resource_path := ""
var filter := ""
var filter_segments := []

# generated preview textures
var previews: Dictionary

# buttons currently in use. By keeping a reference here we can reuse them when
# repopulating the grid
var controls: Dictionary

# must be provided by an EditorPlugin instance.
var resource_preview: EditorResourcePreview
var filesystem: EditorFileSystem

# A sorted list of resource paths that determines the order resources appear in the grid.
var paths: Array

# all children are added to this group so only one can be selected at a time
var item_group := ButtonGroup.new()

# previews are possibly generated asynchronously so we need to check if they are all done.
var previews_pending := 0

# true if not all previews are ready yet.
var generating_previews := false

signal selection_changed(resource_path, preview)
signal directory_changed(directory)



func _process(_d):
    if generating_previews and previews_pending == 0:
        generating_previews = false
        _clear_grid()
        _populate_grid()


func set_filter(pattern: String):
    var has_changed := pattern != filter 
    if has_changed:
        filter = pattern
        filter_segments = filter.split("|", false)
        if not generating_previews:
            update_browser()

# must be called before calling update
func setup(preview: EditorResourcePreview, filesystem: EditorFileSystem):
    resource_preview = preview
    resource_preview.connect("preview_invalidated", self, "_on_preview_invalidated")
    self.filesystem = filesystem

func change_directory(dir: String):
    var directory = Directory.new()
    if directory.dir_exists(dir):
        resource_path = dir
        emit_signal("directory_changed", dir)
        update_browser()
    else:
        push_error("The given directory does not exist: %s" % dir)

func change_sort_order(order: int):
    if order == SORT.ASCENDING or order == SORT.DESCENDING:
        _sort_order = order
        _regen()
    else:
        push_error("Sort order not implemented: %d" % order)



# update without generating previews
func _regen():
    if generating_previews: return
    _clear_grid()
    _populate_grid()

func update_browser():
    if resource_preview == null:
        push_error("Need EditorResourcePreview instance in order to update the resource list")
        return
    if not preferred_item_size or preferred_item_size.x == 0 or preferred_item_size.y == 0:
        push_warning("Preferred item size is null or at least one dimension is zero. Using defaults")
        preferred_item_size = Vector2(64, 64)
    previews_pending = 0
    generating_previews = true
    _generate_previews()
    
    # the rest is done in _process once all previews are ready.


# Step 1: Generate previews

func _generate_previews():
    paths = []
    resource_path = "res://" if resource_path == "" else resource_path
    var f := funcref(self, "_try_get_preview")
    _iter_over_files(resource_path, f, filesystem, resource_class_name)


func _try_get_preview(path: String) -> Texture:
    paths.append(path)
    #print("try_get_preview: %s" % path)
    if previews.has(path):
        # If the preview is out of date, we'll update it later in a signal handler
        resource_preview.check_for_invalidation(path)    #print("...preview already exists")
        return previews[path] as Texture
    else:
        previews_pending += 1
        resource_preview.queue_resource_preview(path, self, "_on_preview_generated", [])
        #print("generating preview, now pending: %directory" % previews_pending)
        return placeholder


func _on_preview_invalidated(path: String):
    if previews.has(path):
        #print("preview invalidated: %s" % path)
        previews_pending += 1
        resource_preview.queue_resource_preview(path, self, "_on_preview_generated", [])


func _on_preview_generated(path: String, texture: Texture, _thumb, _user):
    previews_pending -= 1
    #print("preview generated, still pending: %directory" % previews_pending)
    if texture == null:
        push_error("Unable to generate preview texture for resource at '%s'" % path)
    else:
        previews[path] = texture


# Step 2: Once all previews have been generated, update the grid:

# **Must be called after `generate_previews`!**
func _clear_grid():
    for child in get_children():
        remove_child(child)
        var should_free := true
        # TODO: What's with this key business? BUG?
        var key := ""
        for path in controls.keys():
            if controls[path] == child:
                should_free = false
                key = path
                break
        if should_free:
            controls.erase(key)
            child.queue_free()

        
# **Must be called after `_generate_previews` and `_clear_grid`!**
func _populate_grid():
    paths.sort_custom(self, "_compare_paths")
    for p in paths:
        assert(previews.has(p), "Congratulations, you found a bug.")
        _add_button(p, previews[p])

# TODO: generalise so that users can provide a different function
func _add_button(path: String, texture: Texture) -> void:
    var btn: Button
    if controls.has(path):
        btn = controls[path] 
        btn.rect_min_size = actual_item_size
    else:
        btn = Button.new()
        btn.group = item_group
        btn.toggle_mode = true
        btn.icon = texture
        btn.rect_min_size = actual_item_size
        btn.hint_tooltip = path
        btn.connect("pressed", self, "_on_button_pressed", [btn, path])
        controls[path] = btn
    # not setting the owner because children are created dynamically and
    # shouldn't be saved with the scene.
    var ignore := false
    for f in filter_segments:
        if f in path:
            ignore = true
            break
    if ignore or filter == "":
        #print("Matches filter: %s" % path)
        add_child(btn)


# TODO: Move to helper class
# FIXME: Handle case where b starts with '/'
static func _join_paths(a: String, b: String) -> String:
    if a[-1] == '/':
        return a + b
    else:
        return a + '/' + b

# TODO: Consider moving to helper class
# Expected callback signature: (path: String) -> void
static func _iter_over_files(path: String, f: FuncRef, filesystem: EditorFileSystem, resource_type: String=""):
    var todo := [path]
    # Iterate over the given path (as directory) and any sub-directories that
    # may be found.
    while not todo.empty():
        var curr_dir = todo.pop_back()
        var directory = Directory.new()
        if directory.open(curr_dir) == OK:
            directory.list_dir_begin(true)
            var item = directory.get_next()
            # iterate over items in current directory:
            while item != "":
                var item_path = _join_paths(curr_dir, item)
                if directory.current_is_dir():
                    if not _contains_gdignore(item_path) and item != ".git":
                        todo.push_back(item_path)
                else:
                    # TODO: move to callback
                    var type = filesystem.get_file_type(item_path)
                    var correct_type = resource_type == type or resource_type == ""
                    #print("iterating item_path=%s, type=%s" % [item_path, type])
                    if correct_type:
                        f.call_func(item_path)
                item = directory.get_next()
            directory.list_dir_end()
        else:
            push_error("Unable to access directory '%s'" % curr_dir)

static func _contains_gdignore(full_path) -> bool:
    var dir := Directory.new()
    dir.open(full_path)
    return dir.file_exists(_join_paths(full_path, ".gdignore"))

func _on_button_pressed(button: TextureButton, path: String):
    selected_resource_path = path
    emit_signal("selection_changed", path, previews.get(path))

func _compare_paths(a: String, b: String) -> bool:
    match _sort_order:
        SORT.ASCENDING:
            return a <= b
        SORT.DESCENDING:
            return b < a
        _:
            push_error("sort order not implemented: %directory" % _sort_order)
            return a <= b

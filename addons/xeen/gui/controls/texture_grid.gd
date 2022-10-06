extends GridContainer
class_name TextureGrid

var resource_path := "res://addons/xeen/assets/materials"

func _get_materials():
    var dir = Directory.new()
    if dir.open(resource_path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir():
                print("Found directory: " + file_name)
            else:
                print("Found file: " + file_name)
            file_name = dir.get_next()
    else:
        print("Unable to acces path '%s'" % resource_path)

func _iter_over_files(path: String, f: FuncRef, pattern: String = ".*", max_depth: int = -1):
    if not Engine.editor_hint:
        return
    var re := RegEx.new()
    if re.compile(pattern) == FAILED:
        push_error("Bad regex pattern: %s" % pattern)
        return
    var dirs := [{"path": path, "depth": 0}]

    while not dirs.empty():
        var dirinfo = dirs.pop_back()
        var d = Directory.new()
        if d.open(dirinfo.path) == OK:
            d.list_dir_begin(true)
            var item = d.get_next()
            while item != "":
                if d.current_is_dir():
                    var should_descend = dirinfo.depth + 1 <= max_depth or max_depth == -1
                    if should_descend:
                        dirs.push_front({"path": item, "depth": dirinfo.depth + 1})
                elif re.search(item) != null:
                    f.call_func(path)
        else:
            push_error("Unable to access path '%s'" % dirinfo.path)





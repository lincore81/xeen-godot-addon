extends EditorInspectorPlugin

class_name XeenCellMapInspectorPlugin


func can_handle(object):
	return object is CellMapNode

func parse_property(object, type, path, hint, hint_text, usage):
	pass
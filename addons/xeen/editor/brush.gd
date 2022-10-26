extends Resource
class_name CellBrush

# TODO: Use Brush.cell_template when putting/clearing cells
export var cell_template: PackedScene = preload("res://addons/xeen/map/cells/cell.tscn")

export var faces: Dictionary = {
	Units.FACE.TOP:      FaceInfo.new(),
	Units.FACE.BOTTOM:   FaceInfo.new(),
	Units.FACE.NORTH:    FaceInfo.new(),
	Units.FACE.SOUTH:    FaceInfo.new(),
	Units.FACE.EAST:     FaceInfo.new(),
	Units.FACE.WEST:     FaceInfo.new(),
	Units.FACE.WALLS:    FaceInfo.new(),
}

signal face_changed(face, info)


func paint(cell: Cell):
	# Not raising error to mitigate issue related to UndoRedo.MERGE_ALL: 
	# https://github.com/godotengine/godot/issues/26118
	#assert(cell, "Cell is null!")
	if not cell:
		return
	for f in faces.keys():
		if f != Units.FACE.WALLS:
			cell.set_face_info(f, faces[f])



func set_material(face: int, material: Material):
	if face == Units.FACE.WALLS:
		for w in Units.WALLS:
			set_material(w, material)
	if face in faces:
		var info := faces[face] as FaceInfo
		info.material = material
		_derive_face_properties_from_material(info)
		emit_signal("face_changed", face, info)
	else:
		push_error("Invalid face: %d" % face)


func get_material(face: int) -> Material:
	if face in faces:
		return faces[face].material
	else:
		push_error("Invalid face: %d" % face)
		return null


func matches_cell(cell: Cell):
	for f in faces.keys():
		if cell.has_face(f):
			if str(faces[f].material) != str(cell.get_face_info(f).material):
				return false
	return true

func use_faces_from_cell(cell: Cell):
	for f in faces.keys():
		if cell.has_face(f):
			faces[f].from_info(cell.get_face_info(f))

func set_face_info(face: int, info: FaceInfo):
	if face == Units.FACE.WALLS:
		for w in Units.WALLS:
			set_face_info(w, info)
	if face in faces:
		faces[face] = info
		_derive_face_properties_from_material(info)
		emit_signal("face_changed", face, info)
	else:
		push_error("Invalid face: %d" % face)

func get_face_info(face: int) -> FaceInfo:
	return faces.get(face)

func get_faces() -> Dictionary:
	return faces

func set_faces(infos: Dictionary, quiet := false) -> void:
	for f in infos.keys():
		if faces.has(f):
			faces[f] = infos[f].duplicate()
			if not quiet: 
				emit_signal("face_changed", f, faces[f])

func _derive_face_properties_from_material(info: FaceInfo):
	if info.material:
		var path := info.material.resource_path
		#var invisible := XeenEditorUtil.contains_any_substr(path, XeenConfig.INVISIBLE_MATERIALS)
		var passable := XeenEditorUtil.contains_any_substr(path, XeenConfig.PASSABLE_MATERIALS)
		var decorative := XeenEditorUtil.contains_any_substr(path, XeenConfig.DECORATIVE_MATERIALS)
		#print("derived face properties: invis=%s, passable=%s, decorative=%s" % [str(invisible), str(passable), str(decorative)])
		#info.visibility_policy = Units.VISIBILITY.NEVER if invisible else Units.VISIBILITY.AUTO
		info.passability_policy = Units.PASSABILITY.ALWAYS if passable else Units.PASSABILITY.AUTO
		if decorative:
			info.visibility_policy = Units.VISIBILITY.ALWAYS
			info.passability_policy = Units.PASSABILITY.ALWAYS
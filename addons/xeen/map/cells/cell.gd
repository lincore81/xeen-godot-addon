tool
extends Spatial
class_name Cell



onready var face_info: Dictionary = {
	Units.FACE.TOP: {"info": FaceInfo.new(), "node": $Top as MeshInstance},
	Units.FACE.BOTTOM: {"info": FaceInfo.new(), "node": $Bottom as MeshInstance},
	Units.FACE.NORTH: {"info": FaceInfo.new(), "node": $North as MeshInstance},
	Units.FACE.EAST: {"info": FaceInfo.new(), "node": $East as MeshInstance},
	Units.FACE.SOUTH: {"info": FaceInfo.new(), "node": $South as MeshInstance},
	Units.FACE.WEST: {"info": FaceInfo.new(), "node": $West as MeshInstance},
}


func get_face_node(id: int) -> MeshInstance:
	if face_info.has(id):
		return face_info[id].node
	else:
		push_error("Invalid face id: %d" % id)
		return null

func get_face_ids() -> Array:
	return face_info.keys()

func has_face(id: int):
	return face_info.has(id)

func get_face_info(id: int) -> FaceInfo:
	if face_info.has(id):
		return face_info[id].info
	else:
		return null
	
func set_face_info(id: int, info: FaceInfo):
	#print("sef_face_info: id=%d, info=%s" % [id, info])
	if face_info.has(id):
		var myinfo := face_info[id].info as FaceInfo
		var vis = myinfo.visible
		var pas = myinfo.passable
		myinfo.from_info(info)
		myinfo.visible = vis
		myinfo.passable = pas
		_apply_face_info(id, myinfo)
	else:
		push_error("Invalid face id: %d" % id)
		return null


# if face_info[id].info.visibility is set to AUTO, directly set the child's visibility
func update_auto_visibility(id: int, visible: bool):
	if face_info.has(id):
		var info := face_info[id].info as FaceInfo
		info.visible = visible
		_apply_face_info(id, info)
	else:
		push_error("Invalid face id: %d" % id)
		return null
	
func serialise() -> Dictionary:
	var it = {}
	for f in face_info.keys():
		it[f] = face_info[f].info.to_dict()
	return it

func deserialise(data: Dictionary) -> void:
	for f in data.keys():
		if face_info.has(f):
			var info = face_info[f].info
			var node = face_info[f].node
			info.from_dict(data[f])
			_apply_face_info(f, info)

# TAG: 2D
func is_wall_passable(absdir: int) -> bool:
	var result: bool = false
	var faceid = Units.absdir2face(absdir)
	if faceid != -1 && faceid in face_info:
		var info = face_info[faceid].info
		match info.passability_policy:
			Units.PASSABILITY.ALWAYS:
				return true
			Units.PASSABILITY.NEVER:
				return false
			Units.PASSABILITY.AUTO: # = passable if not visible
				match info.visibility_policy:
					Units.VISIBILITY.ALWAYS:
						return false
					Units.VISIBILITY.NEVER:
						return true
					Units.VISIBILITY.AUTO:
						return not info.visible
	return false


# apply material and visibility to the MeshInstance
func _apply_face_info(id: int, info: FaceInfo):
	var node := face_info[id].node as MeshInstance
	node.set_surface_material(0, info.material)
	if not Engine.editor_hint and info.material:
		var invisible := XeenEditorUtil.contains_any_substr(
				info.material.resource_path, XeenConfig.INVISIBLE_MATERIALS)
		if invisible:
			node.visible = false
			return
	if info.visibility_policy != Units.VISIBILITY.AUTO:
		node.visible = Units.visibility2bool(info.visibility_policy)
	else:
		node.visible = info.visible
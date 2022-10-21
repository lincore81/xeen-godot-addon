extends Resource
class_name FaceInfo

export var material: Material
export var visibility_policy: int = Units.VISIBILITY.AUTO
export var passability_policy: int = Units.PASSABILITY.AUTO
# applies if passability_policy == Units.PASSABILITY.AUTO:
export var passable := false
# applies if visibility == Units.VISIBILITY.AUTO:
export var visible := true
export var rotation: int = Units.ROTATION.NONE
export var fliph := false
export var flipv := false
export var uvscale := Vector2.ONE


func from_info(other: FaceInfo) -> FaceInfo:
	material = other.material
	visibility_policy = other.visibility_policy
	passability_policy = other.passability_policy
	passable = other.passable
	visible = other.visible
	rotation = other.rotation
	fliph = other.fliph
	flipv = other.flipv
	uvscale.x = other.uvscale.x
	uvscale.y = other.uvscale.y
	return self


func to_dict() -> Dictionary:
	return {
		material = self.material,
		visibility_policy = self.visibility_policy,
		passability_policy = self.passability_policy,
		passable = self.passable,
		visible = self.visible,
		rotation = self.rotation,
		fliph = self.fliph,
		flipv = self.flipv,
		uvscale = Vector2(self.uvscale.x, self.uvscale.y)
	}
	

func from_dict(dict: Dictionary):
	material = dict.get("material", null)
	visibility_policy = dict.get("visibility_policy", Units.VISIBILITY.AUTO)
	passability_policy = dict.get("passability_policy", Units.PASSABILITY.AUTO)
	rotation = dict.get("rotation", Units.ROTATION.NONE)
	visible = dict.get("visible", true)
	passable = dict.get("passable", true)
	fliph = dict.get("fliph", false)
	flipv = dict.get("flipv", false)
	uvscale = dict.get("uvscale", Vector2.ONE)
	return self

func equals(other: FaceInfo):
	return (self.material.resource_path == other.material.resource_path
		and self.visibility_policy == other.visibility_policy
		and self.passability_policy == other.passability_policy
	)
	#    and self.visible == other.visible
	#    and self.passable == other.passable
	#    and self.rotation == other.rotation
	#    and self.fliph == other.fliph
	#    and self.flipv == other.flipv
	#    and str(self.uvscale) == str(other.uvscale))

func _to_string():
	var mat = material.resource_path.split("/", false)[-1] if material else "null"
	var vis = Units.VISIBILITY.keys()[visibility_policy]
	var pas = Units.PASSABILITY.keys()[passability_policy]
	var rot = Units.ROTATION.keys()[rotation]
	var flip
	match [fliph, flipv]:
		[false, false]: flip = "No"
		[true, false]: flip = "Horiz"
		[false, true]: flip = "Vert"
		[true, true]: flip = "Both"

	return "[FaceInfo material=%s, visibility_policy=%s, visible=%s, passability_policy=%s, passable=%s, rotation=%s, fliph=%s, uvscale=%s]" % [
		mat, vis, str(visible), pas, str(passable), rot, flip, uvscale]
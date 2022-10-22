extends Object
class_name XeenConfig

const DEFAULT_BRUSH_MATERIALS := {
	Units.FACE.BOTTOM: "res://addons/xeen/assets/materials/rocks/flatstones.tres",
	Units.FACE.TOP: "res://addons/xeen/assets/materials/tech/bigsquares.tres",
	Units.FACE.WALLS: "res://addons/xeen/assets/materials/wood/creakywood.tres",
} 

const DEFAULT_MATERIAL_DIR := "res://addons/xeen/assets/materials"

# If a material resource path matches any of these strings, the face it is
# applied to will be hidden:
const INVISIBLE_MATERIALS := [
	"invisible",
]

# If a material resource path matches any of these strings, the face it is
# applied to can be walked through:
const PASSABLE_MATERIALS := [
	"doorway",
]
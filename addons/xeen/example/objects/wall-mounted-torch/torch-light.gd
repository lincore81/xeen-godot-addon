extends OmniLight

export var colour_variation: Gradient 
export var max_range_variation := 0.3
export var max_energy_variation := 0.15
export var min_duration := 0.2
export var max_duration := 0.7
export var max_position_variation := Vector3(0.08, 0.04, 0.08)

var _initial_range: float
var _initial_energy: float
var _initial_position: Vector3

var _tween: Tween

func _ready():
	if not colour_variation:
		colour_variation = Gradient.new()
		colour_variation.add_point(0, Color.black)
		colour_variation.add_point(1, Color.white)
		push_warning("No gradient given")
	_initial_range = omni_range 
	_initial_energy = light_energy 
	_initial_position = translation
	light_color = colour_variation.interpolate(0.5)
	_tween = Tween.new()
	add_child(_tween)
	_on_tween()
	_tween.connect("tween_all_completed", self, "_on_tween")

func _on_tween():
	var range_variation := rand_range(1 - max_range_variation, 1 + max_range_variation)
	var energy_variation := rand_range(1 - max_energy_variation, 1 + max_energy_variation)
	var target_range := _initial_range * range_variation
	var target_energy := _initial_energy * energy_variation
	var target_colour := colour_variation.interpolate(rand_range(0, 1))
	var target_position := _initial_position + Vector3(
		rand_range(-max_position_variation.x, max_position_variation.x),
		rand_range(-max_position_variation.y, max_position_variation.y),
		rand_range(-max_position_variation.z, max_position_variation.z))

	var duration := rand_range(min_duration, max_duration)
	#print("on_tween: current=%.2f, target=%.2f, duration=%.2f" % [omni_range, target_range, duration])
	_tween.interpolate_property(self, "omni_range", omni_range, target_range, duration, Tween.TRANS_QUART)
	_tween.interpolate_property(self, "light_energy", light_energy, target_energy, duration, Tween.TRANS_CUBIC)
	_tween.interpolate_property(self, "light_color", light_color, target_colour, duration, Tween.TRANS_CUBIC)
	_tween.interpolate_property(self, "translation", translation, target_position, duration, Tween.TRANS_LINEAR)
	_tween.start()

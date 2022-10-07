tool
extends Object
class_name XeenKeybinds

# Used by EditorPanel/BrushView
const set_brush_face = {
    Cell.FACE.BOTTOM: {key = KEY_KP_1},
    Cell.FACE.TOP: {key = KEY_KP_7},
    Cell.FACE.NORTH: {key = KEY_KP_8},
    Cell.FACE.EAST: {key = KEY_KP_6},
    Cell.FACE.SOUTH: {key = KEY_KP_2},
    Cell.FACE.WEST: {key = KEY_KP_4},
    Cell.FACE.WALLS: {key = KEY_KP_5},
}

static func make_shortcut(def, button: BaseButton = null) -> ShortCut:
    var ev := InputEventKey.new()
    assert(def.key, "Unable to create shortcut, there is no key!")
    ev.scancode = def.key
    if def.get("ctrl", false):
        ev.control = true
    if def.get("alt", false):
        ev.alt = true
    if def.get("shift", false):
        ev.shift = true
    var it = ShortCut.new()
    it.shortcut = ev
    if button:
        button.shortcut = it
    return it
    
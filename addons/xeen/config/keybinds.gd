tool
extends Object
class_name XeenKeybinds

# Used by EditorPanel/BrushView
const set_brush_face = {
    Units.FACE.BOTTOM:   {key = KEY_KP_1},
    Units.FACE.TOP:      {key = KEY_KP_7},
    Units.FACE.NORTH:    {key = KEY_KP_8},
    Units.FACE.EAST:     {key = KEY_KP_6},
    Units.FACE.SOUTH:    {key = KEY_KP_2},
    Units.FACE.WEST:     {key = KEY_KP_4},
    Units.FACE.WALLS:    {key = KEY_KP_5},
}

const SELECTION_CLEAR = {key = KEY_C}
const SELECTION_FILL = {key = KEY_ENTER}
const SELECTION_DELETE = {key = KEY_X}

const TOOL_SELECT = {
    Units.TOOL.BRUSH: {key = KEY_1},
    Units.TOOL.BOX_SELECT: {key = KEY_2},
    Units.TOOL.EYEDROPPER: {key = KEY_3},

}




# Create a shortcut from given dictionary. If a button is provided, its shortcut
# field will be set to the created shortcut.
# Possible key-value pairs:
# - key: int (one of the KEY_* constants) *required*
# - ctrl, alt, shift: bool-like (wether the given modifiers should be pressed or not) default: false
static func make_shortcut(def: Dictionary, button: BaseButton = null) -> ShortCut:
    var ev := InputEventKey.new()
    if not def.has("key"):
        return null
    assert(def.key is int, "Key must be an int: %s" % str(def.key))
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
    

static func is_pressed(def: Dictionary, ev: InputEventKey) -> bool:
    var matches_key = ev.scancode == def.get("key", -1)
    var matches_mods = (ev.control == def.get("ctrl", false)
            and ev.shift == def.get("shift", false)
            and ev.alt == def.get("alt", false))
    return matches_key and matches_mods
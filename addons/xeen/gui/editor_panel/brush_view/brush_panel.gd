tool
extends GridContainer
class_name BrushPanel


const PLACEHOLDER = -1

export var empty: Texture = preload("res://addons/xeen/assets/textures/base/empty.png")
export var error: Texture = preload("res://addons/xeen/assets/textures/base/placeholder.png")

export var face_panel: PackedScene = preload("res://addons/xeen/gui/editor_panel/brush_view/face_panel.tscn")

var brush: CellBrush
var is_setup := false
var previewer: EditorResourcePreview

signal face_selected(face)

var faces := {}

func setup(previewer: EditorResourcePreview, layout: Array, cols: int = 3):
    self.previewer = previewer
    columns = cols
    for x in layout:
        if x.face == PLACEHOLDER:
            add_child(Control.new())
        else:
            var p = face_panel.instance()
            var shortcut = x.get("shortcut", XeenKeybinds.set_brush_face.get(x.face, null))
            faces[x.face] = p
            p.setup(x.label, empty, shortcut)
            p.connect("material_pressed", self, "_on_btn_pressed", [x.face])
            add_child(p)
    is_setup = true
    #if brush: _apply_brush()


func _on_btn_pressed(face: int):
    emit_signal("face_selected", face)

func set_brush(brush: CellBrush):
    assert(brush != null, "Brush must not be null.")
    self.brush = brush
    if is_setup:
        _apply_brush()


func _apply_brush():
    assert(brush, "No cell brush!")
    for face in faces.keys():
        var info := brush.get_face_info(face)
        set_face(face, info)


func set_face(face: int, info: FaceInfo, preview: Texture = null):
    if not faces.has(face):
        push_warning("Brush panel does not have face %d." % face)
    elif not info.material: 
        faces[face].set_material_preview(empty)
    elif preview:
        faces[face].set_material_preview(preview)
    elif previewer:
        previewer.queue_resource_preview(info.material.resource_path, self, "_on_preview_generated", face)
    else:
        push_warning("preview and previewer are null, cannot create material preview")

func _on_preview_generated(_path, texture: Texture, _thumb, face: int):
    faces[face].set_material_preview(texture if texture else error)

% Xeen Map Editor


# XeenEditorPlugin

- *extends:* EditorPlugin
- *file:* /plugin.gd

`forward_spatial_gui_input(cam: Camera, ev: InputEvent) -> bool`

`unedit() `

`edit(obj: Object) `

`handles(obj: Object) -> bool`


# XeenEditorUtil

- *extends:* Reference
- *file:* /editor/util.gd

`static pick_cell(global_transform: Transform, camera: Camera, point: Vector2) -> Array`

`static v(x, y, z) `

`static create_wireframe_cube(origin: Vector3, size: Vector3 = Vector3.ONE) -> PoolVector3Array`

`static get_mouse_button_state(ev: InputEventMouseButton) -> Array`

`static contains_any_substr(substr: String, strarr: Array) -> bool`


# XeenEditor

- *extends:* Object
- *file:* /editor/editor.gd

`clear_selection() `

`fill_selection() `

`on_ready(undo: UndoRedo) `

`is_tool_valid(t: int) -> bool`

`set_tool(t: int) `

`try_put_cell(_pos: Maybe = null, action := "", merge_mode := UndoRedo.MERGE_DISABLE) -> bool`

`try_clear_cell(action := "", merge_mode := UndoRedo.MERGE_DISABLE) -> bool`

`try_eyedropper() `

`update_cursor(cam: Camera, mouse_pos: Vector2) -> bool`

`start_drawing(active := true) -> bool`

`stop_drawing() `

`draw() `

`set_default_brush_materials() `

`set_brush_material(face: int, mat: Material) `


# CellBrush

- *extends:* Resource
- *file:* /editor/brush.gd

`paint(cell: Cell) `

`set_material(face: int, material: Material) `

`get_material(face: int) -> Material`

`matches_cell(cell: Cell) `

`use_faces_from_cell(cell: Cell) `

`set_face_info(face: int, info: FaceInfo) `

`get_face_info(face: int) -> FaceInfo`

`get_faces() -> Dictionary`

`set_faces(infos: Dictionary, quiet := false) -> void`


# XeenMapGridGizmoPlugin

- *extends:* EditorSpatialGizmoPlugin
- *file:* /editor/gizmos/grid_gizmo_plugin.gd

`get_name() `

`has_gizmo(spatial) `

`create_gizmo(spatial) `


# XeenMapGridGizmo

- *extends:* EditorSpatialGizmo
- *file:* /editor/gizmos/grid_gizmo.gd

`redraw() `

`draw_cursor(origin: Vector3, editor: XeenEditor) `

`draw_selection(selection: AABB) `

`draw_grid(size: Vector3, origin: Vector3, editor: XeenEditor) `


# MapData

- *extends:* Resource
- *file:* /map/mapdata.gd

`is_empty() -> bool`

`clear() `

`static iter_over_cell_data(data: MapData, callback: FuncRef, context = null) `

`static write_to_disk(data: MapData) `

`static restore_cell(mapdata: MapData, pos: Vector3, cell: Cell) `

`static store_cell(mapdata: MapData, pos: Vector3, cell) `


# CellMapNode

- *extends:* Spatial
- *file:* /map/cell_map_node.gd

`set_size(s: Vector3) `

`get_bounds() -> AABB`

`is_wall_passable(pos: Vector3, abs_dir: int) `

`iterate_over_area(callback: FuncRef, bounds: AABB, skip_null = false, userdata = null) `

`get_cardinal_neighbours(pos: Vector3) -> Dictionary`

`put_cell(pos: Vector3, cell_template: PackedScene, update_visibility := true, update_neighbours := true) -> Cell`

`put_existing_cell(pos: Vector3, cell: Cell, update_visibility := true, update_neighbours := true) -> bool`

`clear_cell(pos: Vector3, update_neighbours := true) -> Cell`

`update_face_visibility(pos: Vector3, removed := false, update_neighbours := true) `

`cell_at(pos: Vector3) -> Cell`

`in_bounds(pos: Vector3) `

`deserialise() `

`serialise() `


# XeenCellMapInspectorPlugin

- *extends:* EditorInspectorPlugin
- *file:* /map/inspector/map_inspector_plugin.gd

`can_handle(object) `

`parse_property(object, type, path, hint, hint_text, usage) `


# Cell

- *extends:* Spatial
- *file:* /map/cells/cell.gd

`get_face_node(id: int) -> MeshInstance`

`get_face_ids() -> Array`

`has_face(id: int) `

`get_face_info(id: int) -> FaceInfo`

`set_face_info(id: int, info: FaceInfo) `

`update_auto_visibility(id: int, visible: bool) `

`serialise() -> Dictionary`

`deserialise(data: Dictionary) -> void`

`is_wall_passable(absdir: int) -> bool`


# Units

- *extends:* Object
- *file:* /datatypes/units.gd

`static get_opposite_face(f: int) -> int`

`static visibility2bool(val: int) -> bool`

`static absdir2str(absdir) -> String`

`static absdir2face(absdir) -> int`

`static reldir2str(absdir) -> String`

`static move2absdir(move: Vector3) -> int`

`static face2str(id: int) -> String`


# BitSet

- *extends:* Reference
- *file:* /datatypes/bitset.gd

`has(bit: int) -> bool`

`setbit(bit: int) -> void`

`clearbit(bit: int) -> void`

`togglebit(bit: int) -> void`

`toarray() -> Array`

`tostr() -> String`


# FaceInfo

- *extends:* Resource
- *file:* /datatypes/faceinfo.gd

`from_info(other: FaceInfo) -> FaceInfo`

`to_dict() -> Dictionary`

`from_dict(dict: Dictionary) `

`equals(other: FaceInfo) `


# Maybe

- *extends:* Object
- *file:* /datatypes/maybe.gd

`is_some() `

`is_none() `

`value(default := null) `


# XeenEditorPanel

- *extends:* PanelContainer
- *file:* /gui/editor_panel/editor_panel.gd

`setup(resource_preview: EditorResourcePreview, filesystem: EditorFileSystem, brush: CellBrush) `

`update_cursor_pos(pos: Vector3, in_bounds: bool) `


# MaterialBrowser

- *extends:* VBoxContainer
- *file:* /gui/editor_panel/asset_browser/material_browser.gd

`get_selection() -> String`

`get_preview(path: String) -> Texture`

`setup(resource_preview: EditorResourcePreview, filesystem: EditorFileSystem) `


# SortButton

- *extends:* Button
- *file:* /gui/editor_panel/asset_browser/sortbtn.gd




# AssetBrowser

- *extends:* HFlowContainer
- *file:* /gui/editor_panel/asset_browser/asset_browser.gd

`set_filter(pattern: String) `

`setup(preview: EditorResourcePreview, filesystem: EditorFileSystem) `

`change_directory(dir: String) `

`change_sort_order(order: int) `

`update_browser() `


# BrushPanel

- *extends:* GridContainer
- *file:* /gui/editor_panel/brush_view/brush_panel.gd

`setup(previewer: EditorResourcePreview, layout: Array, cols: int = 3) `

`set_brush(brush: CellBrush) `

`set_face(face: int, info: FaceInfo, preview: Texture = null) `


# FacePanel

- *extends:* PanelContainer
- *file:* /gui/editor_panel/brush_view/face_panel.gd

`setup(label: String, preview: Texture, shortcut: Dictionary) `

`set_label(text: String) `

`set_shortcut(def: Dictionary) `

`set_material_preview(preview: Texture) `


# XeenConfig

- *extends:* Object
- *file:* /config/config.gd




# XeenKeybinds

- *extends:* Object
- *file:* /config/keybinds.gd

`static make_shortcut(def: Dictionary, button: BaseButton = null) -> ShortCut`

`static is_pressed(def: Dictionary, ev: InputEventKey) -> bool`


# GameScene

- *extends:* Spatial
- *file:* /example/game_scene.gd




# PlayerSpatial

- *extends:* Spatial
- *file:* /example/objects/player/player_spatial.gd

`get_map_position() -> Vector3`

`is_moving() `

`move(target: Vector3) `

`turn(right := true) `

`move_progress() `


# torch-light.gd

- *extends:* OmniLight
- *file:* /example/objects/wall-mounted-torch/torch-light.gd


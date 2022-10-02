# Xeen Map Editor Plugin
## About
This plugin allows 3d grid map creation similar to a GridMap, except with the
following differences:
1. Cells' faces (ceiling, floor and walls) can dynamically adapt to their neighbours
2. Per-face materials can be chosen in the editor.
3. Additional objects and behaviours can be added to a cell (e.g. doors)

Currently the plugin is restricted to 2d maps.


## Plugin structure

- `plugin.gd` (entry script)
- `editor.gd` (manages editor state as much as possible)
- `gui/`
    - `editor_panel.gd` (toggle faces, select materials etc. for current selection/new cells)
- `gizmos/`
    - `grid_gizmo_plugin.gd` (create gizmo)
    - `grid_gizmo.gd` (draw grid, cursor etc.)
- `nodes`/
    - `cell_map_node.gd` (manage map and cell instances)
- `scenes`/
    - `cell.gd` (set own faces, materials etc.)

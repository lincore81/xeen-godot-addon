This is a buggy mess right now.

Enjoy!

# Issues
- [ ] Fix linear 2 srgb shader https://github.com/tobspr/GLSL-Color-Spaces/blob/master/ColorSpaces.inc.glsl

# Features
## Essential
### Basic Editing
- [x] Show a grid and the cell the mouse is hovering over in the 3D vieweport
- [x] I can see the map coordinate of the mouse in the editor.
- [x] I can put a cell instance on the grid by left clicking on it.
- [x] I can ctrl click on an existing cell instance to remove it.
- [x] I can undo and redo edits.
- [x] Walls between adjacent cell instances are automatically hidden.
- [x] The map can be saved and reloaded
- [x] The map works both at runtime and in the editor. It allows the implementation of grid-based player movement.
- [ ] I can select materials for each face in the GUI ("cell brush"). New cells will have those materials applied.
- [ ] I can paint multiple cells by clicking and dragging
- [ ] I can set the cell brush materials by picking an existing cell instance (LMB+Shift perhaps?).
- [ ] I can update existing cells to use the brush materials.
- [ ] I can flip and rotate UV coordinates for each face.
- [ ] I can enable a selection mode that allows me to click and drag to select a area of the map.
- [ ] While in selection mode, I can hit enter to fill the selection with the current brush.
- [ ] While in selection mode, I can hit 'x' or delete to remove all cells in the selection
- [ ] I can cut, copy and paste the selected cells.
- [ ] I can rotate or flip the selection (as a whole)
- [ ] I can drag the selection to move the cells.
- [ ] I can click outside of the selection to clear it and there is also a keyboard shortcut.
- [ ] I can resize and crop the map without losing all data.
- [ ] I can override which faces to show in the cell brush ("always visible", "always show", "auto")

### Advanced editing
- [ ] I can add a cell object to a cell instance that can be accessed through the map class (doors, chests)
- [ ] I can rotate and flip cell objects

### Runtime
- [x] I can determine if an actor can move from a cell to another (by direction)
- [x] I can change cell face materials and visibility at runtime. 
- [ ] I can generate a simple move graph for astar.
- [ ] I can generate a dijkstra map with custom goals.
- [ ] I can mark cell faces as passable for open doors and such

## Nice to Have
### Editing
- [ ] I can vertically translate all 8 vertices of a cell to create sloped floors and ceilings and to adjust the height
- [ ] Cells create additional geometry to fill any resulting gaps (like in Delvers editor)
- [ ] Cells, faces and cell brushes can be extended to allow custom functionality, but have a common interface
- [ ] I can create full 3D maps (multiple layers)
- [ ] I can toggle a setting to render back-faces semi-transparently.

### Runtime
- [ ] Maps can be 'chunked' so that chunks are saved to separate resources and can be separetely loaded and unloaded at runtime.

## Wishful thinking
- [ ] Maps can interact with each other so the player can move between them seamlessly
- [ ] I can mark cells as 'static', which optimises the geometry at runtime.
# 2022-10-09
- [ ] Wrote a simple doc generator that creates a markdown file with all classes and methods. Parameter parsing seems a bit buggy, still.

# 2022-10-08
- [x] Remove cell putting/clearing/updating code from Brush, should only manage its own state
    - Pass brush instance or its materials directly to map node instance.
    - [x] Alternatively the brush could still apply its materials to the brush
    - Reason: Current impl is ridiculous, putting a cell on the map involves Plugin -> Editor -> Brush -> Map Node
- [x] Implement do and undo methods for putting, clearing and updating cells in the editor class

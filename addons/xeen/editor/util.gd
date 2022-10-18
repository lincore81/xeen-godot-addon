tool
extends Reference
class_name XeenEditorUtil

# Return a vector or false if no cell is under the courser.
# Based on: https://github.com/DarkKilauea/godot-scene-map/blob/main/addons/scene_map/plugin.gd
# TODO: Make it work in orthographic projection 
static func pick_cell(global_transform: Transform, camera: Camera, point: Vector2) -> Array:
    #var frustum := camera.get_frustum()
    var from := camera.project_ray_origin(point)
    var normal := camera.project_ray_normal(point)

    # Convert from global space to the local space of the scene map.
    var to_local_transform = global_transform.affine_inverse()
    from = to_local_transform.xform(from)
    normal = to_local_transform.basis.xform(normal).normalized()
    
    var plane := Plane()
    plane.normal = Vector3.UP
    plane.d = 0
    
    var hit := plane.intersects_segment(from, normal * camera.far)
    if !hit:
        return [false, Vector3.ZERO]

    # Make sure the point is still visible by the camera to avoid painting on areas outside of the camera's view.
    #for frustum_plane in frustum:
    #    var local_plane := to_local_transform.xform(frustum_plane) as Plane
    #    if local_plane.is_point_over(hit):
    #        return false

    var pos := Vector3()
    pos.x = int(hit.x)
    pos.z = int(hit.z)
    return [true, pos]



static func v(x, y, z):
    return Vector3(x, y, z)

static func create_wireframe_cube(origin: Vector3, size: Vector3 = Vector3.ONE) -> PoolVector3Array:
    var x0 := min(origin.x, origin.x + size.x)
    var y0 := min(origin.y, origin.y + size.y)
    var z0 := min(origin.z, origin.z + size.z)
    var x1 := max(origin.x, origin.x + size.x)
    var y1 := max(origin.y, origin.y + size.y)
    var z1 := max(origin.z, origin.z + size.z)
    var ls := PoolVector3Array()

    # bottom
    ls.append(v(x0, y0, z0))
    ls.append(v(x1, y0, z0))
    ls.append(v(x0, y0, z1))
    ls.append(v(x1, y0, z1))
    ls.append(v(x0, y0, z0))
    ls.append(v(x0, y0, z1))
    ls.append(v(x1, y0, z0))
    ls.append(v(x1, y0, z1))

    # top
    ls.append(v(x0, y1, z0))
    ls.append(v(x1, y1, z0))
    ls.append(v(x0, y1, z1))
    ls.append(v(x1, y1, z1))
    ls.append(v(x0, y1, z0))
    ls.append(v(x0, y1, z1))
    ls.append(v(x1, y1, z0))
    ls.append(v(x1, y1, z1))

    # sides
    ls.append(v(x0, y0, z0))
    ls.append(v(x0, y1, z0))
    ls.append(v(x1, y0, z0))
    ls.append(v(x1, y1, z0))
    ls.append(v(x0, y0, z1))
    ls.append(v(x0, y1, z1))
    ls.append(v(x1, y0, z1))
    ls.append(v(x1, y1, z1))
    return ls

    
static func get_mouse_button_state(ev: InputEventMouseButton) -> Array:
    return [ev.button_index, ev.pressed]

             
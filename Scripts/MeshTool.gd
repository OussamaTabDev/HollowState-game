@tool
extends MeshInstance3D

@export_group("Collision")
@export var surface: String
@export var dualColliders: bool = false
@export var createSimple: bool = false: set = _create_simple_collision
@export var createTrimesh: bool = false: set = _create_trimesh_collision
@export var remove: bool = false: set = _remove_collision

@export_group("Shadows")
@export var simplification: float = 1.0
@export var shadowLOD: bool = false
@export var shadowOnly: bool = false
@export var generate: bool = false: set = _generate_shadow_caster
@export var reset: bool = false: set = _clear_shadow

@export_group("Fading")
@export var fadeDistance: float = 100.0
@export var apply: bool = false: set = _apply_fade_distance

func _create_simple_collision(_value: bool) -> void :
    if not Engine.is_editor_hint():
        return


    if not mesh or not mesh is ArrayMesh:
        printerr("Requires an ArrayMesh assigned to this MeshInstance3D.")
        return


    _remove_collision(true)


    var static_body: = StaticBody3D.new()
    static_body.name = "Collision"
    add_child(static_body)
    static_body.owner = get_tree().edited_scene_root


    var collision_shape: = CollisionShape3D.new()
    collision_shape.name = "Shape"
    var convex_shape: = mesh.create_convex_shape(true, true)
    collision_shape.shape = convex_shape
    static_body.add_child(collision_shape)
    collision_shape.owner = get_tree().edited_scene_root

    print("Simplified convex collision created for ", name)
    createSimple = false

func _create_trimesh_collision(_value: bool) -> void :
    if not Engine.is_editor_hint():
        return


    if not mesh or not mesh is ArrayMesh:
        printerr("Requires an ArrayMesh assigned to this MeshInstance3D.")
        return


    _remove_collision(true)


    var static_body: = StaticBody3D.new()
    static_body.name = "Collision"
    add_child(static_body)
    static_body.owner = get_tree().edited_scene_root


    var collision_shape: = CollisionShape3D.new()
    collision_shape.name = "Shape"
    var trimesh_shape: = mesh.create_trimesh_shape()
    collision_shape.shape = trimesh_shape
    static_body.add_child(collision_shape)
    collision_shape.owner = get_tree().edited_scene_root

    print("Trimesh collision created for ", name)
    createTrimesh = false

func _remove_collision(_value: bool) -> void :
    if not Engine.is_editor_hint():
        return


    var collision_node = get_node_or_null("Collision")
    if collision_node:
        remove_child(collision_node)
        collision_node.queue_free()

    print("Collision removed for ", name)
    remove = false

func _generate_shadow_caster(_value: bool) -> void :
    if not Engine.is_editor_hint():
        return


    if not mesh or not mesh is ArrayMesh:
        printerr("Requires an ArrayMesh assigned to this MeshInstance3D.")
        return


    var existing_shadows = get_node_or_null("Shadows")
    if existing_shadows:
        remove_child(existing_shadows)
        existing_shadows.queue_free()

    var source_mesh: ArrayMesh = mesh
    var importer_mesh: = ImporterMesh.new()


    for surface_idx in source_mesh.get_surface_count():
        var arrays: Array = source_mesh.surface_get_arrays(surface_idx)
        var primitive_type: int = source_mesh.surface_get_primitive_type(surface_idx)
        importer_mesh.add_surface(primitive_type, arrays)


    var shadows_node: = Node3D.new()
    shadows_node.name = "Shadows"
    add_child(shadows_node)
    shadows_node.owner = get_tree().edited_scene_root


    if shadowLOD:

        for lod_level in range(2):
            var shadow_importer: = ImporterMesh.new()
            var lod_factor: float = simplification * (1.0 + lod_level * 4.0)
            for surface_idx in importer_mesh.get_surface_count():
                var arrays: Array = importer_mesh.get_surface_arrays(surface_idx)
                var simplified_arrays: Array = _simplify_mesh(arrays, lod_factor)
                shadow_importer.add_surface(importer_mesh.get_surface_primitive_type(surface_idx), simplified_arrays)

            var shadow_mesh: ArrayMesh = shadow_importer.get_mesh()
            var shadow_node: = MeshInstance3D.new()
            shadow_node.name = "Shadow_LOD" + str(lod_level)
            shadows_node.add_child(shadow_node)
            shadow_node.mesh = shadow_mesh
            shadow_node.owner = get_tree().edited_scene_root


            if lod_level == 0:
                shadow_node.visibility_range_end = 50.0
            else:
                shadow_node.visibility_range_begin = 50.0

            if shadowOnly:
                shadow_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

        print("Shadow LODs generation complete for ", name)
    else:

        var shadow_importer: = ImporterMesh.new()
        for surface_idx in importer_mesh.get_surface_count():
            var arrays: Array = importer_mesh.get_surface_arrays(surface_idx)
            var simplified_arrays: Array = _simplify_mesh(arrays, simplification)
            shadow_importer.add_surface(importer_mesh.get_surface_primitive_type(surface_idx), simplified_arrays)

        var shadow_mesh: ArrayMesh = shadow_importer.get_mesh()
        var shadow_node: = MeshInstance3D.new()
        shadow_node.name = "Shadow"
        shadows_node.add_child(shadow_node)
        shadow_node.mesh = shadow_mesh
        shadow_node.owner = get_tree().edited_scene_root
        if shadowOnly:
            shadow_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

        print("Shadow generation complete for ", name)


    if shadowOnly:
        cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        print("Shadow casting disabled for source mesh ", name)

    generate = false

func _clear_shadow(_value: bool) -> void :
    if not Engine.is_editor_hint():
        return


    var shadows_node = get_node_or_null("Shadows")
    if shadows_node:
        remove_child(shadows_node)
        shadows_node.queue_free()

    print("Shadows node cleared for ", name)
    reset = false

func _apply_fade_distance(_value: bool) -> void :
    if not Engine.is_editor_hint():
        return


    visibility_range_end = fadeDistance
    print("Source mesh visibility_range_end set to ", fadeDistance, " for ", name)


    var shadows_node = get_node_or_null("Shadows")
    if shadows_node and shadowLOD:
        var lod0 = shadows_node.get_node_or_null("Shadow_LOD0")
        var lod1 = shadows_node.get_node_or_null("Shadow_LOD1")
        if lod0:
            lod0.visibility_range_end = fadeDistance / 2 + 1.0
            print("Shadow_LOD0 visibility_range_end set to ", lod0.visibility_range_end, " for ", name)
        if lod1:
            lod1.visibility_range_begin = fadeDistance / 2
            lod1.visibility_range_end = fadeDistance
            print("Shadow_LOD1 visibility_range_begin set to ", lod1.visibility_range_begin, ", end set to ", lod1.visibility_range_end, " for ", name)

    apply = false

func _simplify_mesh(arrays: Array, factor: float = simplification) -> Array:

    var new_arrays: Array = []
    new_arrays.resize(Mesh.ARRAY_MAX)

    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    var tangents: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT] if arrays[Mesh.ARRAY_TANGENT] else PackedFloat32Array()
    var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV] else PackedVector2Array()

    if vertices.is_empty() or indices.is_empty():
        return arrays


    var step: int = int(max(1, factor * 5))
    var new_vertices: = PackedVector3Array()
    var new_indices: = PackedInt32Array()
    var new_tangents: = PackedFloat32Array()
    var new_uvs: = PackedVector2Array()
    var vertex_map: = {}


    for i in range(0, vertices.size(), step):
        var new_idx: int = new_vertices.size()
        new_vertices.append(vertices[i])
        vertex_map[i] = new_idx


        if not tangents.is_empty() and i * 4 < tangents.size():
            new_tangents.append(tangents[i * 4])
            new_tangents.append(tangents[i * 4 + 1])
            new_tangents.append(tangents[i * 4 + 2])
            new_tangents.append(tangents[i * 4 + 3])


        if not uvs.is_empty() and i < uvs.size():
            new_uvs.append(uvs[i])


    for i in range(0, indices.size(), 3):
        var i0: int = indices[i]
        var i1: int = indices[i + 1]
        var i2: int = indices[i + 2]


        var new_i0: int = vertex_map.get(i0, _find_closest_vertex(i0, vertex_map, vertices))
        var new_i1: int = vertex_map.get(i1, _find_closest_vertex(i1, vertex_map, vertices))
        var new_i2: int = vertex_map.get(i2, _find_closest_vertex(i2, vertex_map, vertices))

        if new_i0 != new_i1 and new_i1 != new_i2 and new_i2 != new_i0:
            new_indices.append(new_i0)
            new_indices.append(new_i1)
            new_indices.append(new_i2)


    new_arrays[Mesh.ARRAY_VERTEX] = new_vertices
    new_arrays[Mesh.ARRAY_INDEX] = new_indices
    if not new_tangents.is_empty():
        new_arrays[Mesh.ARRAY_TANGENT] = new_tangents
    if not new_uvs.is_empty():
        new_arrays[Mesh.ARRAY_TEX_UV] = new_uvs

    return new_arrays

func _find_closest_vertex(original_idx: int, vertex_map: Dictionary, vertices: PackedVector3Array) -> int:

    if vertex_map.has(original_idx):
        return vertex_map[original_idx]


    var orig_pos: Vector3 = vertices[original_idx]
    var closest_idx: int = 0
    var min_dist: float = INF

    for mapped_idx in vertex_map.keys():
        var dist: float = vertices[mapped_idx].distance_squared_to(orig_pos)
        if dist < min_dist:
            min_dist = dist
            closest_idx = vertex_map[mapped_idx]

    return closest_idx

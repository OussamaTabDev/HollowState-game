@tool
extends Node3D

@export var generate: bool = false:
    set = ExecuteGenerate
@export var clear: bool = false:
    set = ExecuteClear

@export_group("Elements")
@export var elements: Array[PackedScene]

@export_group("Parameters")
@export var area = 0
@export var density = 0
@export var offset = 0.0
@export var minYOffset = 0.0
@export var maxYOffset = 0.0
@export var minScale = 1.0
@export var maxScale = 1.0
@export var XRotation = 0.0
@export var YRotation = 0.0
@export var ZRotation = 0.0
@export var surfaceNormal = false
@export var maxAngle = 40.0

@export_group("Masking")
@export_flags_3d_physics var layers
@export var surfaces: Array[String] = ["Grass"]
@export var perimeter = 0
@export var maxHeight = 0
@export var minHeight = 0

@export_group("Chunks")
@export var chunks = false
@export var chunkSize = 0
@export var chunkVisibility = 0
@export var chunkShadows = false

var hitPosition: Vector3
var hitNormal: Vector3

func ExecuteGenerate(_value: bool) -> void :
    ExecuteClear(true)


    if chunks:
        CreateChunks()


    for x in range(1, area - 2):
        for y in range(1, area - 2):
            if density != 0 && (x % density == 0 and y % density == 0):
                var spawnPosition = Vector3(x - (area / 2.0) + randf_range( - offset, offset), 0, y - (area / 2.0) + randf_range( - offset, offset))
                var randomRotation = Vector3(randf_range( - XRotation, XRotation), randf_range( - YRotation, YRotation), randf_range( - ZRotation, ZRotation))
                var randomScale = randf_range(minScale, maxScale)


                if !RaycastCheck(spawnPosition + Vector3(0, maxHeight, 0), spawnPosition + Vector3(0, minHeight, 0), true):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(0, 100, - perimeter), spawnPosition + Vector3(0, -200, - perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(perimeter, 100, - perimeter), spawnPosition + Vector3(perimeter, -200, - perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(perimeter, 100, 0), spawnPosition + Vector3(perimeter, -200, 0), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(perimeter, 100, perimeter), spawnPosition + Vector3(perimeter, -200, perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3(0, 100, perimeter), spawnPosition + Vector3(0, -200, perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3( - perimeter, 100, perimeter), spawnPosition + Vector3( - perimeter, -200, perimeter), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3( - perimeter, 100, 0), spawnPosition + Vector3( - perimeter, -200, 0), false):
                    continue

                if !RaycastCheck(spawnPosition + Vector3( - perimeter, 100, - perimeter), spawnPosition + Vector3( - perimeter, -200, - perimeter), false):
                    continue


                var randomIndex = randi_range(0, elements.size() - 1)
                var element = elements[randomIndex].instantiate()


                add_child(element, true)
                element.set_owner(get_tree().edited_scene_root)


                element.scale = Vector3(randomScale, randomScale, randomScale)
                element.position = hitPosition + Vector3(0, randf_range(minYOffset, maxYOffset) * randomScale, 0)
                element.rotation_degrees = randomRotation


                if surfaceNormal:
                    element.global_transform.basis = SurfaceNormal(element.global_transform.basis, hitNormal)


                if chunks:
                    AssignToChunk(element, element.global_transform.origin)


    if chunks:
        RemoveEmptyChunks()
        MergeChunks()

    generate = false

func RaycastCheck(rayStart: Vector3, rayEnd: Vector3, originRay: bool) -> bool:
    var ray = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, layers)
    var hit = get_world_3d().direct_space_state.intersect_ray(ray)

    if hit.is_empty() || !hit.collider.get("surface"):
        return false

    if !hit.is_empty() && surfaces.has(hit.collider.get("surface")):
        if originRay:
            hitPosition = hit.position
            hitNormal = hit.normal


            var angle_to_vertical = rad_to_deg(hitNormal.angle_to(Vector3.UP))
            if angle_to_vertical > maxAngle:
                return false

        var posX = abs(hitPosition.x)
        var posZ = abs(hitPosition.z)


        if posX < float(area) / 2 && posZ < float(area) / 2:
            return true
        else:
            return false
    else:
        return false

func SurfaceNormal(node_basis: Basis, normal: Vector3) -> Basis:
    var result = Basis()
    var newScale = node_basis.get_scale().abs()
    result.x = normal.cross(node_basis.z)
    result.y = normal
    result.z = node_basis.x.cross(normal)

    result = result.orthonormalized()
    result.x *= newScale.x
    result.y *= newScale.y
    result.z *= newScale.z
    return result

func ExecuteClear(_value: bool) -> void :
    var childCount = get_child_count()

    if childCount != 0:
        for child in get_children():
            remove_child(child)
            child.queue_free()

    clear = false

func CreateChunks():
    for x in area:
        for y in area:
            if int(chunkSize) != 0 && (x % int(chunkSize) == 0 and y % int(chunkSize) == 0):
                var chunk = MeshInstance3D.new()
                chunk.mesh = BoxMesh.new()
                chunk.mesh.size = Vector3(chunkSize, 100, chunkSize)
                chunk.position = Vector3(x - (area / 2.0) + (chunkSize / 2.0), 0, y - (area / 2.0) + (chunkSize / 2.0))

                add_child(chunk, true)
                chunk.set_owner(get_tree().edited_scene_root)
                chunk.visibility_range_end = chunkVisibility
                chunk.name = "Chunk"

                if chunkShadows:
                    chunk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
                else:
                    chunk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func AssignToChunk(node: Node3D, origin: Vector3):

    for chunk in get_children():

        if chunk is MeshInstance3D:
            var chunkAABB: AABB = chunk.global_transform * chunk.get_aabb()

            if chunkAABB.has_point(origin):

                node.reparent(chunk, true)
                node.set_owner(get_tree().edited_scene_root)
                node.name = "Element"

func RemoveEmptyChunks():

    for chunk in get_children():

        if chunk.get_child_count() == 0:

            remove_child(chunk)
            chunk.queue_free()

func MergeChunks():

    var chunkMaterial: Material = get_child(0).get_child(0).get_child(0).get_surface_override_material(0)


    for chunk in get_children():
        chunk.mesh = ArrayMesh.new()

        var mergedMesh: ArrayMesh
        var surfaceTool = SurfaceTool.new()


        for element in chunk.get_children():

            for child in element.get_children():

                if child is MeshInstance3D:

                    surfaceTool.append_from(child.mesh, 0, element.transform)


            chunk.remove_child(element)
            element.queue_free()


        mergedMesh = surfaceTool.commit()
        chunk.mesh = mergedMesh


        chunk.set_surface_override_material(0, chunkMaterial)

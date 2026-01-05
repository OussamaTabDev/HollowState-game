@tool
extends Node3D

@export var generate: bool = false:
    set = ExecuteGenerate
@export var clear: bool = false:
    set = ExecuteClear

@export_group("Elements")
@export var elements: Array[PackedScene]

@export_group("Parameters")
@export var density = 10
@export var row_spacing = 10.0
@export var YOffset = 0.0
@export var minScale = 1.0
@export var maxScale = 1.0
@export var XRotation = 0.0
@export var YRotation = 0.0
@export var ZRotation = 0.0

@export_group("Masking")
@export_flags_3d_physics var layers
@export var surfaces: Array[String] = ["Grass"]

var hitPosition
var hitNormal

func ExecuteGenerate(_value: bool) -> void :
    ExecuteClear(true)


    var spawn_range_x = 200
    var total_rows = 3

    for i in range(total_rows):
        var row_z = (i - 1) * row_spacing

        for x in range( - spawn_range_x, spawn_range_x):

            if density > 0 && x % density == 0:
                var spawn_position_local = Vector3(x, 0, row_z)


                var spawn_position_global = global_transform * spawn_position_local


                if !RaycastCheck(spawn_position_global + Vector3(0, 100, 0), spawn_position_global + Vector3(0, -200, 0), true):
                    continue

                var random_rotation = Vector3(
                    randf_range( - XRotation, XRotation), 
                    randf_range( - YRotation, YRotation), 
                    randf_range( - ZRotation, ZRotation)
                )
                var random_scale = randf_range(minScale, maxScale)


                var random_index = randi_range(0, elements.size() - 1)
                var element = elements[random_index].instantiate()


                add_child(element, true)
                element.set_owner(get_tree().edited_scene_root)


                element.scale = Vector3(random_scale, random_scale, random_scale)
                element.position = to_local(hitPosition) + Vector3(0, YOffset, 0)
                element.rotation_degrees = random_rotation

    generate = false

func RaycastCheck(rayStart: Vector3, rayEnd: Vector3, originRay: bool) -> bool:
    var ray = PhysicsRayQueryParameters3D.create(rayStart, rayEnd, layers)
    var hit = get_world_3d().direct_space_state.intersect_ray(ray)

    if !hit.is_empty() && hit.collider.get("surface") != null && surfaces.has(hit.collider.get("surface")):
        if originRay:
            hitPosition = hit.position
            hitNormal = hit.normal

        return true
    else:
        return false

func ExecuteClear(_value: bool) -> void :
    var children_to_remove = get_children()
    for child in children_to_remove:
        remove_child(child)
        child.queue_free()

    clear = false

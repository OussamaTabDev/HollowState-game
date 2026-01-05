@tool
extends MeshInstance3D


const surface = preload("res://Scripts/Surface.gd")


const probe = preload("res://Resources/Probe.tscn")

@export var reset: bool = false:
    set = ExecuteReset

@export_group("Colliders")
@export var wood: bool = false:
    set = ExecuteWoodCollider
@export var metal: bool = false:
    set = ExecuteMetalCollider
@export var concrete: bool = false:
    set = ExecuteConcreteCollider

@export_group("Probes")
@export var placeProbe: bool = false:
    set = ExecutePlaceProbe


func ExecuteReset(_value: bool) -> void :
    var materialCount = get_surface_override_material_count()

    if materialCount == 1:
        set_surface_override_material(0, null)
    elif materialCount == 2:
        set_surface_override_material(0, null)
        set_surface_override_material(1, null)
    elif materialCount == 3:
        set_surface_override_material(0, null)
        set_surface_override_material(1, null)
        set_surface_override_material(2, null)

    for child in get_children():
        if child is StaticBody3D:
            remove_child(child)
            child.queue_free()

    reset = false



func ExecuteWoodCollider(_value: bool) -> void :
    create_trimesh_collision()

    for child in get_children():
        if child is StaticBody3D:
            child.name = "StaticBody3D"
            child.set_script(surface)
            child.surfaceType = 5
    wood = false

func ExecuteMetalCollider(_value: bool) -> void :
    create_trimesh_collision()

    for child in get_children():
        if child is StaticBody3D:
            child.name = "StaticBody3D"
            child.set_script(surface)
            child.surfaceType = 6
    metal = false

func ExecuteConcreteCollider(_value: bool) -> void :
    create_trimesh_collision()

    for child in get_children():
        if child is StaticBody3D:
            child.name = "StaticBody3D"
            child.set_script(surface)
            child.surfaceType = 7
    concrete = false



func ExecutePlaceProbe(_value: bool) -> void :
    var probeInstance: ReflectionProbe = probe.instantiate()

    add_child(probeInstance, true)
    probeInstance.set_owner(get_tree().edited_scene_root);
    probeInstance.name = "Probe_" + name

    probeInstance.position = get_aabb().get_center()
    probeInstance.size = get_aabb().size

    probeInstance.size.x += 0.1
    probeInstance.size.y += 0.1
    probeInstance.size.z += 0.1

    placeProbe = false

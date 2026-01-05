@tool
extends Node3D

@export var targets: Array[MeshInstance3D]

const probe = preload("res://Resources/Probe.tscn")

@export var place: bool = false:
    set = ExecutePlaceProbes

@export var reset: bool = false:
    set = ExecuteResetProbes

func ExecutePlaceProbes(_value: bool) -> void :
    ExecuteResetProbes(true)

    for target: MeshInstance3D in targets:
        var probeInstance: ReflectionProbe = probe.instantiate()

        add_child(probeInstance, true)
        probeInstance.set_owner(get_tree().edited_scene_root);
        probeInstance.name = "Probe"

        probeInstance.position = target.get_aabb().get_center()
        probeInstance.size = target.get_aabb().size

        probeInstance.size.x -= 0.05
        probeInstance.size.y -= 0.05
        probeInstance.size.z -= 0.05





    place = false

func ExecuteResetProbes(_value: bool) -> void :
    var childCount = get_child_count()

    if childCount != 0:
        for child in get_children():
            remove_child(child)
            child.queue_free()

    reset = false

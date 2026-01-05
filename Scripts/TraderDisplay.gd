extends Node3D

func _ready() -> void :
    for child in get_children():

        if child is Pickup:
            child.collision.disabled = true
            child.Freeze()

        if child is LootContainer:
            child.locked = true

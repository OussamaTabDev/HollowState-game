extends Node3D

var controller

func _ready():
    controller = get_tree().current_scene.get_node("/root/Map/Core/Controller")

func _physics_process(_delta):
    if controller != null:
        if controller.global_position.y < -10:
            controller.global_transform = global_transform

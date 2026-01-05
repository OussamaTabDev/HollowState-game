extends Node3D

var target

func _ready():
    target = get_tree().current_scene.get_node("/root/Map/Core/Controller")

func _physics_process(_delta):
    global_position = target.global_position

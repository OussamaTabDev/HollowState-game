extends Node3D


var gameData = preload("res://Resources/GameData.tres")

@export var camera: Node3D

func _physics_process(delta):
    camera.global_transform = global_transform

    if gameData.zoomLevel == 3:
        camera.fov = lerp(camera.fov, gameData.scopeFOV, delta * 10)
    elif gameData.zoomLevel == 2:
        camera.fov = lerp(camera.fov, gameData.scopeFOV * 2.5, delta * 10)
    elif gameData.zoomLevel == 1:
        camera.fov = lerp(camera.fov, gameData.baseFOV, delta * 10)

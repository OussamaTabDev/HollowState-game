extends MeshInstance3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")

@export var shadowDistance = 40.0
var processCycle: float = 1.0
var processTimer: float = 0.0

func _physics_process(delta: float) -> void :

    processTimer += delta

    if processTimer > processTimer:
        var distance = gameData.cameraPosition.distance_to(global_position)

        if distance > shadowDistance:
            cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        else:
            cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

        processTimer = 0.0

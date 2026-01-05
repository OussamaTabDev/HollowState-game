extends Area3D


var gameData = preload("res://Resources/GameData.tres")

var sensorTimer = 0.0
var sensorCycle = 0.2
var indoorValue = 0.0


@onready var character = $"../Character"
var world

func _ready() -> void :
    world = get_tree().current_scene.get_node("/root/Map/World")

func _physics_process(delta):
    if gameData.isCaching:
        return

    Indoor(delta)
    sensorTimer += delta

    if sensorTimer > sensorCycle:
        Detect()
        sensorTimer = 0.0

func Detect():
    var overlaps = get_overlapping_areas()
    if not world:
        return
    if overlaps.size() > 0:
        for overlap in overlaps:
            if overlap is Area:

                if overlap.type == "Indoor":
                    gameData.indoor = true
                    world.thunderBlock = true
                else:
                    gameData.indoor = false
                    world.thunderBlock = false

                if overlap.type == "Mine" && !gameData.isFlying:
                    if !overlap.owner.isDetonated:
                        overlap.owner.Detonate()

                if overlap.type == "Fire":
                    gameData.isBurning = true
                    if !gameData.burn:
                        character.Burn(true)
                else:
                    gameData.isBurning = false

                if overlap.type == "Heat":
                    gameData.heat = true
                else:
                    gameData.heat = false

    else:
        gameData.indoor = false
        gameData.isBurning = false
        gameData.heat = false
        world.thunderBlock = false

func Indoor(delta):
    if gameData.indoor:
        indoorValue = move_toward(indoorValue, 1.0, delta)
    else:
        indoorValue = move_toward(indoorValue, 0.0, delta)

    RenderingServer.global_shader_parameter_set("Indoor", indoorValue)

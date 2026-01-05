extends Node


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var compile = true


var cache = preload("res://Resources/Cache.tscn")


@onready var camera = $"../../Camera"
@onready var controller = $"../../Controller"
@onready var settings = $"../../UI/Settings"
@onready var UIManager = $"../../UI"

var scanPhase = 0
var shaderCache

func _ready():
    if compile:
        CreateCache()
        gameData.isCaching = true
        camera.global_position = Vector3(0, 2, 0)
        print("Cache: Start")
    else:
        Loader.FadeOutLoading()
        gameData.isCaching = false
        camera.global_position = Vector3(0, 2, 0)
        Spawn()

func _physics_process(delta):
    if gameData.isCaching:
        camera.rotation_degrees.y += delta * 250.0

        if camera.rotation_degrees.y >= 360 && scanPhase == 0:
            camera.global_position = Vector3(0, 2, 100)
            scanPhase = 1

        if camera.rotation_degrees.y >= 360 && scanPhase == 1:
            camera.global_position = Vector3(0, 2, 0)
            scanPhase = 2

        if camera.rotation_degrees.y >= 360 && scanPhase == 2:
            camera.global_position = Vector3(0, 2, -100)
            scanPhase = 3

        if camera.rotation_degrees.y >= 360 && scanPhase == 3:
            CacheReady()

func CreateCache():
    shaderCache = cache.instantiate()
    camera.add_child(shaderCache)
    shaderCache.transform.origin.z -= 2.0

func CacheReady():
    gameData.isCaching = false
    print("Cache: Ready")
    Loader.FadeOutLoading()
    ClearCache()
    Spawn()

func ClearCache():
    camera.remove_child(shaderCache)
    shaderCache.HideDecals()
    shaderCache.queue_free()

func Spawn():
    var spawnTarget: String
    var spawnPoint: Node3D
    var map = get_tree().current_scene.get_node("/root/Map")
    var transitions = get_tree().get_nodes_in_group("Transition")
    if not map or not transitions:
        return

    controller.global_position = Vector3(0, 2, 0)


    if map.mapName == "Tutorial":
        Simulation.simulate = false
        controller.global_position = Vector3(0, 3, 14)

    elif map.mapName == "Cabin":
        Loader.LoadWorld()
        Loader.LoadCharacter()
        Loader.LoadShelter("Cabin")
        Simulation.simulate = true
        spawnTarget = "Door_Cabin_Exit"

    elif map.mapName == "Village":
        if gameData.previousMap == "Cabin":
            Loader.LoadWorld()
            Loader.LoadCharacter()
            Simulation.simulate = true
            spawnTarget = "Door_Cabin_Enter"
        elif gameData.previousMap == "Minefield":
            Loader.LoadWorld()
            Loader.LoadCharacter()
            Simulation.simulate = true
            spawnTarget = "Transition_Minefield"

    elif map.mapName == "Minefield":
        if gameData.previousMap == "Village":
            Loader.LoadWorld()
            Loader.LoadCharacter()
            Simulation.simulate = true
            spawnTarget = "Transition_Village"
        elif gameData.previousMap == "Apartments":
            Loader.LoadWorld()
            Loader.LoadCharacter()
            Simulation.simulate = true
            spawnTarget = "Transition_Apartments"

    elif map.mapName == "Apartments":
        if gameData.previousMap == "Minefield":
            Loader.LoadWorld()
            Loader.LoadCharacter()
            Simulation.simulate = true
            spawnTarget = "Transition_Minefield"


    if spawnTarget != "":
        for transition in transitions:
            if transition.owner.name == spawnTarget:

                spawnPoint = transition.owner.spawn

                if spawnPoint:
                    controller.global_transform.basis = spawnPoint.global_transform.basis
                    controller.global_transform.basis = controller.global_transform.basis.rotated(Vector3.UP, deg_to_rad(180))
                    controller.global_position = spawnPoint.global_position

    gameData.isTransitioning = false
    gameData.isOccupied = false
    gameData.freeze = false
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


    if gameData.permadeath:

        await get_tree().create_timer(1.0).timeout;
        PlayVostokEnter()

func PlayVostokEnter():
    var vostokEnter = audioInstance2D.instantiate()
    add_child(vostokEnter)
    vostokEnter.PlayInstance(audioLibrary.vostokEnter)

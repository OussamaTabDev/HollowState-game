extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@onready var masterBus = AudioServer.get_bus_index("Master")
@onready var ambientBus = AudioServer.get_bus_index("Ambient")
@onready var SFXBus = AudioServer.get_bus_index("SFX")
@onready var musicBus = AudioServer.get_bus_index("Music")

@onready var info = $Info
@onready var world
@onready var camera

var infoToggle = false
var seasonToggle = false
var DOFToggle = false
var mainMenu = false

func _ready():
    if gameData.flycam:
        show()
        world = get_tree().current_scene.get_node("/root/Map/World")
        camera = get_tree().current_scene.get_node("/root/Map/Core/Camera")

        gameData.season = 1
        gameData.TOD = 2
        gameData.weather = 1
        world.ExecuteUltraRendering(true)
        world.ExecuteUltraLighting(true)
        world.ExecuteSummer(true)
        world.ExecuteDayNeutral(true)
        world.UpdateAmbientSFX()

        camera.attribute.dof_blur_far_enabled = false
        camera.attribute.dof_blur_near_enabled = false

        AudioServer.set_bus_volume_db(masterBus, linear_to_db(1))
        AudioServer.set_bus_volume_db(ambientBus, linear_to_db(1))
        AudioServer.set_bus_volume_db(SFXBus, linear_to_db(1))
        AudioServer.set_bus_mute(musicBus, true)
    else:
        hide()

func _input(event):
    if !gameData.flycam:
        return


    if event.is_action_pressed("flycam_info"):
        infoToggle = !infoToggle

        if infoToggle:
            info.hide()
            PlayClick()
        else:
            info.show()
            PlayClick()


    if event.is_action_pressed("flycam_season"):
        seasonToggle = !seasonToggle

        if seasonToggle:
            gameData.season = 2
            world.ExecuteWinter(true)
            world.UpdateAmbientSFX()
        else:
            gameData.season = 1
            world.ExecuteSummer(true)
            world.UpdateAmbientSFX()


    if event.is_action_pressed("flycam_dawn_neutral"):
        gameData.TOD = 1
        gameData.weather = 1
        world.ExecuteDawnNeutral(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_day_neutral"):
        gameData.TOD = 2
        gameData.weather = 1
        world.ExecuteDayNeutral(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_dusk_neutral"):
        gameData.TOD = 3
        gameData.weather = 1
        world.ExecuteDuskNeutral(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_night_neutral"):
        gameData.TOD = 4
        gameData.weather = 1
        world.ExecuteNightNeutral(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_dawn_dark"):
        gameData.TOD = 1
        gameData.weather = 2
        world.ExecuteDawnDark(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_day_dark"):
        gameData.TOD = 2
        gameData.weather = 2
        world.ExecuteDayDark(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_dusk_dark"):
        gameData.TOD = 3
        gameData.weather = 2
        world.ExecuteDuskDark(true)
        world.UpdateAmbientSFX()
    if event.is_action_pressed("flycam_night_dark"):
        gameData.TOD = 4
        gameData.weather = 2
        world.ExecuteNightDark(true)
        world.UpdateAmbientSFX()


    if event.is_action_pressed("flycam_dof"):
        DOFToggle = !DOFToggle

        if DOFToggle:
            camera.attribute.dof_blur_amount = 0.1
            camera.attribute.dof_blur_far_distance = 5.0
            camera.attribute.dof_blur_far_transition = 5.0
            camera.attribute.dof_blur_far_enabled = true
            camera.attribute.dof_blur_near_enabled = false
        else:
            camera.attribute.dof_blur_amount = 0.0
            camera.attribute.dof_blur_far_distance = 10.0
            camera.attribute.dof_blur_far_transition = 5.0
            camera.attribute.dof_blur_far_enabled = false
            camera.attribute.dof_blur_near_enabled = false


    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                if world.sun.light_energy < 4.0:
                    world.sun.light_energy += 0.1

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                if world.sun.light_energy > 0.0:
                    world.sun.light_energy -= 0.1

    else:

        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                world.sun.rotation_degrees.y += 5

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                world.sun.rotation_degrees.y -= 5


    if event.is_action_pressed("flycam_door"):
        var doors = get_tree().get_nodes_in_group("Door")

        if doors.size() != 0:
            GetClosestDoor().Interact()


    if event.is_action_pressed("flycam_return") && !mainMenu:
        Loader.LoadScene("Menu")
        mainMenu = true
        PlayClick()

func GetClosestDoor() -> Node3D:
    var minimumDistance = 1000
    var closestDoor: Node3D

    var doors = get_tree().get_nodes_in_group("Door")


    for door in doors:

        var distance = camera.global_position.distance_to(door.global_position)


        if distance < minimumDistance:

            minimumDistance = distance

            closestDoor = door

    return closestDoor

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

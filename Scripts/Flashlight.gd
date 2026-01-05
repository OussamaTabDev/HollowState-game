extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var lightWorld = $World
@onready var lightFPS = $FPS


var interface
var lightSlot
var lightData

func _ready():

    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    await get_tree().create_timer(0.1).timeout;
    if not interface: 
        return 
    lightSlot = interface.equipmentUI.get_child(16)
    Deactivate()

func _physics_process(delta):

    if gameData.flashlight:
        if lightSlot.get_child_count() != 0 && lightData:
            Consumption(delta)
            Reactivate()


    if lightSlot:
        ResetCheck()


    if gameData.freeze:
        return


    if Input.is_action_just_pressed(("flashlight")):

        if lightSlot.get_child_count() != 0:

            lightData = lightSlot.get_child(0).slotData.itemData


            if lightSlot.get_child(0).slotData.condition > 0:
                gameData.flashlight = !gameData.flashlight


                if gameData.flashlight:
                    Activate()
                    LightAudio()
                else:
                    Deactivate()
                    LightAudio()

func Activate():

    gameData.flashlight = true


    lightData = lightSlot.get_child(0).slotData.itemData


    if lightData.power == lightData.Power.Low:
        lightWorld.spot_range = 25.0
        lightWorld.light_energy = 10.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 2.0

    elif lightData.power == lightData.Power.Medium:
        lightWorld.spot_range = 50.0
        lightWorld.light_energy = 20.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 3.0

    elif lightData.power == lightData.Power.High:
        lightWorld.spot_range = 100.0
        lightWorld.light_energy = 50.0
        lightFPS.omni_range = 2.0
        lightFPS.light_energy = 4.0


    lightWorld.light_color = lightData.color
    lightFPS.light_color = lightData.color

func Deactivate():

    gameData.flashlight = false
    lightData = null


    lightWorld.spot_range = 0.0
    lightWorld.light_energy = 0.0
    lightFPS.omni_range = 0.0
    lightFPS.light_energy = 0.0

func Reactivate():
    if Engine.get_physics_frames() % 10 == 0:
        if lightSlot.get_child_count() != 0 && lightData:
            Activate()

func Consumption(delta):

    if lightSlot.get_child(0).slotData.condition > 0:

        if lightData.power == lightData.Power.Low:
            lightSlot.get_child(0).slotData.condition -= delta * 0.05

        elif lightData.power == lightData.Power.Medium:
            lightSlot.get_child(0).slotData.condition -= delta * 0.1

        elif lightData.power == lightData.Power.High:
            lightSlot.get_child(0).slotData.condition -= delta * 0.2


        if gameData.interface:
            lightSlot.get_child(0).UpdateDetails()

func ResetCheck():

    if Engine.get_physics_frames() % 10 == 0:

        if gameData.isSubmerged:
            Deactivate()

        elif lightSlot.get_child_count() == 0:
            Deactivate()

        elif lightSlot.get_child_count() != 0:

            if lightSlot.get_child(0).slotData.condition <= 0:
                Deactivate()

func LightAudio():
    var flashlight = audioInstance2D.instantiate()
    add_child(flashlight)
    flashlight.PlayInstance(audioLibrary.flashlight)

func Load():
    if gameData.flashlight:
        Activate()
    else:
        Deactivate()

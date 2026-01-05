extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var overlay = $Overlay


var world
var interface
var NVGSlot
var NVGData
var NVGMaterial

func _ready():

    await get_tree().create_timer(0.1).timeout;
    world = get_tree().current_scene.get_node("/root/Map/World")
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    if not interface:
        return 
    NVGSlot = interface.equipmentUI.get_child(17)
    NVGMaterial = overlay.get_child(0).material
    Deactivate()

func _physics_process(delta):

    if gameData.NVG:
        if NVGSlot.get_child_count() != 0 && NVGData:
            Consumption(delta)
            Reactivate()


    if NVGSlot:
        ResetCheck()


    if gameData.freeze:
        return


    if Input.is_action_just_pressed(("nvg")):

        if NVGSlot.get_child_count() != 0:

            NVGData = NVGSlot.get_child(0).slotData.itemData


            if NVGSlot.get_child(0).slotData.condition > 0:
                gameData.NVG = !gameData.NVG


                if gameData.NVG:
                    Activate()
                    NVGAudio()
                else:
                    Deactivate()
                    NVGAudio()

func Activate():

    gameData.NVG = true
    overlay.show()


    NVGData = NVGSlot.get_child(0).slotData.itemData


    if NVGData.power == NVGData.Power.Low:
        world.environment.environment.tonemap_exposure = 1.0
        world.environment.environment.tonemap_white = 0.2

    elif NVGData.power == NVGData.Power.Medium:
        world.environment.environment.tonemap_exposure = 1.0
        world.environment.environment.tonemap_white = 0.1

    elif NVGData.power == NVGData.Power.High:
        world.environment.environment.tonemap_exposure = 1.0
        world.environment.environment.tonemap_white = 0.05


    NVGMaterial.set_shader_parameter("color", NVGData.color)

func Deactivate():

    gameData.NVG = false
    NVGData = null
    overlay.hide()


    world.environment.environment.tonemap_exposure = 1.0
    world.environment.environment.tonemap_white = 1.0

func Reactivate():
    if Engine.get_physics_frames() % 10 == 0:
        if NVGSlot.get_child_count() != 0 && NVGData:
            Activate()

func Consumption(delta):

    if NVGSlot.get_child(0).slotData.condition > 0:

        if NVGData.power == NVGData.Power.Low:
            NVGSlot.get_child(0).slotData.condition -= delta * 0.05

        elif NVGData.power == NVGData.Power.Medium:
            NVGSlot.get_child(0).slotData.condition -= delta * 0.1

        elif NVGData.power == NVGData.Power.High:
            NVGSlot.get_child(0).slotData.condition -= delta * 0.2


        if gameData.interface:
            NVGSlot.get_child(0).UpdateDetails()

func ResetCheck():

    if Engine.get_physics_frames() % 10 == 0:

        if gameData.isSubmerged || gameData.isSleeping:
            Deactivate()

        elif NVGSlot.get_child_count() == 0:
            Deactivate()

        elif NVGSlot.get_child_count() != 0:

            if NVGSlot.get_child(0).slotData.condition <= 0:
                Deactivate()

func NVGAudio():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.flashlight)

func Load():
    if gameData.NVG:
        Activate()
    else:
        Deactivate()

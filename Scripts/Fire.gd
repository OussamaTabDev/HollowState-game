extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var effect: Node3D
@export var audio: AudioStreamPlayer3D
@export var fireArea: Node3D
@export var heatArea: Node3D

var active = false
var interface
var matchesSlot

func _ready():

    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
    await get_tree().create_timer(0.1).timeout;
    matchesSlot = interface.equipmentUI.get_child(15)


    var roll = randi_range(1, 100)


    if roll <= 5:
        active = true
        Activate()
    else:
        active = false
        Deactivate()

func Interact():

    if !active:
        if MatchCheck():
            Activate()
            IgniteAudio()
            ConsumeMatch()
            active = true

    else:
        Deactivate()
        ExtinguishAudio()
        active = false

func Activate():

    effect.show()


    if audio:
        audio.play()

    if fireArea:
        fireArea.monitorable = true

    if heatArea:
        heatArea.monitorable = true

func Deactivate():

    effect.hide()


    if audio:
        audio.stop()

    if fireArea:
        fireArea.monitorable = false

    if heatArea:
        heatArea.monitorable = false

func UpdateTooltip():

    if !active:
        if MatchCheck():
            gameData.tooltip = "Fire [Ignite]"
        else:
            gameData.tooltip = "Fire [Matches not equipped]"


    elif active:
        gameData.tooltip = "Fire [Extinguish]"

func MatchCheck():

    if matchesSlot.get_child_count() != 0:

        if matchesSlot.get_child(0).slotData.amount > 0:
            return true

    return false

func ConsumeMatch():

    if matchesSlot.get_child_count() != 0:

        if matchesSlot.get_child(0).slotData.amount > 0:

            matchesSlot.get_child(0).slotData.amount -= 1

            if matchesSlot.get_child(0).slotData.amount == 0:
                matchesSlot.get_child(0).queue_free()
                matchesSlot.hint.show()

func IgniteAudio():
    var ignite = audioInstance2D.instantiate()
    add_child(ignite)
    ignite.PlayInstance(audioLibrary.ignite)

func ExtinguishAudio():
    var extinguish = audioInstance2D.instantiate()
    add_child(extinguish)
    extinguish.PlayInstance(audioLibrary.extinguish)

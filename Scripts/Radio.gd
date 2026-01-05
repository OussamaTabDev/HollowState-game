extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var audioClips: Array[AudioStreamWAV]
@export var tuningClips: Array[AudioStreamWAV]
@export var audio: AudioStreamPlayer3D
@export var tuning: AudioStreamPlayer3D
var active = false
var isTuning = false

func _physics_process(_delta):
    if active && !audio.is_playing() && !tuning.is_playing():
        if isTuning:

            audio.stream = GetRandomClip()
            audio.play()
            isTuning = false
        else:

            tuning.stream = GetRandomTuningClip()
            tuning.play()
            isTuning = true

func Interact():
    active = !active

    if active:

        tuning.stream = GetRandomTuningClip()
        tuning.play()
        isTuning = true
    else:
        InteractAudio()
        audio.stop()
        tuning.stop()
        isTuning = false

func GetRandomClip():
    var randomIndex: int = randi_range(0, audioClips.size() - 1)
    return audioClips[randomIndex]

func GetRandomTuningClip():
    var randomIndex: int = randi_range(0, tuningClips.size() - 1)
    return tuningClips[randomIndex]

func UpdateTooltip():
    if active:
        gameData.tooltip = "Radio [Turn Off]"
    else:
        gameData.tooltip = "Radio [Turn On]"

func InteractAudio():
    var interactAudio = audioInstance2D.instantiate()
    add_child(interactAudio)
    interactAudio.PlayInstance(audioLibrary.radio)

extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var isActive = false

func UpdateTooltip():
    if isActive:
        gameData.tooltip = "Computer [No Floppy Disk]"
    else:
        gameData.tooltip = "Computer [No Floppy Disk]"

func Interact():
    ErrorAudio()

func ErrorAudio():
    var error = audioInstance2D.instantiate()
    add_child(error)
    error.PlayInstance(audioLibrary.UIError)

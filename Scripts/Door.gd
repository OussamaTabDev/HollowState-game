extends Node3D
class_name Door


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")

@export var openAngle: Vector3
@export var openOffset: Vector3
@export var audioEvent: AudioEvent
@export var handle: Node3D
@export var randomize = false

var defaultPosition = Vector3.ZERO
var defaultRotation = Vector3.ZERO
var targetRotation = Vector3.ZERO
var openSpeed = 4.0
var isOpen = false


var isOccupied = false
var occupiedTime = 5.0
var occupiedTimer = 0.0


var animationTime = 0.0

func _ready():
    animationTime = 0.0
    defaultPosition = position
    defaultRotation = rotation_degrees

    if randomize:
        var randomRoll = randi_range(0, 5)

        if randomRoll == 0:
            animationTime += 4.0
            isOpen = true

func _physics_process(delta):
    if animationTime > 0:
        animationTime -= delta

        if isOpen:
            position = lerp(position, openOffset + defaultPosition, delta * openSpeed)
            rotation_degrees = lerp(rotation_degrees, openAngle + defaultRotation, delta * openSpeed)
        else:
            position = lerp(position, defaultPosition, delta * openSpeed)
            rotation_degrees = lerp(rotation_degrees, defaultRotation, delta * openSpeed)

    if isOccupied:
        occupiedTimer += delta

        if occupiedTimer > occupiedTime:
            occupiedTimer = 0.0
            isOccupied = false

func Interact():
    animationTime += 4.0

    if isOccupied:
        return

    isOpen = !isOpen
    DoorAudio()

func UpdateTooltip():
    if isOccupied:
        gameData.tooltip = "Door [Occupied]"
    else:
        if isOpen && !isOccupied:
            gameData.tooltip = "Door [Close]"
        else:
            gameData.tooltip = "Door [Open]"

func DoorAudio():
    var audio = audioInstance3D.instantiate()
    handle.add_child(audio)
    audio.PlayInstance(audioEvent, 5, 50)

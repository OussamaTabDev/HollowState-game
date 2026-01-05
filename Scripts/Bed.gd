extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


const message = preload("res://UI/Elements/Message.tscn")


var sleepTime = 0
var canSleep = true

func _ready() -> void :

    canSleep = true
    sleepTime = randi_range(4, 8)

func Interact():
    if canSleep:

        Simulation.simulate = false
        gameData.isSleeping = true
        gameData.freeze = true


        UpdateSimulation(sleepTime * 100)
        PlayTransition()
        PlaySleep()


        await get_tree().create_timer(sleepTime, false).timeout;


        var controller = get_tree().current_scene.get_node("/root/Map/Core/Controller")
        controller.global_transform.basis = controller.global_transform.basis.rotated(Vector3.UP, deg_to_rad(180))


        var newMessage = message.instantiate()
        get_tree().get_root().add_child(newMessage)
        newMessage.Text("You slept " + str(sleepTime) + " hours")


        Simulation.simulate = true
        gameData.isSleeping = false
        gameData.freeze = false
        canSleep = false

func UpdateTooltip():
    if canSleep:
        gameData.tooltip = "Sleep (Random sleep: 4-8h)"
    else:
        gameData.tooltip = ""

func UpdateSimulation(sleepTime):

    var currentTime = Simulation.time
    var combinedTime = currentTime + sleepTime
    var wakeTime: float


    if combinedTime >= 2400.0:
        wakeTime = combinedTime - 2400.0
        Simulation.day += 1
        Simulation.time = wakeTime
        Simulation.weatherTime -= sleepTime
        Loader.UpdateProgression()

    else:
        wakeTime = combinedTime
        Simulation.time = wakeTime
        Simulation.weatherTime -= sleepTime

    print("Current time: " + str(int(currentTime)) + " Sleep time: " + str(int(sleepTime)) + " Wake time: " + str(int(wakeTime)))

func PlayTransition():
    var transition = audioInstance2D.instantiate()
    add_child(transition)
    transition.PlayInstance(audioLibrary.transition)

func PlaySleep():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.sleep)

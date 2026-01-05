extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@export var spawn: Node3D
@export var time: float
@export var energy: float
@export var hydration: float
@export var hint: String
@export var nextMap: String
@export var nextZone: String
@export var currentMap: String
@export var shelterEnter: bool
@export var shelterExit: bool
@export var tutorialExit: bool

func _ready():
    if spawn:
        spawn.hide()

func Interact():

    Simulation.simulate = false

    if tutorialExit:
        Loader.LoadScene(nextMap)
    else:

        UpdateSimulation()


        gameData.currentMap = nextMap
        gameData.previousMap = currentMap
        gameData.energy -= energy
        gameData.hydration -= hydration


        Loader.LoadScene(nextMap)
        Loader.SaveCharacter()
        Loader.SaveWorld()

        if shelterExit:
            Loader.SaveShelter(currentMap)

func UpdateSimulation():

    var travelTime = time * 100.0
    var currentTime = Simulation.time
    var combinedTime = currentTime + travelTime
    var arrivalTime: float


    if combinedTime >= 2400.0:
        arrivalTime = combinedTime - 2400.0
        Simulation.day += 1
        Simulation.time = arrivalTime
        Simulation.weatherTime -= travelTime
        Loader.UpdateProgression()

    else:
        arrivalTime = combinedTime
        Simulation.time = arrivalTime
        Simulation.weatherTime -= travelTime

    print("Transition: " + nextMap)
    print("Current time: " + str(int(currentTime)) + " Travel time: " + str(int(travelTime)) + " Arrival time: " + str(int(arrivalTime)))

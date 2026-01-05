extends Control


var gameData = preload("res://Resources/GameData.tres")


@onready var map = $Info / Map
@onready var FPS = $Info / FPS
@onready var frames = $Info / FPS / Frames
@onready var tooltip = $Tooltip
@onready var label = $Tooltip / Label
@onready var permadeath = $Permadeath
@onready var decor = $Decor
@onready var placement = $Placement
@onready var magazine = $Magazine
@onready var chamber = $Chamber
@onready var stats = $Stats
@onready var vitals = $Stats / Vitals
@onready var medical = $Stats / Medical
@onready var oxygen = $Stats / Oxygen


@onready var transition = $Transition
@onready var destination = $Transition / Elements / Header / Destination
@onready var zone = $Transition / Elements / Header / Zone
@onready var cost = $Transition / Elements / Cost
@onready var timeCost = $Transition / Elements / Cost / Time / Value
@onready var energyCost = $Transition / Elements / Cost / Energy / Value
@onready var hydrationCost = $Transition / Elements / Cost / Hydration / Value
@onready var details = $Transition / Elements / Details
@onready var detailsHint = $Transition / Elements / Details / Hint


var showDecor = true
var showPlacement = true


var currentMap

func _ready():

    tooltip.hide()


    label.text = str(gameData.tooltip)


    var currentMap = get_tree().current_scene.get_node("/root/Map")


    if currentMap:
        if gameData.tutorial:
            map.text = str(currentMap.mapName)
        else:
            map.text = str(currentMap.mapName + " (" + currentMap.mapType + ")")

func _physics_process(_delta):
    if Engine.get_physics_frames() % 10 == 0 && !gameData.isTransitioning:

        if FPS.visible:
            frames.text = str(Engine.get_frames_per_second())


        if gameData.interaction && !gameData.transition:
            tooltip.show()
            label.text = str(gameData.tooltip)
        else:
            tooltip.hide()


        if gameData.transition && !gameData.interaction && !gameData.isPlacing && !gameData.isInserting:
            transition.show()
        else:
            transition.hide()


        if gameData.isSwimming:
            oxygen.show()
        else:
            oxygen.hide()


        if gameData.permadeath || gameData.difficulty == 3:
            permadeath.show()
        else:
            permadeath.hide()


        if gameData.decor:
            if showDecor || gameData.tutorial:
                decor.show()
                stats.hide()
        else:
            decor.hide()
            stats.show()


        if !gameData.decor && gameData.isPlacing:
            if showPlacement || gameData.tutorial:
                placement.show()
                stats.hide()
        elif !gameData.decor:
            placement.hide()
            stats.show()



func Transition(nextMap, nextZone, time, energy, hydration, hint):

    destination.text = nextMap
    zone.text = nextZone


    if time != 0 || energy != 0 || hydration != 0:
        cost.show()
        timeCost.text = "+" + str(int(time)) + "h"
        energyCost.text = "-" + str(int(energy))
        hydrationCost.text = "-" + str(int(hydration))
    else:
        cost.hide()


    if hint != "":
        details.show()
        detailsHint.text = hint

        if nextZone == "Vostok":
            detailsHint.modulate = Color.RED
        else:
            detailsHint.modulate = Color.GREEN
    else:
        details.hide()



func ShowMap(state: bool):
    if state:
        map.show()
    else:
        map.hide()

func ShowFPS(state: bool):
    if state:
        FPS.show()
    else:
        FPS.hide()

func ShowVitals(state: bool):
    if state:
        vitals.show()
    else:
        vitals.hide()

func ShowMedical(state: bool):
    if state:
        medical.show()
    else:
        medical.hide()

func ShowPlacement(state: bool):
    if state:
        showPlacement = true
    else:
        showPlacement = false

func ShowDecor(state: bool):
    if state:
        showDecor = true
    else:
        showDecor = false

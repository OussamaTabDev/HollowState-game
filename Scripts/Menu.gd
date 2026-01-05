extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var main = $Main
@onready var modes = $Modes
@onready var roadmap = $Roadmap
@onready var settings = $Settings
@onready var tools = $Tools
@onready var patches = $Patches
@onready var about = $About
@onready var flycam = $Flycam


@onready var music = $Audio
@onready var musicOffButton = $Music / Buttons / Music_Off
@onready var musicOnButton = $Music / Buttons / Music_On


@onready var override = $Override
@onready var forceSummer = $Override / Buttons / Force_Summer
@onready var forceWinter = $Override / Buttons / Force_Winter


@onready var newButton = $Main / Buttons / New
@onready var loadButton = $Main / Buttons / Load
@onready var tutorialButton = $Main / Buttons / Tutorial
@onready var patchesButton = $Main / Buttons / Patches
@onready var settingsButton = $Main / Buttons / Settings
@onready var toolsButton = $Main / Buttons / Tools
@onready var quitButton = $Main / Buttons / Quit



@onready var standard: Panel = $Modes / Difficulty / Standard
@onready var darkness: Panel = $Modes / Difficulty / Darkness
@onready var ironman: Panel = $Modes / Difficulty / Ironman
@onready var dynamic: Panel = $Modes / Season / Dynamic
@onready var summer: Panel = $Modes / Season / Summer
@onready var winter: Panel = $Modes / Season / Winter


@onready var blocker = $Blocker


@onready var SNF = $SNF

func _ready():

    get_tree().paused = false


    Engine.max_fps = 120


    Simulation.simulate = false


    gameData.Reset()
    gameData.menu = true


    Loader.FadeOut()
    Loader.ShowCursor()


    if !Loader.ValidateVersion():
        Loader.FormatAll()
        Loader.CreateVersion()
        tutorialButton.modulate = Color.GREEN
    else:
        tutorialButton.modulate = Color.WHITE


    if !Loader.ValidateShelter():
        loadButton.disabled = true
        override.hide()
    else:
        loadButton.disabled = false


        if Loader.CurrentSeason() == 1:
            override.show()
            forceSummer.set_pressed_no_signal(true)
            forceWinter.set_pressed_no_signal(false)
        elif Loader.CurrentSeason() == 2:
            override.show()
            forceSummer.set_pressed_no_signal(false)
            forceWinter.set_pressed_no_signal(true)


    blocker.mouse_filter = MOUSE_FILTER_IGNORE



func _on_new_pressed():
    modes.show()
    main.hide()
    SNF.hide()
    PlayClick()

func _on_load_pressed():
    Loader.LoadScene("Cabin")
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_tutorial_pressed():
    Loader.LoadScene("Tutorial")
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP

func _on_settings_pressed():
    settings.show()
    main.hide()
    SNF.hide()
    PlayClick()

func _on_roadmap_pressed():
    roadmap.show()
    main.hide()
    SNF.hide()
    PlayClick()

func _on_patches_pressed():
    patches.show()
    main.hide()
    SNF.hide()
    PlayClick()

func _on_tools_pressed():
    tools.show()
    main.hide()
    SNF.hide()
    PlayClick()

func _on_about_pressed():
    about.show()
    main.hide()
    SNF.hide()
    PlayClick()

func _on_quit_pressed():
    Loader.Quit()
    PlayClick()


    blocker.mouse_filter = MOUSE_FILTER_STOP



func _on_modes_enter_pressed():

    var difficulty = 1
    var season = 1


    if standard.chosen:
        difficulty = 1
    elif darkness.chosen:
        difficulty = 2
    elif ironman.chosen:
        difficulty = 3


    if summer.chosen:
        season = 1
    elif winter.chosen:
        season = 2
    elif dynamic.chosen:
        season = 3


    Loader.NewGame(difficulty, season)


    if difficulty == 1:
        Loader.LoadScene("Cabin")

    else:
        Loader.LoadSceneRandom()


    blocker.mouse_filter = MOUSE_FILTER_STOP
    PlayClick()



func _on_flycam_pressed():
    main.hide()
    modes.hide()
    patches.hide()
    settings.hide()
    tools.hide()
    flycam.show()
    PlayClick()



func _on_modes_return_pressed():
    main.show()
    modes.hide()
    SNF.show()
    PlayClick()

func _on_settings_return_pressed():
    main.show()
    settings.hide()
    SNF.show()
    PlayClick()

func _on_roadmap_return_pressed():
    main.show()
    roadmap.hide()
    SNF.show()
    PlayClick()

func _on_patches_return_pressed():
    main.show()
    patches.hide()
    SNF.show()
    PlayClick()

func _on_tools_return_pressed():
    main.show()
    tools.hide()
    SNF.show()
    PlayClick()

func _on_about_return_pressed() -> void :
    main.show()
    about.hide()
    SNF.show()
    PlayClick()



func _on_music_on_pressed():
    music.stream_paused = false
    PlayClick()

func _on_music_off_pressed():
    music.stream_paused = true
    PlayClick()



func _on_force_summer_pressed() -> void :
    Loader.ForceSeason(1)
    forceSummer.set_pressed_no_signal(true)
    forceWinter.set_pressed_no_signal(false)
    PlayClick()

func _on_force_winter_pressed() -> void :
    Loader.ForceSeason(2)
    forceSummer.set_pressed_no_signal(false)
    forceWinter.set_pressed_no_signal(true)
    PlayClick()



func PlayClick():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UIClick)

extends ProgressBar


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@onready var timer = $Timer

var interface
var recipe

func Start(targetRecipe, targetInterface):

    recipe = targetRecipe.recipeData

    interface = targetInterface


    interface.isOccupied = true


    timer.wait_time = recipe.time
    timer.start()


    value = 0


    PlayCraftLoop()

func _physics_process(_delta):
    var percentage = ((1 - timer.time_left / recipe.time) * 100)
    value = percentage

func _on_timer_timeout() -> void :
    interface.isOccupied = false
    interface.Completed()
    PlayCraftEnd()
    queue_free()

func PlayCraftLoop():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(recipe.loop)

func PlayCraftEnd():
    var audio = audioInstance2D.instantiate()
    get_tree().get_root().add_child(audio)
    audio.PlayInstance(recipe.end)

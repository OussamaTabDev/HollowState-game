extends Node3D
class_name Trader


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var LT_Master: LootTable = preload("res://Loot/LT_Master.tres")


const message = preload("res://UI/Elements/Message.tscn")

@export var traderData: TraderData
var tasksCompleted: Array[String]
var supply: Array[SlotData]
var tax = 100.0


@onready var animations = $Trader / Animations
@onready var timer = $Timer


var voiceTimer = 0.0
var voiceCycle = 60.0
var activeVoice = null

var UIManager
var interface


var traderBucket: Array[ItemData]

func _ready():

    timer.wait_time = traderData.resupply * 60
    timer.start()


    await get_tree().create_timer(randi_range(0, 4)).timeout;
    animations.play("Trader_Idle")


    UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")
    interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


    FillTraderBucket()
    CreateSupply()

func _physics_process(delta):
    SupplyTimer()
    Voices(delta)

func SupplyTimer():

    if interface && gameData.isTrading:
        var timeLeft = timer.time_left
        var minutes = floor(timeLeft / 60)
        var seconds = int(timeLeft) % 60
        interface.traderResupply.text = "%02d:%02d" % [minutes, seconds]


    if timer.is_stopped():

        CreateSupply()


        if gameData.isTrading:
            interface.Resupply()
            PlayTraderReset()


        timer.start()

func FillTraderBucket():
    if LT_Master.items.size() != 0:
        for item in LT_Master.items:
            if traderData.name == "Generalist" && item.generalist:
                traderBucket.append(item)

func CreateSupply():

    supply.clear()


    for index in 40:
        var newSlotData = SlotData.new()
        var randomPick = randi_range(0, traderBucket.size() - 1)
        newSlotData.itemData = traderBucket[randomPick]


        if newSlotData.itemData.defaultAmount != 0 && newSlotData.itemData.subtype != "Magazine":
            newSlotData.amount = newSlotData.itemData.defaultAmount

        supply.append(newSlotData)

func RemoveFromSupply(item: ItemData):
    for slotData in supply:
        if slotData.itemData.name == item.name:
            supply.erase(slotData)
            break

func Interact():
    UIManager.OpenTrader(self)

func UpdateTooltip():
    gameData.tooltip = str(traderData.name)

func CompleteTask(taskData: TaskData):

    var taskString: String
    taskString = taskData.name


    tasksCompleted.append(taskString)
    PlayTraderTask()


    var newMessage = message.instantiate()
    get_tree().get_root().add_child(newMessage)
    newMessage.Text("Task Completed: " + taskData.name)


    if !gameData.tutorial:
        Loader.SaveTrader(traderData.name)
        Loader.UpdateProgression()

func Voices(delta):

    if !is_instance_valid(activeVoice):
        voiceTimer += delta


        var playerDistance = global_position.distance_to(gameData.playerPosition)


        if voiceTimer > voiceCycle && playerDistance < 20.0:
            PlayTraderRandom()


            voiceCycle = randf_range(30.0, 60.0)
            voiceTimer = 0.0



func PlayTraderStart():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderOpen)

    if !is_instance_valid(activeVoice) && traderData.startVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.startVoices, 10, 100)
        activeVoice = voice

func PlayTraderEnd():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderClose)

    if !is_instance_valid(activeVoice) && traderData.endVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.endVoices, 10, 100)
        activeVoice = voice

func PlayTraderReset():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderReset)

func PlayTraderRandom():
    if !is_instance_valid(activeVoice) && traderData.randomVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.randomVoices, 10, 100)
        activeVoice = voice

func PlayTraderTrade():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderTrade)

    if !is_instance_valid(activeVoice) && traderData.tradeVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.tradeVoices, 10, 100)
        activeVoice = voice

func PlayTraderTask():
    var audio = audioInstance2D.instantiate()
    add_child(audio)
    audio.PlayInstance(audioLibrary.UITraderTask)

    if !is_instance_valid(activeVoice) && traderData.taskVoices:
        var voice = audioInstance3D.instantiate()
        add_child(voice)
        voice.position = Vector3(0, 1.7, 0)
        voice.PlayInstance(traderData.taskVoices, 10, 100)
        activeVoice = voice

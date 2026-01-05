extends Button
class_name Level

var levelData: LevelData
var interface: Interface
var isCompleted: bool

@onready var status = $Status
@onready var tax = $Tax
@onready var locked = $Locked
@onready var completed = $Completed

func Initialize(connectedLevel: LevelData, connectedInterface: Interface):
    levelData = connectedLevel
    interface = connectedInterface
    text = levelData.name
    tax.text = "Trader tax: " + str(levelData.tax) + "%"

func UpdateStatus():

    var levelIndex = levelData.level - 1
    var levelVector = interface.trader.levelProgression[levelIndex]
    var tasksAvailable = levelData.tasks.size()
    var tasksCompleted = levelVector.x


    if IsUnlocked():
        interface.UpdateTraderLevel(levelData.level)
        interface.UpdateTraderTax(levelData.tax)
        locked.hide()
        disabled = false

    else:
        locked.show()
        disabled = false


    if levelVector.y == 1:
        isCompleted = true
        completed.show()

    else:
        isCompleted = false
        completed.hide()


    status.text = "Tasks completed: " + str(tasksCompleted) + "/" + str(tasksAvailable)

func IsUnlocked() -> bool:

    if levelData.level == 1:
        return true


    else:

        var previousLevelIndex = levelData.level - 2
        var previousLevelVector = interface.trader.levelProgression[previousLevelIndex]


        if previousLevelVector.y == 1:
            return true

        else:
            return false

func _on_pressed():
    interface.GenerateTasks(levelData, IsUnlocked())
    interface.UpdateTaskUI()
    interface.ResetDelivery()
    interface.ClickAudio()

extends Panel


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


const item = preload("res://UI/Elements/Item.tscn")

var interface
var recipeData: RecipeData


@onready var fill = $Fill
@onready var recipeName = $Info / Name
@onready var time = $Info / Time
@onready var elements = $Elements
@onready var hint = $Elements / Hint


@onready var shelter = $Info / Proximity / Shelter
@onready var workbench = $Info / Proximity / Workbench
@onready var tester = $Info / Proximity / Tester
@onready var heat = $Info / Proximity / Heat


@onready var inputItems = $Elements / Input / Items
@onready var inputGrid = $Elements / Input / Grid


@onready var outputItems = $Elements / Output / Items
@onready var outputGrid = $Elements / Output / Grid


@onready var showButton = $Info / Show
@onready var inputButton = $Elements / Buttons / Input
@onready var completeButton = $Elements / Buttons / Complete


var transparent = Color8(0, 0, 0, 0)
var selected = Color8(255, 255, 255, 16)
var activeColor = Color8(0, 255, 0, 16)



func Initialize(recipe: RecipeData, source):

    Hidden()


    recipeData = recipe


    recipeName.text = recipeData.name
    var minutes = floor(recipeData.time / 60)
    var seconds = int(recipeData.time) % 60
    time.text = "%02d:%02d" % [minutes, seconds]


    interface = source


    SetProximity()
    UpdateProximity()


    if recipeData.locked:
        showButton.disabled = true
        showButton.text = "Locked"
        return


    if recipeData.output[0].type == "Furniture":
        hint.show()
    else:
        hint.hide()


    inputItems.text = CreateInputString()
    outputItems.text = CreateOutputString()


    for child in inputGrid.get_children():
        child.queue_free()


    for child in outputGrid.get_children():
        child.queue_free()


    for itemData in recipeData.input:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newItem = item.instantiate()
        inputGrid.add_child(newItem)
        newItem.Display(interface, newSlotData)


    for itemData in recipeData.output:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newItem = item.instantiate()
        outputGrid.add_child(newItem)
        newItem.Display(interface, newSlotData)

func CreateInputString() -> String:
    var string = ""
    var inputSize = recipeData.input.size()

    for itemData in recipeData.input:
        string += String(itemData.display)
        inputSize -= 1

        if inputSize > 0:
            string += ", "

    return string

func CreateOutputString() -> String:
    var string = ""
    var outputSize = recipeData.output.size()

    for itemData in recipeData.output:
        string += String(itemData.display)
        outputSize -= 1

        if outputSize > 0:
            string += ", "

    return string



func AddInputItem(itemData: ItemData):

    for child in inputGrid.get_children():

        if !child.inputted:

            if itemData.name == child.slotData.itemData.name:
                child.State("Input")
                CanComplete()
                break

func RemoveInputItem(itemData: ItemData):

    for element in inputGrid.get_children():

        if element.inputted:

            if itemData.name == element.slotData.itemData.name:
                element.State("Display")
                CanComplete()
                break

func ResetInput():

    for element in inputGrid.get_children():

        if element.inputted:
            element.State("Display")


    Default()
    completeButton.disabled = true



func _on_show_toggled(toggled_on):
    if toggled_on:
        Default()
        PlayClick()
    else:
        Hidden()
        PlayClick()

func _on_input_toggled(toggled_on: bool) -> void :
    if toggled_on:
        interface.StartInput(self)
        Selected()
        PlayClick()
    else:
        interface.ResetInput()
        Default()
        PlayClick()

func _on_complete_pressed() -> void :
    interface.Craft()
    Active()
    PlayClick()



func CanInput(itemData):

    for element in inputGrid.get_children():

        if !element.inputted:

            if itemData.name == element.slotData.itemData.name:
                return true

    return false

func CanComplete():
    var itemsInputted = 0
    var itemsNeeded = inputGrid.get_child_count()


    for element in inputGrid.get_children():
        if element.inputted:
            itemsInputted += 1


    if itemsInputted == itemsNeeded:
        completeButton.disabled = false
    else:
        completeButton.disabled = true



func Hidden():

    elements.hide()


    showButton.text = "Show"
    showButton.disabled = false


    inputButton.text = "Start Input"
    inputButton.disabled = false
    inputButton.set_pressed_no_signal(false)


    fill.color = transparent


    custom_minimum_size.y = 40
    size.y = 40

func Default():

    elements.show()


    showButton.text = "Hide"
    showButton.disabled = false


    inputButton.text = "Start Input"
    inputButton.disabled = false
    inputButton.set_pressed_no_signal(false)


    fill.color = transparent


    custom_minimum_size.y = 256
    size.y = 256

func Selected():

    elements.show()


    showButton.text = "Hide"
    showButton.disabled = false


    inputButton.text = "Reset Input"
    inputButton.disabled = false
    inputButton.set_pressed_no_signal(true)


    fill.color = selected


    custom_minimum_size.y = 256
    size.y = 256

func Active():

    elements.show()


    showButton.text = "Hide"
    showButton.disabled = true


    inputButton.text = "Reset Input"
    inputButton.disabled = true
    inputButton.set_pressed_no_signal(false)


    completeButton.disabled = true


    fill.color = activeColor



func SetProximity():

    if recipeData.shelter:
        shelter.show()
    else:
        shelter.hide()

    if recipeData.workbench:
        workbench.show()
    else:
        workbench.hide()

    if recipeData.tester:
        tester.show()
    else:
        tester.hide()

    if recipeData.heat:
        heat.show()
    else:
        heat.hide()

func UpdateProximity():
    if recipeData.shelter:
        if gameData.shelter:
            shelter.modulate = Color8(0, 255, 0, 255)
            inputButton.disabled = false
        else:
            shelter.modulate = Color8(255, 255, 255, 64)
            inputButton.disabled = true

    if recipeData.heat:
        if interface && interface.gameData.heat:
            heat.modulate = Color8(0, 255, 0, 255)
            inputButton.disabled = false
        else:
            heat.modulate = Color8(255, 255, 255, 64)
            inputButton.disabled = true



func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

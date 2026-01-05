extends Control


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@onready var panel = $Panel
@onready var buttons = $Panel / Margin / Buttons

var distance
var interface

var hover = false
var centerPosition: Vector2
var hideDistance = 200

func _ready():
    interface = owner
    hide()

func _physics_process(_delta):
    if visible && interface.visible:
        CalculateDistance()
        GetHover()

func Update(slotData: SlotData):

    for button in buttons.get_children():
        button.hide()



    if interface.contextItem.slotData.itemData.usable:
        var useButton = buttons.get_node("Use")
        useButton.text = interface.contextItem.slotData.itemData.phrase
        useButton.show()



    if !interface.hoverSlot && interface.contextItem.slotData.itemData.slots.size() != 0:
        var equipButton = buttons.get_node("Equip")
        equipButton.show()

    if interface.hoverSlot:
        var unequipButton = buttons.get_node("Unequip")
        unequipButton.show()



    if !gameData.decor:
        var dropButton = buttons.get_node("Drop")
        dropButton.show()



    var placeButton = buttons.get_node("Place")
    placeButton.show()



    if gameData.decor:
        var destroyButton = buttons.get_node("Destroy")
        destroyButton.show()



    if interface.contextItem.slotData.itemData.input.size() != 0:
        var separateButton = buttons.get_node("Separate")
        separateButton.show()



    if interface.contextGrid && interface.container:
        var transferButton = buttons.get_node("Transfer")
        transferButton.show()



    if interface.contextGrid && interface.contextItem.slotData.itemData.subtype == "Magazine" && (interface.contextItem.slotData.amount != 0):
        var unloadButton = buttons.get_node("Unload")
        unloadButton.text = "Unload"
        unloadButton.show()

    if interface.contextGrid && interface.contextItem.slotData.itemData.type == "Weapon":
        if interface.contextItem.slotData.itemData.weaponAction == "Manual":
            if interface.contextItem.slotData.amount != 0 || interface.contextItem.slotData.chamber:
                var unloadButton = buttons.get_node("Unload")
                unloadButton.text = "Unload"
                unloadButton.show()

    if interface.contextGrid && interface.contextItem.slotData.itemData.type == "Weapon":
        if interface.contextItem.slotData.itemData.weaponAction != "Manual":
            if interface.contextItem.slotData.amount == 0 && interface.contextItem.slotData.chamber:
                var unloadButton = buttons.get_node("Unload")
                unloadButton.text = "Clear Chamber"
                unloadButton.show()



    if interface.contextItem.slotData.itemData.stackable && interface.contextItem.slotData.amount > 1:
        var splitButton = buttons.get_node("Split")
        splitButton.show()



    if interface.contextItem.slotData.itemData.stackable && interface.contextItem.slotData.amount > interface.contextItem.slotData.itemData.defaultAmount:
        var takeButton = buttons.get_node("Take")
        takeButton.text = "Take " + "(" + str(interface.contextItem.slotData.itemData.defaultAmount) + ")"
        takeButton.show()



    if slotData.nested.size() != 0:
        var nestedIndex = 0

        for nestedItem in slotData.nested:
            var removeString = "Remove_" + str(nestedIndex)
            var removeButton = buttons.get_node(removeString)
            removeButton.text = "Remove " + "(" + slotData.nested[nestedIndex].display + ")"
            removeButton.show()
            nestedIndex += 1



    if interface.contextItem.slotData.itemData.file == "Sleeping_Bag" || interface.contextItem.slotData.itemData.file == "Mattress_Roll":
        var sleepButton = buttons.get_node("Sleep")
        sleepButton.text = "Sleep"
        sleepButton.show()



    panel.size.y = 0.0
    panel.global_position = get_global_mouse_position() - Vector2(0, panel.size.y)
    centerPosition = get_global_mouse_position() - Vector2( - panel.size.x / 2, panel.size.y / 2)

func _on_use_pressed() -> void :
    if interface.visible:
        interface.ContextUse()

func _on_unload_pressed() -> void :
    if interface.visible:
        interface.ContextUnload()

func _on_take_pressed() -> void :
    if interface.visible:
        interface.ContextTake()

func _on_split_pressed() -> void :
    if interface.visible:
        interface.ContextSplit()

func _on_equip_pressed() -> void :
    if interface.visible:
        interface.ContextEquip()

func _on_unequip_pressed() -> void :
    if interface.visible:
        interface.ContextUnequip()

func _on_drop_pressed() -> void :
    if interface.visible:
        interface.ContextDrop()

func _on_place_pressed() -> void :
    if interface.visible:
        interface.ContextPlace()

func _on_destroy_pressed() -> void :
    if interface.visible:
        interface.ContextDestroy()

func _on_separate_pressed() -> void :
    if interface.visible:
        interface.ContextSeparate()

func _on_sleep_pressed() -> void :
    if interface.visible:
        interface.ContextSleep()

func _on_transfer_pressed() -> void :
    if interface.visible:
        interface.ContextTransfer()

func _on_remove_0_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(0)

func _on_remove_1_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(1)

func _on_remove_2_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(2)

func _on_remove_3_pressed() -> void :
    if interface.visible:
        interface.ContextRemove(3)

func GetHover():

    if panel.get_global_rect().has_point(get_global_mouse_position()):
        hover = true
    else:
        hover = false

func CalculateDistance():
    distance = centerPosition.distance_to(get_global_mouse_position())

    if distance > hideDistance:
        interface.HideContext()
        interface.Reset()

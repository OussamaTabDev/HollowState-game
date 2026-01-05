extends Panel


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

var kitData: KitData
@export var slot: PackedScene

@onready var highlight = $Highlight
@onready var kitName = $Name
@onready var kitValue = $Elements / Value / Value
@onready var weapon = $Elements / Weapon
@onready var itemsGrid = $Elements / Items
@onready var select = $Elements / Select

var normalColor = Color(0.0, 0.0, 0.0, 0.0)
var selectedColor = Color(1.0, 1.0, 1.0, 0.1)
var combinedValue = 0.0

func Initialize(kit: KitData):

    kitData = kit


    kitName.text = kitData.name


    weapon.type = weapon.SlotType.Display
    weapon.SetKitWeapon(kit.weapon)
    combinedValue += kit.weapon.value


    for item in itemsGrid.get_children():
        item.queue_free()


    for itemData in kitData.items:
        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData

        var newSlot = slot.instantiate()
        itemsGrid.add_child(newSlot)

        if itemData.type == "Ammunition":
            newSlotData.ammo = itemData.boxSize

        newSlot.type = newSlot.SlotType.Display
        newSlot.SetSlotData(newSlotData)
        combinedValue += itemData.value


    kitValue.text = str(int(combinedValue)) + "€"

func _on_select_toggled(toggled_on):
    if toggled_on:
        SetInitialItems()
        highlight.color = selectedColor
        select.text = "Selected"
    else:
        PlayClick()
        highlight.color = normalColor
        select.text = "Select"

func SetInitialItems():
    print("INITIALS: " + kitData.name)
    Loader.initials.clear()
    Loader.initials.append(kitData.weapon)

    for item in kitData.items:
        Loader.initials.append(item)

func PlayClick():
    var clickAudio = audioInstance2D.instantiate()
    add_child(clickAudio)
    clickAudio.PlayInstance(audioLibrary.UIClick)

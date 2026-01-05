extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

@onready var group: CanvasGroup = $Group
@onready var character = $Group / Character
@export var equipment: Control
@export var stats: Panel

func _ready() -> void :
    group.hide()

func _on_hide_pressed() -> void :
    group.hide()
    ShowSlots()
    PlayClick()

func _on_show_pressed() -> void :
    group.show()
    group.self_modulate = Color8(255, 255, 255, 255)
    character.self_modulate = Color8(255, 255, 255, 16)
    HideSlots()
    PlayClick()

func _on_transparent_pressed() -> void :
    group.show()
    group.self_modulate = Color8(255, 255, 255, 128)
    character.self_modulate = Color8(255, 255, 255, 32)
    ShowSlots()
    PlayClick()

func _on_dark_pressed() -> void :
    group.show()
    group.self_modulate = Color8(0, 0, 0, 64)
    character.self_modulate = Color8(255, 255, 255, 255)
    ShowSlots()
    PlayClick()

func UpdateLayers(item, equipped):
    for layer in character.get_children():

        if layer.name == item.slotData.itemData.slots[0]:
            if equipped:
                layer.texture = item.slotData.itemData.layer
            else:
                layer.texture = null

func HideSlots():
    stats.hide()

    for slot in equipment.get_children():
        if slot is Slot:
            slot.hide()
            slot.hint.hide()

func ShowSlots():
    stats.show()

    for slot in equipment.get_children():
        if slot is Slot:
            slot.show()

            if slot.get_child_count() == 0:
                slot.hint.show()

func PlayClick():
    var click = audioInstance2D.instantiate()
    add_child(click)
    click.PlayInstance(audioLibrary.UIClick)

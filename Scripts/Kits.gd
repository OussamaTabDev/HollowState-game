extends Control

@export var kit: PackedScene
@export var kits: Array[KitData]
@onready var kitList = $List

func _ready():

    for child in kitList.get_children():
        kitList.remove_child(child)
        child.queue_free()


    for kitData in kits:
        var newKit = kit.instantiate()
        newKit.name = kitData.name
        kitList.add_child(newKit)
        newKit.Initialize(kitData)


    if kitList.get_child_count() != 0:
        kitList.get_child(0).select.button_pressed = true

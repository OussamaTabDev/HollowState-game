extends Control

@onready var highlight = $Layers / Background
var defaultColor = Color(0.5, 0.5, 0.5, 0.1)
var hoverColor = Color(0.5, 0.5, 0.5, 0.5)
var interface: Interface

func _ready():
    interface = owner
    highlight.modulate = defaultColor

func ResetHighlight():
    highlight.modulate = defaultColor

func _on_trigger_mouse_entered():
    if interface.grabber.grabbedSlotData.itemData && interface.grabber.grabbedSlotData.itemData.equippable:
        highlight.modulate = hoverColor

func _on_trigger_mouse_exited():
    highlight.modulate = defaultColor

func _on_trigger_gui_input(event):
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
        if interface.grabber.grabbedSlotData.itemData && interface.grabber.grabbedSlotData.itemData.equippable:
            interface.CharacterEquip(interface.grabber.grabbedSlotData)
            highlight.modulate = defaultColor

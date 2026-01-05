extends Control

@onready var interface: Control = $".."
@onready var elements: VBoxContainer = $Elements

@onready var itemSize = $Elements / Item_Size
@onready var tetrisSize = $Elements / Tetris_Size

@onready var hoverItem = $Elements / Hover_Item
@onready var hoverSlot = $Elements / Hover_Slot
@onready var hoverGrid = $Elements / Hover_Grid

@onready var gridSwap = $Elements / Grid_Swap
@onready var slotSwap = $Elements / Slot_Swap
@onready var equip = $Elements / Equip
@onready var unequip = $Elements / Unequip
@onready var combine = $Elements / Combine
@onready var combineSwap = $Elements / Combine_Swap
@onready var combineLoad = $Elements / Combine_Load
@onready var combineStack = $Elements / Combine_Stack

func _ready():
    for element in elements.get_children():
        element.hide()

func _physics_process(_delta):

    if interface.hoverGrid:
        tetrisSize.show()
        tetrisSize.text = str(interface.hoverGrid.tetrisSize)
    else:
        tetrisSize.hide()

    if interface.itemDragged:
        itemSize.show()
        itemSize.text = str(interface.itemDragged.size)
    else:
        itemSize.hide()


    if interface.hoverItem:
        hoverItem.show()
    else:
        hoverItem.hide()

    if interface.hoverGrid:
        hoverGrid.show()
    else:
        hoverGrid.hide()

    if interface.hoverSlot:
        hoverSlot.show()
    else:
        hoverSlot.hide()

    if interface.canCombineLoad:
        combineLoad.show()
    else:
        combineLoad.hide()

    if interface.canCombine:
        combine.show()
    else:
        combine.hide()

    if interface.canCombineSwap:
        combineSwap.show()
    else:
        combineSwap.hide()

    if interface.canGridSwap:
        gridSwap.show()
    else:
        gridSwap.hide()

    if interface.canSlotSwap:
        slotSwap.show()
    else:
        slotSwap.hide()

    if interface.canCombineStack:
        combineStack.show()
    else:
        combineStack.hide()

    if interface.canEquip:
        equip.show()
    else:
        equip.hide()

    if interface.canUnequip:
        unequip.show()
    else:
        unequip.hide()

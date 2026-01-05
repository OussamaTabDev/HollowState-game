extends Panel
class_name SlotL


var gameData: Resource = preload("res://Resources/GameData.tres")


@export var slotData: SlotData
enum SlotType{Inventory, Equipment, Loot, Attachment, Supply, Request, Offer, Display}
@export var type = SlotType.Inventory
@export var isActive = false


@onready var icon = $Icon
@onready var highlight = $Highlight
@onready var abbreviation = $Abbreviation
@onready var indicator = $Indicator
@onready var condition = $Condition
@onready var amount = $Amount
@onready var hint = $Hint
@onready var progress = $Progress


var emptyColor = Color(0.0, 0.0, 0.0, 0.0)
var activeColor = Color(1.0, 1.0, 1.0, 0.04)
var hoverColor = Color(1.0, 1.0, 1.0, 0.1)
var normalColor = Color(1.0, 1.0, 1.0, 1.0)
var occupiedColor = Color(1.0, 1.0, 1.0, 0.5)
var stackColor = Color(0.0, 1.0, 0.0, 0.2)
var errorColor = Color(1.0, 0.0, 0.0, 0.2)
var deliverColor = Color(0.0, 1.0, 0.0, 0.2)
var hoverAttachmentColor = Color(1.0, 1.0, 1.0, 0.2)
var activeAttachmentColor = Color(0.0, 1.0, 0.0, 0.2)
var removeAttachmentColor = Color(1.0, 0.0, 0.0, 0.2)


var interface: Interface
var inspect: Inspect


var isBlocked = false
var isCombining = false
var isOccupied = false
var isDelivered = false
var isCrafting = false
var isActiveAttachment = false


var returnSlot: Slot

func _ready():
    indicator.hide()
    condition.hide()
    amount.hide()
    abbreviation.hide()
    hint.hide()
    progress.hide()

func SetSlotData(newSlotData: SlotData):

    isActive = true
    slotData.Update(newSlotData)
    highlight.color = activeColor
    abbreviation.text = slotData.itemData.abbreviation
    abbreviation.show()


    if type == SlotType.Equipment && (slotData.itemData.type == "Weapon" || slotData.itemData.type == "Knife" || slotData.itemData.type == "Instrument"):
        icon.texture = slotData.itemData.weapon
    else:
        icon.texture = slotData.itemData.icon


    UpdateIndicator()


    UpdateCondition()


    if (slotData.itemData.type == "Weapon" && type != SlotType.Display) || slotData.itemData.type == "Ammunition":
        amount.show()
        amount.text = str(slotData.ammo)
    else:
        amount.hide()

func ClearSlotData():
    isActive = false
    slotData.Reset()
    icon.texture = null
    abbreviation.hide()
    condition.hide()
    indicator.hide()
    amount.hide()

func SetKitWeapon(itemData: ItemData):
    highlight.color = Color(0.0, 0.0, 0.0, 0.2)
    condition.show()
    abbreviation.show()
    abbreviation.text = itemData.abbreviation
    icon.texture = itemData.weapon

func ShowHint():
    hint.show()

    if get_index() == 0:
        hint.text = "Primary"
    elif get_index() == 1:
        hint.text = "Secondary"
    elif get_index() == 2:
        hint.text = "Backpack"
    elif get_index() == 3:
        hint.text = "Rig"
    elif get_index() == 4:
        hint.text = "Head"
    elif get_index() == 5:
        hint.text = "Face"
    elif get_index() == 6:
        hint.text = "Torso"
    elif get_index() == 7:
        hint.text = "Legs"
    elif get_index() == 8:
        hint.text = "Hands"
    elif get_index() == 9:
        hint.text = "Feet"
    elif get_index() == 10:
        hint.text = "Belt"
    elif get_index() == 11:
        hint.text = "Light"
    elif get_index() == 12:
        hint.text = "Knife"

func HideHint():
    hint.hide()

func UpdateIndicator():

    if slotData.itemData.type == "Armor":
        indicator.text = slotData.itemData.rating
        indicator.show()

    elif slotData.itemData.type == "Equipment" && slotData.itemData.carrier && slotData.armor:
        indicator.text = slotData.armor.rating
        indicator.show()

    elif slotData.itemData.type == "Equipment" && slotData.itemData.helmet:
        indicator.text = slotData.itemData.rating
        indicator.show()

    elif slotData.itemData.type == "Weapon" && (slotData.muzzle || slotData.optic):
        indicator.text = "M"
        indicator.show()
    else:
        indicator.hide()

func UpdateCondition():

    if slotData.itemData.type == "Knife":
        condition.show()

    elif slotData.itemData.type == "Armor":
        condition.show()

    elif slotData.itemData.type == "Equipment" && slotData.itemData.carrier && slotData.armor:
        condition.show()

    elif slotData.itemData.type == "Equipment" && slotData.itemData.helmet:
        condition.show()

    elif slotData.itemData.type == "Weapon":
        condition.show()
    else:
        condition.hide()


    if condition.visible:
        if slotData.condition <= 25:
            condition.add_theme_color_override("font_color", Color.RED)
        elif slotData.condition <= 50 && slotData.condition > 25:
            condition.add_theme_color_override("font_color", Color.YELLOW)
        else:
            condition.add_theme_color_override("font_color", Color.GREEN)

        condition.text = str(slotData.condition) + "%"

func UpdateArmorIcon():

    if slotData.armor:
        indicator.show()
        condition.show()
    else:
        indicator.hide()
        condition.hide()

func UpdateModdedIcon():

    if slotData.muzzle || slotData.optic:
        indicator.show()
    else:
        indicator.hide()

func UpdateAmmo():
    amount.text = str(slotData.ammo)

func Occupied():
    isOccupied = true
    gameData.isOccupied = true
    icon.modulate = occupiedColor
    progress.show()
    highlight.color = emptyColor

func Deliver():
    isDelivered = true
    highlight.color = deliverColor

func Craft():
    isCrafting = true
    highlight.color = deliverColor

func ResetDelivery():
    isDelivered = false
    ResetHighlight()

func ResetCrafting():
    isCrafting = false
    ResetHighlight()

func ResetOccupied():
    isOccupied = false
    gameData.isOccupied = false
    icon.modulate = normalColor
    progress.hide()

    if isActive:
        highlight.color = activeColor
    else:
        highlight.color = emptyColor

func ResetHighlight():
    if isActive:
        highlight.color = activeColor
    else:
        highlight.color = emptyColor

func HoverHighlight():
    highlight.color = hoverColor

func CalculateValue() -> int:

    if slotData.itemData.type == "Ammunition":
        var percentage = float(slotData.ammo) / float(slotData.itemData.boxSize)
        return int(slotData.itemData.value * percentage)

    elif slotData.itemData.type == "Armor":
        return int(slotData.itemData.value * (slotData.condition * 0.01))

    elif slotData.itemData.type == "Equipment" && slotData.armor:
        return int(slotData.itemData.value + (slotData.armor.value * (slotData.condition * 0.01)))

    else:
        return int(slotData.itemData.value * (slotData.condition * 0.01))

func CalculateWeight() -> float:

    if slotData.itemData.type == "Ammunition":
        var percentage = float(slotData.ammo) / float(slotData.itemData.boxSize)
        return float(snappedf(slotData.itemData.weight * percentage, 0.01))

    if slotData.itemData.type == "Equipment" && slotData.armor:
        return float(snappedf(slotData.itemData.weight + slotData.armor.weight, 0.01))

    else:
        return float(snappedf(slotData.itemData.weight, 0.01))

func ConnectInterface(targetInterface: Interface):
    interface = targetInterface

func ConnectInspect(targetInspect: Inspect):
    inspect = targetInspect

func SetActiveAttachment():
    isActiveAttachment = true
    highlight.color = activeAttachmentColor

func SetAvailableAttachment():
    isActiveAttachment = false
    highlight.color = emptyColor

func CombineCheck() -> bool:

    if interface.grabber.grabbedSlotData.itemData.type == "Armor" && slotData.itemData.type == "Equipment":

        if slotData.itemData.index == 3 && slotData.itemData.carrier && !slotData.armor:
            return true

        elif slotData.itemData.index == 3 && slotData.itemData.carrier && slotData.armor:
            isBlocked = true
            return false

        elif slotData.itemData.index == 3 && !slotData.itemData.carrier:
            isBlocked = true
            return false
        else:
            return false


    if interface.grabber.grabbedSlotData.itemData.type == "Ammunition" && slotData.itemData.type == "Ammunition":

        if interface.grabber.grabbedSlotData.itemData.file == slotData.itemData.file:

            var combinedAmmo = slotData.ammo + interface.grabber.grabbedSlotData.ammo

            if combinedAmmo <= slotData.itemData.maxStack:
                return true
            else:
                isBlocked = true
                return false

    return false

func Combine():

    if interface.grabber.grabbedSlotData.itemData.type == "Armor" && slotData.itemData.carrier:
        interface.ArmorLoad(self)


    elif interface.grabber.grabbedSlotData.itemData.type == "Ammunition" && slotData.itemData.type == "Ammunition":
        interface.AmmoStack(self)

func _on_mouse_entered():
    if gameData.isOccupied || (gameData.interface && interface.actions.visible):
        return


    if isActive && gameData.interface && !interface.grabber.visible:
        interface.UpdateTooltip(slotData)

        if interface.tooltipMode == 1:
            interface.hovering = true


    isCombining = false
    isBlocked = false


    if type == SlotType.Inventory || type == SlotType.Equipment || type == SlotType.Loot:
        if interface.grabber.visible && isActive:
            if CombineCheck():
                highlight.color = stackColor
                isCombining = true
                return


    if isBlocked:
        highlight.color = errorColor
        return


    if type == SlotType.Inventory || type == SlotType.Loot || type == SlotType.Supply || type == SlotType.Request || type == SlotType.Offer:

        if isActive && !isDelivered && !isCrafting || (interface.grabber.visible && interface.grabber.grabbedSlotData.itemData):
            highlight.color = hoverColor


    elif type == SlotType.Equipment:

        if interface.grabber.visible && interface.grabber.grabbedSlotData.itemData.equippable:

            var index = get_index()

            if interface.grabber.grabbedSlotData.itemData.equippable && interface.grabber.grabbedSlotData.itemData.index == index:
                highlight.color = hoverColor

        elif isActive && !isDelivered:
            highlight.color = hoverColor


    elif type == SlotType.Attachment:
        if isActiveAttachment:
            highlight.color = removeAttachmentColor
        else:
            highlight.color = hoverAttachmentColor

func _on_mouse_exited():
    if gameData.isOccupied || (gameData.interface && interface.actions.visible):
        return


    if gameData.interface && !interface.grabber.visible:
        interface.ResetTooltip()

        if interface.tooltipMode == 1:
            interface.tooltip.hide()
            interface.tooltipTimer = 0.0
            interface.hovering = false


    if type == SlotType.Attachment:
        if isActiveAttachment:
            highlight.color = activeAttachmentColor
        else:
            highlight.color = emptyColor
        return


    if !isDelivered && !isCrafting:
        ResetHighlight()

func _on_gui_input(event: InputEvent):
    if type == SlotType.Display || gameData.isOccupied:
        return


    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():


        if type == SlotType.Attachment:
            if isActiveAttachment:
                inspect.DeactivateAttachment(slotData, get_index())
            else:
                inspect.ActivateAttachment(slotData, get_index())
            return


        if isActive && interface.crafting && !isCrafting:
            if interface.RecipeCompatibility(slotData):
                highlight.color = deliverColor
                isCrafting = true
                interface.selectedRecipe.AddRequiresItem(slotData.itemData)
                interface.ClickAudio()
            return


        elif isActive && interface.crafting && isCrafting:
            ResetHighlight()
            isCrafting = false
            interface.selectedRecipe.RemoveRequiresItem(slotData.itemData)
            interface.ClickAudio()
            return


        if isActive && interface.delivery && !isDelivered:
            if interface.DeliverCompatibility(slotData):
                highlight.color = deliverColor
                isDelivered = true
                interface.selectedTask.AddDeliveryItem(slotData.itemData)
                interface.ClickAudio()
            return


        elif isActive && interface.delivery && isDelivered:
            ResetHighlight()
            isDelivered = false
            interface.selectedTask.RemoveDeliveryItem(slotData.itemData)
            interface.ClickAudio()
            return


        if isCombining:
            Combine()
            isCombining = false
            return


        if isBlocked:
            interface.ErrorAudio()
            return

        if type == SlotType.Inventory:
            interface.InventoryLMBClick(slotData, get_index())
        elif type == SlotType.Equipment:
            interface.EquipmentLMBClick(slotData, get_index())
        elif type == SlotType.Loot:
            interface.ContainerLMBClick(slotData, get_index())
        elif type == SlotType.Supply:
            interface.SupplyLMBClick(slotData, get_index())
        elif type == SlotType.Request:
            interface.RequestLMBClick(slotData, get_index())
        elif type == SlotType.Offer:
            interface.OfferLMBClick(slotData, get_index())


    if (type == SlotType.Inventory || type == SlotType.Equipment || type == SlotType.Loot) && !interface.trader && !interface.grabber.visible && isActive:
        if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
            interface.ShowActions(self)
            interface.actionSlot = self

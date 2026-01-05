extends Control
class_name Interface


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")


@onready var craftingUI = $Elements / Crafting
@onready var containerUI = $Elements / Container
@onready var traderUI = $Elements / Trader
@onready var supplyUI = $Elements / Supply
@onready var levelsUI = $Elements / Levels
@onready var tasksUI = $Elements / Tasks
@onready var requestUI = $Elements / Request
@onready var offerUI = $Elements / Offer
@onready var equipmentUI = $Elements / Equipment
@onready var inventoryUI = $Elements / Inventory
@onready var dealUI = $Elements / Deal
@onready var characterUI = $Elements / Character


@onready var armorValue = $Elements / Character / Stats / Armor / Value
@onready var helmetValue = $Elements / Character / Stats / Helmet / Value


@onready var helmet = $Elements / Character / Helmet
@onready var plate = $Elements / Character / Plate
@onready var helmetCondition = $Elements / Character / Helmet / Stats / Condition
@onready var plateCondition = $Elements / Character / Plate / Stats / Condition
@onready var helmetRating = $Elements / Character / Helmet / Stats / Rating
@onready var plateRating = $Elements / Character / Plate / Stats / Rating


@onready var inventoryGrid = $Elements / Inventory / Grid
@onready var containerGrid = $Elements / Container / Grid
@onready var equipmentGrid = $Elements / Equipment / Grid
@onready var supplyGrid = $Elements / Supply / Grid
@onready var requestGrid = $Elements / Request / Grid
@onready var offerGrid = $Elements / Offer / Grid


@onready var taskList = $Elements / Tasks / Panel / Margin / Container / Scroll / List
@onready var levelList = $Elements / Levels / Panel / Margin / Container / Scroll / List


@onready var recipeProgress = $Elements / Crafting / Types / Margin / Progress
@onready var recipeActive = $Elements / Crafting / Types / Margin / Active
@onready var recipeButtons = $Elements / Crafting / Types / Margin / Buttons
@onready var recipeHint = $Elements / Crafting / Hint
@onready var recipeList = $Elements / Crafting / Recipes / Container / Scroll / List
@onready var craftingTime = $Elements / Crafting / Time / Value
@onready var heat = $Elements / Crafting / Proximity / Elements / Heat
@onready var workbench = $Elements / Crafting / Proximity / Elements / Workbench
@onready var tester = $Elements / Crafting / Proximity / Elements / Tester


@onready var containerHeader = $Elements / Container / Header


@onready var camera = $"../../Camera"
@onready var grabber = $Grabber
@onready var preloader = $"../../Tools/Preloader"
@onready var preview = $Elements / Character / Preview
@onready var tooltip = $Tooltip
@onready var actions = $Actions
@onready var weapons = $"../../Camera/Weapons"
@onready var character = $"../../Controller/Character"


@onready var feet = $Elements / Character / Preview / Layers / Feet
@onready var legs = $Elements / Character / Preview / Layers / Legs
@onready var hands = $Elements / Character / Preview / Layers / Hands
@onready var torso = $Elements / Character / Preview / Layers / Torso
@onready var rig = $Elements / Character / Preview / Layers / Rig
@onready var backpack = $Elements / Character / Preview / Layers / Backpack
@onready var head = $Elements / Character / Preview / Layers / Head
@onready var belt = $Elements / Character / Preview / Layers / Belt


@onready var inventoryWeight = $Elements / Inventory / Weight / Value
@onready var inventoryValue = $Elements / Inventory / Value / Value
@onready var containerWeight = $Elements / Container / Weight / Value
@onready var containerValue = $Elements / Container / Value / Value
@onready var equipmentWeight = $Elements / Equipment / Weight / Value
@onready var equipmentValue = $Elements / Equipment / Value / Value
@onready var traderIcon = $Elements / Trader / Icon
@onready var traderName = $Elements / Trader / Stats / Name / Value
@onready var traderLevel = $Elements / Trader / Stats / Level / Value
@onready var traderTax = $Elements / Trader / Stats / Tax / Value
@onready var traderResupply = $Elements / Trader / Stats / Resupply / Value
@onready var supplyResupply = $Elements / Supply / Resupply / Value
@onready var supplyValue = $Elements / Supply / Value / Value
@onready var requestValue = $Elements / Request / Value / Value
@onready var offerValue = $Elements / Offer / Value / Value
@onready var levelsCompleted = $Elements / Levels / Completed / Value
@onready var tasksCompleted = $Elements / Tasks / Completed / Value


@onready var dealSlider = $Elements / Deal / Slider
@onready var resetButton = $Elements / Deal / Buttons / Reset
@onready var tradeButton = $Elements / Deal / Buttons / Trade
@onready var supplyButton = $Elements / Trader / Modes / Supply
@onready var tasksButton = $Elements / Trader / Modes / Tasks
@onready var servicesButton = $Elements / Trader / Modes / Services


@onready var placer = $"../../Camera/Placer"
@onready var UIManager = $".."


@onready var detector = $"../../Controller/Detector"

@export var slot: PackedScene
@export var task: PackedScene
@export var level: PackedScene
@export var recipe: PackedScene
@export var recipes: Recipes

var container: LootContainer
var trader
var traderMode = 1
var actionSlot


var progressTime = 0.0
var progressTimer = 0.0
var progress = preload("res://UI/Effects/MT_Progress.tres")
var unloadSpeed = 4.0
var unloadTimer = 0.0
var unloadAudio = false
var unloading = false


var dropToggle = false
var transferToggle = false
var equipToggle = false


var baseCarryWeight = 10.0
var currentCarryWeight = 0.0
var currentInventoryWeight = 0.0
var currentInventoryValue = 0.0
var currentContainerWeight = 0.0
var currentContainerValue = 0.0
var currentEquipmentWeight = 0.0
var currentEquipmentValue = 0.0
var currentSupplyValue = 0.0
var currentRequestValue = 0.0
var currentOfferValue = 0.0
var inventoryWeightPercentage = 0.0
var containerWeightPercentage = 0.0

var tooltipOffset = 0.0
var actionsOffset = 0.0

var tooltipMode = 1
var hovering = false
var tooltipDelay = 1.0
var tooltipTimer = 0.0

var selectedTask
var selectedRecipe
var activeRecipe
var proximityPickup

var craftingTimer = 0.0

var delivery = false
var crafting = false

func _ready():
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    grabber.hide()
    tooltip.hide()
    actions.hide()
    InitializeGrids()
    CalculateValues(false)
    ResetLayers()

func InitializeGrids():
    for inventorySlot in inventoryGrid.get_children():
        inventorySlot.ConnectInterface(self)
        inventorySlot.type = inventorySlot.SlotType.Inventory

    for equipmentSlot in equipmentGrid.get_children():
        equipmentSlot.ConnectInterface(self)
        equipmentSlot.type = equipmentSlot.SlotType.Equipment
        equipmentSlot.ShowHint()

    for containerSlot in containerGrid.get_children():
        containerSlot.ConnectInterface(self)
        containerSlot.type = containerSlot.SlotType.Loot

    for supplySlot in supplyGrid.get_children():
        supplySlot.ConnectInterface(self)
        supplySlot.type = supplySlot.SlotType.Supply

    for requestSlot in requestGrid.get_children():
        requestSlot.ConnectInterface(self)
        requestSlot.type = requestSlot.SlotType.Request

    for offerSlot in offerGrid.get_children():
        offerSlot.ConnectInterface(self)
        offerSlot.type = offerSlot.SlotType.Offer

func _input(event):
    if gameData.settings:
        return

    if event.is_action_pressed("hover_tooltip") && gameData.interface && tooltipMode == 2:
        tooltip.visible = !tooltip.visible

        if tooltip.visible && actions.visible:
            HideActions()

        ClickAudio()

func _physics_process(_delta):
    if Input.is_action_pressed(("item_drop")):
        dropToggle = true
    else:
        dropToggle = false

    if Input.is_action_pressed(("item_transfer")):
        transferToggle = true
    else:
        transferToggle = false

    if Input.is_action_pressed(("item_equip")):
        equipToggle = true
    else:
        equipToggle = false

    if grabber.visible:
        grabber.global_position = get_global_mouse_position() - Vector2(32, 32)

    if tooltip.visible:
        tooltip.global_position = get_global_mouse_position() - Vector2(0, tooltipOffset)

    if trader:
        var timeLeft = trader.timer.time_left
        var minutes = floor(timeLeft / 60)
        var seconds = int(timeLeft) % 60
        supplyResupply.text = "%02d:%02d" % [minutes, seconds]

        if trader.resupply:
            print("TIMER RESUPPLY")
            GetResupply()

    if activeRecipe:
        craftingTimer -= _delta
        var minutes = floor(craftingTimer / 60)
        var seconds = int(craftingTimer) % 60
        var percentage = ((1 - craftingTimer / activeRecipe.recipeData.time) * 100)

        recipeProgress.value = percentage
        craftingTime.text = "%02d:%02d" % [minutes, seconds]

        if craftingTimer <= 0:
            CraftCompleted()

    if gameData.isOccupied:
        progressTimer += _delta / progressTime
        progress.set_shader_parameter("value", progressTimer)

        if unloading && unloadAudio:
            unloadTimer += _delta * unloadSpeed

            if unloadTimer > 1:
                UnloadAudio()
                unloadTimer = 0


    if tooltipMode == 1:
        if !grabber.visible && !actions.visible:
            if hovering && !tooltip.visible:
                tooltipTimer += _delta

                if tooltipTimer > tooltipDelay:
                    tooltip.global_position = get_global_mouse_position() - Vector2(0, tooltipOffset)
                    tooltip.show()
                    tooltipTimer = 0.0

            elif !hovering && tooltip.visible:
                tooltip.hide()
                tooltipTimer = 0.0
        else:
            tooltip.hide()
            tooltipTimer = 0.0

func CalculateValues(updateLables: bool):

    currentCarryWeight = 0.0
    currentInventoryWeight = 0.0
    currentInventoryValue = 0.0
    currentEquipmentValue = 0.0
    currentContainerWeight = 0.0
    currentContainerValue = 0.0
    currentEquipmentWeight = 0.0
    currentEquipmentValue = 0.0
    currentSupplyValue = 0.0
    currentRequestValue = 0.0
    currentOfferValue = 0.0
    inventoryWeightPercentage = 0.0
    containerWeightPercentage = 0.0



    for equipmentSlot in equipmentGrid.get_children():
        if equipmentSlot.slotData.itemData:
            currentEquipmentWeight += equipmentSlot.CalculateWeight()
            currentEquipmentValue += equipmentSlot.CalculateValue()
            currentCarryWeight += equipmentSlot.slotData.itemData.capacity

    currentCarryWeight += baseCarryWeight
    UpdateArmorStats()



    for inventorySlot in inventoryGrid.get_children():
        if inventorySlot.slotData.itemData:
            currentInventoryWeight += inventorySlot.CalculateWeight()
            currentInventoryValue += inventorySlot.CalculateValue()

    if currentInventoryWeight > currentCarryWeight:
        if !gameData.overweight:
            character.Overweight(true)
    else:
        character.Overweight(false)


    var combinedWeight = currentInventoryWeight + currentEquipmentWeight

    if combinedWeight > 20:
        character.heavyGear = true
    else:
        character.heavyGear = false



    if container:
        for containerSlot in containerGrid.get_children():
            if containerSlot.slotData.itemData:
                currentContainerWeight += containerSlot.CalculateWeight()
                currentContainerValue += containerSlot.CalculateValue()

        containerWeightPercentage = currentContainerWeight / container.capacity



    if trader:
        for traderSlot in supplyGrid.get_children():
            if traderSlot.slotData.itemData:
                currentSupplyValue += int(traderSlot.CalculateValue() * ((trader.tax * 0.01) + 1))

        for requestSlot in requestGrid.get_children():
            if requestSlot.slotData.itemData:
                currentRequestValue += int(requestSlot.CalculateValue() * ((trader.tax * 0.01) + 1))

        for offerSlot in offerGrid.get_children():
            if offerSlot.slotData.itemData:
                currentOfferValue += offerSlot.CalculateValue()


        if currentOfferValue == 0 && currentRequestValue == 0:
            resetButton.disabled = true
            tradeButton.disabled = true
            dealSlider.value = 1.0


        elif currentOfferValue == currentRequestValue:
            resetButton.disabled = false
            tradeButton.disabled = false
            dealSlider.value = 1.0

        else:


            if currentOfferValue != 0 && currentRequestValue == 0:
                tradeButton.disabled = true
                resetButton.disabled = false
                dealSlider.value = 2


            elif currentOfferValue == 0 && currentRequestValue != 0:
                tradeButton.disabled = true
                resetButton.disabled = false
                dealSlider.value = 0


            else:

                if currentOfferValue > currentRequestValue:
                    tradeButton.disabled = false
                    resetButton.disabled = false

                else:
                    tradeButton.disabled = true
                    resetButton.disabled = false

                var dealPercentage = currentOfferValue / currentRequestValue
                dealSlider.value = dealPercentage



    if updateLables:

        equipmentWeight.text = str("%.1f" % currentEquipmentWeight)
        equipmentValue.text = str(currentEquipmentValue)

        inventoryWeightPercentage = currentInventoryWeight / currentCarryWeight
        inventoryWeight.text = str("%.1f" % currentInventoryWeight) + " / " + str("%.1f" % currentCarryWeight)
        inventoryValue.text = str(currentInventoryValue)

        if inventoryWeightPercentage > 1:
            inventoryWeight.add_theme_color_override("font_color", Color.RED)
        elif inventoryWeightPercentage >= 0.5:
            inventoryWeight.add_theme_color_override("font_color", Color.YELLOW)
        else:
            inventoryWeight.add_theme_color_override("font_color", Color.GREEN)

        if container:
            containerWeight.text = str("%.1f" % currentContainerWeight) + " / " + str("%.1f" % container.capacity)
            containerValue.text = str(currentContainerValue)

            if containerWeightPercentage > 1:
                containerWeight.add_theme_color_override("font_color", Color.RED)
            elif containerWeightPercentage >= 0.5:
                containerWeight.add_theme_color_override("font_color", Color.YELLOW)
            else:
                containerWeight.add_theme_color_override("font_color", Color.GREEN)

        if trader:
            supplyValue.text = str(currentSupplyValue)
            requestValue.text = str(currentRequestValue)
            offerValue.text = str(currentOfferValue)



func OpenInterface():
    tooltip.hide()
    actions.hide()

    if container:
        ResetContainerGrid()
        FillContainerGrid()
        containerHeader.text = container.containerName
        inventoryUI.show()
        equipmentUI.show()
        characterUI.show()
        containerUI.show()
        craftingUI.hide()
        traderUI.hide()
        supplyUI.hide()
        requestUI.hide()
        offerUI.hide()
        dealUI.hide()
        levelsUI.hide()
        tasksUI.hide()

    elif trader:
        traderMode = 1
        gameData.isTrading = true
        supplyButton.button_pressed = true
        Loader.LoadTrader(trader.traderData.name)
        UpdateTraderInfo()
        GenerateLevels()
        UpdateTaskUI()
        ResetSupplyGrid()
        FillSupplyGrid()
        inventoryUI.show()
        equipmentUI.show()
        containerUI.hide()
        characterUI.hide()
        craftingUI.hide()
        traderUI.show()
        supplyUI.show()
        requestUI.show()
        offerUI.show()
        dealUI.show()
        levelsUI.hide()
        tasksUI.hide()
        TraderOpenAudio()

    else:
        inventoryUI.show()
        equipmentUI.show()
        characterUI.show()
        containerUI.hide()
        craftingUI.show()
        traderUI.hide()
        supplyUI.hide()
        requestUI.hide()
        offerUI.hide()
        dealUI.hide()
        levelsUI.hide()
        tasksUI.hide()
        UpdateProximity()
        ResetCrafting()

    CalculateValues(true)


    if equipmentGrid.get_child(0).slotData.itemData:
        equipmentGrid.get_child(0).UpdateAmmo()
    if equipmentGrid.get_child(1).slotData.itemData:
        equipmentGrid.get_child(1).UpdateAmmo()

func CloseInterface():
    if grabber.visible && grabber.grabbedSlotData:
        DropAudio()
        QuickDrop(grabber.grabbedSlotData, "Inventory")
        grabber.Reset()
        grabber.hide()

    tooltip.Reset()
    tooltip.hide()
    actions.Hide()
    hovering = false
    ResetAllHighlights()
    ResetCrafting()


    if container:
        container.Storage(containerGrid)
        ResetContainerGrid()
        container.ContainerAudio()
        container = null


    if trader:
        gameData.isTrading = false
        Loader.SaveTrader(trader.traderData.name)
        GetOfferGridItems()
        ResetSupplyGrid()
        ResetRequestGrid()
        ResetOfferGrid()
        TraderCloseAudio()
        ResetDelivery()
        trader = null



func Pickup(newSlotData: SlotData) -> bool:

    for inventorySlot in inventoryGrid.get_children():

        if !inventorySlot.slotData.itemData:
            inventorySlot.SetSlotData(newSlotData)
            CalculateValues(false)
            return true


    ErrorAudio()
    return false



func ResetContainerGrid():
    for containerSlot in containerGrid.get_children():
        containerSlot.ClearSlotData()
        containerSlot.ResetHighlight()

func FillContainerGrid():

    if container.loot.size() != 0:

        for slotData in container.loot:
            var targetSlot = containerGrid.get_child(slotData.index)
            targetSlot.SetSlotData(slotData)



func CharacterEquip(sourceData):
    var targetSlot = equipmentGrid.get_child(sourceData.itemData.index)


    if targetSlot.slotData.itemData:


        if targetSlot.slotData.itemData.index == 0 && gameData.primary:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        if targetSlot.slotData.itemData.index == 1 && gameData.secondary:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        if targetSlot.slotData.itemData.index == 12 && gameData.knife:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        var swapSlotData = SlotData.new()
        swapSlotData.Update(targetSlot.slotData)


        targetSlot.SetSlotData(sourceData)
        targetSlot.HideHint()
        EquipAudio()


        weapons.UpdateClothing()
        UpdateLayer(sourceData.itemData, true)


        grabber.Reset()
        grabber.hide()
        preview.ResetHighlight()


        if InventoryCapacity(false):
            for inventorySlot in inventoryGrid.get_children():

                if !inventorySlot.slotData.itemData:
                    inventorySlot.SetSlotData(swapSlotData)
                    break
        else:
            QuickDrop(swapSlotData, "Inventory")
            DropAudio()


    else:

        targetSlot.SetSlotData(sourceData)
        targetSlot.HideHint()
        EquipAudio()


        weapons.UpdateClothing()
        UpdateLayer(sourceData.itemData, true)


        grabber.Reset()
        grabber.hide()
        preview.ResetHighlight()

    hovering = false
    CalculateValues(true)

func UpdateLayer(itemData: ItemData, equip: bool):

    if itemData.index == 4:
        if equip:
            head.texture = itemData.layer
        else:
            head.texture = null

    if itemData.index == 6:
        if equip:
            torso.texture = itemData.layer
        else:
            torso.texture = null

    if itemData.index == 3:
        if equip:
            rig.texture = itemData.layer
        else:
            rig.texture = null

    if itemData.index == 2:
        if equip:
            backpack.texture = itemData.layer
        else:
            backpack.texture = null

    if itemData.index == 7:
        if equip:
            legs.texture = itemData.layer
        else:
            legs.texture = null

    if itemData.index == 8:
        if equip:
            hands.texture = itemData.layer
        else:
            hands.texture = null

    if itemData.index == 9:
        if equip:
            feet.texture = itemData.layer
        else:
            feet.texture = null

    if itemData.index == 10:
        if equip:
            belt.texture = itemData.layer
        else:
            belt.texture = null

func ResetLayers():
    feet.texture = null
    legs.texture = null
    hands.texture = null
    torso.texture = null
    rig.texture = null
    backpack.texture = null
    head.texture = null
    belt.texture = null



func ContainerCapacity(sourceData: SlotData, useError: bool) -> bool:
    for containerSlot in containerGrid.get_children():

        if !containerSlot.slotData.itemData:

            var upcomingWeight = currentContainerWeight + sourceData.itemData.weight

            if upcomingWeight > container.capacity:


                if useError:
                    ErrorAudio()
                return false
            else:
                return true


    if useError:
        ErrorAudio()


    return false

func InventoryCapacity(useError: bool) -> bool:
    for inventorySlot in inventoryGrid.get_children():

        if !inventorySlot.slotData.itemData:
            return true


    if useError:
        ErrorAudio()


    return false

func RequestCapacity() -> bool:
    for requestSlot in requestGrid.get_children():

        if !requestSlot.slotData.itemData:
            return true


    ErrorAudio()
    return false

func OfferCapacity() -> bool:
    for offerSlot in offerGrid.get_children():

        if !offerSlot.slotData.itemData:
            return true


    ErrorAudio()
    return false

func SupplyCapacity() -> bool:
    for traderSlot in supplyGrid.get_children():

        if !traderSlot.slotData.itemData:
            return true


    ErrorAudio()
    return false



func InventoryLMBClick(sourceData, sourceIndex):
    var sourceSlot = inventoryGrid.get_child(sourceIndex)


    if sourceData.itemData:


        if trader && traderMode == 1:

            if OfferCapacity():
                QuickTransfer(sourceData, sourceIndex, "Inventory")
                hovering = false
                tooltip.Reset()
                CalculateValues(true)
                ClickAudio()
                return
            else:
                return

        elif trader && traderMode == 2:
            return


        if grabber.visible:


            var swapSlotData = SlotData.new()
            swapSlotData.Update(sourceData)


            sourceSlot.SetSlotData(grabber.grabbedSlotData)
            sourceSlot.HoverHighlight()

            grabber.Update(swapSlotData)
            ClickAudio()


        elif !dropToggle && !transferToggle && !equipToggle:
            grabber.Update(sourceData)
            grabber.show()
            sourceSlot.ClearSlotData()
            ClickAudio()


        elif dropToggle && !transferToggle && !equipToggle:
            QuickDrop(sourceData, "Inventory")
            sourceSlot.ClearSlotData()
            sourceSlot.ResetHighlight()
            hovering = false
            tooltip.Reset()
            CalculateValues(true)
            DropAudio()


        elif !dropToggle && transferToggle && !equipToggle && container:
            if ContainerCapacity(sourceData, true):
                QuickTransfer(sourceData, sourceIndex, "Inventory")
                hovering = false
                tooltip.Reset()
                CalculateValues(true)
                ClickAudio()


        elif !dropToggle && !transferToggle && equipToggle && sourceData.itemData.equippable:
            QuickEquip(sourceData, sourceIndex, "Inventory")
            hovering = false
            tooltip.Reset()
            CalculateValues(true)
            EquipAudio()


    elif grabber.visible:
        sourceSlot.SetSlotData(grabber.grabbedSlotData)
        sourceSlot.HoverHighlight()
        grabber.Reset()
        grabber.hide()
        CalculateValues(true)
        ClickAudio()

func EquipmentLMBClick(sourceData, sourceIndex):
    var sourceSlot = equipmentGrid.get_child(sourceIndex)


    if sourceData.itemData:


        if trader && traderMode == 1:

            if OfferCapacity():
                QuickTransfer(sourceData, sourceIndex, "Equipment")
                hovering = false
                tooltip.Reset()
                CalculateValues(true)
                UnequipAudio()
                ClickAudio()
                return
            else:
                return


        elif trader && traderMode == 2:
            return


        if grabber.visible:

            if grabber.grabbedSlotData.itemData.equippable && grabber.grabbedSlotData.itemData.index == sourceIndex:


                if sourceData.itemData.index == 0 && gameData.primary:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                if sourceData.itemData.index == 1 && gameData.secondary:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                if sourceData.itemData.index == 12 && gameData.knife:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                var swapSlotData = SlotData.new()
                swapSlotData.Update(sourceData)


                sourceSlot.SetSlotData(grabber.grabbedSlotData)
                sourceSlot.HoverHighlight()


                UpdateLayer(grabber.grabbedSlotData.itemData, true)
                weapons.UpdateClothing()


                grabber.Update(swapSlotData)
                EquipAudio()


        elif !dropToggle && !transferToggle && !equipToggle:


            if sourceData.itemData.index == 0 && gameData.primary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if sourceData.itemData.index == 1 && gameData.secondary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if sourceData.itemData.index == 12 && gameData.knife:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            grabber.Update(sourceData)
            grabber.show()


            UpdateLayer(sourceData.itemData, false)


            sourceSlot.ClearSlotData()
            sourceSlot.ShowHint()
            CalculateValues(true)
            UnequipAudio()


            weapons.UpdateClothing()


        elif dropToggle && !transferToggle && !equipToggle:


            if sourceData.itemData.index == 0 && gameData.primary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if sourceData.itemData.index == 1 && gameData.secondary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if sourceData.itemData.index == 12 && gameData.knife:
                weapons.ClearWeapons()
                weapons.PlayUnequip()

            QuickDrop(sourceData, "Inventory")
            UpdateLayer(sourceData.itemData, false)
            sourceSlot.ClearSlotData()
            sourceSlot.ResetHighlight()
            weapons.UpdateClothing()
            sourceSlot.ShowHint()
            hovering = false
            tooltip.Reset()
            CalculateValues(true)
            DropAudio()


        elif !dropToggle && !transferToggle && equipToggle:
            if InventoryCapacity(true):
                QuickUnequip(sourceData, sourceIndex)
                hovering = false
                tooltip.Reset()
                CalculateValues(true)


    elif grabber.visible:
        if grabber.grabbedSlotData.itemData.equippable && grabber.grabbedSlotData.itemData.index == sourceIndex:


            sourceSlot.SetSlotData(grabber.grabbedSlotData)


            UpdateLayer(sourceData.itemData, true)
            weapons.UpdateClothing()

            sourceSlot.HoverHighlight()
            sourceSlot.HideHint()
            grabber.Reset()
            grabber.hide()
            CalculateValues(true)
            EquipAudio()

func ContainerLMBClick(sourceData, sourceIndex):
    if !container:
        return

    var sourceSlot = containerGrid.get_child(sourceIndex)


    if sourceSlot.slotData.itemData:


        if grabber.visible:

            if ContainerCapacity(grabber.grabbedSlotData, true):


                var swapSlotData = SlotData.new()
                swapSlotData.Update(sourceData)


                sourceSlot.SetSlotData(grabber.grabbedSlotData)
                sourceSlot.HoverHighlight()


                grabber.Update(swapSlotData)
                CalculateValues(false)
                ClickAudio()


        elif !dropToggle && !transferToggle && !equipToggle:
            grabber.Update(sourceData)
            grabber.show()
            sourceSlot.ClearSlotData()
            CalculateValues(false)
            ClickAudio()


        elif dropToggle && !transferToggle && !equipToggle:
            QuickDrop(sourceData, "Container")
            sourceSlot.ClearSlotData()
            sourceSlot.ResetHighlight()
            hovering = false
            tooltip.Reset()
            CalculateValues(true)
            DropAudio()


        elif !dropToggle && transferToggle && !equipToggle:
            if InventoryCapacity(true):
                QuickTransfer(sourceData, sourceIndex, "Container")
                hovering = false
                tooltip.Reset()
                CalculateValues(true)
                ClickAudio()


        elif !dropToggle && !transferToggle && equipToggle && sourceData.itemData.equippable:
            QuickEquip(sourceData, sourceIndex, "Container")
            hovering = false
            tooltip.Reset()
            CalculateValues(true)
            EquipAudio()


    elif grabber.visible:


        if ContainerCapacity(grabber.grabbedSlotData, true):

            sourceSlot.SetSlotData(grabber.grabbedSlotData)
            sourceSlot.HoverHighlight()
            grabber.Reset()
            grabber.hide()
            CalculateValues(true)
            ClickAudio()

func SupplyLMBClick(sourceData, sourceIndex):

    if sourceData.itemData:

        if RequestCapacity():
            QuickTransfer(sourceData, sourceIndex, "Supply")
            tooltip.Reset()
            CalculateValues(true)
            ClickAudio()

func RequestLMBClick(sourceData, sourceIndex):

    if sourceData.itemData:

        if SupplyCapacity():
            QuickTransfer(sourceData, sourceIndex, "Request")
            tooltip.Reset()
            CalculateValues(true)
            ClickAudio()

func OfferLMBClick(sourceData, sourceIndex):

    if sourceData.itemData:

        if InventoryCapacity(false):
            QuickTransfer(sourceData, sourceIndex, "Offer")
            tooltip.Reset()
            CalculateValues(true)
            ClickAudio()



func ShowActions(targetSlot):
    if tooltip.visible:
        tooltip.Reset()
        tooltip.hide()

    hovering = false
    actions.Show(targetSlot)
    ClickAudio()

func HideActions():
    actions.Hide()
    ClickAudio()

func ItemActionUse():
    var itemData = actionSlot.slotData.itemData

    actionSlot.Occupied()
    progressTimer = 0.0
    progressTime = itemData.time
    progress.set_shader_parameter("value", 0.0)
    UseAudio(itemData)
    ClickAudio()

    await get_tree().create_timer(itemData.time).timeout;

    character.Consume(itemData)
    actionSlot.ClearSlotData()
    actionSlot.ResetOccupied()
    tooltip.Reset()


    if itemData.used:

        var newSlotData = SlotData.new()
        newSlotData.itemData = itemData.used
        actionSlot.SetSlotData(newSlotData)

    CalculateValues(true)

func ItemActionPlace():

    if preloader.get(actionSlot.slotData.itemData.file):


        var map = get_tree().current_scene.get_node("/root/Map")
        var file = preloader.get(actionSlot.slotData.itemData.file)

        if file:
            var pickup = preloader.get(actionSlot.slotData.itemData.file).instantiate()
            map.add_child(pickup)


            pickup.slotData.Update(actionSlot.slotData)
            pickup.UpdateAttachments()


            placer.ActionPlace(pickup)


            if actionSlot.type == actionSlot.SlotType.Equipment:


                if actionSlot.slotData.itemData.index == 0 && gameData.primary:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                if actionSlot.slotData.itemData.index == 1 && gameData.secondary:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                if actionSlot.slotData.itemData.index == 12 && gameData.knife:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()

                UpdateLayer(actionSlot.slotData.itemData, false)
                actionSlot.ClearSlotData()
                actionSlot.ResetHighlight()
                weapons.UpdateClothing()
                actionSlot.ShowHint()
                tooltip.Reset()
                CalculateValues(true)


            else:


                if actionSlot.slotData.itemData.type == "Ammunition":


                    if actionSlot.slotData.ammo > actionSlot.slotData.itemData.boxSize:


                        var newSlotData = SlotData.new()
                        newSlotData.itemData = actionSlot.slotData.itemData
                        newSlotData.ammo = actionSlot.slotData.itemData.boxSize


                        pickup.slotData.Update(newSlotData)


                        actionSlot.slotData.ammo -= actionSlot.slotData.itemData.boxSize
                        actionSlot.UpdateAmmo()
                        CalculateValues(true)


                    else:
                        actionSlot.ClearSlotData()
                        actionSlot.ResetHighlight()
                        tooltip.Reset()
                        CalculateValues(true)

                else:
                    actionSlot.ClearSlotData()
                    actionSlot.ResetHighlight()
                    tooltip.Reset()
                    CalculateValues(true)


    UIManager.ToggleInterface()

func ItemActionDrop():
    if actionSlot.type == actionSlot.SlotType.Inventory:
        QuickDrop(actionSlot.slotData, "Inventory")
    elif actionSlot.type == actionSlot.SlotType.Equipment:
        QuickDrop(actionSlot.slotData, "Inventory")
    elif actionSlot.type == actionSlot.SlotType.Loot:
        QuickDrop(actionSlot.slotData, "Container")


    if actionSlot.type == actionSlot.SlotType.Equipment:


        if actionSlot.slotData.itemData.index == 0 && gameData.primary:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        if actionSlot.slotData.itemData.index == 1 && gameData.secondary:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        if actionSlot.slotData.itemData.index == 12 && gameData.knife:
            weapons.ClearWeapons()
            weapons.PlayUnequip()

        UpdateLayer(actionSlot.slotData.itemData, false)
        actionSlot.ClearSlotData()
        actionSlot.ResetHighlight()
        weapons.UpdateClothing()
        actionSlot.ShowHint()
        tooltip.Reset()
        CalculateValues(true)
        DropAudio()


    else:
        actionSlot.ClearSlotData()
        actionSlot.ResetHighlight()
        tooltip.Reset()
        CalculateValues(true)
        DropAudio()

func ItemActionEquip():
    var sourceData = actionSlot.slotData
    var sourceIndex = actionSlot.get_index()


    if actionSlot.type == actionSlot.SlotType.Inventory:
        QuickEquip(sourceData, sourceIndex, "Inventory")
        EquipAudio()


    elif actionSlot.type == actionSlot.SlotType.Loot:
        QuickEquip(sourceData, sourceIndex, "Container")
        EquipAudio()


    elif actionSlot.type == actionSlot.SlotType.Equipment:
        if InventoryCapacity(true):
            QuickUnequip(sourceData, sourceIndex)

    tooltip.Reset()
    CalculateValues(true)

func ItemActionTransfer():
    var sourceData = actionSlot.slotData
    var sourceIndex = actionSlot.get_index()


    if actionSlot.type == actionSlot.SlotType.Inventory:
        if ContainerCapacity(sourceData, true):
            QuickTransfer(sourceData, sourceIndex, "Inventory")
            tooltip.Reset()
            CalculateValues(true)


    elif actionSlot.type == actionSlot.SlotType.Loot:
        if InventoryCapacity(true):
            QuickTransfer(sourceData, sourceIndex, "Container")
            tooltip.Reset()
            CalculateValues(true)

func ItemActionUnload():
    if actionSlot.slotData.itemData.type == "Weapon":
        AmmoUnload()
    elif actionSlot.slotData.itemData.type == "Equipment" && actionSlot.slotData.armor:
        ArmorUnload()

func ItemActionSplit():

    if actionSlot.type == actionSlot.SlotType.Inventory:
        if !InventoryCapacity(true):
            return


    if actionSlot.type == actionSlot.SlotType.Loot:
        if !ContainerCapacity(actionSlot.slotData, true):
            return


    var ammoToSplit = actionSlot.slotData.ammo
    var ammoData = actionSlot.slotData.itemData
    var splitAmount = round(ammoToSplit / 2)


    var newSlotData = SlotData.new()
    newSlotData.itemData = ammoData
    newSlotData.ammo = splitAmount


    if actionSlot.type == actionSlot.SlotType.Inventory:

        for inventorySlot in inventoryGrid.get_children():

            if !inventorySlot.slotData.itemData:


                actionSlot.slotData.ammo -= splitAmount
                actionSlot.UpdateAmmo()


                inventorySlot.SetSlotData(newSlotData)
                UnloadEndAudio()


                tooltip.Reset()
                CalculateValues(false)
                break


    if actionSlot.type == actionSlot.SlotType.Loot:

        for containerSlot in containerGrid.get_children():

            if !containerSlot.slotData.itemData:


                actionSlot.slotData.ammo -= splitAmount
                actionSlot.UpdateAmmo()


                containerSlot.SetSlotData(newSlotData)
                UnloadEndAudio()


                tooltip.Reset()
                CalculateValues(false)
                break

func ItemActionTake():

    if actionSlot.type == actionSlot.SlotType.Inventory:
        if !InventoryCapacity(true):
            return


    if actionSlot.type == actionSlot.SlotType.Loot:
        if !ContainerCapacity(actionSlot.slotData, true):
            return


    var ammoData = actionSlot.slotData.itemData
    var ammoToTake = ammoData.boxSize


    var newSlotData = SlotData.new()
    newSlotData.itemData = ammoData
    newSlotData.ammo = ammoToTake


    if actionSlot.type == actionSlot.SlotType.Inventory:

        for inventorySlot in inventoryGrid.get_children():

            if !inventorySlot.slotData.itemData:


                actionSlot.slotData.ammo -= ammoToTake
                actionSlot.UpdateAmmo()


                inventorySlot.SetSlotData(newSlotData)
                UnloadEndAudio()


                tooltip.Reset()
                CalculateValues(false)
                break


    if actionSlot.type == actionSlot.SlotType.Loot:

        for containerSlot in containerGrid.get_children():

            if !containerSlot.slotData.itemData:


                actionSlot.slotData.ammo -= ammoToTake
                actionSlot.UpdateAmmo()


                containerSlot.SetSlotData(newSlotData)
                UnloadEndAudio()


                tooltip.Reset()
                CalculateValues(false)
                break



func AddActiveAttachment(attachmentData: AttachmentData):
    if gameData.primary:
        var primarySlot = equipmentGrid.get_child(0)


        if attachmentData.category == attachmentData.Category.Muzzle:
            primarySlot.slotData.muzzle = attachmentData

        elif attachmentData.category == attachmentData.Category.Optic:
            primarySlot.slotData.optic = attachmentData


            primarySlot.slotData.position = 0.0
            primarySlot.slotData.zoom = 1.0


        primarySlot.UpdateModdedIcon()

    elif gameData.secondary:
        var secondarySlot = equipmentGrid.get_child(1)


        if attachmentData.category == attachmentData.Category.Muzzle:
            secondarySlot.slotData.muzzle = attachmentData

        elif attachmentData.category == attachmentData.Category.Optic:
            secondarySlot.slotData.optic = attachmentData


            secondarySlot.slotData.position = 0.0
            secondarySlot.slotData.zoom = 1.0


        secondarySlot.UpdateModdedIcon()

func RemoveActiveAttachment(attachmentData: AttachmentData):
    if gameData.primary:
        var primarySlot = equipmentGrid.get_child(0)


        if attachmentData.category == attachmentData.Category.Muzzle:
            primarySlot.slotData.muzzle = null

        elif attachmentData.category == attachmentData.Category.Optic:
            primarySlot.slotData.optic = null


            primarySlot.slotData.position = 0.0
            primarySlot.slotData.zoom = 1.0

        primarySlot.UpdateModdedIcon()

    elif gameData.secondary:
        var secondarySlot = equipmentGrid.get_child(1)


        if attachmentData.category == attachmentData.Category.Muzzle:
            secondarySlot.slotData.muzzle = null

        elif attachmentData.category == attachmentData.Category.Optic:
            secondarySlot.slotData.optic = null


            secondarySlot.slotData.position = 0.0
            secondarySlot.slotData.zoom = 1.0

        secondarySlot.UpdateModdedIcon()

func RemoveAttachment(attachmentData: AttachmentData):
    for inventorySlot in inventoryGrid.get_children():
        if inventorySlot.slotData.itemData:
            if inventorySlot.slotData.itemData is AttachmentData && inventorySlot.slotData.itemData.file == attachmentData.file:
                inventorySlot.ClearSlotData()
                inventorySlot.ResetHighlight()
                break

func ReturnAttachment(newSlotData: SlotData) -> bool:

    for inventorySlot in inventoryGrid.get_children():


        if !inventorySlot.slotData.itemData:

            newSlotData.position = 0.0
            newSlotData.zoom = 1.0

            inventorySlot.SetSlotData(newSlotData)
            CalculateValues(true)
            return true

    ErrorAudio()
    return false



func QuickTransfer(sourceData: SlotData, sourceIndex: int, sourceGrid: String):
    var sourceSlot


    hovering = false

    if sourceGrid == "Inventory":
        sourceSlot = inventoryGrid.get_child(sourceIndex)
    elif sourceGrid == "Equipment":
        sourceSlot = equipmentGrid.get_child(sourceIndex)
    elif sourceGrid == "Container":
        sourceSlot = containerGrid.get_child(sourceIndex)
    elif sourceGrid == "Supply":
        sourceSlot = supplyGrid.get_child(sourceIndex)
    elif sourceGrid == "Request":
        sourceSlot = requestGrid.get_child(sourceIndex)
    elif sourceGrid == "Offer":
        sourceSlot = offerGrid.get_child(sourceIndex)
    elif sourceGrid == "Deal":
        sourceSlot = requestGrid.get_child(sourceIndex)


    if sourceGrid == "Inventory" && !trader:

        for containerSlot in containerGrid.get_children():

            if !containerSlot.slotData.itemData:

                containerSlot.SetSlotData(sourceData)

                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                break


    elif sourceGrid == "Container":

        for inventorySlot in inventoryGrid.get_children():

            if !inventorySlot.slotData.itemData:

                inventorySlot.SetSlotData(sourceData)

                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                break


    elif sourceGrid == "Supply":

        for requestSlot in requestGrid.get_children():

            if !requestSlot.slotData.itemData:

                requestSlot.SetSlotData(sourceData)

                requestSlot.returnSlot = sourceSlot

                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                break


    elif sourceGrid == "Request":

        for traderSlot in supplyGrid.get_children():

            if !traderSlot.slotData.itemData:

                sourceSlot.returnSlot.SetSlotData(sourceData)

                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                break


    elif sourceGrid == "Inventory" && trader:

        for offerSlot in offerGrid.get_children():

            if !offerSlot.slotData.itemData:

                offerSlot.SetSlotData(sourceData)

                offerSlot.returnSlot = sourceSlot

                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                break


    elif sourceGrid == "Equipment" && trader:

        for offerSlot in offerGrid.get_children():

            if !offerSlot.slotData.itemData:

                offerSlot.SetSlotData(sourceData)

                offerSlot.returnSlot = sourceSlot


                UpdateLayer(sourceSlot.slotData.itemData, false)


                if sourceData.itemData.index == 0 && gameData.primary:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                if sourceData.itemData.index == 1 && gameData.secondary:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                if sourceData.itemData.index == 12 && gameData.knife:
                    weapons.ClearWeapons()
                    weapons.PlayUnequip()


                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                sourceSlot.ShowHint()


                weapons.UpdateClothing()
                break


    elif sourceGrid == "Offer":

        var returnSlot = sourceSlot.returnSlot


        if returnSlot.type == returnSlot.SlotType.Inventory:
            returnSlot.SetSlotData(sourceData)


        elif returnSlot.type == returnSlot.SlotType.Equipment:
            returnSlot.SetSlotData(sourceData)
            returnSlot.HideHint()
            UpdateLayer(returnSlot.slotData.itemData, true)
            weapons.UpdateClothing()
            EquipAudio()


        sourceSlot.ClearSlotData()
        sourceSlot.ResetHighlight()


    elif sourceGrid == "Deal":

        for inventorySlot in inventoryGrid.get_children():

            if !inventorySlot.slotData.itemData:

                inventorySlot.SetSlotData(sourceData)

                sourceSlot.ClearSlotData()
                sourceSlot.ResetHighlight()
                break

func QuickEquip(sourceData: SlotData, sourceIndex: int, sourceGrid: String):

    var targetSlot = equipmentGrid.get_child(sourceData.itemData.index)
    var sourceSlot


    if sourceGrid == "Inventory":
        sourceSlot = inventoryGrid.get_child(sourceIndex)
    elif sourceGrid == "Container":
        sourceSlot = containerGrid.get_child(sourceIndex)


    if targetSlot.slotData.itemData:


        if sourceData.itemData.index == 0 && gameData.primary:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        if sourceData.itemData.index == 1 && gameData.secondary:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        if sourceData.itemData.index == 12 && gameData.knife:
            weapons.ClearWeapons()
            weapons.PlayUnequip()


        var swapSlotData = SlotData.new()
        swapSlotData.Update(targetSlot.slotData)


        targetSlot.SetSlotData(sourceData)
        targetSlot.HideHint()


        weapons.UpdateClothing()
        UpdateLayer(sourceData.itemData, true)


        sourceSlot.ClearSlotData()


        if sourceGrid == "Inventory":

            if InventoryCapacity(false):
                sourceSlot.SetSlotData(swapSlotData)
                sourceSlot.HoverHighlight()
            else:
                QuickDrop(swapSlotData, "Inventory")
                DropAudio()


        elif sourceGrid == "Container":

            if ContainerCapacity(swapSlotData, false):
                sourceSlot.SetSlotData(swapSlotData)
                sourceSlot.HoverHighlight()
            else:
                QuickDrop(swapSlotData, "Container")
                sourceSlot.ResetHighlight()
                DropAudio()


    else:

        targetSlot.SetSlotData(sourceData)
        targetSlot.HideHint()


        weapons.UpdateClothing()
        UpdateLayer(sourceData.itemData, true)


        sourceSlot.ClearSlotData()
        sourceSlot.ResetHighlight()

func QuickUnequip(sourceData, sourceIndex):
    var sourceSlot = equipmentGrid.get_child(sourceIndex)


    for inventorySlot in inventoryGrid.get_children():

        if !inventorySlot.slotData.itemData:

            inventorySlot.SetSlotData(sourceData)


            if sourceSlot.slotData.itemData.index == 0 && gameData.primary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if sourceSlot.slotData.itemData.index == 1 && gameData.secondary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if sourceSlot.slotData.itemData.index == 12 && gameData.knife:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            UpdateLayer(sourceData.itemData, false)
            sourceSlot.ClearSlotData()
            sourceSlot.ResetHighlight()
            sourceSlot.ShowHint()
            weapons.UpdateClothing()
            UnequipAudio()
            break

func QuickDrop(slotData: SlotData, sourceGrid: String):

    if preloader.get(slotData.itemData.file):


        var dropDirection
        var dropPosition
        var dropRotation


        if sourceGrid == "Inventory":
            dropDirection = - camera.global_transform.basis.z
            dropPosition = (camera.global_position + Vector3(0, -0.25, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, camera.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


        elif sourceGrid == "Container":
            dropDirection = container.global_transform.basis.z
            dropPosition = (container.global_position + Vector3(0, 0.5, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, container.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


        elif sourceGrid == "Trader":
            dropDirection = trader.global_transform.basis.z
            dropPosition = (trader.global_position + Vector3(0, 0.5, 0)) + dropDirection / 2
            dropRotation = Vector3(-25, trader.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


        var map = get_tree().current_scene.get_node("/root/Map")
        var file = preloader.get(slotData.itemData.file)

        if file:
            if slotData.itemData.type == "Ammunition":
                var boxSize = slotData.itemData.boxSize
                var boxesNeeded = ceil(float(slotData.ammo) / float(slotData.itemData.boxSize))
                var ammoLeft = slotData.ammo

                for box in boxesNeeded:
                    var pickup = preloader.get(slotData.itemData.file).instantiate()
                    map.add_child(pickup)
                    pickup.get_child(0).position = dropPosition
                    pickup.get_child(0).rotation_degrees = dropRotation
                    pickup.Unfreeze()
                    pickup.SetDropVelocity(dropDirection, 2.5)


                    var newSlotData = SlotData.new()
                    newSlotData.itemData = slotData.itemData

                    if ammoLeft > boxSize:
                        ammoLeft -= boxSize
                        newSlotData.ammo = boxSize
                        pickup.slotData.Update(newSlotData)
                    else:
                        newSlotData.ammo = ammoLeft
                        pickup.slotData.Update(newSlotData)

                CalculateValues(true)

            else:
                var pickup = preloader.get(slotData.itemData.file).instantiate()
                map.add_child(pickup)
                pickup.get_child(0).position = dropPosition
                pickup.get_child(0).rotation_degrees = dropRotation
                pickup.Unfreeze()
                pickup.SetDropVelocity(dropDirection, 2.5)
                CalculateValues(true)


                pickup.slotData.Update(slotData)
                pickup.UpdateAttachments()


                if pickup.slotData.itemData.proximity:
                    await get_tree().create_timer(0.5).timeout;
                    UpdateProximity()
        else:
            print("File not found: " + slotData.itemData.name)



func UpdateTooltip(slotData: SlotData):
    tooltip.Update(slotData)

func ResetTooltip():
    tooltip.Reset()

func ResetAllHighlights():
    for inventorySlot in inventoryGrid.get_children():
        inventorySlot.ResetHighlight()

    for equipmentSlot in equipmentGrid.get_children():
        equipmentSlot.ResetHighlight()

    for containerSlot in containerGrid.get_children():
        containerSlot.ResetHighlight()

    preview.ResetHighlight()

func _on_background_gui_input(event):
    if event is InputEventMouseButton && (event.button_index == MOUSE_BUTTON_LEFT || event.button_index == MOUSE_BUTTON_RIGHT) && event.is_pressed():

        if grabber.visible && grabber.grabbedSlotData.itemData:
            DropAudio()
            QuickDrop(grabber.grabbedSlotData, "Inventory")
            grabber.Reset()
            grabber.hide()


        hovering = false


        if tooltip.visible:
            tooltip.Reset()


        if actions.visible:
            actions.Hide()
            ResetAllHighlights()



func ArmorLoad(targetSlot: SlotL):
    targetSlot.slotData.armor = grabber.grabbedSlotData.itemData
    targetSlot.slotData.condition = grabber.grabbedSlotData.condition
    targetSlot.UpdateIndicator()
    targetSlot.UpdateCondition()
    targetSlot.HoverHighlight()
    ArmorAudio()

    UpdateArmorStats()

    grabber.Reset()
    grabber.hide()
    UpdateTooltip(targetSlot.slotData)
    CalculateValues(true)

func ArmorUnload():

    if actionSlot.type == actionSlot.SlotType.Inventory || actionSlot.type == actionSlot.SlotType.Equipment:
        if !InventoryCapacity(true):
            return


    if actionSlot.type == actionSlot.SlotType.Loot:
        if !ContainerCapacity(actionSlot.slotData, true):
            return


    var newSlotData = SlotData.new()
    newSlotData.itemData = actionSlot.slotData.armor
    newSlotData.condition = actionSlot.slotData.condition


    if actionSlot.type == actionSlot.SlotType.Inventory || actionSlot.type == actionSlot.SlotType.Equipment:

        for inventorySlot in inventoryGrid.get_children():

            if !inventorySlot.slotData.itemData:


                actionSlot.Occupied()
                unloading = true
                unloadAudio = false
                unloadTimer = 0.0
                progressTimer = 0.0
                progressTime = 1.0
                progress.set_shader_parameter("value", 0.0)


                await get_tree().create_timer(1.0).timeout;


                actionSlot.slotData.armor = null
                actionSlot.UpdateCondition()
                actionSlot.UpdateIndicator()


                inventorySlot.SetSlotData(newSlotData)
                ArmorAudio()


                unloading = false
                actionSlot.ResetOccupied()
                tooltip.Reset()
                CalculateValues(true)
                break


    elif actionSlot.type == actionSlot.SlotType.Loot:

        for containerSlot in containerGrid.get_children():

            if !containerSlot.slotData.itemData:


                actionSlot.Occupied()
                unloading = true
                unloadTimer = 0.0
                progressTimer = 0.0
                progressTime = 1.0
                progress.set_shader_parameter("value", 0.0)


                await get_tree().create_timer(1.0).timeout;


                actionSlot.slotData.armor = null
                actionSlot.UpdateCondition()
                actionSlot.UpdateIndicator()


                containerSlot.SetSlotData(newSlotData)
                ArmorAudio()


                unloading = false
                unloadAudio = false
                actionSlot.ResetOccupied()
                tooltip.Reset()
                CalculateValues(true)
                break

func PlateCheck(penetration: int) -> bool:
    var rigSlot = equipmentGrid.get_child(3)


    if rigSlot.slotData.itemData && rigSlot.slotData.armor && rigSlot.slotData.condition != 0:


        if rigSlot.slotData.armor.protection > penetration:


            rigSlot.slotData.condition -= randi_range(15, 20)


            if rigSlot.slotData.condition <= 0:
                rigSlot.slotData.condition = 0
                ArmorBreakAudio()


            UpdateArmorStats()


            return true


        elif rigSlot.slotData.armor.protection == penetration:


            if penetration == 5:
                rigSlot.slotData.condition -= randi_range(50, 100)

            else:
                rigSlot.slotData.condition -= randi_range(25, 35)


            if rigSlot.slotData.condition <= 0:
                rigSlot.slotData.condition = 0
                ArmorBreakAudio()


            UpdateArmorStats()


            return true


        else:

            rigSlot.slotData.condition = 0
            ArmorBreakAudio()


            UpdateArmorStats()


            return false


    else:


        return false

func HelmetCheck(penetration: int) -> bool:
    var headSlot = equipmentGrid.get_child(4)


    if headSlot.slotData.itemData && headSlot.slotData.itemData.helmet && headSlot.slotData.condition != 0:


        if headSlot.slotData.itemData.protection > penetration:


            headSlot.slotData.condition -= randi_range(15, 20)


            if headSlot.slotData.condition <= 0:
                headSlot.slotData.condition = 0
                ArmorBreakAudio()


            UpdateArmorStats()


            return true


        elif headSlot.slotData.itemData.protection == penetration:


            headSlot.slotData.condition -= randi_range(25, 35)


            if headSlot.slotData.condition <= 0:
                headSlot.slotData.condition = 0
                ArmorBreakAudio()


            UpdateArmorStats()


            return true


        else:

            headSlot.slotData.condition = 0
            ArmorBreakAudio()


            UpdateArmorStats()


            return false


    else:


        return false

func UpdateArmorStats():
    var rigSlot = equipmentGrid.get_child(3)
    var headSlot = equipmentGrid.get_child(4)


    if rigSlot.slotData.armor:
        plate.show()
        plateRating.text = rigSlot.slotData.armor.rating
        plateCondition.text = str(rigSlot.slotData.condition) + "%"
        rigSlot.UpdateCondition()

        if rigSlot.slotData.condition <= 25:
            plateCondition.add_theme_color_override("font_color", Color.RED)
        elif rigSlot.slotData.condition > 25 && rigSlot.slotData.condition <= 50:
            plateCondition.add_theme_color_override("font_color", Color.YELLOW)
        else:
            plateCondition.add_theme_color_override("font_color", Color.GREEN)
    else:
        plate.hide()


    if headSlot.slotData.itemData:

        if headSlot.slotData.itemData.helmet:
            helmet.show()
            helmetRating.text = headSlot.slotData.itemData.rating
            helmetCondition.text = str(headSlot.slotData.condition) + "%"
            headSlot.UpdateCondition()

            if headSlot.slotData.condition <= 25:
                helmetCondition.add_theme_color_override("font_color", Color.RED)
            elif headSlot.slotData.condition > 25 && headSlot.slotData.condition <= 50:
                helmetCondition.add_theme_color_override("font_color", Color.YELLOW)
            else:
                helmetCondition.add_theme_color_override("font_color", Color.GREEN)
        else:
            helmet.hide()
    else:
        helmet.hide()



func RemoveKnife():

    equipmentGrid.get_child(12).ClearSlotData()
    equipmentGrid.get_child(12).ResetHighlight()
    equipmentGrid.get_child(12).ShowHint()
    CalculateValues(true)



func AmmoStack(targetSlot: SlotL):
    targetSlot.slotData.ammo += grabber.grabbedSlotData.ammo
    targetSlot.UpdateAmmo()
    targetSlot.HoverHighlight()
    UnloadEndAudio()

    grabber.Reset()
    grabber.hide()
    UpdateTooltip(targetSlot.slotData)
    CalculateValues(true)

func AmmoUnload():

    if actionSlot.type == actionSlot.SlotType.Inventory || actionSlot.type == actionSlot.SlotType.Equipment:
        if !InventoryCapacity(true):
            return


    if actionSlot.type == actionSlot.SlotType.Loot:
        if !ContainerCapacity(actionSlot.slotData, true):
            return


    var ammoToUnload = actionSlot.slotData.ammo
    var ammoData = actionSlot.slotData.itemData.ammo


    var newSlotData = SlotData.new()
    newSlotData.itemData = ammoData
    newSlotData.ammo = ammoToUnload


    if actionSlot.type == actionSlot.SlotType.Inventory || actionSlot.type == actionSlot.SlotType.Equipment:

        for inventorySlot in inventoryGrid.get_children():

            if !inventorySlot.slotData.itemData:


                if actionSlot.type == actionSlot.SlotType.Equipment:

                    if actionSlot.slotData.itemData.index == 0 && gameData.primary:
                        weapons.ClearWeapons()
                        weapons.PlayUnequip()


                    if actionSlot.slotData.itemData.index == 1 && gameData.secondary:
                        weapons.ClearWeapons()
                        weapons.PlayUnequip()


                actionSlot.Occupied()
                unloading = true
                unloadAudio = true
                unloadTimer = 0.0
                progressTimer = 0.0
                progressTime = ammoToUnload / unloadSpeed
                progress.set_shader_parameter("value", 0.0)


                await get_tree().create_timer(ammoToUnload / unloadSpeed).timeout;


                actionSlot.slotData.ammo = 0
                actionSlot.UpdateAmmo()


                inventorySlot.SetSlotData(newSlotData)
                UnloadEndAudio()


                unloading = false
                unloadAudio = false
                actionSlot.ResetOccupied()
                tooltip.Reset()
                CalculateValues(true)
                break


    elif actionSlot.type == actionSlot.SlotType.Loot:

        for containerSlot in containerGrid.get_children():

            if !containerSlot.slotData.itemData:


                actionSlot.Occupied()
                unloading = true
                unloadAudio = true
                unloadTimer = 0.0
                progressTimer = 0.0
                progressTime = ammoToUnload / unloadSpeed
                progress.set_shader_parameter("value", 0.0)


                await get_tree().create_timer(ammoToUnload / unloadSpeed).timeout;


                actionSlot.slotData.ammo = 0
                actionSlot.UpdateAmmo()


                containerSlot.SetSlotData(newSlotData)
                UnloadEndAudio()


                unloading = false
                unloadAudio = false
                actionSlot.ResetOccupied()
                tooltip.Reset()
                CalculateValues(true)
                break

func AmmoCheck(weaponData: WeaponData) -> bool:

    if !weaponData.ammo:
        return false


    for inventorySlot in inventoryGrid.get_children():

        if inventorySlot.slotData.itemData:

            if inventorySlot.slotData.itemData.type == "Ammunition":

                if inventorySlot.slotData.itemData.file == weaponData.ammo.file:
                    return true

    return false

func Reload(ammoNeeded: int, weaponData: WeaponData) -> int:
    var ammoAvailable = 0
    var ammoDebt = 0
    var ammoDelivery = 0


    for inventorySlot in inventoryGrid.get_children():

        if inventorySlot.slotData.itemData:

            if inventorySlot.slotData.itemData.type == "Ammunition":

                if inventorySlot.slotData.itemData.file == weaponData.ammo.file:

                    ammoAvailable += inventorySlot.slotData.ammo




    if ammoAvailable >= ammoNeeded:
        ammoDelivery = ammoNeeded
        ammoDebt = ammoNeeded


    elif ammoAvailable < ammoNeeded:
        ammoDelivery = ammoAvailable
        ammoDebt = ammoAvailable


    for inventorySlot in inventoryGrid.get_children():
        if inventorySlot.slotData.itemData:
            if inventorySlot.slotData.itemData.type == "Ammunition":
                if inventorySlot.slotData.itemData.file == weaponData.ammo.file:


                    if ammoDebt > inventorySlot.slotData.ammo:

                        ammoDebt -= inventorySlot.slotData.ammo
                        inventorySlot.ClearSlotData()
                        inventorySlot.ResetHighlight()
                        continue


                    elif ammoDebt == inventorySlot.slotData.ammo:

                        inventorySlot.ClearSlotData()
                        inventorySlot.ResetHighlight()
                        break


                    elif ammoDebt < inventorySlot.slotData.ammo:

                        inventorySlot.slotData.ammo -= ammoDebt
                        inventorySlot.UpdateAmmo()
                        break

    return ammoDelivery



func _on_hide_pressed():

    ResetCrafting()

    recipeHint.text = "Recipes hidden"
    recipeHint.show()
    recipeList.hide()
    ClickAudio()

func _on_weapons_pressed():

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.weapons:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.weapons.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func _on_armor_pressed():

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.armor:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.armor.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func _on_equipment_pressed():

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.equipment:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.equipment.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func _on_medical_pressed():

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.medical:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.medical.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func _on_cooking_pressed() -> void :

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.cooking:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.cooking.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func _on_electronics_pressed():

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.electronics:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.electronics.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func _on_misc_pressed():

    ResetCrafting()


    for child in recipeList.get_children():
        recipeList.remove_child(child)
        child.queue_free()


    for craftingRecipe in recipes.misc:
        var newRecipe = recipe.instantiate()
        recipeList.add_child(newRecipe)
        newRecipe.SetRecipeUI(craftingRecipe, self)


    if recipes.misc.size() == 0:
        recipeHint.text = "No recipes available"
        recipeHint.show()
        recipeList.hide()
    else:
        recipeHint.hide()
        recipeList.show()

    ClickAudio()

func Craft():
    gameData.isCrafting = true
    activeRecipe = selectedRecipe
    recipeProgress.show()
    recipeButtons.hide()
    craftingTimer = selectedRecipe.recipeData.time
    CraftStartAudio()

    RemoveRequiredItems()
    CalculateValues(true)
    ResetCrafting()


    if activeRecipe.recipeData.heat || activeRecipe.recipeData.workbench || activeRecipe.recipeData.tester:
        SpawnToProximity()
    else:
        CraftMetalAudio()

func SpawnToProximity():

    if preloader.get(activeRecipe.recipeData.results[0].file):


        var map = get_tree().current_scene.get_node("/root/Map")
        var file = preloader.get(activeRecipe.recipeData.results[0].file)

        if file:
            var pickup = preloader.get(activeRecipe.recipeData.results[0].file).instantiate()
            var target: Node3D = FindClosestProximity()

            map.add_child(pickup)
            pickup.global_transform = target.global_transform
            pickup.global_position = target.global_position


            proximityPickup = pickup


            if proximityPickup.effects:
                for effect in proximityPickup.effects.get_children():
                    if effect is GPUParticles3D:
                        effect.emitting = true
                    if effect is AudioStreamPlayer3D:
                        effect.play()

func FindClosestProximity() -> Node3D:

    var minimumDistance = 10
    var closestProximity: Node3D


    var proximities = get_tree().get_nodes_in_group("Proximity")


    for proximity in proximities:

        var distance = gameData.playerPosition.distance_to(proximity.global_position)


        if distance < minimumDistance:

            minimumDistance = distance

            closestProximity = proximity

    return closestProximity

func CraftCompleted():

    if !activeRecipe.recipeData.heat && !activeRecipe.recipeData.workbench && !activeRecipe.recipeData.tester:
        GetRecipeItems()


    if proximityPickup && proximityPickup.effects:
        for effect in proximityPickup.effects.get_children():
            if effect is GPUParticles3D:
                effect.emitting = false
            if effect is AudioStreamPlayer3D:
                effect.stop()

    gameData.isCrafting = false
    activeRecipe.Completed()
    activeRecipe = null
    proximityPickup = null
    recipeProgress.hide()
    recipeButtons.show()
    craftingTime.text = "00:00"
    CraftEndAudio()

func ResetCrafting():

    if selectedRecipe:
        selectedRecipe.craftButton.disabled = true
        selectedRecipe.combineButton.button_pressed = false


    selectedRecipe = null
    crafting = false


    for inventorySlot in inventoryGrid.get_children():
        inventorySlot.isCrafting = false
        inventorySlot.ResetHighlight()


    for equipmentSlot in equipmentGrid.get_children():
        equipmentSlot.isCrafting = false
        equipmentSlot.ResetHighlight()

func RemoveRequiredItems():
    for inventorySlot in inventoryGrid.get_children():
        if inventorySlot.isCrafting:
            inventorySlot.ClearSlotData()
            inventorySlot.ResetHighlight()

    for equipmentSlot in equipmentGrid.get_children():
        if equipmentSlot.isCrafting:


            if equipmentSlot.slotData.itemData.index == 0 && gameData.primary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if equipmentSlot.slotData.itemData.index == 1 && gameData.secondary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            UpdateLayer(equipmentSlot.slotData.itemData, false)


            equipmentSlot.ClearSlotData()
            equipmentSlot.ResetHighlight()
            equipmentSlot.ShowHint()


            weapons.UpdateClothing()

func RecipeCompatibility(slotData: SlotData) -> bool:

    for requiresSlot in selectedRecipe.requiresGrid.get_children():

        if !requiresSlot.isCrafting:

            if requiresSlot.slotData.itemData.name == slotData.itemData.name:

                return true


    ErrorAudio()
    return false

func GetRecipeItems():

    for resultsSlot in activeRecipe.resultsGrid.get_children():

        if resultsSlot.slotData.itemData:

            if InventoryCapacity(false):

                for inventorySlot in inventoryGrid.get_children():

                    if !inventorySlot.slotData.itemData:
                        inventorySlot.SetSlotData(resultsSlot.slotData)
                        break

            else:
                QuickDrop(resultsSlot.slotData, "Inventory")

    CalculateValues(true)

func UpdateProximity():
    detector.Detect()

    if gameData.heat:
        heat.modulate = Color8(0, 255, 0, 255)
    else:
        heat.modulate = Color8(255, 255, 255, 64)


    if recipeList.get_child_count() != 0:

        for child in recipeList.get_children():
            child.UpdateProximity()



func UpdateTraderInfo():
    traderIcon.texture = trader.traderData.icon
    traderName.text = trader.traderData.name
    traderResupply.text = str(trader.traderData.resupply) + ":00"

func UpdateTraderTax(updatedTax: int):
    trader.tax = updatedTax
    traderTax.text = str(updatedTax) + "%"

func UpdateTraderLevel(updatedLevel: int):
    trader.level = updatedLevel
    traderLevel.text = str(updatedLevel)

func _on_supply_pressed():

    ResetDelivery()
    ResetSupplyGrid()
    ResetRequestGrid()
    ResetOfferGrid()
    FillSupplyGrid()
    CalculateValues(true)

    traderMode = 1
    supplyUI.show()
    requestUI.show()
    offerUI.show()
    dealUI.show()
    levelsUI.hide()
    tasksUI.hide()
    ClickAudio()

func _on_reset_pressed():
    GetOfferGridItems()
    ResetSupplyGrid()
    ResetRequestGrid()
    ResetOfferGrid()
    FillSupplyGrid()
    CalculateValues(true)
    ClickAudio()
    TraderResetAudio()

func _on_trade_pressed():
    GetRequestGridItems()
    ResetSupplyGrid()
    ResetRequestGrid()
    ResetOfferGrid()
    FillSupplyGrid()
    CalculateValues(true)
    ClickAudio()
    TraderTradeAudio()



func GetResupply():
    GetOfferGridItems()
    ResetSupplyGrid()
    ResetRequestGrid()
    ResetOfferGrid()
    FillSupplyGrid()
    CalculateValues(true)
    TraderResetAudio()
    trader.resupply = false

func FillSupplyGrid():
    var fillIndex = 0


    if trader.supply.size() != 0:

        for slotData in trader.supply:
            var targetSlot = supplyGrid.get_child(fillIndex)
            targetSlot.SetSlotData(slotData)
            fillIndex += 1

func ResetSupplyGrid():
    for traderSlot in supplyGrid.get_children():
        traderSlot.ClearSlotData()
        traderSlot.ResetHighlight()

func ResetRequestGrid():
    for requestSlot in requestGrid.get_children():
        requestSlot.ClearSlotData()
        requestSlot.ResetHighlight()

func ResetOfferGrid():
    for offerSlot in offerGrid.get_children():
        offerSlot.ClearSlotData()
        offerSlot.ResetHighlight()

func GetRequestGridItems():
    var slotIndex = 0

    for requestSlot in requestGrid.get_children():

        if requestSlot.slotData.itemData:

            trader.RemoveFromSupply(requestSlot.slotData.itemData)

            if InventoryCapacity(false):
                QuickTransfer(requestSlot.slotData, slotIndex, "Deal")
            else:
                QuickDrop(requestSlot.slotData, "Trader")

        slotIndex += 1

func GetOfferGridItems():
    var slotIndex = 0

    for offerSlot in offerGrid.get_children():

        if offerSlot.slotData.itemData:

            if InventoryCapacity(true):
                QuickTransfer(offerSlot.slotData, slotIndex, "Offer")

        slotIndex += 1



func _on_tasks_pressed():

    ResetDelivery()
    GetOfferGridItems()
    ResetSupplyGrid()
    ResetRequestGrid()
    ResetOfferGrid()
    CalculateValues(true)

    traderMode = 2
    supplyUI.hide()
    requestUI.hide()
    offerUI.hide()
    dealUI.hide()
    levelsUI.show()
    tasksUI.show()
    ClickAudio()


    GenerateTasks(trader.traderData.levels[0], true)
    levelList.get_child(0).button_pressed = true

func GenerateLevels():

    for child in levelList.get_children():
        levelList.remove_child(child)
        child.queue_free()


    for traderlevel in trader.traderData.levels:
        var newLevel = level.instantiate()
        newLevel.name = traderlevel.name
        newLevel.text = traderlevel.name
        levelList.add_child(newLevel)
        newLevel.Initialize(traderlevel, self)

func GenerateTasks(levelData: LevelData, unlocked: bool):

    for child in taskList.get_children():
        taskList.remove_child(child)
        child.queue_free()


    for taskData in levelData.tasks:
        var newTask = task.instantiate()
        taskList.add_child(newTask)
        newTask.SetTaskUI(taskData, self)


        if unlocked:

            newTask.Unlocked()

            for taskString in trader.tasksCompleted:

                if newTask.taskData.name == taskString:

                    newTask.Completed()

        else:

            newTask.Locked()

func UpdateTaskUI():

    var availableLevels = trader.traderData.levels.size()
    var availableTasks = taskList.get_child_count()
    var completedLevels = 0
    var completedTasks = 0


    for child in levelList.get_children():

        child.UpdateStatus()

        if child.isCompleted:
            completedLevels += 1


    for child in taskList.get_children():

        if child.isCompleted:
            completedTasks += 1


    levelsCompleted.text = str(completedLevels) + "/" + str(availableLevels)

    tasksCompleted.text = str(completedTasks) + "/" + str(availableTasks)

func ResetDelivery():

    selectedTask = null
    delivery = false


    for inventorySlot in inventoryGrid.get_children():
        inventorySlot.isDelivered = false
        inventorySlot.ResetHighlight()


    for equipmentSlot in equipmentGrid.get_children():
        equipmentSlot.isDelivered = false
        equipmentSlot.ResetHighlight()

func GetTaskItems(completedTask):

    for receiveSlot in completedTask.receiveGrid.get_children():

        if receiveSlot.slotData.itemData:

            if InventoryCapacity(false):

                for inventorySlot in inventoryGrid.get_children():

                    if !inventorySlot.slotData.itemData:
                        inventorySlot.SetSlotData(receiveSlot.slotData)
                        break

            else:
                QuickDrop(receiveSlot.slotData, "Trader")

func DeliverCompatibility(slotData: SlotData) -> bool:

    for deliverySlot in selectedTask.deliverGrid.get_children():

        if !deliverySlot.isDelivered:

            if deliverySlot.slotData.itemData.name == slotData.itemData.name:

                    return true


    ErrorAudio()
    return false

func RemoveDeliveredItems():
    for inventorySlot in inventoryGrid.get_children():
        if inventorySlot.isDelivered:
            inventorySlot.ClearSlotData()
            inventorySlot.ResetHighlight()

    for equipmentSlot in equipmentGrid.get_children():
        if equipmentSlot.isDelivered:


            if equipmentSlot.slotData.itemData.index == 0 && gameData.primary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if equipmentSlot.slotData.itemData.index == 1 && gameData.secondary:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            if equipmentSlot.slotData.itemData.index == 12 && gameData.knife:
                weapons.ClearWeapons()
                weapons.PlayUnequip()


            UpdateLayer(equipmentSlot.slotData.itemData, false)


            equipmentSlot.ClearSlotData()
            equipmentSlot.ResetHighlight()
            equipmentSlot.ShowHint()


            weapons.UpdateClothing()



func UseAudio(itemData: ItemData):
    var use = audioInstance2D.instantiate()
    add_child(use)
    use.PlayInstance(itemData.audio)

func DropAudio():
    var drop = audioInstance2D.instantiate()
    add_child(drop)
    drop.PlayInstance(audioLibrary.UIDrop)

func ClickAudio():
    if gameData.interface:
        var click = audioInstance2D.instantiate()
        add_child(click)
        click.PlayInstance(audioLibrary.UIClick)

func ErrorAudio():
    var error = audioInstance2D.instantiate()
    add_child(error)
    error.PlayInstance(audioLibrary.UIError)

func EquipAudio():
    var equip = audioInstance2D.instantiate()
    add_child(equip)
    equip.PlayInstance(audioLibrary.UIEquip)

func CraftStartAudio():
    var craftStart = audioInstance2D.instantiate()
    add_child(craftStart)
    craftStart.PlayInstance(audioLibrary.UICraftStart)

func CraftEndAudio():
    var craftEnd = audioInstance2D.instantiate()
    add_child(craftEnd)
    craftEnd.PlayInstance(audioLibrary.UICraftEnd)

func CraftMetalAudio():
    var craftMetal = audioInstance2D.instantiate()
    add_child(craftMetal)
    craftMetal.PlayInstance(audioLibrary.UICraftMetal)

func UnequipAudio():
    var unequip = audioInstance2D.instantiate()
    add_child(unequip)
    unequip.PlayInstance(audioLibrary.UIUnequip)

func UnloadAudio():
    var unload = audioInstance2D.instantiate()
    add_child(unload)
    unload.PlayInstance(audioLibrary.unload)

func UnloadEndAudio():
    var unloadEnd = audioInstance2D.instantiate()
    add_child(unloadEnd)
    unloadEnd.PlayInstance(audioLibrary.unloadEnd)

func ArmorAudio():
    var armor = audioInstance2D.instantiate()
    add_child(armor)
    armor.PlayInstance(audioLibrary.UIArmor)

func ArmorBreakAudio():
    var armorBreak = audioInstance2D.instantiate()
    add_child(armorBreak)
    armorBreak.PlayInstance(audioLibrary.armorBreak)

func TraderOpenAudio():
    var traderOpen = audioInstance2D.instantiate()
    add_child(traderOpen)
    traderOpen.PlayInstance(audioLibrary.UITraderOpen)

func TraderCloseAudio():
    var traderClose = audioInstance2D.instantiate()
    add_child(traderClose)
    traderClose.PlayInstance(audioLibrary.UITraderClose)

func TraderTradeAudio():
    var trade = audioInstance2D.instantiate()
    add_child(trade)
    trade.PlayInstance(audioLibrary.UITraderTrade)

func TraderResetAudio():
    var traderReset = audioInstance2D.instantiate()
    add_child(traderReset)
    traderReset.PlayInstance(audioLibrary.UITraderReset)

func TraderTaskAudio():
    var traderTask = audioInstance2D.instantiate()
    add_child(traderTask)
    traderTask.PlayInstance(audioLibrary.UITraderTask)

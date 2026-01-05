extends Control


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")

const item = preload("res://UI/Elements/Item.tscn")
const task = preload("res://UI/Elements/Task.tscn")
const progress = preload("res://UI/Elements/Progress.tscn")
const completion = preload("res://UI/Elements/Completion.tscn")
const message = preload("res://UI/Elements/Message.tscn")


@onready var camera = $"../../Camera"
@onready var placer = $"../../Camera/Placer"
@onready var character = $"../../Controller/Character"
@onready var rigManager = $"../../Camera/Manager"
@onready var UIManager = $".."
@onready var tooltip = $Tooltip


@onready var catalogUI = $Catalog
@onready var inventoryUI = $Inventory
@onready var containerUI = $Container
@onready var equipmentUI = $Equipment
@onready var characterUI = $Character
@onready var craftingUI = $Crafting
@onready var traderUI = $Trader
@onready var supplyUI = $Supply
@onready var tasksUI = $Tasks
@onready var dealUI = $Deal


@onready var background = $Background
@onready var catalogGrid = $Catalog / Margin / Scroll / Control / Grid
@onready var inventoryGrid = $Inventory / Grid
@onready var containerGrid = $Container / Grid
@onready var supplyGrid = $Supply / Grid
@onready var equipment = $Equipment
@onready var highlight = $Clipper / Highlight
@onready var clipper = $Clipper


@onready var traderIcon = $Trader / Panel / Icon
@onready var traderName = $Trader / Panel / Stats / Name / Value
@onready var traderTasks = $Trader / Panel / Stats / Tasks / Value
@onready var traderTax = $Trader / Panel / Stats / Tax / Value
@onready var traderResupply = $Trader / Panel / Stats / Resupply / Value
@onready var supplyButton = $Trader / Panel / Buttons / Supply
@onready var taskButton = $Trader / Panel / Buttons / Tasks
@onready var dealSlider = $Deal / Panel / Indicator / Slider
@onready var requestValue = $Deal / Panel / Indicator / Request / Value
@onready var offerValue = $Deal / Panel / Indicator / Offer / Value
@onready var resetButton = $Deal / Panel / Buttons / Reset
@onready var acceptButton = $Deal / Panel / Buttons / Accept
@onready var supplyValue = $Supply / Header / Value / Value
@onready var taskList = $Tasks / Panel / Margin / Scroll / List


@onready var inventoryCapacity = $Inventory / Header / Capacity / Value
@onready var inventoryWeight = $Inventory / Header / Weight / Value
@onready var inventoryValue = $Inventory / Header / Value / Value
@onready var containerName = $Container / Header / Label
@onready var containerWeight = $Container / Header / Weight / Value
@onready var containerValue = $Container / Header / Value / Value

@onready var equipmentCapacity = $Equipment / Stats / Elements / Capacity / Value
@onready var equipmentValue = $Equipment / Stats / Elements / Value / Value
@onready var equipmentInsulation = $Equipment / Stats / Elements / Insulation / Value


@onready var context = $Context
@onready var preview = $Preview


@onready var day = $Character / Stats / Elements / Day / Value
@onready var shelters = $Character / Stats / Elements / Shelters / Value
@onready var tasks = $Character / Stats / Elements / Tasks / Value


@onready var warp = $Warp


var cellSize = 64
var itemDragged = null
var itemOffset = Vector2()
var mousePosition
var lastMousePosition = Vector2.ZERO


var tooltipMode = 1
var tooltipDelay = 0.5
var tooltipTimer = 0.0
var tooltipOffset = 0.0


var hoverGrid = null
var hoverItem = null
var hoverSlot = null
var hoverEquipment = null
var hoverInfo = null
var hoverInfos: Array


var trader
var container


var contextItem = null
var contextSlot = null
var contextGrid = null


var canEquip = false
var canUnequip = false
var canCombine = false
var canSlotSwap = false
var canGridSwap = false
var canCombineSwap = false
var canCombineLoad = false
var canCombineStack = false
var canCombineCharge = false


var returnSlot = null
var returnGrid = null
var returnRotated = false
var returnPosition = Vector2()


var activeProgress = null


var isInputting = false
var inputTarget = null


var baseCarryWeight = 10.0
var currentInventoryCapacity = 0.0
var currentInventoryWeight = 0.0
var currentInventoryValue = 0.0
var currentContainerWeight = 0.0
var currentContainerValue = 0.0
var currentEquipmentWeight = 0.0
var currentEquipmentValue = 0.0
var currentEquipmentInsulation = 0.0
var currentSupplyValue = 0.0
var inventoryWeightPercentage = 0.0
var insulationMultiplier = 0.0


var hover = Color8(255, 255, 255, 32)
var valid = Color8(0, 255, 0, 32)
var invalid = Color8(255, 0, 0, 32)
var swap = Color8(255, 255, 0, 32)
var combine = Color8(0, 255, 0, 32)



func _physics_process(delta):


	if !visible:
		return



	if Engine.get_physics_frames() % 20 == 0 && !itemDragged:
		UpdateStats(true)



	if gameData.isOccupied:
		context.hide()
		highlight.hide()
		return



	if !gameData.isTrading && !isInputting:

		if Engine.get_physics_frames() % 100:
			DisplayTime()


		if Input.is_action_just_pressed("context") && !itemDragged:
			if context.visible:
				HideContext()
				Reset()
			else:
				ShowContext()
			return


		if Input.is_action_just_pressed("left_mouse") && contextItem && !context.hover:
			HideContext()
			Reset()
			return


		if Input.is_action_pressed("item_transfer") && Input.is_action_just_pressed("left_mouse") && !contextItem && !gameData.decor:
			FastTransfer()


		elif Input.is_action_pressed("item_equip") && Input.is_action_just_pressed("left_mouse") && !contextItem && !gameData.decor:
			FastEquip()


		elif Input.is_action_pressed("item_drop") && Input.is_action_just_pressed("left_mouse") && !contextItem && !gameData.decor:
			FastDrop()


		elif Input.is_action_just_pressed("left_mouse") && !contextItem:
			Grab()


		elif Input.is_action_just_released("left_mouse") && !contextItem:
			Release()


		elif Input.is_action_just_pressed("item_rotate") && itemDragged && !contextItem:
			Rotate(itemDragged)



	if trader:
		if Input.is_action_just_pressed("left_mouse") && supplyUI.visible:
			TradeSelection()



	if isInputting:
		if Input.is_action_just_pressed("left_mouse") && !supplyUI.visible:
			InputSelection()



	mousePosition = get_global_mouse_position()
	var mouseMoved = mousePosition.distance_to(lastMousePosition) > 1.0
	lastMousePosition = mousePosition

	Hover()
	Highlight()



	if tooltipMode == 1:


		if hoverItem && Engine.get_physics_frames() % 10 == 0:
			tooltip.Update(hoverItem)

		if hoverEquipment && Engine.get_physics_frames() % 10 == 0:
			tooltip.Update(hoverEquipment)

		if hoverInfo && Engine.get_physics_frames() % 10 == 0:
			tooltip.Info(hoverInfo)


		if tooltip.visible:
			tooltip.global_position = get_global_mouse_position() - Vector2(0, tooltipOffset)


		if !itemDragged && !context.visible && !mouseMoved:


			if (hoverItem || hoverEquipment || hoverInfo) && !tooltip.visible:

				tooltipTimer += delta


				if tooltipTimer > tooltipDelay:
					tooltip.global_position = get_global_mouse_position() - Vector2(0, tooltipOffset)
					tooltip.show()
					tooltipTimer = 0.0


			elif !hoverItem && !hoverEquipment && !hoverInfo && tooltip.visible:
				tooltip.hide()
				tooltipTimer = 0.0
		else:
			tooltip.hide()
			tooltipTimer = 0.0
	else:
		tooltip.hide()



	if itemDragged:
		Drag()
		clipper.z_index = 0
	else:
		clipper.z_index = -1



func Open():

	Reset()
	HideAllUI()


	if gameData.decor:
		catalogUI.show()


	elif container:
		containerName.text = container.containerName
		inventoryUI.show()
		equipmentUI.show()
		characterUI.show()
		containerUI.show()
		UpdateContainerGrid()
		FillContainerGrid()


	elif trader:
		if !gameData.tutorial:
			Loader.LoadTrader(trader.traderData.name)

		UpdateTraderInfo()
		ResetTrading()
		supplyButton.button_pressed = true
		inventoryUI.show()
		characterUI.show()
		traderUI.show()
		supplyUI.show()
		dealUI.show()
		FillSupplyGrid()
		trader.PlayTraderStart()


	else:
		inventoryUI.show()
		equipmentUI.show()
		characterUI.show()
		craftingUI.show()


	UpdateUIDetails()
	UpdateStats(true)


	var warpPosition = get_viewport().get_final_transform() * get_viewport().get_canvas_transform() * warp.global_position
	Input.warp_mouse(warpPosition)
	tooltip.hide()
	highlight.hide()

func Close():

	if itemDragged:
		Drop(itemDragged)


	if container:
		StorageContainerGrid()
		ClearContainerGrid()
		container.ContainerAudio()
		container = null


	if trader:
		if !gameData.tutorial:
			Loader.SaveTrader(trader.traderData.name)

		ResetTrading()
		ClearSupplyGrid()
		trader.PlayTraderEnd()
		trader = null


	Reset()
	HideAllUI()
	UpdateStats(false)
	tooltip.hide()
	highlight.hide()



func UpdateUIDetails():

	for child in inventoryGrid.get_children():
		if child is Item:
			child.UpdateDetails()


	for child in equipment.get_children():
		if child is Slot && child.get_child_count() != 0:
			child.get_child(0).UpdateDetails()

func UpdateStats(updateLabels: bool):

	await get_tree().physics_frame


	currentInventoryCapacity = 0.0
	currentInventoryWeight = 0.0
	currentInventoryValue = 0.0
	currentEquipmentValue = 0.0
	currentContainerWeight = 0.0
	currentContainerValue = 0.0
	currentEquipmentWeight = 0.0
	currentEquipmentValue = 0.0
	currentEquipmentInsulation = 0.0
	currentSupplyValue = 0.0
	inventoryWeightPercentage = 0.0



	for equipmentSlot in equipment.get_children():
		if equipmentSlot is Slot && equipmentSlot.get_child_count() != 0:
			currentEquipmentWeight += equipmentSlot.get_child(0).Weight()
			currentEquipmentValue += equipmentSlot.get_child(0).Value()
			currentInventoryCapacity += equipmentSlot.get_child(0).slotData.itemData.capacity
			currentEquipmentInsulation += equipmentSlot.get_child(0).slotData.itemData.insulation

	currentInventoryCapacity += baseCarryWeight
	insulationMultiplier = 1.0 - (currentEquipmentInsulation / 100.0)
	character.insulation = insulationMultiplier



	for element in inventoryGrid.get_children():
		currentInventoryWeight += element.Weight()
		currentInventoryValue += element.Value()

	if currentInventoryWeight > currentInventoryCapacity:
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
		for element in containerGrid.get_children():
			currentContainerWeight += element.Weight()
			currentContainerValue += element.Value()



	if trader:
		for element in supplyGrid.get_children():
			currentSupplyValue += element.Value()



	if updateLabels:

		inventoryWeightPercentage = currentInventoryWeight / currentInventoryCapacity
		inventoryCapacity.text = str("%.1f" % currentInventoryCapacity)
		inventoryWeight.text = str("%.1f" % currentInventoryWeight)
		inventoryValue.text = str(int(round(currentInventoryValue)))

		if inventoryWeightPercentage > 1: inventoryWeight.modulate = Color.RED
		elif inventoryWeightPercentage >= 0.5: inventoryWeight.modulate = Color.YELLOW
		else: inventoryWeight.modulate = Color.GREEN

		equipmentCapacity.text = str(int(round(currentInventoryCapacity))) + "kg"
		equipmentValue.text = str(int(round(currentEquipmentValue)))
		equipmentInsulation.text = str(int(round(currentEquipmentInsulation)))

		if currentEquipmentInsulation <= 25: equipmentInsulation.modulate = Color.RED
		elif currentEquipmentInsulation > 25 && currentEquipmentInsulation <= 50: equipmentInsulation.modulate = Color.YELLOW
		else: equipmentInsulation.modulate = Color.GREEN

		if container:
			containerWeight.text = str("%.1f" % currentContainerWeight)
			containerValue.text = str(int(round(currentContainerValue)))
		if trader:
			supplyValue.text = str(int(round(currentSupplyValue)))

func HideAllUI():
	craftingUI.hide()
	catalogUI.hide()
	inventoryUI.hide()
	equipmentUI.hide()
	characterUI.hide()
	containerUI.hide()
	traderUI.hide()
	supplyUI.hide()
	tasksUI.hide()
	dealUI.hide()



func UpdateContainerGrid():
	containerGrid.CreateContainerGrid(container.containerSize)

func FillContainerGrid():

	if container.storaged:
		for slotData in container.storage:
			LoadGridItem(slotData, containerGrid, slotData.gridPosition)

	else:
		for slotData in container.loot:
			Create(slotData, containerGrid, false)

func ClearContainerGrid():

	containerGrid.ClearGrid()


	for element in containerGrid.get_children():
		element.queue_free()

func StorageContainerGrid():
	container.Storage(containerGrid)



func UpdateTraderInfo():
	traderIcon.texture = trader.traderData.icon
	traderName.text = trader.traderData.name

	var availableTasks = trader.traderData.tasks.size()
	var completedTasks = 0
	var tax = 100.0


	for element in trader.tasksCompleted:
		completedTasks += 1
		tax -= 10.0


	traderTasks.text = str(completedTasks) + "/" + str(availableTasks)


	trader.tax = tax
	traderTax.text = str(int(round(tax))) + "%"

func FillSupplyGrid():

	for slotData in trader.supply:
		Create(slotData, supplyGrid, false)

func ClearSupplyGrid():

	supplyGrid.ClearGrid()


	for element in supplyGrid.get_children():
		element.queue_free()

func Resupply():
	ResetTrading()
	ClearSupplyGrid()
	FillSupplyGrid()

func TradeSelection():

	if hoverItem:

		if hoverItem.selected:
			hoverItem.State("Static")
			CalculateDeal()
			PlayClick()

		else:
			hoverItem.State("Selected")
			CalculateDeal()
			PlayClick()

func ResetTrading():

	for element in inventoryGrid.get_children():
		if element.selected:
			element.State("Static")


	for element in supplyGrid.get_children():
		if element.selected:
			element.State("Static")


	requestValue.text = str("0")
	offerValue.text = str("0")


	dealSlider.value = 1.0
	resetButton.disabled = true
	acceptButton.disabled = true

func CalculateDeal():

	var currentRequestValue = 0.0
	var currentOfferValue = 0.0


	for element in supplyGrid.get_children():
		if element.selected:
			currentRequestValue += element.Value() * ((trader.tax * 0.01 + 1))


	for element in inventoryGrid.get_children():
		if element.selected:
			currentOfferValue += element.Value()


	requestValue.text = str(int(round(currentRequestValue)))
	offerValue.text = str(int(round(currentOfferValue)))


	if currentOfferValue == 0 && currentRequestValue == 0:
		resetButton.disabled = true
		acceptButton.disabled = true
		dealSlider.value = 1.0

	elif currentOfferValue == currentRequestValue:
		resetButton.disabled = false
		acceptButton.disabled = false
		dealSlider.value = 1.0

	else:

		if currentOfferValue != 0 && currentRequestValue == 0:
			acceptButton.disabled = true
			resetButton.disabled = false
			dealSlider.value = 2

		elif currentOfferValue == 0 && currentRequestValue != 0:
			acceptButton.disabled = true
			resetButton.disabled = false
			dealSlider.value = 0

		else:

			if currentOfferValue > currentRequestValue:
				acceptButton.disabled = false
				resetButton.disabled = false

			else:
				acceptButton.disabled = true
				resetButton.disabled = false

			var dealPercentage = currentOfferValue / currentRequestValue
			dealSlider.value = dealPercentage

func CompleteDeal():

	for element in inventoryGrid.get_children():
		if element.selected:
			inventoryGrid.Pick(element)
			element.queue_free()


	for element in supplyGrid.get_children():
		if element.selected:


			if element.slotData.itemData.type == "Furniture":
				Create(element.slotData, catalogGrid, false)


				var newMessage = message.instantiate()
				get_tree().get_root().add_child(newMessage)
				newMessage.Text("New Furniture Added (Furniture Catalog)")


			else:
				Create(element.slotData, inventoryGrid, true)


	for element in supplyGrid.get_children():
		if element.selected:

			trader.RemoveFromSupply(element.slotData.itemData)


			supplyGrid.Pick(element)
			element.queue_free()

func _on_reset_pressed() -> void :
	ResetTrading()
	trader.PlayTraderReset()

func _on_accept_pressed() -> void :
	CompleteDeal()
	ResetTrading()
	trader.PlayTraderTrade()

func _on_supply_pressed() -> void :
	supplyUI.show()
	tasksUI.hide()
	PlayClick()

func _on_tasks_pressed() -> void :
	supplyUI.hide()
	tasksUI.show()
	ResetTrading()
	InitializeTasks()
	PlayClick()

func InitializeTasks():

	for element in taskList.get_children():
		element.queue_free()


	for taskData in trader.traderData.tasks:
		var newTask = task.instantiate()
		taskList.add_child(newTask)
		newTask.Initialize(taskData, self)


		for element in trader.tasksCompleted:

			if element == newTask.taskData.name:
				newTask.Completed()



func StartInput(target):

	ResetInput()


	isInputting = true
	inputTarget = target

func ResetInput():

	for child in inventoryGrid.get_children():
		if child.selected:
			child.State("Static")


	if inputTarget:
		inputTarget.ResetInput()
		inputTarget = null


	isInputting = false

func InputSelection():
	if hoverItem:

		if hoverItem.selected:
			hoverItem.State("Static")
			inputTarget.RemoveInputItem(hoverItem.slotData)
			PlayClick()


		elif inputTarget.CanInput(hoverItem.slotData):
			hoverItem.State("Selected")
			inputTarget.AddInputItem(hoverItem.slotData)
			PlayClick()


		else:
			PlayError()

func DestroyInputItems():

	for child in inventoryGrid.get_children():
		if child.selected:
			inventoryGrid.Pick(child)
			child.queue_free()

func GetOutputItems():
	for child in inputTarget.outputGrid.get_children():
		if child.slotData.itemData.type == "Furniture":
			Create(child.slotData, catalogGrid, false)
		else:
			Create(child.slotData, inventoryGrid, true)

func Complete():

	if trader:
		trader.CompleteTask(inputTarget.taskData)
		UpdateTraderInfo()

	DestroyInputItems()
	GetOutputItems()
	ResetInput()



func LoadGridItem(slotData, targetGrid, gridPosition):

	var newItem = item.instantiate()
	newItem.slotData.Update(slotData)


	targetGrid.add_child(newItem)
	newItem.Initialize(self, slotData)


	if slotData.gridRotated:
		Rotate(newItem)


	newItem.position = gridPosition


	targetGrid.Place(newItem)


	Reset()

func LoadSlotItem(slotData, slotName):

	for equipmentSlot in equipment.get_children():
		if equipmentSlot is Slot && equipmentSlot.name == slotName:

			var newItem = item.instantiate()
			newItem.slotData.Update(slotData)


			add_child(newItem)
			newItem.Initialize(self, slotData)


			Equip(newItem, equipmentSlot)

func Create(slotData, targetGrid, useDrop):

	var newItem = item.instantiate()
	newItem.slotData.Update(slotData)


	add_child(newItem)
	newItem.Initialize(self, slotData)


	if useDrop:
		if AutoPlace(newItem, targetGrid, null, true):
			Reset()
			return true
		else:
			Reset()
			return false


	else:
		if AutoPlace(newItem, targetGrid, null, false):
			Reset()
			return true
		else:
			Reset()
			return false

func AutoStackL(slotData, targetGrid):

	if slotData.itemData.stackable:

		for element in targetGrid.get_children():

			if element.slotData.itemData.file == slotData.itemData.file:

				var upcomingAmount = slotData.amount
				var upcomingStack = element.slotData.amount + upcomingAmount


				if upcomingStack <= element.slotData.itemData.maxAmount:

					element.slotData.amount += upcomingAmount
					PlayStack()

					element.UpdateDetails()

					return true


	return false

func AutoStack(slotData, targetGrid):

	if slotData.itemData.stackable:

		for element in targetGrid.get_children():

			if element.slotData.itemData.file == slotData.itemData.file:

				var amountFromFullStack = element.slotData.itemData.maxAmount - element.slotData.amount


				if slotData.amount <= amountFromFullStack:

					element.slotData.amount += slotData.amount
					element.UpdateDetails()
					PlayStack()


					return true


				else:

					var amountToStack = amountFromFullStack
					element.slotData.amount += amountToStack
					element.UpdateDetails()
					PlayStack()


					var leftovers = slotData.amount - amountToStack


					var newSlotData = SlotData.new()
					newSlotData.itemData = slotData.itemData
					newSlotData.amount = leftovers


					Create(newSlotData, targetGrid, true)


					return true


	return false

func Grab():

	if canUnequip:
		itemDragged = Unequip(hoverSlot)
		PlayUnequip()
		return


	if hoverItem && hoverGrid:

		itemDragged = hoverGrid.Pick(hoverItem)


		returnSlot = null
		returnGrid = hoverGrid
		returnRotated = itemDragged.rotated
		returnPosition = itemDragged.global_position


		itemOffset = Vector2( - itemDragged.size.x / 2, - itemDragged.size.y / 2)


		itemDragged.reparent(self)
		itemDragged.State("Free")
		PlayClick()

func Release():

	if !itemDragged:
		return


	if canEquip:
		Equip(itemDragged, hoverSlot)
		Reset()
		PlayEquip()
		return


	if canSlotSwap:
		SlotSwap()
		Reset()
		PlayEquip()
		return


	if canGridSwap:
		GridSwap()
		Reset()
		PlayClick()
		return


	if canCombine || canCombineSwap || canCombineLoad || canCombineStack || canCombineCharge:

		if hoverItem:
			Combine(hoverItem)
			PlayClick()
			return

		if hoverSlot:
			Combine(hoverSlot.get_child(0))
			PlayClick()
			return


	if hoverGrid:

		if hoverGrid.Place(itemDragged):
			Reset()
		else:
			Return(itemDragged)
			Reset()

	else:
		if gameData.decor:
			Return(itemDragged)
			Reset()
		else:

			Drop(itemDragged)
			Reset()


	PlayClick()

func Return(target):

	if target.rotated != returnRotated:
		Rotate(target)


	if returnGrid && returnPosition:
		target.global_position = returnPosition
		returnGrid.Place(target)

	elif hoverGrid && !returnPosition && returnSlot:
		Equip(target, returnSlot)

func Rotate(target):

	if target.rotated:
		target.size = Vector2(target.size.y, target.size.x)
		target.rotated = false
		target.UpdateDetails()
		target.UpdateSprite()

	else:
		target.size = Vector2(target.size.y, target.size.x)
		target.rotated = true
		target.UpdateDetails()
		target.UpdateSprite()


	itemOffset = Vector2( - target.size.x / 2, - target.size.y / 2)

func Drop(target):

	var map = get_tree().current_scene.get_node("/root/Map")
	var file = Database.get(target.slotData.itemData.file)


	if !file:
		print("File not found: " + target.slotData.itemData.name)
		target.queue_free()
		PlayDrop()
		return


	var dropDirection
	var dropPosition
	var dropRotation
	var dropForce = 2.5

	if trader:

		if hoverGrid == null:
			dropDirection = trader.global_transform.basis.z
			dropPosition = (trader.global_position + Vector3(0, 1.0, 0)) + dropDirection / 2
			dropRotation = Vector3(-25, trader.rotation_degrees.y + 180 + randf_range(-45, 45), 45)
	else:

		if hoverGrid == null:
			dropDirection = - camera.global_transform.basis.z
			dropPosition = (camera.global_position + Vector3(0, -0.25, 0)) + dropDirection / 2
			dropRotation = Vector3(-25, camera.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


		elif hoverGrid.get_parent().name == "Inventory":
			dropDirection = - camera.global_transform.basis.z
			dropPosition = (camera.global_position + Vector3(0, -0.25, 0)) + dropDirection / 2
			dropRotation = Vector3(-25, camera.rotation_degrees.y + 180 + randf_range(-45, 45), 45)


		elif hoverGrid.get_parent().name == "Container":
			dropDirection = container.global_transform.basis.z
			dropPosition = (container.global_position + Vector3(0, 0.5, 0)) + dropDirection / 2
			dropRotation = Vector3(-25, container.rotation_degrees.y + 180 + randf_range(-45, 45), 45)



	if target.slotData.itemData.stackable:
		var boxSize = target.slotData.itemData.defaultAmount
		var boxesNeeded = ceil(float(target.slotData.amount) / float(boxSize))
		var amountLeft = target.slotData.amount

		for box in boxesNeeded:

			var pickup = file.instantiate()
			map.add_child(pickup)


			pickup.position = dropPosition
			pickup.rotation_degrees = dropRotation
			pickup.linear_velocity = dropDirection * dropForce
			pickup.Unfreeze()


			var newSlotData = SlotData.new()
			newSlotData.itemData = target.slotData.itemData


			if amountLeft > boxSize:
				amountLeft -= boxSize
				newSlotData.amount = boxSize
				pickup.slotData.Update(newSlotData)
			else:
				newSlotData.amount = amountLeft
				pickup.slotData.Update(newSlotData)



	else:

		var pickup = file.instantiate()
		map.add_child(pickup)


		pickup.position = dropPosition
		pickup.rotation_degrees = dropRotation
		pickup.linear_velocity = dropDirection * dropForce
		pickup.Unfreeze()


		pickup.slotData.Update(target.slotData)
		pickup.UpdateAttachments()


	target.reparent(self)
	target.queue_free()
	PlayDrop()


	UpdateStats(true)

func Drag():

	itemDragged.global_position = mousePosition + itemOffset


	if hoverSlot && (canEquip || canSlotSwap):
		itemDragged.equipSlot = hoverSlot
		itemDragged.equipped = true
		itemDragged.UpdateSprite()
	else:
		itemDragged.equipSlot = null
		itemDragged.equipped = false
		itemDragged.UpdateSprite()



func Equip(targetItem, targetSlot):

	if targetItem.rotated:
		Rotate(targetItem)


	targetSlot.hint.hide()
	targetItem.reparent(targetSlot)
	targetItem.State("Static")
	targetItem.position = Vector2.ZERO
	targetItem.size = targetSlot.size
	targetItem.equipSlot = targetSlot
	targetItem.equipped = true


	targetItem.UpdateDetails()
	targetItem.UpdateSprite()


	preview.UpdateLayers(targetItem, true)
	rigManager.UpdateRig(false)

func Unequip(targetSlot):

	var slotItem = targetSlot.get_child(0)


	targetSlot.hint.show()
	slotItem.reparent(self)
	slotItem.State("Free")
	slotItem.equipSlot = null
	slotItem.equipped = false


	slotItem.size = slotItem.slotData.itemData.size * 64


	slotItem.UpdateDetails()
	slotItem.UpdateSprite()


	itemOffset = Vector2( - slotItem.size.x / 2, - slotItem.size.y / 2)


	returnSlot = targetSlot


	preview.UpdateLayers(slotItem, false)
	rigManager.UpdateRig(false)


	return slotItem

func GridSwap():

	hoverGrid.Pick(hoverItem)

	var tetrisState = TetrisCheck(hoverItem, itemDragged)


	if tetrisState == 1:

		if (itemDragged.rotated && !hoverItem.rotated) || ( !itemDragged.rotated && hoverItem.rotated):
			Rotate(itemDragged)
		if (hoverItem.rotated && !returnRotated) || ( !hoverItem.rotated && returnRotated):
			Rotate(hoverItem)


	if tetrisState == 2:

		if ( !itemDragged.rotated && !hoverItem.rotated) || (itemDragged.rotated && hoverItem.rotated):
			Rotate(itemDragged)
		if ( !hoverItem.rotated && !returnRotated) || (hoverItem.rotated && returnRotated):
			Rotate(hoverItem)


	itemDragged.global_position = hoverItem.global_position
	hoverGrid.Place(itemDragged)


	hoverItem.global_position = returnPosition
	returnGrid.Place(hoverItem)

func SlotSwap():

	if returnSlot:

		var swapSlot = returnSlot

		var itemEquipped = Unequip(hoverSlot)

		Equip(itemDragged, hoverSlot)


		if itemEquipped.slotData.itemData.slots.has(swapSlot.name):

			Equip(itemEquipped, swapSlot)
		else:

			Drop(itemEquipped)


	else:

		var swapGrid = returnGrid

		var itemEquipped = Unequip(hoverSlot)

		Equip(itemDragged, hoverSlot)

		AutoPlace(itemEquipped, swapGrid, null, true)

func Combine(targetItem):

	var combineItem = itemDragged
	var combineTarget = targetItem



	if canCombineCharge:
		Charge(combineTarget, combineItem)
		PlayClick()
		Reset()



	elif canCombineLoad:
		Load(combineTarget, combineItem)
		PlayClick()
		Reset()



	elif canCombineStack:
		targetItem.slotData.amount += combineItem.slotData.amount
		targetItem.UpdateDetails()
		combineItem.queue_free()
		PlayStack()
		Reset()



	elif canCombineSwap:

		var swapAmmo = combineTarget.slotData.amount

		var swapData = combineTarget.CombineSwap(combineItem)


		var newSlotData = SlotData.new()
		newSlotData.itemData = swapData


		if swapData.subtype == "Magazine":
			print("Swap ammo: " + str(swapAmmo))
			newSlotData.amount = swapAmmo


		if swapData.type == "Armor":
			newSlotData.condition = combineTarget.slotData.condition

		Create(newSlotData, returnGrid, true)

		combineTarget.Combine(combineItem)
		combineItem.queue_free()


		if hoverSlot:
			if swapData.subtype == "Magazine":

				if (hoverSlot.name == "Primary" && gameData.primary) || (hoverSlot.name == "Secondary" && gameData.secondary):
					rigManager.UpdateRig(true)
					ChangeMagazine(hoverSlot)
				else:
					rigManager.UpdateRig(false)
			else:
				rigManager.UpdateRig(false)

		PlayAttach()
		Reset()



	else:

		var combineData = combineItem.slotData.itemData

		combineTarget.Combine(combineItem)
		combineItem.queue_free()


		if hoverSlot:
			if combineData.subtype == "Magazine":

				if (hoverSlot.name == "Primary" && gameData.primary) || (hoverSlot.name == "Secondary" && gameData.secondary):
					rigManager.UpdateRig(true)
					ChangeMagazine(hoverSlot)
				else:
					rigManager.UpdateRig(false)
			else:
				rigManager.UpdateRig(false)

		PlayAttach()
		Reset()

func FastTransfer():

	if hoverGrid && hoverItem && container:

		if hoverGrid.get_parent().name == "Inventory":
			if AutoStack(hoverItem.slotData, containerGrid):
				hoverGrid.Pick(hoverItem)
				hoverItem.queue_free()
				Reset()
				PlayClick()
			elif AutoPlace(hoverItem, containerGrid, inventoryGrid, true):
				Reset()
				PlayClick()
			else:
				Reset()
				PlayError()


		elif hoverGrid.get_parent().name == "Container":
			if AutoStack(hoverItem.slotData, inventoryGrid):
				hoverGrid.Pick(hoverItem)
				hoverItem.queue_free()
				Reset()
				PlayClick()
			elif AutoPlace(hoverItem, inventoryGrid, containerGrid, true):
				Reset()
				PlayClick()
			else:
				Reset()
				PlayError()

func FastEquip():

	if hoverGrid && hoverItem:

		var targetSlot
		var swapNeeded = false


		var compatibleSlots = []


		for slot in equipment.get_children():
			if hoverItem.slotData.itemData.slots.has(slot.name):
				compatibleSlots.append(slot)


		if compatibleSlots:

			for slot in compatibleSlots:
				if slot.get_child_count() == 0:
					targetSlot = slot
					break


			if !targetSlot:
				targetSlot = compatibleSlots[0]
				swapNeeded = true


		if targetSlot && !swapNeeded:
			hoverGrid.Pick(hoverItem)
			Equip(hoverItem, targetSlot)
			Reset()
			PlayEquip()

		elif targetSlot && swapNeeded:
			hoverGrid.Pick(hoverItem)
			AutoPlace(Unequip(targetSlot), inventoryGrid, null, true)
			Equip(hoverItem, targetSlot)
			Reset()
			PlayEquip()


	elif hoverSlot && hoverSlot.get_child_count() != 0:
		AutoPlace(Unequip(hoverSlot), inventoryGrid, null, true)
		Reset()
		PlayUnequip()

func FastDrop():

	if canUnequip:
		hoverSlot.hint.show()
		Drop(hoverSlot.get_child(0))
		Reset()


		rigManager.UpdateRig(false)


	elif hoverGrid && hoverItem:
		Drop(hoverGrid.Pick(hoverItem))
		Reset()



func ShowContext():

	if hoverItem || hoverSlot:

		if hoverItem:
			contextItem = hoverItem
			contextGrid = hoverGrid
			context.Update(contextItem.slotData)
			context.show()


		elif hoverSlot && hoverSlot.get_child_count() != 0:
			contextItem = hoverSlot.get_child(0)
			contextSlot = hoverSlot
			context.Update(contextItem.slotData)
			context.show()

func HideContext():
	context.hide()

func ContextEquip():
	var targetSlot
	var swapNeeded = false


	var compatibleSlots = []


	for slot in equipment.get_children():
		if contextItem.slotData.itemData.slots.has(slot.name):
			compatibleSlots.append(slot)


	if compatibleSlots:

		for slot in compatibleSlots:
			if slot.get_child_count() == 0:
				targetSlot = slot
				break


		if !targetSlot:
			targetSlot = compatibleSlots[0]
			swapNeeded = true


	if targetSlot && !swapNeeded:
		contextGrid.Pick(contextItem)
		Equip(contextItem, targetSlot)
		Reset()
		HideContext()
		PlayEquip()

	elif targetSlot && swapNeeded:
		contextGrid.Pick(contextItem)
		AutoPlace(Unequip(targetSlot), inventoryGrid, null, true)
		Equip(contextItem, targetSlot)
		Reset()
		HideContext()
		PlayEquip()

func ContextUnequip():

	AutoPlace(Unequip(contextSlot), inventoryGrid, null, true)


	Reset()
	HideContext()
	PlayUnequip()

func ContextSplit():

	var splitAmount = round(contextItem.slotData.amount / 2)


	contextItem.slotData.amount -= splitAmount
	contextItem.UpdateDetails()


	var newSlotData = SlotData.new()
	newSlotData.itemData = contextItem.slotData.itemData
	newSlotData.amount = splitAmount


	Create(newSlotData, contextGrid, true)
	HideContext()
	PlayStack()

func ContextTake():

	var takeAmount = contextItem.slotData.itemData.defaultAmount


	contextItem.slotData.amount -= takeAmount
	contextItem.UpdateDetails()


	var newSlotData = SlotData.new()
	newSlotData.itemData = contextItem.slotData.itemData
	newSlotData.amount = takeAmount


	Create(newSlotData, contextGrid, true)
	HideContext()
	PlayStack()

func ContextDrop():

	if contextGrid:
		Drop(contextGrid.Pick(contextItem))
		HideContext()
		Reset()

	elif contextSlot:
		contextSlot.hint.show()
		Drop(contextSlot.get_child(0))
		HideContext()
		Reset()


		rigManager.UpdateRig(false)

func ContextPlace():

	var map = get_tree().current_scene.get_node("/root/Map")
	var file = Database.get(contextItem.slotData.itemData.file)


	if !file:
		print("File not found: " + contextItem.slotData.itemData.name)


	else:
		var pickup = file.instantiate()
		map.add_child(pickup)


		if !gameData.decor:
			pickup.slotData.Update(contextItem.slotData)
			pickup.UpdateAttachments()


		if gameData.decor && contextItem.slotData.storage.size() != 0:
			pickup.storage = contextItem.slotData.storage
			pickup.storaged = true


		placer.ContextPlace(pickup)


		if contextGrid:
			contextGrid.Pick(contextItem)


		contextItem.reparent(self)
		contextItem.queue_free()


		if contextSlot:
			rigManager.UpdateRig(false)
			contextSlot.hint.show()

		Reset()
		HideContext()
		PlayClick()


		UIManager.ToggleInterface()

func ContextDestroy():
	contextGrid.Pick(contextItem)
	contextItem.queue_free()
	HideContext()
	PlayClick()
	PlayDrop()
	Reset()

func ContextTransfer():

	if contextGrid.get_parent().name == "Inventory":
		if AutoStack(contextItem.slotData, containerGrid):
				contextGrid.Pick(contextItem)
				contextItem.queue_free()
				Reset()
				HideContext()
				PlayClick()
		elif AutoPlace(contextItem, containerGrid, inventoryGrid, true):
			Reset()
			HideContext()
			PlayClick()
		else:
			Reset()
			HideContext()
			PlayError()


	elif contextGrid.get_parent().name == "Container":
		if AutoStack(contextItem.slotData, inventoryGrid):
				contextGrid.Pick(contextItem)
				contextItem.queue_free()
				Reset()
				HideContext()
				PlayClick()
		elif AutoPlace(contextItem, inventoryGrid, containerGrid, true):
			Reset()
			HideContext()
			PlayClick()
		else:
			Reset()
			HideContext()
			PlayError()

func ContextSeparate():

	var sourceItem = contextItem
	var sourceGrid = contextGrid

	for element in contextItem.slotData.itemData.input:

		var newSlotData = SlotData.new()
		newSlotData.itemData = element


		if contextGrid == inventoryGrid:
			Create(newSlotData, inventoryGrid, true)


		elif contextGrid == containerGrid:
			Create(newSlotData, containerGrid, true)


		elif contextGrid == catalogGrid:
			var newItem = item.instantiate()
			newItem.slotData.Update(newSlotData)
			add_child(newItem)
			Drop(newItem)


	sourceGrid.Pick(sourceItem)
	sourceItem.queue_free()
	HideContext()
	PlayClick()

func ContextSleep():

	contextGrid.Pick(contextItem)
	contextItem.reparent(self)
	contextItem.queue_free()


	HideContext()
	PlayClick()
	Reset()


	UIManager.ToggleInterface()


	Sleep()

func ContextRemove(nestedIndex):

	var contextAmmo = contextItem.slotData.amount


	var removeItem = contextItem.Remove(nestedIndex)


	var newSlotData = SlotData.new()
	newSlotData.itemData = removeItem


	if removeItem.subtype == "Magazine":
		newSlotData.amount = contextAmmo


	if removeItem.type == "Armor":
		newSlotData.condition = contextItem.slotData.condition
		contextItem.slotData.condition = 100.0


	if contextGrid:
		Create(newSlotData, contextGrid, true)
		HideContext()
		PlayAttach()


	elif contextSlot:

		if removeItem.subtype == "Magazine":

			if (contextSlot.name == "Primary" && gameData.primary) || (contextSlot.name == "Secondary" && gameData.secondary):
				rigManager.UpdateRig(true)
				ChangeMagazine(contextSlot)
			else:
				rigManager.UpdateRig(false)
		else:
			rigManager.UpdateRig(false)


		if removeItem.subtype == "Magazine":

			if rigManager.get_child_count() != 0:

				var rig = rigManager.get_child(0)

				if rig is WeaponRig:

					rig.UpdateBulletsDetach(contextAmmo)


		Create(newSlotData, inventoryGrid, true)
		HideContext()
		PlayAttach()

func ContextUse():

	Use(contextItem, contextGrid)
	HideContext()
	PlayClick()

func ContextUnload():

	if contextItem.slotData.itemData.subtype == "Magazine":
		UnloadMagazine(contextItem, contextGrid)
		HideContext()
		PlayClick()

	elif contextItem.slotData.itemData.type == "Weapon":
		UnloadWeapon(contextItem, contextGrid)
		HideContext()
		PlayClick()



func Use(targetItem, targetGrid):

	gameData.isOccupied = true


	PlayUse(targetItem.slotData.itemData)


	var newProgress = progress.instantiate()
	add_child(newProgress)
	newProgress.global_position = targetItem.global_position
	newProgress.size = targetItem.size


	newProgress.Use(4.0)
	activeProgress = newProgress


	await activeProgress.completed




	if activeProgress:

		character.Consume(targetItem.slotData.itemData)
		targetGrid.Pick(targetItem)
		targetItem.queue_free()


		activeProgress.queue_free()
		activeProgress = null
		gameData.isOccupied = false
		Reset()

func Charge(targetItem, sourceItem):

	gameData.isOccupied = true


	sourceItem.queue_free()


	var newProgress = progress.instantiate()
	add_child(newProgress)
	newProgress.global_position = targetItem.global_position
	newProgress.size = targetItem.size


	newProgress.Use(2.0)
	activeProgress = newProgress


	await activeProgress.completed




	if activeProgress:

		targetItem.slotData.condition = 100.0
		targetItem.UpdateDetails()
		PlayAttach()


		activeProgress.queue_free()
		activeProgress = null
		gameData.isOccupied = false
		Reset()

func Load(targetItem, sourceItem):

	gameData.isOccupied = true


	sourceItem.hide()


	var ammoNeeded = targetItem.slotData.itemData.maxAmount - targetItem.slotData.amount
	var ammoProvided = sourceItem.slotData.amount
	var ammoReturn = false
	var ammoToLoad = 0


	var ammoReturnGrid = returnGrid
	var ammoReturnPosition = returnPosition


	if ammoProvided > ammoNeeded:
		ammoReturn = true
		ammoToLoad = ammoNeeded

	else:
		ammoReturn = false
		ammoToLoad = ammoProvided


	var newProgress = progress.instantiate()
	add_child(newProgress)
	newProgress.global_position = targetItem.global_position
	newProgress.size = targetItem.size


	newProgress.Load(ammoToLoad)
	activeProgress = newProgress


	await activeProgress.completed




	if activeProgress:

		if ammoReturn:
			sourceItem.show()
			sourceItem.slotData.amount -= ammoNeeded
			sourceItem.UpdateDetails()
			sourceItem.global_position = ammoReturnPosition
			ammoReturnGrid.Place(sourceItem)

		else:
			sourceItem.queue_free()


		targetItem.slotData.amount += ammoToLoad
		targetItem.UpdateDetails()
		targetItem.UpdateSprite()
		PlayAttach()


		activeProgress.queue_free()
		activeProgress = null
		gameData.isOccupied = false
		Reset()

func UnloadMagazine(targetItem, targetGrid):

	gameData.isOccupied = true


	var ammoData = targetItem.slotData.itemData.compatible[0]
	var ammoToUnload = targetItem.slotData.amount


	var newProgress = progress.instantiate()
	add_child(newProgress)
	newProgress.global_position = targetItem.global_position
	newProgress.size = targetItem.size


	newProgress.Unload(ammoToUnload)
	activeProgress = newProgress


	await activeProgress.completed




	if activeProgress:

		targetItem.slotData.amount = 0
		targetItem.UpdateDetails()
		targetItem.UpdateSprite()


		var newSlotData = SlotData.new()
		newSlotData.itemData = ammoData
		newSlotData.amount = ammoToUnload


		if !AutoStack(newSlotData, targetGrid):
			Create(newSlotData, targetGrid, true)
			PlayStack()


		activeProgress.queue_free()
		activeProgress = null
		gameData.isOccupied = false
		Reset()

func UnloadWeapon(targetItem, targetGrid):

	gameData.isOccupied = true


	var ammoData = targetItem.slotData.itemData.ammo
	var ammoToUnload: int


	if targetItem.slotData.chamber:
		ammoToUnload = targetItem.slotData.amount + 1
	else:
		ammoToUnload = targetItem.slotData.amount


	var newProgress = progress.instantiate()
	add_child(newProgress)
	newProgress.global_position = targetItem.global_position
	newProgress.size = targetItem.size


	newProgress.Unload(ammoToUnload)
	activeProgress = newProgress


	await activeProgress.completed




	if activeProgress:

		targetItem.slotData.amount = 0
		targetItem.slotData.chamber = false
		targetItem.UpdateDetails()


		var newSlotData = SlotData.new()
		newSlotData.itemData = ammoData
		newSlotData.amount = ammoToUnload


		if !AutoStack(newSlotData, targetGrid):
			Create(newSlotData, targetGrid, true)
			PlayStack()


		activeProgress.queue_free()
		activeProgress = null
		gameData.isOccupied = false
		Reset()

func ChangeMagazine(targetSlot):

	gameData.isOccupied = true


	await get_tree().create_timer(0.1).timeout;
	var animationLength = rigManager.get_child(0).GetAnimationLength()


	var newProgress = progress.instantiate()
	add_child(newProgress)
	newProgress.global_position = targetSlot.global_position
	newProgress.size = targetSlot.size


	newProgress.Use(animationLength)
	activeProgress = newProgress


	await activeProgress.completed




	if activeProgress:

		activeProgress.queue_free()
		activeProgress = null
		gameData.isOccupied = false



func PlateCheck(penetration: int) -> bool:

	var rigSlot = equipmentUI.get_child(7)

	if rigSlot.get_child_count() != 0:

		var slotData = rigSlot.get_child(0).slotData


		if slotData.nested.size() != 0:
			for itemData in slotData.nested:


				if itemData.type == "Armor" && slotData.condition != 0:



					if itemData.protection > penetration:

						slotData.condition -= randi_range(15, 20)

						if slotData.condition <= 0:
							slotData.condition = 0
							PlayArmorBreak()

						rigSlot.get_child(0).UpdateDetails()


						return true
						break



					elif itemData.protection == penetration:

						slotData.condition -= randi_range(25, 35)

						if slotData.condition <= 0:
							slotData.condition = 0
							PlayArmorBreak()

						rigSlot.get_child(0).UpdateDetails()

						return true
						break



					elif itemData.protection < penetration:

						slotData.condition = 0
						PlayArmorBreak()

						rigSlot.get_child(0).UpdateDetails()

						return false
						break


	return false

func HelmetCheck(penetration: int) -> bool:

	var helmetSlot = equipmentUI.get_child(8)

	if helmetSlot.get_child_count() != 0:

		var slotData = helmetSlot.get_child(0).slotData


		if slotData.condition != 0:



			if slotData.itemData.protection > penetration:

				slotData.condition -= randi_range(15, 20)

				if slotData.condition <= 0:
					slotData.condition = 0
					PlayArmorBreak()

				helmetSlot.get_child(0).UpdateDetails()

				return true



			elif slotData.itemData.protection == penetration:

				slotData.condition -= randi_range(25, 35)

				if slotData.condition <= 0:
					slotData.condition = 0
					PlayArmorBreak()

				helmetSlot.get_child(0).UpdateDetails()

				return true



			elif slotData.itemData.protection < penetration:

				slotData.condition = 0
				PlayArmorBreak()

				helmetSlot.get_child(0).UpdateDetails()

				return false


	return false



func Hover():

	hoverItem = GetHoverItem()
	hoverGrid = GetHoverGrid()
	hoverSlot = GetHoverSlot()
	hoverEquipment = GetHoverEquipment()
	hoverInfo = GetHoverInfo()



	if itemDragged && hoverGrid && hoverItem && !returnSlot && !canCombine && !canCombineSwap && !canCombineStack && !canCombineLoad:
		var compatibility = TetrisCheck(hoverItem, itemDragged)

		if compatibility == 1 || compatibility == 2:
			canGridSwap = true
		else:
			canGridSwap = false
	else:
		canGridSwap = false



	if itemDragged && hoverSlot && hoverSlot.get_child_count() == 0 && itemDragged.slotData.itemData.slots.has(hoverSlot.name):
		canEquip = true
	else:
		canEquip = false



	if hoverSlot && !itemDragged && hoverSlot.get_child_count() != 0:
		canUnequip = true
	else:
		canUnequip = false



	if itemDragged && hoverSlot && hoverSlot.get_child_count() != 0 && itemDragged.slotData.itemData.slots.has(hoverSlot.name):
		canSlotSwap = true
	else:
		canSlotSwap = false



	if itemDragged && hoverItem:
		var compatibility = CombineCheck(hoverItem, itemDragged)

		if compatibility == 0:
			canCombine = false
			canCombineSwap = false
			canCombineLoad = false
			canCombineStack = false
			canCombineCharge = false
		elif compatibility == 1:
			canCombine = true
			canCombineSwap = false
			canCombineLoad = false
			canCombineStack = false
			canCombineCharge = false
		elif compatibility == 2:
			canCombine = false
			canCombineSwap = true
			canCombineLoad = false
			canCombineStack = false
			canCombineCharge = false
		elif compatibility == 3:
			canCombine = false
			canCombineSwap = false
			canCombineLoad = true
			canCombineStack = false
			canCombineCharge = false
		elif compatibility == 4:
			canCombine = false
			canCombineSwap = false
			canCombineLoad = false
			canCombineStack = true
			canCombineCharge = false
		elif compatibility == 5:
			canCombine = false
			canCombineSwap = false
			canCombineLoad = false
			canCombineStack = true
			canCombineCharge = true



	elif itemDragged && hoverSlot && hoverSlot.get_child_count() != 0:
		var compatibility = CombineCheck(hoverSlot.get_child(0), itemDragged)

		if compatibility == 0:
			canCombine = false
			canCombineSwap = false
			canCombineCharge = false
		elif compatibility == 1:
			canCombine = true
			canCombineSwap = false
			canCombineCharge = false
		elif compatibility == 2:
			canCombine = false
			canCombineSwap = true
			canCombineCharge = false
		elif compatibility == 5:
			canCombine = false
			canCombineCharge = true
	else:
		canCombine = false
		canCombineSwap = false
		canCombineLoad = false
		canCombineStack = false
		canCombineCharge = false

func Highlight():


	if contextItem:
		return

	if !hoverGrid && !hoverSlot:
		highlight.hide()
		return

	if hoverGrid:
		if !itemDragged && !hoverItem:
			highlight.hide()
			return

	if hoverSlot:
		if !canEquip && !canUnequip && !canSlotSwap && !canCombine && !canCombineSwap && !canCombineCharge:
			highlight.hide()
			return



	if canCombine || canCombineSwap:
		highlight.get_child(0).show()
	else:
		highlight.get_child(0).hide()

	if canCombineLoad:
		highlight.get_child(1).show()
	else:
		highlight.get_child(1).hide()

	if canCombineCharge:
		highlight.get_child(2).show()
	else:
		highlight.get_child(2).hide()



	if !itemDragged && hoverItem && hoverGrid:
		highlight.color = hover
		highlight.size = hoverItem.size
		highlight.global_position = hoverItem.global_position
		highlight.show()




	if itemDragged && hoverSlot && (canEquip || canCombine || canCombineSwap):
		highlight.color = valid
		highlight.size = hoverSlot.size
		highlight.global_position = hoverSlot.global_position
		highlight.show()


	if !itemDragged && hoverSlot && canUnequip:
		highlight.color = hover
		highlight.size = hoverSlot.size
		highlight.global_position = hoverSlot.global_position
		highlight.show()


	if itemDragged && hoverSlot && !canEquip && (canSlotSwap || canCombineSwap):
		highlight.color = swap
		highlight.size = hoverSlot.size
		highlight.global_position = hoverSlot.global_position
		highlight.show()


	if itemDragged && hoverSlot && canCombineCharge:
		highlight.color = valid
		highlight.size = hoverSlot.size
		highlight.global_position = hoverSlot.global_position
		highlight.show()



	if itemDragged && hoverGrid:


		if hoverItem && (canCombine || canCombineSwap || canGridSwap || canCombineStack || canCombineLoad):
			highlight.global_position = hoverItem.global_position
			highlight.size = hoverItem.size
			highlight.show()


			if canCombineSwap || canGridSwap:
				highlight.color = swap
			else:
				highlight.color = combine


		else:

			var itemPosition = itemDragged.global_position + Vector2(float(cellSize) / 2, float(cellSize) / 2)
			var gridPosition = hoverGrid.GetGridPosition(itemPosition)
			var itemSize = hoverGrid.GetGridSize(itemDragged)


			highlight.size = itemDragged.size
			highlight.global_position.x = gridPosition.x * cellSize + hoverGrid.global_position.x
			highlight.global_position.y = gridPosition.y * cellSize + hoverGrid.global_position.y
			highlight.show()


			if hoverGrid.CheckGridSpace(gridPosition.x, gridPosition.y, itemSize.x, itemSize.y):
				highlight.color = valid
			else:
				highlight.color = invalid



func AddToCatalog(itemData, storage):

	var newSlotData = SlotData.new()
	newSlotData.itemData = itemData


	if storage:
		newSlotData.storage = storage

	Create(newSlotData, catalogGrid, false)



func DisplayTime():

	var timeSlot = equipmentUI.get_child(18)


	if timeSlot.get_child_count() != 0:

		var hours = int(Simulation.time) / 100
		var minutes = int(Simulation.time) % 100
		minutes = int(floor(minutes / 5.0) * 5)


		if minutes >= 60:
			minutes = 0
			hours += 1


		hours = hours % 24


		timeSlot.get_child(0).condition.show()
		timeSlot.get_child(0).condition.text = "%02d:%02d" % [hours, minutes]

func Sleep():

	var sleepTime = randi_range(4, 8)


	Simulation.simulate = false
	gameData.isSleeping = true
	gameData.freeze = true


	UpdateSimulation(sleepTime * 100)
	PlayTransition()
	PlaySleep()

	await get_tree().create_timer(sleepTime).timeout;


	var newMessage = message.instantiate()
	get_tree().get_root().add_child(newMessage)
	newMessage.Text("You slept " + str(sleepTime) + " hours")


	Simulation.simulate = true
	gameData.isSleeping = false
	gameData.freeze = false

func UpdateSimulation(sleepTime):

	var currentTime = Simulation.time
	var combinedTime = currentTime + sleepTime
	var wakeTime: float


	if combinedTime >= 2400.0:
		wakeTime = combinedTime - 2400.0
		Simulation.day += 1
		Simulation.time = wakeTime
		Simulation.weatherTime -= sleepTime
		Loader.UpdateProgression()

	else:
		wakeTime = combinedTime
		Simulation.time = wakeTime
		Simulation.weatherTime -= sleepTime

	print("Current time: " + str(int(currentTime)) + " Sleep time: " + str(int(sleepTime)) + " Wake time: " + str(int(wakeTime)))



func Reset():

	itemDragged = null
	returnSlot = null
	returnGrid = null
	returnPosition = null
	returnRotated = false
	contextItem = null
	contextGrid = null
	contextSlot = null
	isInputting = false

func CombineCheck(targetItem, combineItem):



	if combineItem.slotData.itemData.file == targetItem.slotData.itemData.file && targetItem.slotData.itemData.stackable:
		var upcomingStack = combineItem.slotData.amount + targetItem.slotData.amount


		if upcomingStack <= targetItem.slotData.itemData.maxAmount:
			return 4




	for element in targetItem.slotData.itemData.compatible:

		if element.file == combineItem.slotData.itemData.file:



			if element.name == "Batteries" && targetItem.slotData.itemData.type == "Electronics":
				return 5



			if element.type == "Ammo" && targetItem.slotData.itemData.subtype == "Magazine":
				if targetItem.slotData.amount != targetItem.slotData.itemData.maxAmount:
					return 3
				else:
					return 0



			for nestedItem in targetItem.slotData.nested:
				if nestedItem.file == combineItem.slotData.itemData.file:
					return 2



			if targetItem.slotData.itemData.type == "Weapon":
				for nestedItem in targetItem.slotData.nested:
					if nestedItem.subtype == combineItem.slotData.itemData.subtype:
						return 2



			if combineItem.slotData.itemData.type == "Patch":
				for nestedItem in targetItem.slotData.nested:
					if nestedItem.type == "Patch":
						return 2



			if combineItem.slotData.itemData.type == "Medical":
				for nestedItem in targetItem.slotData.nested:
					if nestedItem.type == "Medical":
						return 2



			if combineItem.slotData.itemData.type == "Armor":
				for nestedItem in targetItem.slotData.nested:
					if nestedItem.type == "Armor":
						return 2




			return 1

	return 0

func TetrisCheck(A, B):
	if A.slotData.itemData.size == B.slotData.itemData.size:
		return 1
	elif A.slotData.itemData.size.x == B.slotData.itemData.size.y && A.slotData.itemData.size.y == B.slotData.itemData.size.x:
		return 2
	else:
		return 0

func GetMagazine(weaponData, weaponSlot, swapMagazine):
	var highestMagazine = null
	var highestAmount = 0


	for magazine in inventoryGrid.get_children():

		if magazine.slotData.itemData.subtype == "Magazine" and magazine.slotData.amount != 0 and weaponData.compatible.has(magazine.slotData.itemData):

			if magazine.slotData.amount > highestAmount:
				highestAmount = magazine.slotData.amount
				highestMagazine = magazine


	if highestMagazine != null:

		var weaponAmmo = weaponSlot.get_child(0).slotData.amount
		var magazineAmmo = highestMagazine.slotData.amount


		if swapMagazine:

			weaponSlot.get_child(0).slotData.amount = magazineAmmo

			highestMagazine.slotData.amount = weaponAmmo
			highestMagazine.UpdateSprite()


			if weaponSlot.get_child(0).slotData.amount != 0 && !weaponSlot.get_child(0).slotData.chamber:
				weaponSlot.get_child(0).slotData.chamber = true
				weaponSlot.get_child(0).slotData.amount -= 1


		else:

			weaponSlot.get_child(0).Combine(highestMagazine)

			inventoryGrid.Pick(highestMagazine)
			highestMagazine.queue_free()


		return true


	return false

func GetAmmo(weaponData, weaponSlot):

	for element in inventoryGrid.get_children():

		if element.slotData.itemData.type == "Ammo":

			if element.slotData.itemData.file == weaponData.ammo.file:

				if element.slotData.amount != 0:

					element.slotData.amount -= 1

					if element.slotData.amount == 0:
						inventoryGrid.Pick(element)
						element.queue_free()


				return true


	return false

func AutoPlace(targetItem, targetGrid, sourceGrid, usedrop):

	if sourceGrid:
		sourceGrid.Pick(targetItem)


	if !targetGrid.Spawn(targetItem):

		Rotate(targetItem)

		if !targetGrid.Spawn(targetItem):

			if sourceGrid:
				Rotate(targetItem)
				sourceGrid.Place(targetItem)
				return false

			else:
				if usedrop:
					Drop(targetItem)
					return false
				else:
					targetItem.queue_free()
					Reset()
					return false
	return true

func GetHoverItem():

	if inventoryGrid.is_visible_in_tree():
		for element in inventoryGrid.get_children():
			if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
				return element


	if containerGrid.is_visible_in_tree():
		for element in containerGrid.get_children():
			if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
				return element


	if catalogGrid.is_visible_in_tree():
		for element in catalogGrid.get_children():
			if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
				return element


	if supplyGrid.is_visible_in_tree():
		for element in supplyGrid.get_children():
			if element.get_global_rect().has_point(mousePosition) && element is Item && element != itemDragged && !context.visible:
				return element


	return null

func GetHoverGrid():

	var grids = [inventoryGrid, containerGrid, catalogGrid, supplyGrid]


	for grid in grids:
		if grid.is_visible_in_tree():
			if grid.get_global_rect().has_point(mousePosition) && grid is Grid:
				return grid


	return null

func GetHoverSlot():

	for slot in equipment.get_children():
		if slot.is_visible_in_tree():
			if slot.get_global_rect().has_point(mousePosition) && slot is Slot:
				return slot


	return null

func GetHoverEquipment():

	for slot in equipment.get_children():
		if slot.is_visible_in_tree():
			if slot.get_global_rect().has_point(mousePosition) && slot is Slot:
				if slot.get_child_count() != 0:
					return slot.get_child(0)


	return null

func GetHoverInfo():

	for info in hoverInfos:
		if info.is_visible_in_tree():
			if info.get_global_rect().has_point(mousePosition):
				return info


	return null



func PlayUse(itemData: ItemData):
	if itemData.audio:
		var use = audioInstance2D.instantiate()
		add_child(use)
		use.PlayInstance(itemData.audio)

func PlayDrop():
	var drop = audioInstance2D.instantiate()
	add_child(drop)
	drop.PlayInstance(audioLibrary.UIDrop)

func PlayClick():
	if gameData.interface:
		var click = audioInstance2D.instantiate()
		add_child(click)
		click.PlayInstance(audioLibrary.UIClick)

func PlayError():
	var error = audioInstance2D.instantiate()
	add_child(error)
	error.PlayInstance(audioLibrary.UIError)

func PlayEquip():
	var equip = audioInstance2D.instantiate()
	add_child(equip)
	equip.PlayInstance(audioLibrary.UIEquip)

func PlayUnequip():
	var unequip = audioInstance2D.instantiate()
	add_child(unequip)
	unequip.PlayInstance(audioLibrary.UIUnequip)

func PlayAttach():
	var attach = audioInstance2D.instantiate()
	add_child(attach)
	attach.PlayInstance(audioLibrary.UIAttach)

func PlayStack():
	var stack = audioInstance2D.instantiate()
	add_child(stack)
	stack.PlayInstance(audioLibrary.UIStack)

func PlayArmorBreak():
	var armorBreak = audioInstance2D.instantiate()
	add_child(armorBreak)
	armorBreak.PlayInstance(audioLibrary.armorBreak)

func PlaySleep():
	var audio = audioInstance2D.instantiate()
	add_child(audio)
	audio.PlayInstance(audioLibrary.sleep)

func PlayTransition():
	var transition = audioInstance2D.instantiate()
	add_child(transition)
	transition.PlayInstance(audioLibrary.transition)

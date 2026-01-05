extends Node3D
class_name LootContainer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var LT_Master: LootTable = preload("res://Loot/LT_Master.tres")

@export_group("Container")
@export var containerName: String
@export var containerSize = Vector2(8, 13)
@export var audioEvent: AudioEvent

@export_group("Loot")
@export var generate: bool
@export var civilian = false
@export var military = false
@export var stash = false
@export var limit: String
@export var exclude: String
@export var smallItems = false
@export var minRoll = 1
@export var maxRoll = 100

@export_group("Debug")
@export var debug: LootTable
@export var force = false
@export var locked = false
@export var fill = false


var rarityRoll = 100
var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]


var loot: Array[SlotData]
var storage: Array[SlotData]
var storaged = false

func _ready():
	if generate && !fill && !force && !locked:
		ClearBuckets()
		#FillBuckets()
		#GenerateLoot()

	if force && debug:
		DebugForce()

	if fill && debug:
		DebugFill()

	if stash:

		var stashRoll = randi_range(1, 10)


		if stashRoll != 1:
			global_position.y = -100.0
			hide()

		else:
			print("Stash visible")

func ClearBuckets():
	commonBucket.clear()
	uncommonBucket.clear()
	rareBucket.clear()
	legendaryBucket.clear()

func FillBuckets():
	if LT_Master.items.size() != 0:
		for item in LT_Master.items:

			if item.type != "Furniture":

				if (civilian && item.civilian) || (military && item.military):


					if smallItems:

						var tetrisSize = item.size.x + item.size.y
						if tetrisSize > 3: break


					if limit == "" && exclude != item.type:
						if item.rarity == item.Rarity.Common: commonBucket.append(item)
						elif item.rarity == item.Rarity.Uncommon: uncommonBucket.append(item)
						elif item.rarity == item.Rarity.Rare: rareBucket.append(item)
						elif item.rarity == item.Rarity.Legendary: legendaryBucket.append(item)

					elif limit == item.type:
						if item.rarity == item.Rarity.Common: commonBucket.append(item)
						elif item.rarity == item.Rarity.Uncommon: uncommonBucket.append(item)
						elif item.rarity == item.Rarity.Rare: rareBucket.append(item)
						elif item.rarity == item.Rarity.Legendary: legendaryBucket.append(item)

func GenerateLoot():

	rarityRoll = randi_range(minRoll, maxRoll)




	if rarityRoll == 1:

		var legendaryPicks = 1


		if legendaryBucket.size() != 0:

			for pick in legendaryPicks:
				var randomPick = randi_range(0, legendaryBucket.size() - 1)
				CreateLoot(legendaryBucket[randomPick])




	if rarityRoll >= 2 && rarityRoll <= 5:


		var rarePicks = 1


		if rareBucket.size() != 0:

			for pick in rarePicks:
				var randomPick = randi_range(0, rareBucket.size() - 1)
				CreateLoot(rareBucket[randomPick])




	if rarityRoll >= 6 && rarityRoll <= 20:


		var uncommonPicks = randi_range(1, 2)


		if uncommonBucket.size() != 0:

			for pick in uncommonPicks:
				var randomPick = randi_range(0, uncommonBucket.size() - 1)
				CreateLoot(uncommonBucket[randomPick])




	if rarityRoll <= 50:


		var commonPicks = randi_range(0, 5)


		if commonBucket.size() != 0:

			for pick in commonPicks:
				var randomPick = randi_range(0, commonBucket.size() - 1)
				CreateLoot(commonBucket[randomPick])




	if rarityRoll == 100:


		var rarePicks = randi_range(1, 2)
		var uncommonPicks = randi_range(2, 4)
		var commonPicks = randi_range(5, 10)


		if rareBucket.size() != 0:

			for pick in rarePicks:
				var randomPick = randi_range(0, rareBucket.size() - 1)
				CreateLoot(rareBucket[randomPick])


		if uncommonBucket.size() != 0:

			for pick in uncommonPicks:
				var randomPick = randi_range(0, uncommonBucket.size() - 1)
				CreateLoot(uncommonBucket[randomPick])


		if commonBucket.size() != 0:

			for pick in commonPicks:
				var randomPick = randi_range(0, commonBucket.size() - 1)
				CreateLoot(commonBucket[randomPick])

func Interact():

	if !locked:
		var UIManager = get_tree().current_scene.get_node("/root/Map/Core/UI")
		UIManager.OpenContainer(self)
		ContainerAudio()

func UpdateTooltip():
	if locked:
		gameData.tooltip = containerName + " [Locked]"
	else:
		gameData.tooltip = containerName + " [Open]"

func CreateLoot(item: ItemData):

	var newSlotData = SlotData.new()
	newSlotData.itemData = item

	if gameData.tutorial:

		if item.defaultAmount != 0 && item.subtype != "Magazine":
			newSlotData.amount = item.defaultAmount
	else:

		if item.defaultAmount != 0:
			newSlotData.amount = randi_range(1, item.defaultAmount)

		if item.type == "Weapon" || item.type == "Armor" || item.subtype == "Light" || item.subtype == "NVG":
			newSlotData.condition = randi_range(50, 100)


	loot.append(newSlotData)

func Storage(containerGrid: Grid):

	storaged = true

	storage.clear()

	for item in containerGrid.get_children():

		var newSlotData = SlotData.new()
		newSlotData.Update(item.slotData)

		newSlotData.GridSave(item.position, item.rotated)

		storage.append(newSlotData)



func DebugFill():
	for index in 40:
		var randomPick = randi_range(0, debug.items.size() - 1)
		CreateLoot(debug.items[randomPick])

func DebugForce():
	for index in debug.items.size():
		CreateLoot(debug.items[index])



func ContainerAudio():
	var audio = audioInstance2D.instantiate()
	add_child(audio)
	audio.PlayInstance(audioEvent)

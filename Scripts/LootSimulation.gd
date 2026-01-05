extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var LT_Master: LootTable = preload("res://Loot/LT_Master.tres")

@export_group("Loot")
@export var generate: bool
@export var civilian = false
@export var military = false
@export var limit: String
@export var exclude: String


var rarityRoll = 100
var commonBucket: Array[ItemData]
var uncommonBucket: Array[ItemData]
var rareBucket: Array[ItemData]
var legendaryBucket: Array[ItemData]


var loot: Array[ItemData]

func _ready():
    var gizmo = get_child(0)
    gizmo.hide()

    if generate:
        Clear()
        FillBuckets()
        GenerateLoot()
        SpawnItems()

func Clear():
    commonBucket.clear()
    uncommonBucket.clear()
    rareBucket.clear()
    legendaryBucket.clear()

func FillBuckets():
    if LT_Master.items.size() != 0:
        for item in LT_Master.items:

            if item.type != "Furniture":

                if (civilian && item.civilian) || (military && item.military):

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

    rarityRoll = randi_range(1, 100)




    if rarityRoll == 1:


        var legendaryPicks = 1


        if legendaryBucket.size() != 0:

            for pick in legendaryPicks:
                var randomPick = randi_range(0, legendaryBucket.size() - 1)
                loot.append(legendaryBucket[randomPick])




    if rarityRoll >= 2 && rarityRoll <= 5:


        var rarePicks = 1


        if rareBucket.size() != 0:

            for pick in rarePicks:
                var randomPick = randi_range(0, rareBucket.size() - 1)
                loot.append(rareBucket[randomPick])




    if rarityRoll >= 6 && rarityRoll <= 20:


        var uncommonPicks = randi_range(1, 2)


        if uncommonBucket.size() != 0:

            for pick in uncommonPicks:
                var randomPick = randi_range(0, uncommonBucket.size() - 1)
                loot.append(uncommonBucket[randomPick])




    if rarityRoll <= 50:


        var commonPicks = randi_range(0, 5)


        if commonBucket.size() != 0:

            for pick in commonPicks:
                var randomPick = randi_range(0, commonBucket.size() - 1)
                loot.append(commonBucket[randomPick])




    if rarityRoll == 100:


        var rarePicks = 1
        var uncommonPicks = 2
        var commonPicks = 10


        if rareBucket.size() != 0:

            for pick in rarePicks:
                var randomPick = randi_range(0, rareBucket.size() - 1)
                loot.append(rareBucket[randomPick])


        if uncommonBucket.size() != 0:

            for pick in uncommonPicks:
                var randomPick = randi_range(0, uncommonBucket.size() - 1)
                loot.append(uncommonBucket[randomPick])


        if commonBucket.size() != 0:

            for pick in commonPicks:
                var randomPick = randi_range(0, commonBucket.size() - 1)
                loot.append(commonBucket[randomPick])

func SpawnItems():
    if loot.size() != 0:
        for itemData in loot:

            var file = Database.get(itemData.file)
            if !file:
                print("File not found: " + itemData.file)
                return


            var pickup = Database.get(itemData.file).instantiate()
            add_child(pickup)


            var dropDirection = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
            pickup.Unfreeze()
            pickup.linear_velocity = dropDirection * 10.0


            var newSlotData = SlotData.new()
            newSlotData.itemData = itemData


            if itemData.defaultAmount != 0:
                newSlotData.amount = randi_range(1, itemData.defaultAmount)

            if itemData.type == "Weapon" || itemData.type == "Armor" || itemData.subtype == "Light" || itemData.subtype == "NVG":
                newSlotData.condition = randi_range(50, 100)


            pickup.slotData = newSlotData

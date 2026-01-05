extends Resource
class_name SlotDataL

@export var itemData: ItemData
@export var condition = 100.0
@export var index = 0

@export_group("Armor")
@export var armor: ItemData

@export_group("Weapon")
@export var ammo = 0
@export var chamber = 0
@export var firemode = 1
@export var position = 0.0
@export var zoom = 1
@export var optic: AttachmentData
@export var muzzle: AttachmentData

func Update(slotData: SlotData):
    itemData = slotData.itemData
    condition = slotData.condition
    ammo = slotData.ammo
    chamber = slotData.chamber
    firemode = slotData.firemode
    armor = slotData.armor
    position = slotData.position
    zoom = slotData.zoom
    optic = slotData.optic
    muzzle = slotData.muzzle

func Reset():
    itemData = null
    condition = 100.0
    ammo = 0
    chamber = 0
    firemode = 1
    armor = null
    position = 0.0
    zoom = 1
    optic = null
    muzzle = null
    index = 0

extends Resource
class_name ItemDataL

@export_group("Naming")
@export var file: String
@export var name: String
@export var abbreviation: String

@export_group("Stats")
@export var type: String
enum ItemRarity{Common, Uncommon, Rare, Legendary}
@export var rarity = ItemRarity.Common
@export var weight = 1.0
@export var value = 1.0

@export_group("Icons")
@export var icon: Texture2D
@export var weapon: Texture2D

@export_group("Use")
@export var usable = false
@export var phrase: String
@export var time = 0.0
@export var used: ItemData
@export var audio: AudioEvent

@export_group("Vitals")
@export var health = 0.0
@export var energy = 0.0
@export var hydration = 0.0
@export var temperature = 0.0

@export_group("Medical")
@export var bleeding = false
@export var fracture = false
@export var burn = false
@export var rupture = false
@export var headshot = false

@export_group("Equipment")
@export var equippable = false
@export var layer: Texture2D
@export var material: Material
@export var index = 0
@export var capacity = 0.0

@export_group("Ammo")
@export var boxSize = 0
@export var maxStack = 0

@export_group("Armor")
@export var plate = false
@export var carrier = false
@export var helmet = false
@export var protection = 0
@export var rating: String

@export_group("Crafting")
@export var tool = false
@export var proximity = false
@export var remains = false

@export_group("Compatibility")
@export_multiline var compatibility: String










@export_group("Placement")
@export var defaultOffset: Vector3
@export var defaultRotation = 0.0
@export var wallOffset = 0.0

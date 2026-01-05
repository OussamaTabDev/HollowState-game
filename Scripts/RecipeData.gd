extends Resource
class_name RecipeData

@export var name: String
@export var locked: bool
@export var shelter: bool
@export var workbench: bool
@export var tester: bool
@export var heat: bool
@export var time: float
@export var loop: AudioEvent
@export var end: AudioEvent
@export var input: Array[ItemData]
@export var output: Array[ItemData]

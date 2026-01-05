extends Resource
class_name TaskData

@export var name: String
@export var difficulty: String
@export_multiline var description: String
@export var deliver: Array[ItemData]
@export var receive: Array[ItemData]

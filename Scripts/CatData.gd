extends ItemData
class_name CatData

@export var meowLow: Resource
@export var meowHigh: Resource

enum MeowDirection{X, Y, Z}
@export var meowDirection = MeowDirection.X
@export var meowRotation: Vector2

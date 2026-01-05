@tool
extends Node3D

@export var attachmentData: AttachmentData
@export var reticle: Material
@export var secondary: Node3D

@export var calculate: bool = false:
    set = ExecuteCalculate

@export_group("Abilities")
@export var railMovement = false
@export var slideFollow = false

@export_group("Rail")
@export var minPosition = 0.0
@export var maxPosition = 0.0

@export_group("Values")
@export var defaultPosition = 0.0
@export var slideOffsetY = 0.0
@export var slideOffsetZ = 0.0

func ExecuteCalculate(_value: bool) -> void :
    defaultPosition = position.z

    if slideFollow:
        var skeleton = owner.skeleton
        var slideTransform = skeleton.get_bone_global_pose(owner.slideIndex)
        var slidePosition = skeleton.to_global(slideTransform.origin)
        slideOffsetY = position.y - slidePosition.y
        slideOffsetZ = position.z - slidePosition.z

    calculate = false

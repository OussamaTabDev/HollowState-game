extends Node3D
class_name Hitbox

@export var type: String

func ApplyDamage(damage: float):
    var finalDamage

    if type == "Head":
        finalDamage = 100
    elif type == "Torso":
        finalDamage = damage
    elif type == "Leg_L" || type == "Leg_R":
        finalDamage = damage / 2

    owner.WeaponDamage(type, finalDamage)

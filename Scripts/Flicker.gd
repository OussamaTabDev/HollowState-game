@tool
extends OmniLight3D

@export var maxEnergy = 1.0
@export var minEnergy = 1.0
@export var frequency = 0.1
var flickerTimer = 0.0
var targetEnergy = 0.0

func _process(delta):
    flickerTimer += delta

    if flickerTimer > frequency:
        targetEnergy = randf_range(minEnergy, maxEnergy)
        flickerTimer = 0.0

    light_energy = lerpf(light_energy, targetEnergy, delta * 4.0)

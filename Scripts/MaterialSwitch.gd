extends Node3D

@export var interior = false
@export var interiorMaterial: Material
@export var meshes: Array[MeshInstance3D]

func _ready():
    if interior:
        for mesh in meshes:
            mesh.set_surface_override_material(0, interiorMaterial)

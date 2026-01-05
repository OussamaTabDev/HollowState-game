@tool
extends Node3D

@export var high = Mesh
@export var low = Mesh

func Low():
    var mesh: MeshInstance3D = get_child(0)
    mesh.mesh = low

func High():
    var mesh: MeshInstance3D = get_child(0)
    mesh.mesh = high

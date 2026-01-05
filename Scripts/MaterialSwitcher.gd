extends Node3D

@export var target: Node3D
@export var debug: Material
@export var before: Material
@export var after: Material


func _input(event):

    if Input.is_key_pressed(KEY_1):
        target.set_surface_override_material(0, debug)

    if Input.is_key_pressed(KEY_2):
        target.set_surface_override_material(0, before)

    if Input.is_key_pressed(KEY_3):
        target.set_surface_override_material(0, after)

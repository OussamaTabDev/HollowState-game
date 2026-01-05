extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var gameData = preload("res://Resources/GameData.tres")


var pickup
var interface


var revivalTime = 30.0
var revivalTimer = 0.0

func _physics_process(delta) -> void :
    revivalTimer += delta


    if revivalTimer > revivalTime:
        queue_free()


    if global_position.y < -99:
        Revive()

func Revive():
    var rigidbody = pickup.get_child(0)
    rigidbody.rotation_degrees = Vector3.ZERO
    rigidbody.linear_velocity = Vector3.ZERO
    rigidbody.angular_velocity = Vector3.ZERO
    rigidbody.global_position = gameData.playerPosition + Vector3(0, 1, 0)
    ReviveAudio()

func ReviveAudio():
    var revive = audioInstance2D.instantiate()
    add_child(revive)
    revive.PlayInstance(audioLibrary.revive)

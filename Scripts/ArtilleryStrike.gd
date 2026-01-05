extends Node3D


var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")
var audioInstance3D = preload("res://Resources/AudioInstance3D.tscn")
var gameData = preload("res://Resources/GameData.tres")
var explosion = preload("res://Effects/Explosion.tscn")

var strikeArea = 50
var strikeHeight = 100
var strikes = 100
var strikeTime = 0

func _ready():

    var randomPosition = Vector3(randi_range(-300, 300), strikeHeight, randi_range(-300, 300))
    global_position = randomPosition
    strikeTime = randf_range(0.1, 1.0)

func _physics_process(delta):
    strikeTime -= delta

    if strikeTime <= 0:
        Strike()
        strikeTime = randf_range(0.5, 2.0)

func Strike():
    if strikes > 0:

        var ray = PhysicsRayQueryParameters3D.new()


        var strikeOffset = Vector3(randf_range( - strikeArea / 2.0, strikeArea / 2.0), 0, randf_range( - strikeArea / 2.0, strikeArea / 2.0))
        ray.from = global_position + strikeOffset
        ray.to = ray.from + Vector3(0, -200, 0)


        var spaceState = get_world_3d().direct_space_state
        var hit = spaceState.intersect_ray(ray)

        if hit:
            Incoming(hit.position)
            strikes -= 1
    else:
        print("Strike Ended")
        queue_free()



func Incoming(hitPosition):
    var effect = explosion.instantiate()
    get_tree().get_root().add_child(effect)
    effect.position = hitPosition + Vector3(0, 0.5, 0)
    effect.Explode()

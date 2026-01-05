extends Node3D

@onready var leftPropeller = $Propeller_L
@onready var rightPropeller = $Propeller_R
@onready var audio = $Audio
@onready var airdrop: RigidBody3D = $Airdrop

var passed = false
var dropped = false
var fallen = false

var audioThreshold = 1800.0
var dropThreshold = 100.0
var flyHeight = 200.0
var flySpeed = 100.0

var parachute
var ray

func _ready():
    InitializeDrop()
    var randomPosition = randf_range(-2000, 2000)
    var randomDirection = randi_range(0, 1)

    if randomDirection == 0:
        global_position = Vector3(2000, flyHeight, randomPosition)
    else:
        global_position = Vector3(-2000, flyHeight, randomPosition)

    look_at(Vector3(0, flyHeight, 0), Vector3.UP, true)

func InitializeDrop():
    dropThreshold = randf_range(1, 250)
    ray = airdrop.get_node("Ray")
    parachute = airdrop.get_node("Parachute")
    parachute.scale = Vector3.ZERO
    airdrop.hide()
    airdrop.sleeping = true
    airdrop.can_sleep = true
    airdrop.freeze = true

func _physics_process(delta):
    RotorBlades(delta)

    global_position += transform.basis.z * delta * flySpeed
    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))


    if distanceToCenter < audioThreshold && !passed:
        Pass()

    if distanceToCenter < dropThreshold && !dropped:
        Drop()

    if ray.is_colliding() && dropped:
        Fall()


    if dropped && !fallen:
        parachute.scale = lerp(parachute.scale, Vector3.ONE, delta)


    if fallen:
        parachute.scale = lerp(parachute.scale, Vector3.ZERO, delta * 2.0)


    if distanceToCenter > 2000 && fallen && parachute.scale < Vector3(0.01, 0.01, 0.01):
        queue_free()

func Pass():
    audio.play()
    passed = true

func Drop():
    airdrop.show()
    airdrop.reparent(get_tree().get_root())
    airdrop.linear_velocity = transform.basis.z * flySpeed
    airdrop.sleeping = false
    airdrop.can_sleep = false
    airdrop.freeze = false
    dropped = true

func Fall():
    airdrop.gravity_scale = 2.0
    airdrop.angular_velocity = Vector3(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
    fallen = true

func RotorBlades(delta):
    leftPropeller.rotation.z += delta * 20.0
    rightPropeller.rotation.z += delta * 20.0

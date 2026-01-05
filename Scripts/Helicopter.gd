extends Node3D


var gameData = preload("res://Resources/GameData.tres")


@export var parts: Node3D
@export var mainRotor: Node3D
@export var tailRotor: Node3D


@onready var audio: AudioStreamPlayer3D = $Audio


const message = preload("res://UI/Elements/Message.tscn")


var flyby = false
var patrol = false
var moveSpeed = 0.0
var rotationSpeed = 0.4
var distanceToWaypoint = 0.0
var waypoint: Vector3
var isRotating = false
var rotationTime = 10.0
var rotationTimer = 0.0
var flyHeight = 150.0
var flySpeed = 75.0

@export_group("Searchlight")
@export var searchlightSpeed = 0.5
@export_range(0, 180, 1) var minAngleX = 45.0
@export_range(0, 180, 1) var maxAngleX = 90.0
@export_range(-180, 180, 1) var minAngleY = -90.0
@export_range(-180, 180, 1) var maxAngleY = 90.0
@onready var searchlight: Node3D = $Searchlight
@onready var detector: Area3D = $Searchlight / Detector
@onready var spot: SpotLight3D = $Searchlight / Spot
@onready var omni: OmniLight3D = $Searchlight / Omni
var searchlightTarget: Vector3
var searchlightTimer = 0.0
var detectionTimer = 0.0
var evade = false
var spotted = false
var AISpawner

func _ready():

    await get_tree().create_timer(0.1).timeout;


    AISpawner = get_tree().current_scene.get_node("/root/Map/AI")


    var randomPosition = randf_range(-2000, 2000)
    var randomDirection = randi_range(0, 1)


    if randomDirection == 0:
        global_position = Vector3(2000, flyHeight, randomPosition)
    else:
        global_position = Vector3(-2000, flyHeight, randomPosition)

    look_at(Vector3(0, flyHeight, 0), Vector3.UP, true)


    patrol = true
    SetWaypoint()
    SetSearchlightTarget()



func _physics_process(delta):
    RotorBlades(delta)

    if flyby:
        Flyby(delta)
    if patrol:
        Patrol(delta)
    if searchlight:
        Searchlight(delta)



func Flyby(delta):
    global_position += transform.basis.z * delta * flySpeed
    parts.rotation_degrees.x = 10.0

    var distanceToCenter = global_position.distance_to(Vector3(0, flyHeight, 0))

    if distanceToCenter > 4000:
        queue_free()

func Patrol(delta):

    if !isRotating:

        if spotted:
            moveSpeed = lerp(moveSpeed, 0.0, delta)
            parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 0.0, delta)

        else:
            global_position = position.move_toward(waypoint, delta * moveSpeed)
            parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 10.0, delta)
            distanceToWaypoint = position.distance_to(waypoint)

            if distanceToWaypoint < 50.0:
                moveSpeed = lerp(moveSpeed, 5.0, delta)
            else:
                moveSpeed = lerp(moveSpeed, 25.0, delta)

            if distanceToWaypoint < 1.0:
                isRotating = true
                SetWaypoint()


    if isRotating:
        moveSpeed = lerp(moveSpeed, 0.0, delta)
        parts.rotation_degrees.x = lerp(parts.rotation_degrees.x, 0.0, delta)

        var waypointDirection = Vector3(waypoint.x, 0.0, waypoint.z) - global_position
        rotation.y = lerp_angle(rotation.y, atan2(waypointDirection.x, waypointDirection.z), delta * rotationSpeed)
        rotationTimer += delta

        if rotationTimer >= rotationTime:
            rotationTimer = 0.0
            isRotating = false

func RotorBlades(delta):
    mainRotor.rotation.y += delta * 15.0
    tailRotor.rotation.x += delta * 20.0

func SetWaypoint():
    waypoint = Vector3(randf_range(-1000, 1000), flyHeight, randf_range(-1000, 1000))



func Searchlight(delta):

    if gameData.TOD == 4:

        ActivateSearchlight()


        searchlightTimer += delta
        detectionTimer += delta


        if spotted:
            searchlight.look_at(gameData.playerPosition, Vector3.UP, true)

        else:

            if searchlightTimer > 5.0:
                SetSearchlightTarget()
                searchlightTimer = 0.0


            if detectionTimer > 0.2:
                Detection()
                detectionTimer = 0.0


            searchlight.rotation_degrees = searchlight.rotation_degrees.lerp(searchlightTarget, searchlightSpeed * delta)

    else:
        DeactivateSearchlight()

func ActivateSearchlight():
    searchlight.show()
    detector.monitoring = true
    spot.spot_range = 400.0
    omni.omni_range = 5.0

func DeactivateSearchlight():
    searchlight.hide()
    detector.monitoring = false
    spot.spot_range = 0.0
    omni.omni_range = 0.0

func Detection():
    var overlaps = detector.get_overlapping_bodies()

    if overlaps.size() != 0:
        for overlap in overlaps:
            if overlap.name == "Controller" && !spotted:
                Spotted()

func Spotted():

    spotted = true


    detector.set_collision_mask_value(2, false)


    AISpawner.AlertGuards()


    var newMessage = message.instantiate()
    get_tree().get_root().add_child(newMessage)
    newMessage.Text("You have been spotted!")


    await get_tree().create_timer(10.0).timeout;
    spotted = false


    await get_tree().create_timer(20.0).timeout;
    detector.set_collision_mask_value(2, true)

func SetSearchlightTarget():
    var targetRotationX = randf_range(minAngleX, maxAngleX)
    var targetRotationY = randf_range(minAngleY, maxAngleY)
    searchlightTarget = Vector3(targetRotationX, targetRotationY, 0)

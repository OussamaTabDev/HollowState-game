extends Node3D


var gameData = preload("res://Resources/GameData.tres")


var weaponData: Resource
var collision: RayCast3D

var targetPosition = Vector3.ZERO
var targetRotation = Vector3.ZERO
var lerpSpeed = 7.5

var aimToggle = false
var canted = false
var offset = 0.0

func _ready():
    weaponData = owner.weaponData
    collision = owner.collision
    position = weaponData.lowPosition
    rotation_degrees.x = weaponData.lowRotation.x
    rotation_degrees.y = weaponData.lowRotation.y
    rotation_degrees.z = weaponData.lowRotation.z

func _input(event):
    if gameData.freeze || gameData.isAiming || gameData.isInspecting || gameData.isPlacing || Input.is_action_pressed("rail_movement"):
        return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            gameData.weaponPosition = 2

        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            gameData.weaponPosition = 1

func _physics_process(delta):
    if gameData.freeze:
        return


    if gameData.isPlacing:
        gameData.weaponPosition = 1
        targetPosition = weaponData.lowPosition
        targetRotation = weaponData.lowRotation


    elif gameData.isInspecting:
        targetPosition = weaponData.inspectPosition
        targetRotation = weaponData.inspectRotation

    else:


        if collision.is_colliding():
            gameData.isColliding = true
        else:
            gameData.isColliding = false


        if gameData.isColliding:
            targetPosition = weaponData.collisionPosition
            targetRotation = weaponData.collisionRotation


        else:


            if gameData.isRunning || gameData.isPreparing || gameData.isReloading && (gameData.weaponType == 0 || gameData.weaponType == 1):

                if gameData.weaponPosition == 1:
                    aimToggle = false
                    gameData.isAiming = false
                    gameData.isCanted = false
                    targetPosition = weaponData.lowPosition
                    targetRotation = weaponData.lowRotation
                    lerpSpeed = 6.0

                elif gameData.weaponPosition == 2:
                    aimToggle = false
                    gameData.isAiming = false
                    gameData.isCanted = false
                    targetPosition = weaponData.highPosition
                    targetRotation = weaponData.highRotation
                    lerpSpeed = 6.0
            else:


                if gameData.aimMode == 1:
                    if Input.is_action_pressed(("aim")):

                        if Input.is_action_just_pressed(("canted")) && !gameData.interaction:
                            canted = !canted

                        if canted:
                            gameData.isCanted = true
                            gameData.isAiming = false
                            targetPosition = weaponData.cantedPosition
                            targetRotation = weaponData.cantedRotation
                            lerpSpeed = 6.0
                        else:
                            gameData.isCanted = false
                            gameData.isAiming = true
                            targetPosition = weaponData.aimPosition - Vector3(0, get_parent().aimOffset, 0)
                            targetRotation = weaponData.aimRotation
                            lerpSpeed = 7.5

                    elif !gameData.isColliding:
                        gameData.isAiming = false
                        gameData.isCanted = false

                        if gameData.weaponPosition == 2:
                            targetPosition = weaponData.highPosition
                            targetRotation = weaponData.highRotation
                            lerpSpeed = 6.0
                        else:
                            targetPosition = weaponData.lowPosition
                            targetRotation = weaponData.lowRotation
                            lerpSpeed = 6.0


                elif gameData.aimMode == 2:
                    if Input.is_action_just_pressed(("aim")):

                        aimToggle = !aimToggle

                    if aimToggle:
                        if Input.is_action_just_pressed(("canted")) && !gameData.interaction:
                            canted = !canted

                        if canted:
                            gameData.isCanted = true
                            gameData.isAiming = false
                            targetPosition = weaponData.cantedPosition
                            targetRotation = weaponData.cantedRotation
                            lerpSpeed = 6.0
                        else:
                            gameData.isCanted = false
                            gameData.isAiming = true
                            targetPosition = weaponData.aimPosition - Vector3(0, get_parent().aimOffset, 0)
                            targetRotation = weaponData.aimRotation
                            lerpSpeed = 7.5
                    else:
                        if !gameData.isColliding:
                            gameData.isAiming = false
                            gameData.isCanted = false

                            if gameData.weaponPosition == 2:
                                targetPosition = weaponData.highPosition
                                targetRotation = weaponData.highRotation
                                lerpSpeed = 6.0
                            else:
                                targetPosition = weaponData.lowPosition
                                targetRotation = weaponData.lowRotation
                                lerpSpeed = 6.0


    position = lerp(position, Vector3( - targetPosition.x, targetPosition.y, - targetPosition.z), delta * lerpSpeed)
    rotation_degrees.x = lerp(rotation_degrees.x, targetRotation.x, delta * lerpSpeed)
    rotation_degrees.y = lerp(rotation_degrees.y, targetRotation.y, delta * lerpSpeed)
    rotation_degrees.z = lerp(rotation_degrees.z, targetRotation.z, delta * lerpSpeed)

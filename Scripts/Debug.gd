extends Control


var gameData = preload("res://Resources/GameData.tres")


@onready var input = $States / Input
@onready var isIdle = $States / isIdle
@onready var isMoving = $States / isMoving
@onready var isWalking = $States / isWalking
@onready var isRunning = $States / isRunning
@onready var isCrouching = $States / isCrouching
@onready var isAiming = $States / isAiming
@onready var isCanted = $States / isCanted
@onready var isFiring = $States / isFiring
@onready var isReloading = $States / isReloading
@onready var isInserting = $States / isInserting
@onready var primary = $States / Primary
@onready var secondary = $States / Secondary
@onready var firemode = $States / Firemode
@onready var weaponPosition = $"States/Position"
@onready var ammo = $States / Ammo
@onready var TOD = $States / TOD
@onready var settings = $States / Settings
@onready var flashlight = $States / Flashlight
@onready var surface = $States / Surface
@onready var chamber = $States / Chamber
@onready var nvg = $States / NVG
@onready var base_fov = $States / BaseFOV
@onready var aim_fov = $States / AimFOV


@onready var starvation = $States / Starvation
@onready var dehydration = $States / Dehydration
@onready var bleeding = $States / Bleeding
@onready var fracture = $States / Fracture
@onready var burn = $States / Burn
@onready var rupture = $States / Rupture


func _physics_process(_delta):
    input.text = str("Input: ", gameData.inputDirection)
    isIdle.text = str("isIdle: ", gameData.isIdle)
    isMoving.text = str("isMoving: ", gameData.isMoving)
    isWalking.text = str("isWalking: ", gameData.isWalking)
    isRunning.text = str("isRunning: ", gameData.isRunning)
    isCrouching.text = str("isCrouching: ", gameData.isCrouching)
    isAiming.text = str("isAiming: ", gameData.isAiming)
    isCanted.text = str("isCanted: ", gameData.isCanted)
    isFiring.text = str("isFiring: ", gameData.isFiring)
    isReloading.text = str("isReloading: ", gameData.isReloading)
    ammo.text = str("Ammo: ", gameData.ammo)
    flashlight.text = str("Flashlight: ", gameData.flashlight)
    nvg.text = str("NVG: ", gameData.NVG)

    primary.text = str("Primary: ", gameData.primary)
    secondary.text = str("Secondary: ", gameData.secondary)
    settings.text = str("Settings: ", gameData.settings)
    isInserting.text = str("isInserting: ", gameData.isInserting)

    base_fov.text = str("Base FOV: ", gameData.baseFOV)
    aim_fov.text = str("Aim FOV: ", gameData.aimFOV)

    starvation.text = str("Starvation: ", gameData.starvation)
    dehydration.text = str("Dehydration: ", gameData.dehydration)
    bleeding.text = str("Bleeding: ", gameData.bleeding)
    fracture.text = str("Fracture: ", gameData.fracture)
    burn.text = str("Burn: ", gameData.burn)
    rupture.text = str("Rupture: ", gameData.rupture)

    if gameData.surface == 1:
        surface.text = str("Surface: Grass")
    elif gameData.surface == 2:
        surface.text = str("Surface: Dirt")
    elif gameData.surface == 3:
        surface.text = str("Surface: Asphalt")
    elif gameData.surface == 4:
        surface.text = str("Surface: Rock")
    elif gameData.surface == 5:
        surface.text = str("Surface: Wood")
    elif gameData.surface == 6:
        surface.text = str("Surface: Metal")
    elif gameData.surface == 7:
        surface.text = str("Surface: Concrete")
    else:
        surface.text = str("Surface: Default")


    if gameData.firemode == 1:
        firemode.text = str("Firemode: Semi")
    else:
        firemode.text = str("Firemode: Auto")

    if gameData.weaponPosition == 1:
        weaponPosition.text = str("Weapon Position: Low")
    else:
        weaponPosition.text = str("Weapon Position: High")


    if gameData.TOD == 1:
        TOD.text = str("TOD: Dawn")
    elif gameData.TOD == 2:
        TOD.text = str("TOD: Day")
    elif gameData.TOD == 3:
        TOD.text = str("TOD: Dusk")
    elif gameData.TOD == 4:
        TOD.text = str("TOD: Night")

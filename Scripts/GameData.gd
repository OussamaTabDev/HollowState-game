extends Resource
class_name GameData


var zone: String
var currentMap: String
var previousMap: String
var menu = false
var shelter = false
var tutorial = false
var permadeath = false
var flycam = false


var difficulty = 1
var season = 1
var TOD = 1
var indoor = false
var lastSleep = 0.0
var heavyFog = false


var settings = false
var interface = false
var decor = false


var health = 100.0
var energy = 100.0
var hydration = 100.0
var mental = 100.0
var temperature = 100.0
var cat = 100.0
var oxygen = 100.0


var bodyStamina = 100.0
var armStamina = 100.0


var overweight = false
var starvation = false
var dehydration = false
var bleeding = false
var fracture = false
var burn = false
var frostbite = false
var insanity = false
var poisoning = false
var rupture = false
var headshot = false


var inputDirection = Vector2.ZERO
var cameraPosition = Vector3.ZERO
var playerPosition = Vector3.ZERO
var playerVector = Vector3.ZERO


var baseFOV = 70.0
var aimFOV = 70.0
var isScoped = false
var headbob = 1.0


var lookSensitivity = 1.0
var aimSensitivity = 1.0
var scopeSensitivity = 1.0


var mouseMode = 1
var sprintMode = 1
var leanMode = 1
var aimMode = 1


var freeze = false
var vehicle = false
var isDead = false
var isGrounded = false
var isFalling = false
var isFlying = false
var isWater = false
var isSwimming = false
var isSubmerged = false
var isIdle = false
var isMoving = false
var isWalking = false
var isRunning = false
var isCrouching = false
var isAiming = false
var isCanted = false
var isFiring = false
var isColliding = false
var isReloading = false
var isInspecting = false
var isInserting = false
var isChecking = false
var isDrawing = false
var isCaching = false
var isDragging = false
var isBurning = false
var isOccupied = false
var isCrafting = false
var isTrading = false
var isTransitioning = false
var isPlacing = false
var isSleeping = false


var surface: String
var jump = false
var land = false
var crouch = false
var stand = false
var damage = false
var impact = false


var leanLBlocked = false
var leanRBlocked = false


var primary = false
var secondary = false
var knife = false
var grenade1 = false
var grenade2 = false
var weaponAction: String
var weaponPosition = 1
var inspectPosition = 1
var firemode = 1


var flashlight = false
var NVG = false


var interaction = false
var interactionText: String
var transition = false
var indicator = false
var message = false
var messageText: String


var heat = false


var musicPreset = 1


var tooltip = null

func Reset():
    zone = "Area 05"
    currentMap = "Attic"
    previousMap = "Village"
    menu = false
    shelter = false
    tutorial = false

    health = 100.0
    energy = 100.0
    hydration = 100.0
    mental = 100.0
    temperature = 100.0
    cat = 100.0
    oxygen = 100.0
    bodyStamina = 100.0
    armStamina = 100.0

    overweight = false
    starvation = false
    dehydration = false
    bleeding = false
    fracture = false
    burn = false
    frostbite = false
    insanity = false
    poisoning = false
    rupture = false
    headshot = false

    inputDirection = Vector2.ZERO
    cameraPosition = Vector3.ZERO
    playerPosition = Vector3.ZERO
    playerVector = Vector3.ZERO

    isDead = false
    isGrounded = false
    isFalling = false
    isFlying = false
    isWater = false
    isSwimming = false
    isSubmerged = false
    isIdle = false
    isMoving = false
    isWalking = false
    isRunning = false
    isCrouching = false
    isAiming = false
    isCanted = false
    isFiring = false
    isColliding = false
    isReloading = false
    isInspecting = false
    isInserting = false
    isChecking = false
    isDrawing = false
    isCaching = false
    isDragging = false
    isOccupied = false
    isCrafting = false
    isTrading = false
    isTransitioning = false
    isPlacing = false
    isSleeping = false
    primary = false
    secondary = false
    knife = false
    grenade1 = false
    grenade2 = false
    weaponAction = ""
    weaponPosition = 1
    firemode = 1

    difficulty = 1
    season = 1
    TOD = 1
    flashlight = false
    NVG = false
    freeze = false
    vehicle = false
    settings = false
    interface = false
    surface = ""
    isPlacing = false
    decor = false
    heavyFog = false


    interaction = false
    interactionText = ""
    message = false
    messageText = ""
    transition = false
    indicator = false

    tooltip = null

    inspectPosition = 1
    indoor = false
    permadeath = false

    baseFOV = 70.0
    aimFOV = 70.0
    isScoped = false
    headbob = 1.0

    lookSensitivity = 1.0
    aimSensitivity = 1.0
    scopeSensitivity = 1.0

    mouseMode = 1
    sprintMode = 1
    leanMode = 1
    aimMode = 1

    jump = false
    land = false
    crouch = false
    stand = false
    damage = false
    impact = false

    leanLBlocked = false
    leanRBlocked = false

    musicPreset = 1

    heat = false

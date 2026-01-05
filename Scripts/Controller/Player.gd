extends CharacterBody3D

# Resources
var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")

# Node references
@onready var pelvis = $Pelvis
@onready var head = $Pelvis/Riser/Head
@onready var bob = $Pelvis/Riser/Head/Bob
@onready var camera = $Pelvis/Riser/Head/Bob/Impulse/Damage/Noise/Camera
@onready var character = $Character
@onready var rigManager = $"../Camera/Manager"
@onready var state_machine = $StateMachine

# Colliders
@onready var standCollider = $Stand
@onready var crouchCollider = $Crouch

# Raycasts
@onready var above = $Raycasts/Above
@onready var below = $Raycasts/Below
@onready var left = $Raycasts/Left
@onready var right = $Raycasts/Right

# Movement variables
var currentSpeed = 0.0
var walkSpeed = 2.5
var sprintSpeed = 5.0
var crouchSpeed = 1.0
var swimSpeed = 2.0
var lerpSpeed = 5.0
var inertia = 1.0

# Headbob constants
const headbobWalkSpeed = 10.0
const headbobSprintSpeed = 20.0
const headbobCrouchSpeed = 8.0
const headbobSwimSpeed = 6.0
const headbobWalkIntensity = 0.02
const headbobSprintIntensity = 0.05
const headbobCrouchIntensity = 0.02
const headbobSwimIntensity = 0.02

# Headbob variables
var headbobIndex = 0.0
var headbobIntensity = 0.0
var headbobVector = Vector2.ZERO
var canStep = false

# Input variables
var mouseSensitivity = 0.1
var movementDirection = Vector3.ZERO
var inputDirection = Vector2.ZERO

# Jump and physics variables
var jumpVelocity = 7.0
var jumpControl = 8.0
var velocityMultiplier = 1.0
var gravityMultiplier = 2.0
var lastVelocity = Vector3.ZERO

# Impulse variables
var jumpImpulse = 0.0
var jumpImpulseTimer = 0.0
var landImpulse = 0.0
var landImpulseTimer = 0.0
var crouchImpulse = 0.0
var crouchImpulseTimer = 0.0
var standImpulse = 0.0
var standImpulseTimer = 0.0
var hasJumped = false
var hasLanded = true

# Surface detection
var surface
var scanTimer = 0.0
var scanCycle = 0.2

# Sprint
var sprintToggle = false

# Gravity and fall
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fallStartLevel = 0.0
var fallThreshold = 5.0

func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	gameData.isFlying = false
	pelvis.position.y = 1.
	state_machine.player = self
	standCollider.disabled = false
	crouchCollider.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lastVelocity.y = 0.0

func _input(event):
	if gameData.freeze || gameData.isCaching:
		return
	
	HandleMouseLook(event)

func _physics_process(delta):
	if gameData.isCaching:
		return
	
	# Handle special modes first
	if gameData.isFlying:
		return  # State machine handles this
	
	# Core systems that run every frame
	InputDirection(delta)
	SurfaceDetection(delta)
	SwimDetection()
	
	# Movement systems (when not in special states)
	if !gameData.isSwimming and !gameData.isFlying:
		Movement(delta)
		Inertia(delta)
		Gravity(delta)
		Headbob(delta)
	
	# Impulse systems
	JumpImpulse(delta)
	LandImpulse(delta)
	CrouchImpulse(delta)
	StandImpulse(delta)
	
	# Handle freeze/vehicle
	if gameData.freeze || gameData.isCaching || gameData.vehicle:
		inputDirection = Vector2.ZERO
		currentSpeed = lerp(currentSpeed, 0.0, delta * 5.0)
		return

func HandleMouseLook(event):
	if event is InputEventMouseMotion && !gameData.freeze:
		var sensitivity: float
		var invert_y: bool = (gameData.mouseMode == 2)
		
		# Determine sensitivity based on aim/scope state
		if gameData.isAiming && gameData.isScoped:
			sensitivity = clampf(gameData.scopeSensitivity, 0.1, 2.0) / 10
		elif gameData.isAiming:
			sensitivity = clampf(gameData.aimSensitivity, 0.1, 2.0) / 10
		else:
			sensitivity = clampf(gameData.lookSensitivity, 0.1, 2.0) / 10
		
		# Apply rotation
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		
		var y_rotation = event.relative.y * sensitivity
		if invert_y:
			head.rotate_x(deg_to_rad(y_rotation))
		else:
			head.rotate_x(deg_to_rad(-y_rotation))
		
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func InputDirection(_delta):
	inputDirection = Input.get_vector("left", "right", "forward", "backward")
	gameData.inputDirection = inputDirection

func Movement(delta):
	gameData.playerPosition = global_transform.origin
	gameData.playerVector = -camera.global_basis.z
	RenderingServer.global_shader_parameter_set("Player", global_transform.origin)
	
	if is_on_floor():
		gameData.isGrounded = true
		velocityMultiplier = 1.0
		movementDirection = lerp(movementDirection, (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized(), delta * lerpSpeed)
	else:
		gameData.isGrounded = false
		velocityMultiplier = 0.8
		if inputDirection != Vector2.ZERO:
			movementDirection = lerp(movementDirection, (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized(), delta * lerpSpeed / jumpControl)
	
	if movementDirection:
		var speed_modifier = 1.0
		if gameData.overweight || gameData.fracture:
			speed_modifier = 1.0 / 1.5
		
		velocity.x = movementDirection.x * (currentSpeed * speed_modifier * velocityMultiplier * inertia)
		velocity.z = movementDirection.z * (currentSpeed * speed_modifier * velocityMultiplier * inertia)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	lastVelocity = velocity
	move_and_slide()

func Inertia(delta):
	var target_inertia = 1.0
	
	if gameData.isWalking || gameData.isRunning:
		if inputDirection.y >= 0 && inputDirection.y < 0.5:
			target_inertia = 0.8 if gameData.isWalking else 0.7
		elif inputDirection.y > 0.5:
			target_inertia = 0.6
	
	inertia = lerp(inertia, target_inertia, delta * 2.0)

func Gravity(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier

func Headbob(delta):
	# Set headbob parameters based on state
	if gameData.isWalking:
		headbobIntensity = headbobWalkIntensity * gameData.headbob
		headbobIndex += headbobWalkSpeed * delta
	elif gameData.isRunning:
		headbobIntensity = headbobSprintIntensity * gameData.headbob
		headbobIndex += headbobSprintSpeed * delta
	elif gameData.isCrouching:
		headbobIntensity = headbobCrouchIntensity * gameData.headbob
		headbobIndex += headbobCrouchSpeed * delta
	elif gameData.isSwimming:
		headbobIntensity = headbobSwimIntensity * gameData.headbob
		headbobIndex += headbobSwimSpeed * delta
	
	# Apply headbob
	if (is_on_floor() || gameData.isSwimming) && inputDirection != Vector2.ZERO:
		headbobVector.x = sin(headbobIndex / 2)
		headbobVector.y = sin(headbobIndex)
		bob.position.x = lerp(bob.position.x, headbobVector.x * headbobIntensity, delta * lerpSpeed)
		bob.position.y = lerp(bob.position.y, headbobVector.y * (headbobIntensity * 2), delta * lerpSpeed)
	else:
		bob.position.x = lerp(bob.position.x, 0.0, delta * lerpSpeed)
		bob.position.y = lerp(bob.position.y, 0.0, delta * lerpSpeed)
	
	# Footstep detection
	if headbobVector.y < -0.5 && !canStep:
		canStep = true
	if headbobVector.y > 0.5 && canStep:
		if gameData.isSwimming:
			if gameData.isSubmerged:
				PlaySwimSubmerged()
			else:
				PlaySwimSurface()
		else:
			PlayFootstep()
		canStep = false

func JumpImpulse(delta):
	if jumpImpulseTimer < jumpImpulse:
		gameData.jump = true
		jumpImpulseTimer += delta
	else:
		gameData.jump = false
		jumpImpulseTimer = 0.0
		jumpImpulse = 0.0

func LandImpulse(delta):
	if landImpulseTimer < landImpulse:
		gameData.land = true
		landImpulseTimer += delta
	else:
		gameData.land = false
		landImpulseTimer = 0.0
		landImpulse = 0.0

func CrouchImpulse(delta):
	if crouchImpulseTimer < crouchImpulse:
		gameData.crouch = true
		crouchImpulseTimer += delta
	else:
		gameData.crouch = false
		crouchImpulseTimer = 0.0
		crouchImpulse = 0.0

func StandImpulse(delta):
	if standImpulseTimer < standImpulse:
		gameData.stand = true
		standImpulseTimer += delta
	else:
		gameData.stand = false
		standImpulseTimer = 0.0
		standImpulse = 0.0

func SwimDetection():
	if !gameData.isSwimming && gameData.isWater && position.y < -2.5:
		state_machine.force_transition("Swim")
	elif gameData.isSwimming && position.y > -2.2:
		state_machine.force_transition("Idle")

func SurfaceDetection(delta):
	scanTimer += delta
	
	if scanTimer > scanCycle:
		if below.is_colliding():
			surface = below.get_collider().get("surface")
			
			match surface:
				"Grass": gameData.surface = "Grass"
				"Dirt", "Mud": gameData.surface = "Dirt"
				"Asphalt": gameData.surface = "Asphalt"
				"Rock": gameData.surface = "Rock"
				"Wood": gameData.surface = "Wood"
				"Metal": gameData.surface = "Metal"
				"Concrete": gameData.surface = "Concrete"
				_: gameData.surface = "Concrete"
		
		gameData.leanLBlocked = left.is_colliding()
		gameData.leanRBlocked = right.is_colliding()
		
		scanTimer = 0.0

# Audio playback functions
func PlayFootstep():
	var footstep = audioInstance2D.instantiate()
	add_child(footstep)
	PlayMovementCloth()
	
	if character.heavyGear:
		PlayMovementGear()
	
	if gameData.isWater:
		footstep.PlayInstance(audioLibrary.footstepWater)
	else:
		var sound_array = GetFootstepSound(false)
		footstep.PlayInstance(sound_array)

func PlayFootstepJump():
	var footstep = audioInstance2D.instantiate()
	add_child(footstep)
	PlayMovementCloth()
	
	if character.heavyGear:
		PlayMovementGear()
	
	if gameData.isWater:
		footstep.PlayInstance(audioLibrary.footstepWater)
	else:
		var sound_array = GetFootstepSound(false)
		footstep.PlayInstance(sound_array)

func PlayFootstepLand():
	var footstep = audioInstance2D.instantiate()
	add_child(footstep)
	PlayMovementCloth()
	
	if character.heavyGear:
		PlayMovementGear()
	
	if gameData.isWater:
		footstep.PlayInstance(audioLibrary.footstepWaterLand)
	else:
		var sound_array = GetFootstepSound(true)
		footstep.PlayInstance(sound_array)

func GetFootstepSound(is_landing: bool):
	var sound_map = {
		"Grass": audioLibrary.footstepGrassLand if is_landing else audioLibrary.footstepGrass,
		"Dirt": audioLibrary.footstepDirtLand if is_landing else audioLibrary.footstepDirt,
		"Asphalt": audioLibrary.footstepAsphaltLand if is_landing else audioLibrary.footstepAsphalt,
		"Rock": audioLibrary.footstepRockLand if is_landing else audioLibrary.footstepRock,
		"Wood": audioLibrary.footstepWoodLand if is_landing else audioLibrary.footstepWood,
		"Metal": audioLibrary.footstepMetalLand if is_landing else audioLibrary.footstepMetal,
		"Concrete": audioLibrary.footstepConcreteLand if is_landing else audioLibrary.footstepConcrete
	}
	
	# Handle winter season
	if gameData.season == 2:
		if gameData.surface in ["Grass", "Dirt"]:
			return audioLibrary.footstepSnowHardLand if is_landing else audioLibrary.footstepSnowHard
	
	return sound_map.get(gameData.surface, audioLibrary.footstepConcreteLand if is_landing else audioLibrary.footstepConcrete)

func PlaySwimSurface():
	var swimSurface = audioInstance2D.instantiate()
	add_child(swimSurface)
	swimSurface.PlayInstance(audioLibrary.swimSurface)

func PlaySwimSubmerged():
	var swimSubmerged = audioInstance2D.instantiate()
	add_child(swimSubmerged)
	swimSubmerged.PlayInstance(audioLibrary.swimSubmerged)

func PlayMovementCloth():
	var movementCloth = audioInstance2D.instantiate()
	add_child(movementCloth)
	movementCloth.PlayInstance(audioLibrary.movementCloth)

func PlayMovementGear():
	var movementGear = audioInstance2D.instantiate()
	add_child(movementGear)
	movementGear.PlayInstance(audioLibrary.movementGear)

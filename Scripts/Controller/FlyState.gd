extends State
class_name FlyState

func enter():
	if game_data:
		game_data.isFalling = false
	if player:
		player.fallStartLevel = player.global_position.y

func update(_delta: float):
	if !player or !game_data:
		return
	
	var fly_speed: float
	var height_vector: float = 0.0
	
	# Set fly speed based on modifiers
	if Input.is_key_pressed(KEY_SHIFT):
		fly_speed = 50.0
	elif Input.is_key_pressed(KEY_CTRL):
		fly_speed = 0.5
	else:
		fly_speed = 2.0
	
	# Handle vertical movement
	if Input.is_key_pressed(KEY_E):
		height_vector = 1.0
	if Input.is_key_pressed(KEY_Q):
		height_vector = -1.0
	
	# Calculate velocity
	player.velocity = player.camera.global_basis * Vector3(player.inputDirection.x, height_vector, player.inputDirection.y) * fly_speed
	
	# Stop if no input
	if player.inputDirection == Vector2.ZERO and !Input.is_action_pressed("lean_L") and !Input.is_action_pressed("lean_R"):
		height_vector = 0.0
		player.velocity = Vector3.ZERO
	
	player.move_and_slide()
	
	# Update player position for game systems
	game_data.playerPosition = player.global_transform.origin
	game_data.playerVector = player.camera.global_basis.z
	
	# Check for exit fly mode
	if !game_data.isFlying:
		transition_to("FallState")
		return

func exit():
	pass

extends State
class_name SprintState

func enter():
	if game_data:
		game_data.isRunning = true
		game_data.isWalking = false
		game_data.isMoving = true
		game_data.isCrouching = false

func update(delta: float):
	if !player:
		return
	
	# Lerp to sprint speed
	player.currentSpeed = lerp(player.currentSpeed, player.sprintSpeed, delta * 1.0)
	if player.pelvis.position.y < 1.0:
		player.pelvis.position.y = lerp(player.pelvis.position.y, 1.0, delta * 5.0)
	# Check for state transitions
	if game_data and game_data.freeze:
		return
	
	# Check if stopped moving
	if player.inputDirection == Vector2.ZERO:
		if game_data.sprintMode == 2:
			# Keep sprint toggle active
			pass
		transition_to("IdleState")
		return
	
	# Check for sprint release (hold mode)
	if game_data.sprintMode == 1:
		if !Input.is_action_pressed("sprint"):
			transition_to("WalkState")
			return
	# Check for sprint toggle (toggle mode)
	elif game_data.sprintMode == 2:
		if Input.is_action_just_pressed("sprint"):
			player.sprintToggle = false
			transition_to("WalkState")
			return
	
	# Check for crouch
	if Input.is_action_just_pressed("crouch") and player.is_on_floor():
		game_data.isCrouching = true
		player.sprintToggle = false
		transition_to("CrouchState")
		return
	
	# Check for jump
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition_to("JumpState")
		return
	
	# Check if falling
	if !player.is_on_floor() and player.velocity.y < 0:
		transition_to("FallState")
		return
	
	# Check for swimming
	if game_data.isSwimming:
		transition_to("SwimState")
		return

func exit():
	if game_data:
		game_data.isRunning = false

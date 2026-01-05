extends State
class_name WalkState

func enter():
	if game_data:
		game_data.isWalking = true
		game_data.isRunning = false
		game_data.isMoving = true
		game_data.isCrouching = false

func update(delta: float):
	if !player:
		return
	
	# Lerp to walk speed
	player.currentSpeed = lerp(player.currentSpeed, player.walkSpeed, delta * 2.5)
	
	# Check for state transitions
	if game_data and game_data.freeze:
		return
	
	# Check if stopped moving
	if player.inputDirection == Vector2.ZERO:
		transition_to("IdleState")
		return
	
	# Check for sprint
	if game_data.sprintMode == 1:
		if Input.is_action_pressed("sprint"):
			transition_to("SprintState")
			return
	elif game_data.sprintMode == 2:
		if Input.is_action_just_pressed("sprint"):
			player.sprintToggle = !player.sprintToggle
		if player.sprintToggle:
			transition_to("SprintState")
			return
	
	# Check for crouch
	if Input.is_action_just_pressed("crouch") and player.is_on_floor():
		game_data.isCrouching = true
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
		game_data.isWalking = false

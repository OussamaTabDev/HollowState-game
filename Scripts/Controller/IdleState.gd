extends State
class_name IdleState

func enter():
	if game_data:
		game_data.isIdle = true
		game_data.isMoving = false
		game_data.isWalking = false
		game_data.isRunning = false
		print("Entered Idle State")

func update(delta: float):
	if !player:
		return
	
	# Lerp speed to zero
	player.currentSpeed = lerp(player.currentSpeed, 0.0, delta * 5.0)
	if player.pelvis.position.y < 1.0:
		player.pelvis.position.y = lerp(player.pelvis.position.y, 1.0, delta * 5.0)
	# Check for state transitions
	if game_data and game_data.freeze:
		return
	
	# Check if player starts moving
	if player.inputDirection != Vector2.ZERO:
		if game_data.isCrouching:
			transition_to("CrouchState")
		else:
			transition_to("WalkState")
		return
	
	# Check for jump
	if Input.is_action_just_pressed("jump") and player.is_on_floor() and !game_data.isCrouching:
		transition_to("JumpState")
		return
	
	# Check for crouch
	if Input.is_action_just_pressed("crouch") and player.is_on_floor():
		game_data.isCrouching = !game_data.isCrouching
		if game_data.isCrouching:
			transition_to("CrouchState")
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
		game_data.isIdle = false

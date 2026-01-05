extends State
class_name CrouchState

func enter():
	if game_data:
		game_data.isCrouching = true
		game_data.isWalking = false
		game_data.isRunning = false
	
	if player:
		player.crouchImpulse = 0.1
		player.standCollider.disabled = true
		player.crouchCollider.disabled = false

	print( player , game_data)
func update(delta: float):
	if !player:
		return
	
	# Lerp to crouch speed
	player.currentSpeed = lerp(player.currentSpeed, player.crouchSpeed, delta * 2.5)
	
	# Lerp pelvis position
	player.pelvis.position.y = lerp(player.pelvis.position.y, 0.5, delta * 5.0)
	
	# Check for state transitions
	if game_data and game_data.freeze:
		return
	
	# Check for un-crouch
	if (Input.is_action_just_pressed("crouch") or Input.is_action_just_pressed("jump")) and player.is_on_floor() and !player.above.is_colliding():
		game_data.isCrouching = false
		player.standImpulse = 0.1
		player.standCollider.disabled = false
		player.crouchCollider.disabled = true
		
		if player.inputDirection != Vector2.ZERO:
			transition_to("WalkState")
		else:
			transition_to("IdleState")
		
		
		return
	
	# Check if stopped moving while crouched
	if player.inputDirection == Vector2.ZERO:
		game_data.isMoving = false
	else:
		game_data.isMoving = true
	
	# Can't jump while crouched
	
	# Check if falling
	if !player.is_on_floor() and player.velocity.y < 0:
		transition_to("FallState")
		return
	
	# Check for swimming
	if game_data.isSwimming:
		transition_to("SwimState")
		return
	
	# Handle sprint toggle in crouch
	if game_data.sprintMode == 2 and Input.is_action_just_pressed("sprint"):
		player.sprintToggle = !player.sprintToggle

func exit():
	if game_data:
		game_data.isCrouching = false

	if player:
		player.standImpulse = 0.1
		player.standCollider.disabled = false
		player.crouchCollider.disabled = true

            # standImpulse = 0.1
            # standCollider.disabled = false
            # crouchCollider.disabled = true
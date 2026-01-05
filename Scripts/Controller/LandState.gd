extends State
class_name LandState

func enter():
	if !player:
		return
	
	player.landImpulse = 0.1
	
	if !player.hasLanded:
		player.PlayFootstepLand()
	
	player.hasLanded = true
	player.hasJumped = false
	
	# Check for fall damage
	if game_data and player.global_position.y < player.fallStartLevel - player.fallThreshold:
		player.character.FallDamage(player.fallStartLevel - player.global_position.y)
		print("FALL " + str(player.fallStartLevel - player.global_position.y))

func update(_delta: float):
	if !player:
		return
	
	# Immediately transition to appropriate ground state
	if game_data and game_data.freeze:
		return
	
	# Check what state to transition to based on input and crouch status
	if game_data.isCrouching:
		transition_to("CrouchState")
	elif player.inputDirection != Vector2.ZERO:
		if game_data.sprintMode == 1 and Input.is_action_pressed("sprint"):
			transition_to("SprintState")
		elif game_data.sprintMode == 2 and player.sprintToggle:
			transition_to("SprintState")
		else:
			transition_to("WalkState")
	else:
		transition_to("IdleState")

func exit():
	pass

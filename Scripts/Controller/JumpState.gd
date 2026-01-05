extends State
class_name JumpState

func enter():
	if !player:
		return
	
	player.hasJumped = true
	player.hasLanded = false
	
	if game_data:
		if game_data.bodyStamina > 0:
			game_data.bodyStamina -= 10
	
	# Apply jump velocity
	if game_data and (game_data.overweight or game_data.fracture):
		player.velocity.y = player.jumpVelocity / 1.2
	else:
		player.velocity.y = player.jumpVelocity
	
	player.jumpImpulse = 0.1
	player.PlayFootstepJump()

func update(delta: float):
	if !player:
		return
	
	# Check for state transitions
	if game_data and game_data.freeze:
		return
	
	# Check if reached peak of jump or starting to fall
	if player.velocity.y <= 0:
		transition_to("FallState")
		return
	
	# Check for swimming during jump
	if game_data and game_data.isSwimming:
		transition_to("SwimState")
		return

func exit():
	pass

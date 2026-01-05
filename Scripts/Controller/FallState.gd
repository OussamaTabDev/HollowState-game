extends State
class_name FallState

func enter():
	if game_data:
		game_data.isFalling = true
		player.fallStartLevel = player.global_position.y

func update(delta: float):
	if !player:
		return
	
	# Check for state transitions
	if game_data and game_data.freeze:
		return
	
	if player.pelvis.position.y < 1.0:
		player.pelvis.position.y = lerp(player.pelvis.position.y, 1.0, delta * 5.0)
		
	# Check if landed
	if player.is_on_floor():
		transition_to("LandState")
		return
	
	# Check for swimming during fall
	if game_data and game_data.isSwimming:
		transition_to("SwimState")
		return

func exit():
	if game_data:
		game_data.isFalling = false

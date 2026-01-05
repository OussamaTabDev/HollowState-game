extends State
class_name SwimState

func enter():
	if !player:
		return
	
	player.movementDirection = Vector3.ZERO
	player.lastVelocity = Vector3.ZERO
	
	# Clear rig if exists
	if player.rigManager and player.rigManager.get_child_count() != 0:
		player.rigManager.ClearRig()
		player.rigManager.PlayUnequip()
	
	# Set to crouch collider
	player.crouchImpulse = 0.1
	player.standCollider.disabled = true
	player.crouchCollider.disabled = false
	
	if game_data:
		game_data.isSwimming = true
		game_data.isWalking = false
		game_data.isRunning = false
	
	# Reset fall tracking
	player.fallStartLevel = player.global_position.y
	
	# Handle entry from jump/fall
	if player.hasJumped or (game_data and game_data.isFalling):
		player.PlayFootstepLand()
		player.velocity.y = player.velocity.y * 0.5
		if game_data:
			game_data.isFalling = false
		player.hasJumped = false

func update(delta: float):
	if !player:
		return
	
	# Set swim speed based on conditions
	if game_data and (game_data.overweight or game_data.fracture):
		player.swimSpeed = 1.0
	else:
		player.swimSpeed = 2.0
	
	# Maintain depth
	if player.position.y > -3.0:
		player.position.y = lerp(player.position.y, -3.0, delta * 2.0)
	
	# Lerp pelvis position
	player.pelvis.position.y = lerp(player.pelvis.position.y, 0.5, delta * 2.0)
	
	# Calculate swim velocity
	if player.head.rotation_degrees.x > 0 and player.position.y > -3.0:
		player.velocity = lerp(player.velocity, player.global_basis * Vector3(player.inputDirection.x, 0, player.inputDirection.y) * player.swimSpeed, delta)
	else:
		player.velocity = lerp(player.velocity, player.camera.global_basis * Vector3(player.inputDirection.x, 0, player.inputDirection.y) * player.swimSpeed, delta)
	
	# Handle movement state
	if player.inputDirection == Vector2.ZERO:
		player.velocity = lerp(player.velocity, Vector3.ZERO, delta)
		if game_data:
			game_data.isMoving = false
	else:
		if game_data:
			game_data.isMoving = true
	
	player.move_and_slide()
	
	# Check for exit swimming
	if player.position.y > -2.2:
		transition_to("IdleState")
		return

func exit():
	if !player:
		return
	
	player.movementDirection = Vector3.ZERO
	player.lastVelocity = Vector3.ZERO
	
	# Restore appropriate collider
	if game_data and game_data.isCrouching:
		player.crouchImpulse = 0.1
		player.standCollider.disabled = true
		player.crouchCollider.disabled = false
	else:
		player.standImpulse = 0.1
		player.standCollider.disabled = false
		player.crouchCollider.disabled = true
	
	if game_data:
		game_data.isSwimming = false

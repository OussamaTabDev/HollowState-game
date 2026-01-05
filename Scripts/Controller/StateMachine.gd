extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}
var player
func _ready():
	player = get_parent()
	# Collect all child State nodes
	for child in get_children():
		if child is State:
			child.player = player
			child.game_data = player.gameData
			child.audio_library = player.audioLibrary
			states[child.name.to_lower()] = child
			child.state_transition.connect(on_state_transition)
	
	# Initialize with the first state if initial_state not set
	if initial_state:
		current_state = initial_state
	elif states.size() > 0:
		current_state = states.values()[0]
	
	if current_state:
		current_state.enter()

func _physics_process(delta):
	if current_state:
		current_state.update(delta)

func _input(event):
	if current_state:
		current_state.handle_input(event)

func on_state_transition(old_state: State, new_state_name: String):
	if old_state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func force_transition(new_state_name: String):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

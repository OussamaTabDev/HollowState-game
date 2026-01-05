extends Node
class_name State

signal state_transition(old_state: State, new_state_name: String)

var player: CharacterBody3D
var game_data
var audio_library

func _ready():
	# Wait for parent to be ready
	await get_parent().ready
	
	# Get references from the player
	var state_machine = get_parent()
	if state_machine and state_machine.get_parent():
		player = state_machine.get_parent()
		if player.has_node("gameData") or player.get("gameData"):
			game_data = player.gameData
		if player.has_node("audioLibrary") or player.get("audioLibrary"):
			audio_library = player.audioLibrary

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func handle_input(_event: InputEvent):
	pass

func transition_to(new_state_name: String):
	state_transition.emit(self, new_state_name)

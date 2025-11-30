class_name PauseManager
extends Node

var paused: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
func unpause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		paused = !paused
		if paused:
			pause_game()
		else:
			unpause_game()

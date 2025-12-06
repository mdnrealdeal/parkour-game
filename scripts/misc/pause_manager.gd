class_name PauseManager
extends Node

var paused: bool = false
var fullscreen_toggle: bool = false

func _ready() -> void:
	if not OS.has_feature("editor"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	get_window().title = "playtesting: parkour-game"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
func unpause_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		paused = not paused
		if paused:
			pause_game()
		else:
			unpause_game()
	
	if event.is_action_pressed("game_quit"):
		get_tree().quit()
	if event.is_action_pressed("reload_scene"):
		get_tree().reload_current_scene()

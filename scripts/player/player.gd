class_name Player
extends Actor

@export_range(0, 100, 1) var mouse_sensitivity: int = 30
const SENS_MODIFIER = 0.0001

func _ready() -> void:
	super._ready()

func _calculate_movement_parameters() -> void:
	input_dir = Input.get_vector("move_left", "move_right", 
	"move_forward", "move_backward")
	
	if Input.is_action_just_pressed("jump"):
		request_to_jump = true
	if Input.is_action_just_pressed("dash"):
		request_to_dash = true
	request_to_crouch = Input.is_action_pressed("crouch")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var final_sensitivity: float = mouse_sensitivity * SENS_MODIFIER
		
		rotate_y(-event.relative.x * final_sensitivity)
		head.rotate_x(-event.relative.y * final_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

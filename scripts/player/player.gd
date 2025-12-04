class_name Player
extends Actor

const SENS_HUMAN_MOD = 0.0001

@export_range(0, 100, 1) var mouse_sensitivity: int = 30

func _ready() -> void:
	blackboard = PlayerBlackboard.new()
	blackboard.name = "PlayerBlackboard"
	add_child(blackboard)
	
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
		var sens_mult: float = _add_camera_magnetism(event)
		
		var final_sensitivity: float = (mouse_sensitivity * SENS_HUMAN_MOD) * sens_mult
		#print(final_sensitivity)
		
		rotate_y(-event.relative.x * final_sensitivity)
		head.rotate_x(-event.relative.y * final_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _add_camera_magnetism(event: InputEvent) -> float:
	if not blackboard.is_wall_running:
		return 1.0
	
	var wall_normal: Vector3 = blackboard.current_wall_normal
	var look_dir := -head.global_transform.basis.z
	var relative_x: float = event.relative.x
	
	var alignment: float = look_dir.dot(wall_normal)
	
	var moving_away: bool = false
		
	if blackboard.current_wall_side == ActorBlackboard.WallSide.RIGHT and relative_x < 0:
		moving_away = true
	elif blackboard.current_wall_side == ActorBlackboard.WallSide.LEFT and relative_x > 0:
		moving_away = true
	
	print("Side: %s | Align: %.2f | MovingAway: %s" % [blackboard.current_wall_side, alignment, moving_away])
	if alignment > 0.01:
		var raw_tension: float = clamp((alignment - 0.1) / 0.8, 0.0, 1.0)
		var curved_tension: float = raw_tension * raw_tension
		
		if moving_away:
			return lerp(1.0, 0.01, curved_tension)
		else:
			return lerp(1.0, 0.2, curved_tension)
	return 1.0

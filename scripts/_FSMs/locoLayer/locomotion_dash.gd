class_name LocomotionDash
extends State

var _duration: float = 0.0
var _dash_direction: Vector3

func _ready() -> void:
	pass

func enter(_previous_state: State = null) -> void:
	if actor_ref.input_dir.length() > 0:
		_dash_direction = (actor_ref.transform.basis * 
		Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y)).normalized()
		#clampf(actor_ref.input_dir.y, -0.7, 1)
	else:
		var cam_forward: Vector3 = actor_ref.head.global_transform.basis.z
		cam_forward.y = 0
		_dash_direction = cam_forward.normalized()
	
	actor_ref.blackboard.run_time += 1.5
	
	actor_ref.velocity = _dash_direction * actor_ref.move_stats.dash_speed
	_duration = actor_ref.move_stats.dash_duration

func exit() -> void:
	actor_ref.blackboard.start_dash_cooldown(actor_ref.move_stats.dash_cooldown)

func physics_update(_delta: float) -> void:
	actor_ref.velocity = _dash_direction * actor_ref.move_stats.dash_speed
	
	_duration -= _delta
	if _duration <= 0:
		transition_requested.emit(self, LocomotionAir)
	
func can_interrupt(_delta: float) -> bool:
	if not actor_ref.request_to_dash: return false
	if not actor_ref.blackboard.is_dash_ready(): return false
	if not actor_ref.is_on_floor(): return false
	return true

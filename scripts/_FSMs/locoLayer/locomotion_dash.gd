class_name LocomotionDash
extends State

var _duration: float = 0.0
var _dash_direction: Vector3

@onready var _cooldown_timer: Timer = Timer.new() 

func _ready() -> void:
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)

func enter(_previous_state: State = null) -> void:
	if actor_ref.input_dir.length() > 0:
		_dash_direction = (actor_ref.transform.basis * 
		Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y)).normalized()
	else:
		var cam_forward: Vector3 = -actor_ref.head.global_transform.basis.z
		cam_forward.y = 0
		_dash_direction = cam_forward.normalized()
	
	actor_ref.velocity = _dash_direction * actor_ref.move_stats.dash_speed
	_duration = actor_ref.move_stats.dash_duration

func exit() -> void:
	_cooldown_timer.start(actor_ref.move_stats.dash_cooldown)

func physics_update(_delta: float) -> void:
	actor_ref.velocity = _dash_direction * actor_ref.move_stats.dash_speed
	
	_duration -= _delta
	if _duration <= 0:
		transition_requested.emit(self, LocomotionAir)
	
func can_interrupt(_delta: float) -> bool:
	return actor_ref.request_to_dash and can_activate()

func can_activate() -> bool:
	return _cooldown_timer.is_stopped()

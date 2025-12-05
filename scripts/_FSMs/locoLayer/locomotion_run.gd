class_name LocomotionRun
extends State

#region Internal variables
const STRAFE_RUN_DECAY: float = 2.0
const SPRINT_STRAFE_THRESHOLD: float = 0.5
#endregion

func _ready() -> void:
	is_grounded_state = true

func physics_update(delta: float) -> void:
	_update_run_time(delta)
	
	if _check_transitions(): return
	if _handle_jump(): return
	
	_apply_movement(delta)

#region Helper Functions
func _update_run_time(delta: float) -> void:
	if actor_ref.input_dir.y < -SPRINT_STRAFE_THRESHOLD:
		actor_ref.blackboard.run_time += delta
	else:
		actor_ref.blackboard.run_time -= delta * STRAFE_RUN_DECAY

func _check_transitions() -> bool:
	if not actor_ref.is_on_floor():
		transition_requested.emit(self, LocomotionAir)
		return true
		
	if actor_ref.input_dir.length() == 0:
		transition_requested.emit(self, LocomotionIdle)
		return true
	return false

func _handle_jump() -> bool:
	if actor_ref.request_to_jump:
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		transition_requested.emit(self, LocomotionAir)
		return true
	return false

func _apply_movement(delta: float) -> void:
	var direction: Vector3 = (actor_ref.transform.basis *
	Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y)).normalized()
	
	var current_speed: float = actor_ref.move_stats.speed
	var current_accel: float = actor_ref.move_stats.acceleration
	
	if actor_ref.blackboard.run_time >= actor_ref.move_stats.time_before_sprinting:
		actor_ref.blackboard.is_sprinting = true
		current_speed = actor_ref.move_stats.sprint_speed
		current_accel = actor_ref.move_stats.sprint_acceleration
	else:
		actor_ref.blackboard.is_sprinting = false
	
	var target_velocity: Vector3 = direction * current_speed
	var current_velocity: Vector3 = Vector3(actor_ref.velocity.x, 0, actor_ref.velocity.z)
	
	current_velocity = current_velocity.lerp(target_velocity, current_accel * delta)
	
	actor_ref.velocity.x = current_velocity.x
	actor_ref.velocity.z = current_velocity.z
#endregion

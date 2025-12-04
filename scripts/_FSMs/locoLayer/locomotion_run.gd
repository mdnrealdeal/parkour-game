class_name LocomotionRun
extends State

#region Internal variables
const STRAFE_RUN_DECAY: float = 2.0
const SPRINT_STRAFE_THRESHOLD: float = 0.5
#endregion

func enter(_previous_state: State = null) -> void:
	pass

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	
	if actor_ref.input_dir.y < -SPRINT_STRAFE_THRESHOLD:
		actor_ref.blackboard.run_time += delta
	else:
		actor_ref.blackboard.run_time -= delta * STRAFE_RUN_DECAY
	
	if not actor_ref.is_on_floor():
		transition_requested.emit(self, LocomotionAir)
		return
		
	if actor_ref.input_dir.length() == 0:
		transition_requested.emit(self, LocomotionIdle)
		return

	if actor_ref.request_to_jump:
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		transition_requested.emit(self, LocomotionAir)
		return
	
	
	var direction: Vector3 = (actor_ref.transform.basis *
	Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y)).normalized()
	
	var _current_speed: float = actor_ref.move_stats.speed
	var _current_acceleration: float = actor_ref.move_stats.acceleration
	
	if actor_ref.blackboard.run_time >= actor_ref.move_stats.time_before_sprinting:
		actor_ref.blackboard.is_sprinting = true
		_current_speed = actor_ref.move_stats.sprint_speed
		_current_acceleration = actor_ref.move_stats.sprint_acceleration
	else:
		actor_ref.blackboard.is_sprinting = false
	
	var target_velocity: Vector3 = direction * _current_speed
	var current_velocity: Vector3 = Vector3(actor_ref.velocity.x, 0, actor_ref.velocity.z)
	
	current_velocity = current_velocity.lerp(target_velocity, _current_acceleration * delta)
	
	actor_ref.velocity.x = current_velocity.x
	actor_ref.velocity.z = current_velocity.z

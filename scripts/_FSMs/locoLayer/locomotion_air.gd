class_name LocomotionAir
extends State

#region Internal variables
const WALLRUN_THRESHOLD: float = 0.5
#endregion

func _ready() -> void:
	pass

func enter(previous_state: State = null) -> void:
	if previous_state is not LocomotionDash:
		actor_ref.blackboard.air_jumps_left = actor_ref.move_stats.max_air_jumps
		
		if actor_ref.velocity.y <= 0.0:
			actor_ref.blackboard.start_coyote_cooldown(actor_ref.move_stats.coyote_time_duration)
		else:
			actor_ref.blackboard.coyote_cooldown.stop()
	else: 
		pass

func physics_update(delta: float) -> void:
	actor_ref.velocity.y -= actor_ref.gravity * delta

	if actor_ref.is_on_floor():
		if actor_ref.input_dir.length() > 0: 
			transition_requested.emit(self, LocomotionRun)
		else:
			transition_requested.emit(self, LocomotionIdle)
		return

	if actor_ref.input_dir.y < -WALLRUN_THRESHOLD or actor_ref.input_dir.y > WALLRUN_THRESHOLD:
		if actor_ref.ray_right.is_colliding() or actor_ref.ray_left.is_colliding():
			if not actor_ref.blackboard.is_wallrun_cooldown_active():
				transition_requested.emit(self, LocomotionWallrun)
				return
	
	if actor_ref.request_to_jump and actor_ref.blackboard.is_coyote_cooldown_active():
		actor_ref.blackboard.coyote_cooldown.stop()
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		# TASK: Implement jump squat when ready
		#transition_requested.emit(self, LocomotionJumpSquat)
	elif actor_ref.request_to_jump and actor_ref.blackboard.air_jumps_left > 0:
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		actor_ref.blackboard.air_jumps_left -= 1

	var direction: Vector3 = (actor_ref.transform.basis * 
	Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y)).normalized()
	
	var target_velocity: Vector3 = direction * actor_ref.move_stats.speed
	var current_velocity: Vector3 = Vector3(actor_ref.velocity.x, 0, actor_ref.velocity.z)

	
	if direction.length() > 0:
		current_velocity = current_velocity.move_toward(target_velocity, 
		actor_ref.move_stats.air_acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector3.ZERO, 2.0 * delta)
		pass
	
	actor_ref.velocity.x = current_velocity.x
	actor_ref.velocity.z = current_velocity.z

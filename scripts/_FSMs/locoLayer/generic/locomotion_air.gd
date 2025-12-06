class_name LocomotionAir
extends State

#region Internal variables
const WALLRUN_THRESHOLD: float = 0.5
#endregion

func enter(previous_state: State = null) -> void:
	if previous_state and previous_state.is_grounded_state:
		actor_ref.blackboard.reset_air_movements(actor_ref.move_stats.max_air_jumps)
		
		if actor_ref.velocity.y <= 0.0:
			actor_ref.blackboard.start_coyote_cooldown(actor_ref.move_stats.coyote_time_duration)
		else:
			actor_ref.blackboard.coyote_cooldown.stop()

func physics_update(delta: float) -> void:
	if _check_transitions(): return
	if _handle_jump(): return
	
	_apply_gravity(delta)
	_apply_movement(delta)

#region Helper Functions
func _check_transitions() -> bool:
	if _try_mantle_transition(): return true
	if _try_grounded_transition(): return true
	if _try_wallrun_transition(): return true
	
	return false

func _try_mantle_transition() -> bool:
	if not actor_ref is Player: return false
	
	var player_ref: Player = actor_ref as Player
	
	if player_ref.ray_up.is_colliding(): return false
	
	if not player_ref.ray_forward.is_colliding(): return false
	if not player_ref.ray_ledge.is_colliding(): return false
	
	transition_requested.emit(self, LocomotionMantle)
	return true

func _try_grounded_transition() -> bool:
	if not actor_ref.is_on_floor(): return false
	
	if actor_ref.input_dir.length() > 0:
		transition_requested.emit(self, LocomotionRun)
	else:
		transition_requested.emit(self, LocomotionIdle)
	return true

func _try_wallrun_transition() -> bool:
	if actor_ref.input_dir.length() < WALLRUN_THRESHOLD: return false
	
	if not (actor_ref.ray_right.is_colliding() or actor_ref.ray_left.is_colliding()):
		return false
	
	if actor_ref.blackboard.is_wallrun_cooldown_active(): return false
	
	transition_requested.emit(self, LocomotionWallrun)
	return true

func _handle_jump() -> bool:
	if not actor_ref.request_to_jump:
		return false
		
	if actor_ref.blackboard.is_coyote_cooldown_active():
		actor_ref.blackboard.coyote_cooldown.stop()
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		return false
		
	elif actor_ref.blackboard.air_jumps_left > 0:
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		actor_ref.blackboard.air_jumps_left -= 1
		return false
		
	return false

func _apply_gravity(delta: float) -> void:
	actor_ref.velocity.y -= actor_ref.gravity * delta

func _apply_movement(delta: float) -> void:
	var direction: Vector3 = (actor_ref.transform.basis * Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y)).normalized()
	
	var target_velocity: Vector3 = direction * actor_ref.move_stats.speed
	var current_velocity: Vector3 = Vector3(actor_ref.velocity.x, 0, actor_ref.velocity.z)
	
	if direction.length() > 0:
		current_velocity = current_velocity.move_toward(target_velocity, 
		actor_ref.move_stats.air_acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector3.ZERO, 2.0 * delta)
	
	actor_ref.velocity.x = current_velocity.x
	actor_ref.velocity.z = current_velocity.z
#endregion

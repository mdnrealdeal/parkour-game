class_name LocomotionIdle
extends State

#region Internal variables
const IDLE_RUN_DECAY: float = 3.0
#endregion

func enter(_previous_state: State = null) -> void:
	actor_ref.blackboard.is_sprinting = false

func physics_update(delta: float) -> void:
	_update_run_decay(delta)
	
	if _check_transitions(): return
	if _handle_jump(): return
	
	_apply_friction(delta)

#region Helper Functions
func _update_run_decay(delta: float) -> void:
	actor_ref.blackboard.run_time -= delta * IDLE_RUN_DECAY

func _check_transitions() -> bool:
	if not actor_ref.is_on_floor():
		transition_requested.emit(self, LocomotionAir)
		return true

	if actor_ref.input_dir.length() > 0:
		transition_requested.emit(self, LocomotionRun)
		return true
	return false

func _handle_jump() -> bool:
	if actor_ref.request_to_jump:
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		transition_requested.emit(self, LocomotionAir)
		return true
	return false

func _apply_friction(delta: float) -> void:
	var current_velocity := Vector2(actor_ref.velocity.x, actor_ref.velocity.z)
	current_velocity = current_velocity.move_toward(Vector2.ZERO, actor_ref.move_stats.friction * delta)

	actor_ref.velocity.x = current_velocity.x
	actor_ref.velocity.z = current_velocity.y
#endregion

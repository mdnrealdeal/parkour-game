class_name LocomotionAir
extends State

#region Internal variables
var air_jumps_left: int = 0
@onready var coyote_timer: Timer = Timer.new()
#endregion

func _ready() -> void:
	coyote_timer.one_shot = true
	add_child(coyote_timer)

func enter() -> void:
	air_jumps_left = actor_ref.move_stats.max_air_jumps
	if actor_ref.velocity.y <= 0.0:
		coyote_timer.start(actor_ref.move_stats.coyote_time_duration)
	else: 
		coyote_timer.stop()

func physics_update(delta: float) -> void:
	actor_ref.velocity.y -= actor_ref.gravity * delta

	if actor_ref.is_on_floor():
		if actor_ref.input_dir.length() > 0: 
			transition_requested.emit(self, LocomotionRun)
		else:
			transition_requested.emit(self, LocomotionIdle)
		return

	##region TODO: Wallrunning code. Not used yet. 
	#if actor_ref.ray_right.is_colliding() or actor_ref.ray_left.is_colliding():
		#if actor_ref.input_dir.y < 0: 
			#transition_requested.emit(self, "WallRun")
			#return
	##endregion
	
	if actor_ref.request_to_jump and not coyote_timer.is_stopped():
		coyote_timer.stop()
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		# TASK: Implement jump squat when ready
		#transition_requested.emit(self, LocomotionJumpSquat)
	elif actor_ref.request_to_jump and air_jumps_left > 0:
		actor_ref.velocity.y = actor_ref.move_stats.jump_force
		air_jumps_left -= 1

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

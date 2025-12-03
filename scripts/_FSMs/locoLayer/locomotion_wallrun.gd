class_name LocomotionWallrun
extends State

#region Internal variables
enum WallSide {LEFT = -1, NONE = 0, RIGHT = 1}
var _wall_normal: Vector3
var _wall_side: int = WallSide.NONE
var _linger_timer: float = 0.0 
#endregion

func enter(_previous_state: State = null) -> void:
	actor_ref.is_wall_running = true
	_linger_timer = 0.0
	
	if actor_ref.velocity.y != 0.0:
		actor_ref.velocity.y = actor_ref.velocity.y / 2
	
	if actor_ref.ray_right.is_colliding():
		_wall_side = WallSide.RIGHT
		_wall_normal = actor_ref.ray_right.get_collision_normal()
	elif actor_ref.ray_left.is_colliding():
		_wall_side = WallSide.LEFT
		_wall_normal = actor_ref.ray_left.get_collision_normal()

func exit() -> void:
	actor_ref.is_wall_running = false
	
func physics_update(_delta: float) -> void:
	
	if do_wall_jump(): return
	
	actor_ref.velocity.y -= (actor_ref.gravity * actor_ref.move_stats.wallrun_gravity_mult) * _delta
	
	var is_on_wall: bool = false
	var current_normal: Vector3 = Vector3.ZERO
	
	if _wall_side == WallSide.RIGHT:
		if actor_ref.ray_right.is_colliding():
			is_on_wall = true
			current_normal = actor_ref.ray_right.get_collision_normal()
		if actor_ref.ray_back_right.is_colliding():
			is_on_wall = true
			current_normal = actor_ref.ray_back_right.get_collision_normal()
	
	if _wall_side == WallSide.LEFT:
		if actor_ref.ray_left.is_colliding():
			is_on_wall = true
			current_normal = actor_ref.ray_left.get_collision_normal()
		if actor_ref.ray_back_left.is_colliding():
			is_on_wall = true
			current_normal = actor_ref.ray_back_left.get_collision_normal()
	
	if is_on_wall:
		_wall_normal = current_normal
		_linger_timer = 0.0
	else:
		_linger_timer += _delta
		if _linger_timer > actor_ref.move_stats.wallrun_linger_duration:
			transition_requested.emit(self, LocomotionRun)
			return
	
	if actor_ref.is_on_floor():
		transition_requested.emit(self, LocomotionIdle)
		return
		
		
	var input_dir_3d := (
		(actor_ref.transform.basis * Vector3(actor_ref.input_dir.x, 0, 
		actor_ref.input_dir.y))
		.normalized()
		)
	
	var wallrun_speed := actor_ref.move_stats.wallrun_speed
	if actor_ref.input_dir.y > 0:
		wallrun_speed = wallrun_speed * actor_ref.move_stats.wallrun_speed_penalty
	
	var wall_forward := input_dir_3d.slide(_wall_normal).normalized()
	var target_velocity := wall_forward * wallrun_speed
	
	actor_ref.velocity.x = lerp(actor_ref.velocity.x, target_velocity.x,
	actor_ref.move_stats.acceleration * _delta)
	
	actor_ref.velocity.z = lerp(actor_ref.velocity.z, target_velocity.z, 
	actor_ref.move_stats.acceleration * _delta)
	
	if is_on_wall:
		actor_ref.velocity -= _wall_normal * 0.5

func do_wall_jump() -> bool:
	if actor_ref.request_to_jump:
		var look_dir := -actor_ref.head.global_transform.basis.z
		look_dir.y = 0
		look_dir = look_dir.normalized()
		
		var steer_dir := look_dir.slide(_wall_normal).normalized()
		
		var jump_velocity := (
			(_wall_normal * actor_ref.move_stats.wallrun_jump_force_side) +
			(Vector3.UP * actor_ref.move_stats.wallrun_jump_force_up) +
			(actor_ref.move_stats.wallrun_jump_force_forward * steer_dir)
			)
		
		actor_ref.velocity = jump_velocity
		transition_requested.emit(self, LocomotionAir)
		return true
	return false

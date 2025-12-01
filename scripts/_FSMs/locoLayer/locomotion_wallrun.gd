class_name LocomotionWallrun
extends State

#region Internal variables
enum WallSide {LEFT = -1, NONE = 0, RIGHT = 1}
var _wall_normal: Vector3
var _wall_side: int = WallSide.NONE
#endregion

func enter(_previous_state: State = null) -> void:
	actor_ref.is_wall_running = true
	
	if actor_ref.ray_right.is_colliding():
		_wall_side = WallSide.RIGHT
		_wall_normal = actor_ref.ray_right.get_collision_normal()
	elif actor_ref.ray_left.is_colliding():
		_wall_side = WallSide.LEFT
		_wall_normal = actor_ref.ray_left.get_collision_normal()

func exit() -> void:
	actor_ref.is_wall_running = false
	
func physics_update(_delta: float) -> void:
	actor_ref.velocity.y -= (actor_ref.gravity * actor_ref.move_stats.wallrun_gravity_mult) * _delta
	
	var is_on_wall: bool = false
	if _wall_side == WallSide.RIGHT and actor_ref.ray_right.is_colliding():
		is_on_wall = true
		_wall_normal = actor_ref.ray_right.get_collision_normal()
	elif _wall_side == WallSide.LEFT and actor_ref.ray_left.is_colliding():
		is_on_wall = true
		_wall_normal = actor_ref.ray_left.get_collision_normal()
	
	if not is_on_wall:
		transition_requested.emit(self, LocomotionAir)
	
	if actor_ref.is_on_floor():
		transition_requested.emit(self, LocomotionIdle)
	
	if actor_ref.request_to_jump:
		var jump_velocity := (
			(_wall_normal * actor_ref.move_stats.wallrun_jump_force_side) +
			(Vector3.UP * actor_ref.move_stats.wallrun_jump_force_side)
			)
		
		actor_ref.velocity = jump_velocity
		transition_requested.emit(self, LocomotionAir)
		return
	
	var input_dir_3d := (
		(actor_ref.transform.basis * Vector3(actor_ref.input_dir.x, 0, actor_ref.input_dir.y))
		.normalized()
		)
	
	var wall_forward := input_dir_3d.slide(_wall_normal).normalized()
	var target_velocity := wall_forward * actor_ref.move_stats.speed
	
	actor_ref.velocity.x = lerp(actor_ref.velocity.x, target_velocity.x, actor_ref.move_stats.acceleration * _delta)
	actor_ref.velocity.z = lerp(actor_ref.velocity.z, target_velocity.z, actor_ref.move_stats.acceleration * _delta)
	
	#actor_ref.velocity -= _wall_normal * 1.0

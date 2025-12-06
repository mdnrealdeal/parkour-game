class_name LocomotionMantle
extends State

var player_check: Player:
	get: return actor_ref as Player

func enter(_previous_state: State = null) -> void:
	assert(player_check != null, "ERROR: State only compatible with Player actor.")
	
	var target_pos: Vector3 = actor_ref.ray_ledge.get_collision_point()
	
	var tween: Tween = create_tween()
	
	tween.set_parallel(false)
	
	tween.tween_property(actor_ref, "global_position:y", target_pos.y, 0.6)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(actor_ref, "global_position:x", target_pos.x, 0.2)
	tween.parallel().tween_property(actor_ref, "global_position:z", target_pos.z, 0.2)
	
	tween.finished.connect(_on_mantle_finished)

func physics_update(_delta: float) -> void:
	actor_ref.velocity = Vector3.ZERO

func _on_mantle_finished() -> void:
	transition_requested.emit(self, LocomotionIdle)

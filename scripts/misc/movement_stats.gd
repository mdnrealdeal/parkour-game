class_name MovementStats
extends Resource

# welcome to the hell of misc movement stats to edit.
@export_group("Movement")
@export var speed: float = 4.0
@export var acceleration: float = 6.0
@export var friction: float = 6.0

@export_group("Sprinting")
@export var sprint_speed: float = 8.0
@export var sprint_acceleration: float = 6.0
@export_range(0, 10, 0.5, "or_greater") var time_before_sprinting: float = 5.0

@export_group("Air")
@export var air_acceleration: float = 2.0
@export var max_air_jumps: int = 1
@export var jump_force: float = 4.5
@export_range(0, 5, 0.1, "or_greater") var coyote_time_duration: float = 0.5

@export_group("Dash")
@export var dash_speed: float = 20.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 10.0

var run_time: float = 0.0:
	set(new_time):
		run_time = clampf(new_time, 0.0, time_before_sprinting)

var time_since_grounded: float = 0.0:
	set(new_time):
		time_since_grounded = clampf(time_since_grounded, 0.0, coyote_time_duration)

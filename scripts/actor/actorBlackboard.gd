class_name ActorBlackboard
extends Node

# references


# timers
@onready var coyote_cooldown_timer: Timer = Timer.new()
@onready var wallrun_cooldown_timer: Timer = Timer.new()


# float counters
var max_run_time: float = 5.0
var run_time: float = 0.0:
	set(new_time):
		run_time = clampf(new_time, 0.0, max_run_time)

# counters
var air_jumps_left: int = 0

# state flags
var is_wall_running: bool = false
var is_sprinting: bool = false
var is_crouching: bool = false

func _ready() -> void:
	coyote_cooldown_timer.one_shot = true
	coyote_cooldown_timer.name = "Coyote Cooldown Timer"
	
	wallrun_cooldown_timer.one_shot = true
	wallrun_cooldown_timer.name = "Wallrun Cooldown Timer"
	
	add_child(coyote_cooldown_timer)
	add_child(wallrun_cooldown_timer)

func setup_run_time(time: float) -> void:
	max_run_time = time

class_name ActorBlackboard
extends Node

#region Actor data properties
# consts / enums
enum WallSide {LEFT = -1, NONE = 0, RIGHT = 1}

# timers
@onready var coyote_cooldown: Timer = Timer.new()
@onready var wallrun_cooldown: Timer = Timer.new()
@onready var dash_cooldown: Timer = Timer.new()

# float counters
var _max_run_time: float = 5.0
var run_time: float = 0.0:
	set(new_time):
		run_time = clampf(new_time, 0.0, _max_run_time)

# counters
var air_jumps_left: int = 0

# state flags
var is_wall_running: bool = false
var is_sprinting: bool = false:
	set(value):
		if is_sprinting != value:
			is_sprinting = !is_sprinting
			_on_sprinting_changed(value)

var is_crouching: bool = false
var last_wall_normal: Vector3 = Vector3.ZERO
var last_wall_side: int = WallSide.NONE
#endregion

func _ready() -> void:
	coyote_cooldown.name = "Coyote Cooldown Timer"
	coyote_cooldown.one_shot = true
	
	wallrun_cooldown.name = "Wallrun Cooldown Timer"
	wallrun_cooldown.one_shot = true
	
	dash_cooldown.name = "Dash Cooldown Timer"
	dash_cooldown.one_shot = true
	
	add_child(coyote_cooldown)
	add_child(wallrun_cooldown)
	add_child(dash_cooldown)


#region helper functions
func start_wallrun_cooldown(duration: float) -> void:
	wallrun_cooldown.start(duration) 

func is_wallrun_cooldown_active() -> bool:
	return not wallrun_cooldown.is_stopped()



func start_dash_cooldown(duration: float) -> void:
	dash_cooldown.start(duration)

func is_dash_ready() -> bool:
	return dash_cooldown.is_stopped()



func start_coyote_cooldown(duration: float) -> void:
	coyote_cooldown.start(duration)

func is_coyote_cooldown_active() -> bool:
	return not coyote_cooldown.is_stopped()



func reset_air_movements(max_jumps: int) -> void:
	air_jumps_left = max_jumps
	#dash_cooldown.stop()

func setup_run_time(time: float) -> void:
	_max_run_time = time
	
func _on_sprinting_changed(_active: bool) -> void:
	pass
#endregion

class_name LabelStateDisplay
extends Label


# NOTICE: This is purely meant for debugging states.
# DO NOT INTEGRATE INTO FINISHED GAME! 

@export var actor: Actor

# History trackers
var loco_current: String = ""
var loco_prev: String = ""
var action_current: String = ""
var action_prev: String = ""

func _ready() -> void:
	# Auto-find actor if attached to the player hierarchy
	if not actor:
		actor = owner as Actor
	
	# Wait one frame for FSMs to initialize
	await get_tree().process_frame
	
	if actor:
		_setup_connections()
		_update_text()

func _setup_connections() -> void:
	# Connect Locomotion Layer
	if actor.fsm_loco_layer:
		actor.fsm_loco_layer.state_changed.connect(_on_loco_changed)
		if actor.fsm_loco_layer.current_state:
			loco_current = actor.fsm_loco_layer.current_state.name
			
	# Connect Action Layer (Crouch/Stand)
	if actor.fsm_action_layer:
		actor.fsm_action_layer.state_changed.connect(_on_action_changed)
		if actor.fsm_action_layer.current_state:
			action_current = actor.fsm_action_layer.current_state.name

func _on_loco_changed(new_state: State) -> void:
	loco_prev = loco_current
	loco_current = new_state.name
	_update_text()

func _on_action_changed(new_state: State) -> void:
	action_prev = action_current
	action_current = new_state.name
	_update_text()

func _process(_delta: float) -> void:
	# Update physics data every frame (Velocity changes constantly)
	_update_text()

func _update_text() -> void:
	if not actor: return
	
	var h_vel := Vector2(actor.velocity.x, actor.velocity.z).length()
	var v_vel := actor.velocity.y
	
	var inputdir_x := actor.input_dir.x
	var inputdir_y := actor.input_dir.y
	
	text = """
	Locomotion FSM:
	State: %s
	Prev:  %s
	
	Action FSM:
	State: %s
	Prev:  %s
	
	Stats:
	Horizontal Speed: %.2f
	Vertical Speed: %.2f
	Wallrun: %s
	Sprinting: %s
	X Input Dir: %s
	Y Input Dir: %s
	""" % [
		loco_current, loco_prev,
		action_current, action_prev,
		h_vel, v_vel,
		str(actor.is_wall_running),
		str(actor.is_sprinting),
		inputdir_x, inputdir_y
	]

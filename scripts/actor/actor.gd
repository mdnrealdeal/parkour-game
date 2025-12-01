@abstract
class_name Actor
extends CharacterBody3D

#region Internal component references
@onready var fsm_loco_layer: StateMachine = %LocoLayer
@onready var fsm_action_layer: StateMachine = %ActionLayer
@onready var head: Node3D = %Head
@onready var collider: CollisionShape3D = %CollisionShape3D
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
#endregion

# Movement stats edited here.
@export var move_stats: MovementStats

#region Virtual controller variables
var input_dir: Vector2 = Vector2.ZERO
var request_to_jump: bool = false
var request_to_dash: bool = false
var request_to_crouch: bool = false

var run_time: float = 0.0:
	set(new_time):
		run_time = clampf(new_time, 0.0, move_stats.time_before_sprinting)
		
#endregion

#region Methods
@abstract func _calculate_movement_parameters() -> void

func _ready() -> void:
	fsm_loco_layer.init(self)
	fsm_action_layer.init(self)

func _physics_process(delta: float) -> void:
	_calculate_movement_parameters()
	
	fsm_loco_layer.process_physics(delta)
	fsm_action_layer.process_physics(delta)
	
	move_and_slide()
	
	request_to_jump = false
	request_to_dash = false
	
func _process(delta: float) -> void:
	fsm_loco_layer.process_frame(delta)
	fsm_action_layer.process_frame(delta)

#endregion

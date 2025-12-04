@abstract
class_name Actor
extends CharacterBody3D

#region Internal component references
@onready var fsm_loco_layer: StateMachine = %LocoLayer
@onready var fsm_action_layer: StateMachine = %ActionLayer
@onready var head: Node3D = %Head
@onready var collider: CollisionShape3D = %CollisionShape3D
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var ray_left: RayCast3D = %RayLeft
@onready var ray_back_left: RayCast3D = %RayBackLeft
@onready var ray_right: RayCast3D = %RayRight
@onready var ray_back_right: RayCast3D = %RayBackRight
#endregion

# Actor-specific data here.
@export var move_stats: MovementStats
var blackboard: ActorBlackboard

#region Virtual controller variables
var input_dir: Vector2 = Vector2.ZERO
var request_to_jump: bool = false
var request_to_dash: bool = false
var request_to_crouch: bool = false
#endregion

#region Methods
@abstract func _calculate_movement_parameters() -> void

func _ready() -> void:
	if not blackboard:
		blackboard = ActorBlackboard.new()
		blackboard.name = "GenericActorBlackboard"
		add_child(blackboard)
	
	blackboard.setup_run_time(move_stats.time_before_sprinting)
	
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

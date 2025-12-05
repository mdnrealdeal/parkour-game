@abstract
class_name State
extends Node


#region Signals
@warning_ignore("unused_signal")
signal transition_requested(from_state: State, to_state_class: Script)
#endregion

#region Variables
var actor_ref: Actor
@export var is_interruptable_state: bool = false
var is_grounded_state: bool = false
#endregion

#region Methods

func can_interrupt(_delta: float) -> bool:
	return false

func enter(_previous_state: State = null) -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

#endregion

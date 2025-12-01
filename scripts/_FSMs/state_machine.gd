class_name StateMachine
extends Node

#region Exported variables
@export var initial_state: State
#endregion

#region Internal variables
var current_state: State
var states: Dictionary[Script, State] = {}
var interrupt_states: Array[State] = []
#endregion

signal state_changed(new_state: State)

func init(actor: Actor) -> void:
	states.clear()
	interrupt_states.clear()
	
	_recursively_find_states(self, actor)
		
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		

func _recursively_find_states(node: Node, actor: Actor) -> void:
	for child in node.get_children():
		if child is State:
			states[child.get_script()] = child
			child.actor_ref = actor
			
			if not child.transition_requested.is_connected(on_transition_requested):
				child.transition_requested.connect(on_transition_requested)
			
			if child.is_interruptable_state:
				interrupt_states.append(child)
		
		elif child.get_child_count() > 0:
			_recursively_find_states(child, actor)

func on_transition_requested(from_state: State, to_state_class: Script) -> void:
	if from_state != current_state:
		push_warning("FSM Warning: State (" + from_state.name + ") 
			requested transition without being current valid state 
			(" + current_state.namew + "). Transition denied.")
		return
	
	var new_state: State = states.get(to_state_class)
	
	if not new_state:
		push_warning("FSM Warning: State transition target '" + str(to_state_class) + "' not found in dictionary.")
		print(states)
		return
	
	change_state(new_state)

func change_state(new_state: State) -> void:
	var previous_state: State = current_state
	
	if current_state:
		current_state.exit()
	
	new_state.enter(previous_state)
	current_state = new_state
	
	state_changed.emit(new_state)

func process_physics(delta: float) -> void:
	for state in interrupt_states:
		if state != current_state and state.can_interrupt(delta):
			change_state(state)
			return
	
	if current_state:
		current_state.physics_update(delta)

func process_frame(delta: float) -> void:
	if current_state:
		current_state.update(delta)

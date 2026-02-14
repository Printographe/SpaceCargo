extends Node
class_name StateMachine 

class ConcreteTransition:
	var current_state : int
	var next_state : int
	var transition_function : Callable
	
	func _init(from : int, to : int, transition : Callable) -> void:
		self.current_state = from
		self.next_state = to
		self.transition_function = transition


signal stateChange(prev_state, current_state)

var _state_identifiers 

var _debug : bool = false
var _name : String
var _states : Array[int]
  
var _current_state : int

#Params

var _ignore_self_transitions : bool = false
var _is_no_conditions_dfs : bool = false

#Allowed to do in state
var process_functions = {}
#transition<State> : Hash<State, [ConcreteTransition]>
	# with Transition[state] = ConcreteTransition._current_state
var transitions = {}

func show_debug():
	self._debug = true
	return self

func sm_print_debug(bla):
	if self._debug:
		print(self._name + ": " + str(bla))


func _init(s0 : int, states : Array[int], state_to_string) -> void:
	stateChange.emit(null, s0)
	self._current_state = s0
	self._states = states
	self._state_identifiers = state_to_string
	for state in states:
		transitions[state] = []

func ignore_self_transitions():
	self._ignore_self_transitions = true
	return self

# Every state in the state space has at most one transition (eg. A --> B --> C --> D). 
# Used to permit the usage of the next() method which given the current state would go to the next one.
func no_conditions_dfs():
	self._is_no_conditions_dfs = true

func get_states():
	return self._states

func get_state():
	return self._current_state

func get_current_state_identifier() -> String:
	return get_state_identifier(self._current_state)

func get_state_identifier(state) -> String:
	return self._state_identifiers[state]

func to_next():
	if self._is_no_conditions_dfs:
		if self.transitions[_current_state][0]:
			self.switch_to(self.transitions[_current_state][0])
		else : 
			push_error("The state {cs} doesn't have a transition state".format({"cs" : self._current_state}))
	else:
		push_error("Can't use the to_next method without adding add no_conditions_dfs() to the instance")



func add_transition(from: int, to: int, with: Callable):
	if self._is_no_conditions_dfs and len(self.transitions[from].keys()) > 1:
		push_error("This graph can have at most one transition per state")
	self.transitions[from].append(ConcreteTransition.new(from, to, with))
	return self


func add_st_transition(to : int, with : Callable) -> StateMachine:
	for state in self._states:
		if state == to and _ignore_self_transitions:
			continue
		self.add_transition(state, to, with)
	return self
	
func add_st_transition_arr(to : Array, with: Callable):
	for state in to:
		if self._states.has(state):
			self.add_st_transition(state, with)
		else :
			push_error("State {} not declared among states definition".format(state))
	return self



	

func set_process_function(state : int, f : Callable, replace : bool = false) -> StateMachine:
	if self.process_functions.has(state) and replace :
		push_error("Trying to set a process function for a state that's already set")
	else:
		self.process_functions[state] = f
	
	return self

func set_process_function_for(states_array : Array, f : Callable, replace_all : bool = false) -> StateMachine:
	for state in states_array:
		if self._states.has(state):
			self.set_process_function(state, f, replace_all)
		else: 
			push_error("State {} not declared among states definition".format(state))
	return self

func set_st_process_function(f : Callable) -> StateMachine:
	for state in self._states:
		self.process_functions[state] = f 
	return self

#for debug
func generate_transition_map() -> Dictionary:
	var simplified_transition_map = {}
	for state in self._states:
		simplified_transition_map[_state_identifiers[state]] = []
		for transition : ConcreteTransition in self.transitions[state]:
			simplified_transition_map[_state_identifiers[state]].append(_state_identifiers[transition.next_state])
			
	sm_print_debug(simplified_transition_map)
	return simplified_transition_map

func generate_process_map() -> Dictionary:
	var process_map : Dictionary = {}
	for state in self._states:
		if self.process_functions.has(state) : 
			process_map[_state_identifiers[state]] = "Ok"
		else :
			process_map[_state_identifiers[state]] = "Unset"
	return process_map


func use_process(delta : float) -> void:
	if self.process_functions.has(self._current_state):
		self.process_functions[_current_state].call(delta)



func switch_to(next):
	sm_print_debug("Attempt to switch from " + _state_identifiers[self._current_state] + " to " + _state_identifiers[next])
	if next == self._current_state and self._ignore_self_transitions:
		return 
	for transition : ConcreteTransition in self.transitions[self._current_state]:
		if transition.next_state == next :
			
			stateChange.emit(self._current_state, next)
			transition.transition_function.call_deferred(self._current_state, next)
			
			self._current_state = next
			sm_print_debug("switched to " + str(_state_identifiers[_current_state]))
			return
			
	
	push_error("No transition from {0} to {1} in the transition map"\
		.format([get_state_identifier(_current_state), get_state_identifier(next)]))
	
	
	#self.current_state = transition_map[self.current_state]
	
	
	#utility 

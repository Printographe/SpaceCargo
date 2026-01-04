extends Node
class_name Mission

# DFE
# 4 step progress : 
#	1. Go to Point A from your current position
#	2.Take the cargo 
#	3. Go to Point B
#	4. Put the cargo there


signal emit_contract_info
signal updateAdvancement(max : int, current : int)

enum MissionState {
	NULL,
	PENDING,
	ACCEPTED_ONGOING,
	REFUSED,
	FINISHED_SUCCESS,
	FINISHED_FAILURE,
}



var max_progress: int = 0
var _progress: int =0

func incr_progress():
	
	self._progress +=1
	updateAdvancement.emit(_progress, max_progress)
	if _progress == max_progress:
		self.statemachine.switch_to(MissionState.FINISHED_SUCCESS)
		





var statemachine : StateMachine


@export var contractor = ""
@export_multiline var context = ""
#More points? 


@export var time : float 
@export var price: float
@export var id : int



func _enter_tree() -> void:
	
	
	
	var state_identifier = {
	MissionState.NULL : StringName("Null"),
	MissionState.PENDING : StringName("Pending"),
	MissionState.ACCEPTED_ONGOING : StringName("Ongoing"),
	MissionState.REFUSED : StringName("Refused"),
	MissionState.FINISHED_SUCCESS : StringName("Success"),
	MissionState.FINISHED_FAILURE : StringName("Failed"),
	}
	
	self.statemachine = StateMachine.new(MissionState.NULL,
		[
			MissionState.NULL,
			MissionState.PENDING,
			MissionState.ACCEPTED_ONGOING,
			MissionState.REFUSED,
			MissionState.FINISHED_SUCCESS,
			MissionState.FINISHED_FAILURE
		], state_identifier) \
		.add_transition(MissionState.NULL, MissionState.PENDING, print_transition) \
		.add_transition(MissionState.PENDING, MissionState.ACCEPTED_ONGOING, print_transition ) \
		.add_transition(MissionState.ACCEPTED_ONGOING, MissionState.FINISHED_SUCCESS,print_transition)\
		.add_transition(MissionState.ACCEPTED_ONGOING, MissionState.FINISHED_FAILURE, print_transition)\
		.add_transition(MissionState.PENDING, MissionState.REFUSED, func (u, v) :
			print_transition(u, v))
	
	self.add_to_group("missions");
	self.statemachine.switch_to(MissionState.PENDING)
	
	
	self.max_progress = self.get_child_count()
	for child : MissionItem in self.get_children():
		child.taskDone.connect(incr_progress)
	
	
	

func print_transition(last, current):
	print("Mission {id} : from {last} to {state}"\
		.format(
			{"id" : self.id,
			"last" : self.statemachine.get_state_identifier(last),
			"state" :self.statemachine.get_state_identifier(current) }))

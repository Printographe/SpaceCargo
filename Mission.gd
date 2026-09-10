extends Node3D
class_name Mission

# DFE
# 4 step progress : 
#	1. Go to Point A from your current position
#	2.Take the cargo 
#	3. Go to Point B
#	4. Put the cargo there

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

var progress : int: 
    get():
        return _progress
    set(value):
        _progress = clamp(value, 0,  max_progress)
        updateAdvancement.emit(max_progress, _progress)





var statemachine : StateMachine


@export var contractor = ""
@export_multiline var context = ""
#More points? 


@export var time : float 
@export var price: float
@export var id : int



func _enter_tree() -> void:
    
    
    
    var state_identifiers = {
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
        ], state_identifiers) \
        .add_transition(MissionState.NULL, MissionState.PENDING, print_transition) \
        .add_transition(MissionState.PENDING, MissionState.ACCEPTED_ONGOING, print_transition ) \
        .add_transition(MissionState.ACCEPTED_ONGOING, MissionState.FINISHED_SUCCESS,print_transition)\
        .add_transition(MissionState.ACCEPTED_ONGOING, MissionState.FINISHED_FAILURE, print_transition)\
        .add_transition(MissionState.PENDING, MissionState.REFUSED, func (u, v) :
            print_transition(u, v))
    
    self.add_to_group("missions");
    self.statemachine.switch_to(MissionState.PENDING)

func recursively_connect_children(children):
    for child in children :
        if child is MissionItem:
            max_progress += 1
            child.taskDone.connect(func (): 
                progress += 1
                if progress == max_progress and self.statemachine.get_state() == MissionState.ACCEPTED_ONGOING:
                    self.statemachine.switch_to(MissionState.FINISHED_SUCCESS)
                
            )
            child.connect_to_mission(self)
        else: 
            recursively_connect_children(child.get_children())	

func _ready() -> void:
    recursively_connect_children(self.get_children())

func get_state():
    return self.statemachine.get_state()			
    

func print_transition(last, current):
    print("Mission {id} : from {last} to {state}"\
        .format(
            {"id" : self.id,
            "last" : self.statemachine.get_state_identifier(last),
            "state" :self.statemachine.get_state_identifier(current) }))

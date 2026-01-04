extends Area3D
class_name MissionItem


var mission : Mission

@export var progress: int

signal taskDone
signal showContent

@onready var StateFunction = {
	Mission.MissionState.PENDING : on_pending,
	Mission.MissionState.REFUSED : on_refusal,
	Mission.MissionState.FINISHED_SUCCESS : on_success,
	Mission.MissionState.ACCEPTED_ONGOING : on_progress,
	Mission.MissionState.FINISHED_FAILURE : on_failure
}


signal player_entered(body : PlayerController)

func on_success(player):
	print("Why doesn't it work ?")

func on_failure(player):
	pass
	

func on_progress(player):
	pass

func on_refusal(player):
	pass
	
func on_pending(player):
	print("body entered from mission itemds")

func mission_done():
	pass

func show_content(title, content, show_mission = false):
	self.showContent.emit(title, content, show_mission, self.mission)


func _player_entered_check(body):
	if body is PlayerController:
		player_entered.emit(body)

func _ready():
	self.body_entered.connect(_player_entered_check)
	
	mission = get_parent()
	if mission is Mission:
		#allowed, because it synchronises 
		player_entered.connect(StateFunction[mission.statemachine.get_state()])
		mission.statemachine.stateChange.connect(func (prev, current): 

			_on_mission_state_change(prev, current)
		)
	else :
		push_error(false, "MissionItem instance not child of Mission")
	
	self.add_to_group("mission_items")
	


func _on_mission_state_change(prev, current):
	#These are sequential and work only on body entered
	if not prev == null:
		self.player_entered.disconnect(StateFunction[prev])
	self.player_entered.connect(StateFunction[current])
	
	#These work instantly
	if current == Mission.MissionState.FINISHED_SUCCESS:
		mission_done()

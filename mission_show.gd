extends MarginContainer
class_name MissionShow


var free = true
var current_mission : Mission = null

signal freeMS(MissionShow)

func _ready() -> void:
	$Panel/VboxContainer/MarginContainer2/ProgressBar.set_value(0)


func connect_to_mission(mission : Mission):
	self.free = false
	self.current_mission = mission
	$Timer.set_wait_time(mission.time)
	$Timer.set_one_shot(true)
	
	$Timer.timeout.connect(func() : print("timeout for mission #" + str(mission.id)))
	$Panel/VboxContainer/MarginContainer2/ProgressBar.set_max(mission.max_progress)
	current_mission.updateAdvancement.connect(func (_maximum, curr) : $Panel/VboxContainer/MarginContainer2/ProgressBar.set_value(curr))
	self.show()
	$Timer.start()
	current_mission.statemachine.stateChange.connect(sever_ties, CONNECT_ONE_SHOT)

func _process(_delta: float) -> void:
	if current_mission == null : return 
	$Panel/VboxContainer/MarginContainer/HBoxContainer/time.set_text(str("%0.2fs" % $Timer.get_time_left()))


func sever_ties(_prev, curr) : 
	if curr == Mission.MissionState.FINISHED_FAILURE or curr == Mission.MissionState.FINISHED_SUCCESS:
		#Possible bug : keeping connection to multiple signals
		self.current_mission = null
		self.free = true
		self.freeMS.emit(self)

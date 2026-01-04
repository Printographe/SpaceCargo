extends Control


var show_mission_container = false

var available_mission_button : Dictionary[Mission, Button] = {}


var debug_hidden = false


func connect_mission() :
	var missions = get_tree().get_nodes_in_group("missions")
	for mission: Mission in missions:
		mission.statemachine.stateChange.connect(func (_last, current): 
			if current == Mission.MissionState.FINISHED_SUCCESS:
				$MissionSuccessMessage.show()
				
				$time.set_wait_time(2)
				$time.start()
				$time.timeout.connect(func () : 
					$MissionSuccessMessage.hide(), CONNECT_ONE_SHOT)
				$Dashboard_panel/MissionProgressbar.set_progress(1) 
				
			elif current == Mission.MissionState.REFUSED :
				if available_mission_button.has(mission):
					available_mission_button[mission].queue_free()
					available_mission_button.erase(mission)
					
					
			elif current == Mission.MissionState.ACCEPTED_ONGOING:
				mission.updateAdvancement.connect(func(curr, maximum) : update_progressbar(curr, maximum))
				
			
			if current == Mission.MissionState.FINISHED_SUCCESS :
				print("Mission rcv from Dashboard")
				if available_mission_button.has(mission):
					available_mission_button[mission].queue_free()
					available_mission_button.erase(mission)
		)

func setup_player_debug():
	$ShowDebug.pressed.connect(func ():
		for node in get_tree().get_nodes_in_group("Debug"):
			node.visible = debug_hidden
			debug_hidden = !debug_hidden)
	

func _ready():
	$Dashboard_panel/mission_button.connect("pressed", on_mission_button_pressed)
	$Dashboard_panel/MissionProgressbar.set_progress(0)
	#$FuelBar.set_progress()
	setup_player_debug()
	connect_mission()
	
	$MissionItemText.showMission.connect($mission_panel.set_contract_info)



func on_mission_button_pressed():
	self.show_mission_container = !self.show_mission_container
	$Dashboard_panel/mission_container.visible = self.show_mission_container
	update_mission_container()
	
func update_mission_container():
	var missions = get_tree().get_nodes_in_group("missions") 
	
	var pending_missions = []
	for mission : Mission in missions:
		if mission.statemachine.get_state() == Mission.MissionState.PENDING:
			pending_missions.append(mission)
	#for mission in missions:
		#print("mission {id} : {state}"\
			#.format({"id" : mission.id, "state" :  mission.statemachine.get_state_identifier(mission.statemachine.current_state) }))
	print("Pending Missions :", pending_missions)
	for mission in pending_missions: 
		if available_mission_button.has(mission) : continue
		else:
			var mission_button = Button.new()
			mission_button.name = "Mission " + str(mission.id)
			mission_button.text = mission.contractor
			mission_button.pressed.connect(func () : $mission_panel.set_contract_info(mission) )
			
			available_mission_button[mission] = mission_button
			
			$Dashboard_panel/mission_container.add_child(mission_button)

func update_progressbar(current, maximum):
	$Dashboard_panel/MissionProgressbar.set_progress(float(current)/float(maximum))

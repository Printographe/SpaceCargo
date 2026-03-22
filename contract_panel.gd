extends Control

#Will have to implement it

#signal accept_mission
#signal refuse_mission


var connected_mission : Mission = null;

func _ready() -> void:
	$VBoxContainer/HBoxContainer/cancelbutton.pressed.connect(self.hide)
	self.hide()


func set_contract_info(mission : Mission):

	if connected_mission : 
		$VBoxContainer/MarginContainer2/ActionButtons/ConfirmButton.disconnect("pressed", on_confirm_button_pressed)
		$VBoxContainer/MarginContainer2/ActionButtons/RefuseButton.disconnect("pressed", on_refused_button_pressed)
	
	connected_mission = mission

	print_rich("[color=green]Showing mission {0}[/color]".format([mission.id]))
	
	
	$VBoxContainer/Offer/amount.set_text(str(mission.price))
	$VBoxContainer/Time/time.set_text(str(mission.time))
	$VBoxContainer/MarginContainer/Context.set_text(mission.context)
	
	for button in $VBoxContainer/MarginContainer2/ActionButtons.get_children():
		button.show()
	
	match mission.statemachine.get_state() :
		
		Mission.MissionState.PENDING:
			$VBoxContainer/MarginContainer2/ActionButtons/OngoingButton.hide()
			
			$VBoxContainer/MarginContainer2/ActionButtons/ConfirmButton.connect("pressed", on_confirm_button_pressed.bind(connected_mission), CONNECT_ONE_SHOT)
				
			$VBoxContainer/MarginContainer2/ActionButtons/RefuseButton.connect("pressed", on_refused_button_pressed.bind(connected_mission), CONNECT_ONE_SHOT)
	
		Mission.MissionState.ACCEPTED_ONGOING:
			$VBoxContainer/MarginContainer2/ActionButtons/ConfirmButton.hide()
			$VBoxContainer/MarginContainer2/ActionButtons/RefuseButton.hide()
			$VBoxContainer/MarginContainer2/ActionButtons/OngoingButton.show()
			$VBoxContainer/MarginContainer2/ActionButtons/OngoingButton \
				.pressed.connect(self.hide, CONNECT_ONE_SHOT)
		_:
			push_error("Mission {id} shown while state is {state}"
				.format({"id" : mission.id, "state" : mission.statemachine.get_state_identifier(mission.statemachine.current_state) }))
	
	self.show()

func on_confirm_button_pressed(mission):
	mission.statemachine.switch_to(Mission.MissionState.ACCEPTED_ONGOING)
	self.hide()

func on_refused_button_pressed(mission):
	self.hide()
	mission.statemachine.switch_to(Mission.MissionState.REFUSED)

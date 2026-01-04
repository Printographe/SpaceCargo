extends Control

signal accept_mission
signal refuse_mission




func _ready() -> void:
	$VBoxContainer/HBoxContainer/cancelbutton.pressed.connect(self.hide)
	self.hide()


func set_contract_info(mission : Mission):
	print_rich("[color=green]Showing mission {0}[/color]".format([mission.id]))
	
	
	$VBoxContainer/Offer/amount.text = str(mission.price)
	$VBoxContainer/Time/time.text = str(mission.time)
	$VBoxContainer/Context.text = mission.context
	
	for button in $VBoxContainer/ActionButtons.get_children():
		button.show()
	
	match mission.statemachine.get_state() :
		
		Mission.MissionState.PENDING:
			$VBoxContainer/ActionButtons/OngoingButton.hide()
			
			$VBoxContainer/ActionButtons/ConfirmButton.connect("pressed", func ():
				self.hide()
				mission.statemachine.switch_to(Mission.MissionState.ACCEPTED_ONGOING)
				self.hide(), CONNECT_ONE_SHOT)
				
			$VBoxContainer/ActionButtons/RefuseButton.connect("pressed", func ():
				self.hide()
				mission.statemachine.switch_to(Mission.MissionState.REFUSED),
				CONNECT_ONE_SHOT)
	
		Mission.MissionState.ACCEPTED_ONGOING:
			$VBoxContainer/ActionButtons/ConfirmButton.hide()
			$VBoxContainer/ActionButtons/RefuseButton.hide()
			$VBoxContainer/ActionButtons/OngoingButton.show()
			$VBoxContainer/ActionButtons/OngoingButton \
				.pressed.connect(self.hide, CONNECT_ONE_SHOT)
		_:
			push_error("Mission {id} shown while state is {state}"
				.format({"id" : mission.id, "state" : mission.statemachine.get_state_identifier(mission.statemachine.current_state) }))
	#Match end
	self.show()

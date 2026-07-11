extends Control

#Will have to implement it

#signal accept_mission
#signal refuse_mission

signal nextItem


@onready var confirmButton : Button = $VBoxContainer/MarginContainer2/ActionButtons/ConfirmButton
@onready var refuseButton : Button = $VBoxContainer/MarginContainer2/ActionButtons/RefuseButton
@onready var cancelButton : Button = $VBoxContainer/MarginContainer3/HBoxContainer/cancelbutton
@onready var ongoingButton : Button = $VBoxContainer/MarginContainer2/ActionButtons/OngoingButton


@onready var amount_label : Label = $VBoxContainer/Offer/amount
@onready var time_label : Label = $VBoxContainer/Time/time
@onready var context_text : RichTextLabel = $VBoxContainer/MarginContainer/Context

@onready var action_buttons_container = $VBoxContainer/MarginContainer2/ActionButtons

var connected_mission : Mission = null;


func finished():
    self.hide()
    nextItem.emit()

func _ready() -> void:
    self.hide()


func set_contract_info(mission : Mission):

    if connected_mission :
        if confirmButton.pressed.is_connected(on_refused_button_pressed) :
            confirmButton.disconnect("pressed", on_confirm_button_pressed)
        if refuseButton.pressed.is_connected(on_refused_button_pressed):
            refuseButton.disconnect("pressed", on_refused_button_pressed)
    
    connected_mission = mission

    print_rich("[color=green]Showing mission {0}[/color]".format([mission.id]))
    
    
    amount_label.set_text(str(mission.price))
    time_label.set_text(str(mission.time))
    context_text.set_text(mission.context)
    
    for button in action_buttons_container.get_children():
        button.show()
    
    match mission.statemachine.get_state() :
        
        Mission.MissionState.PENDING:
            ongoingButton.hide()
            confirmButton.pressed.connect(on_confirm_button_pressed.bind(connected_mission), CONNECT_ONE_SHOT)
            refuseButton.pressed.connect(on_refused_button_pressed.bind(connected_mission), CONNECT_ONE_SHOT)
            confirmButton.grab_focus()

        Mission.MissionState.ACCEPTED_ONGOING:
            confirmButton.hide()
            refuseButton.hide()
            ongoingButton.show()
            ongoingButton.grab_focus()
            ongoingButton.pressed.connect(finished, CONNECT_ONE_SHOT)
        _:
            push_error("Mission {id} shown while state is {state}"
                .format({"id" : mission.id, "state" : mission.statemachine.get_current_state_identifier() }))
    
    self.show()

func on_confirm_button_pressed(mission):
    print("ça marche ????")
    mission.statemachine.switch_to(Mission.MissionState.ACCEPTED_ONGOING)
    finished()

func on_refused_button_pressed(mission):
    mission.statemachine.switch_to(Mission.MissionState.REFUSED)
    finished()

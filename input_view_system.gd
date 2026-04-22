###This class is soooo bad
##TODO : Divide into two classes => input system and visual system 

extends VBoxContainer



@onready var key_a_button = $HBoxContainer3/UIInteractionButton/Button
@onready var key_a_label = $HBoxContainer3/UIInteractionButton/Label

@onready var key_x_button = $MarginContainer2/HBoxContainer2/AccelerationButton/Button
@onready var key_x_label = $MarginContainer2/HBoxContainer2/AccelerationButton/Label

@onready var key_e_button = $MarginContainer/HBoxContainer/ObjectInteractionButton/Button
@onready var key_e_label = $MarginContainer/HBoxContainer/ObjectInteractionButton/Label

@onready var key_c_button = $MarginContainer2/HBoxContainer2/BrakesButton/Button
@onready var key_c_label = $MarginContainer2/HBoxContainer2/BrakesButton/Label


var player : PlayerController = null
var check_speed_up = false

var paused = false

##We should make it a queue ordered by priority
var current_focus : Dictionary[Interaction.KEYS, Interaction] = {
    Interaction.KEYS.A : null,
    Interaction.KEYS.E : null,
    Interaction.KEYS.C : null,
    Interaction.KEYS.X : null,
}

#Ideally, I'd make these statically sized.. but oh well.
var awaiting_interactions : Dictionary[Interaction.KEYS, Array] = {
    Interaction.KEYS.A : [],
    Interaction.KEYS.E : [],
    Interaction.KEYS.C : [],
    Interaction.KEYS.X : [],
}



@onready var key_to_button : Dictionary[Interaction.KEYS, Button] = {
    Interaction.KEYS.X : key_x_button,
    Interaction.KEYS.C : key_c_button,
    Interaction.KEYS.A : key_a_button,
    Interaction.KEYS.E : key_e_button,
}

@onready var key_to_label = {
    Interaction.KEYS.X : key_x_label,
    Interaction.KEYS.C : key_c_label,
    Interaction.KEYS.A : key_a_label,
    Interaction.KEYS.E : key_e_label,
}


#My own keycode to Godot input event to 
#TODO : Just rename my keys with the same events and put it as a static map 
var int_key_to_ui = {
    Interaction.KEYS.X : "accelerate",
    Interaction.KEYS.C : "decelerate",
    Interaction.KEYS.A : "ui_interaction",
    Interaction.KEYS.E : "object_interaction",
}

var awaiting_interactibles: Array[Interactible] = []

func add_interactible(interactible : Interactible):
    interactible.sendInteraction.connect(set_interaction)
    interactible.loseInteraction.connect(remove_interactions)
    interactible.pauseInputProcessing.connect(func () : paused = true)

func _enter_tree() -> void:
    add_to_group("interaction_system", true)
        

    for  k in get_tree().get_nodes_in_group("PlayerController"):
        player = k
    if player and player is PlayerController:
        player.movement_statemachine.stateChange.connect(on_speed_change)
        #manual call for sync
        on_speed_change(player.STATES.NULL, player.movement_statemachine.get_state())


func resume_input_listner():
    self.paused = false


func suspend_interaction(interaction : Interaction):
    disconnect_interaction(interaction)
    add_awaiting_interaction(interaction)

func add_awaiting_interaction(interaction : Interaction):
    #TODO implement a binary insert 
    self.awaiting_interactions[interaction.key].append(interaction)
    self.awaiting_interactions.sort()

func fetch_awaiting_interaction(key):
    if len(self.awaiting_interactions[key]) > 0:
        return self.awaiting_interactions[key].pop_front()




func on_speed_change(past, current):
    key_x_button.set_disabled(true)
    if current == PlayerController.STATES.IDLE:
        key_c_button.set_disabled(true)
    else:
        # key_x_button.set_disabled(false)
        key_c_button.set_disabled(false)
    if player.gear_to_number[past] < player.gear_to_number[current]:
        check_speed_up = true
    else:
        key_x_button.set_disabled(false) 

func set_interaction(interaction: Interaction):
    var current_focus_input : Interaction = current_focus[interaction.key] 

    if current_focus_input:
        if interaction.priority >= current_focus_input.priority:
            suspend_interaction(current_focus_input)
            set_focus(interaction)
        else: 
            add_awaiting_interaction(interaction)
    else :
        set_focus(interaction)


func set_focus_on_awaiting_interection(key):
    var possible_awaiting_interaction = fetch_awaiting_interaction(key)
    if possible_awaiting_interaction:
        set_focus(possible_awaiting_interaction)
    else :
        current_focus[key] = null

func remove_interactions(interaction_stack: Array[Interaction]):
    for interaction : Interaction in interaction_stack:
        if  current_focus[interaction.key] == interaction and not (interaction.persistent or interaction.delete_on_play):
            var key = interaction.key
            disconnect_interaction(current_focus[key])
            set_focus_on_awaiting_interection(key)
    
    for key in awaiting_interactions.keys():
        for awaiting_interaction in awaiting_interactions[key]:
            for interaction in interaction_stack:
                if interaction == awaiting_interaction and not (interaction.persistent or interaction.delete_on_play):
                    disconnect_interaction(interaction)
                    awaiting_interactions[key].erase(interaction) 


func disconnect_interaction(interaction : Interaction):
    var pertaining_button = key_to_button[interaction.key]
    if pertaining_button.pressed.is_connected(interaction._callback):
        pertaining_button.pressed.disconnect(interaction._callback)
    key_to_button[interaction.key].set_disabled(true)
    key_to_label[interaction.key].set_text("")


func set_focus(interaction: Interaction):
    current_focus[interaction.key] = interaction
    key_to_button[interaction.key].pressed.connect(interaction._callback)
    key_to_button[interaction.key].set_disabled(false)
    key_to_label[interaction.key].set_text(interaction.label)


func _input(_event: InputEvent) -> void:
    if paused : return
    for key in current_focus:
        var interaction : Interaction = current_focus[key]
        if interaction == null : continue
        if Input.is_action_just_released(int_key_to_ui[interaction.key]) and interaction.is_valid():
            interaction.play()
            if interaction.delete_on_play: #order matters
                disconnect_interaction(interaction)
                set_focus_on_awaiting_interection(key)

func _process(_delta: float) -> void:
    if player and check_speed_up and player.can_speed_up():
            key_x_button.set_disabled(false)
            check_speed_up = false

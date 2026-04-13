extends VBoxContainer

##Rewrite with statemachine ????

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

##We should make it a queue ordered by priority
var current_focus : Dictionary[Interaction.KEYS, Interaction] = {
    Interaction.KEYS.A : null,
    Interaction.KEYS.E : null,
    Interaction.KEYS.C : null,
    Interaction.KEYS.X : null,
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

var int_key_to_ui = {
    Interaction.KEYS.X : "accelerate",
    Interaction.KEYS.C : "decelerate",
    Interaction.KEYS.A : "ui_interaction",
    Interaction.KEYS.E : "object_interaction",
}


func _ready() -> void:
    for node in get_tree().get_nodes_in_group("Interactibles"):
        var interactible : Interactible = node
        interactible.sendInteraction.connect(set_interaction)
        interactible.loseInteraction.connect(reset_interaction)

    for  k in get_tree().get_nodes_in_group("PlayerController"):
        player = k
    if player and player is PlayerController:
        player.movement_statemachine.stateChange.connect(on_speed_change)
        #manual call for sync
        on_speed_change(player.STATES.NULL, player.movement_statemachine.get_state())




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
    print("asking for interaction to be set ")

    if current_focus[interaction.key]:
        if interaction.priority >= current_focus[interaction.key].priority:
            disconnect_interaction(current_focus[interaction.key])
        else: 
            push_error("Interaction priority is below current interaction's priority")
            return

    set_focus(interaction)
        
func reset_interaction(focus):
    for key in current_focus:
        if  current_focus[key] and current_focus[key].emitor == focus:
            print("removing interaction from here (input view system l86)")
            disconnect_interaction(current_focus[key])
            current_focus[key] = null
    
func disconnect_interaction(interaction : Interaction):
    print("disconnecting from button")
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


func _input(event: InputEvent) -> void:
    for key in current_focus:
        var interaction = current_focus[key]
        if interaction == null : continue
        if Input.is_action_pressed(int_key_to_ui[interaction.key]) and interaction.is_valid():
            interaction.play()

func _process(_delta: float) -> void:
    if player and check_speed_up and player.can_speed_up():
            key_x_button.set_disabled(false)
            check_speed_up = false

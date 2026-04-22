extends Node
class_name Interactible

signal sendInteraction(interaction)
signal loseInteraction
signal pauseInputProcessing
signal resumeInputProcessing



##TODO when separating VisualInteraction from Interaction, add node_path for the "emitor" 
##The emitor should be the reference that tells if the interaction is valid or not => self would work too ig but better safe than sorry 

#inner workings :sleep:
var _interaction_stack :Array[Interaction] = []


func send_interaction(key : int, label :String, callback : Callable):
    var interaction = Interaction.new(key, label, self, callback)
    _send_interaction_with_raw(interaction)

func send_delete_on_play_interaction(key : int, label : String, callback : Callable):
    var interaction = Interaction.new(key, label, self, callback)
    interaction.delete_on_play = true
    _send_interaction_with_raw(interaction)

func send_persistent_interaction(key, label, callback):
    var interaction = Interaction.new(key, label, self, callback)
    interaction.persistent = true
    _send_interaction_with_raw(interaction)

func _send_interaction_with_raw(interaction: Interaction):
    self._interaction_stack.push_back(interaction)
    sendInteraction.emit(interaction)


func _ready() -> void:
    var interaction_system = get_tree().get_first_node_in_group("interaction_system")
    interaction_system.add_interactible(self)
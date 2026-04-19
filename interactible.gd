extends Area3D
class_name Interactible

signal sendInteraction(interaction)
signal loseInteraction


@export var child_mesh_path : NodePath
@onready var highlight_shader = preload("res://simple contour shader.tres") 


##TODO when separating VisualInteraction from Interaction, add node_path for the "emitor" 
##The emitor should be the reference that tells if the interaction is valid or not => self would work too ig but better safe than sorry 

#inner workings :sleep:
var _interaction_stack :Array[Interaction] = []


var _player : PlayerController



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
    self.add_to_group("Interactibles")
    for player_node : PlayerController in get_tree().get_nodes_in_group("PlayerController"):
        _player = player_node
        _player.interactible_detected.connect(_on_detected)
        _player.interactible_undetected.connect(_on_undetect)


func on_detected(player):
    pass

func _on_detected(body):
    _set_detect(body, true)
    if self == body : 
        on_detected(self._player)

func _on_undetect(body):
    _set_detect(body, false)
    if self == body :
        if len(self._interaction_stack)> 0:
            loseInteraction.emit(self._interaction_stack)
            #thank god for manual memory management :)
            self._interaction_stack.clear()
        on_interaction_lost()

func on_interaction_lost():
    pass


func _set_detect(body, enabled):
    if self != body: return
    var val = {true : highlight_shader, false : null}[enabled]
    var child_mesh = get_node_or_null(child_mesh_path)
    if !child_mesh:
        push_error("Child mesh not specified")
        return
    else:
        if not child_mesh is MeshInstance3D:
            for child in child_mesh.get_children():
                _set_overlay(child, val)
        else : 
            _set_overlay(child_mesh, val)

func _set_overlay(object, val):
    if object is MeshInstance3D:
        object.set_material_overlay(val)
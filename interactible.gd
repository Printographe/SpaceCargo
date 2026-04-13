extends Area3D
class_name Interactible

signal sendInteraction(interaction)
signal loseInteraction


@export var child_mesh_path : NodePath
@onready var highlight_shader = preload("res://simple contour shader.tres") 


var __player : PlayerController

func _ready() -> void:
    self.add_to_group("Interactibles")
    for player_node : PlayerController in get_tree().get_nodes_in_group("PlayerController"):
        __player = player_node
        __player.interactible_detected.connect(_on_detected)
        __player.interactible_undetected.connect(_on_undetect)


func on_detected(player):
    pass


func _on_detected(body):
    _set_detect(body, true)
    if self == body : 
        on_detected(self.__player)

func _on_undetect(body):
    _set_detect(body, false)
    if self == body :
        loseInteraction.emit(self)
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
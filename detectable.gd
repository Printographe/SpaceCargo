extends Area3D

class_name Detectable

@export var interactible_path : NodePath
@export var child_mesh_path : NodePath
@onready var highlight_shader = preload("res://simple contour shader.tres") 

var __player : PlayerController
var interactible : Interactible
var enabled : bool = true


func _ready() -> void:
    interactible = get_node_or_null(interactible_path)
    if not interactible :
        push_error("A detectable is needed in order to for the interactible to work as expected.")
    for player_node : PlayerController in get_tree().get_nodes_in_group("PlayerController"):
        __player = player_node
        __player.on_detectable_found.connect(_on_detected)
        __player.on_detectable_lost.connect(_on_undetect)


func on_detected(player):
    pass

func _on_detected(body):
    if not enabled : return 
    _set_detect(body, true)
    if self == body : 
        on_detected(self.__player)

#the signal is about something being undetected, we need to check that it's this specific instance 
func _on_undetect(body):
    if not enabled : return
    _set_detect(body, false)
    if self == body :
        if len(self.interactible._interaction_stack)> 0:
            interactible.loseInteraction.emit(self.interactible._interaction_stack)
            #thank god for manual memory management :)
            self.interactible._interaction_stack.clear()
        self.on_detection_lost()


func _set_detect(body, entering):
    if self != body: return
    var val = {true : highlight_shader, false : null}[entering]
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

func on_detection_lost():
    pass

func disable_detection():
    self.enabled = false
    _on_undetect(self)
    

func enable_detection():
    self.enabled = true

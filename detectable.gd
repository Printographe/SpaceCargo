extends Area3D

class_name Detectable


var interactible : Interactible



@export var child_mesh_path : NodePath
@onready var highlight_shader = preload("res://simple contour shader.tres") 

var _player : PlayerController

func _ready() -> void:
    interactible = Interactible.new()
    self.add_child(interactible) 

    for player_node : PlayerController in get_tree().get_nodes_in_group("PlayerController"):
        _player = player_node
        _player.on_detectable_found.connect(_on_detected)
        _player.on_detectable_lost.connect(_on_undetect)


func on_detected(player):
    pass

func _on_detected(body):
    _set_detect(body, true)
    if self == body : 
        on_detected(self._player)

func _on_undetect(body):
    _set_detect(body, false)
    if self == body :
        if len(self.interactible._interaction_stack)> 0:
            interactible.loseInteraction.emit(self.interactible._interaction_stack)
            #thank god for manual memory management :)
            self.interactible._interaction_stack.clear()
        self.on_detection_lost()


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

func on_detection_lost():
    pass
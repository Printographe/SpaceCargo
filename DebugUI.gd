extends Control
class_name DebugUI

var debug_name : String
func set_debug_name(name):
	self.debug_name = name


func _enter_tree() -> void:
	self.add_to_group("Debug")

func connect_to_node(node):
	pass

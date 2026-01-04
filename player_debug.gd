extends DebugUI
class_name PlayerDebug

var player : PlayerController

func connect_to_node(node):
	self.player = node
	if player is PlayerController:
		player.rotation_statemachine.stateChange.connect(func (prev, curr) :
			$HBoxContainer2/VBoxContainer/PrevStateValue.text = player.rotation_statemachine.get_state_identifier(prev)
			$HBoxContainer2/VBoxContainer2/CurrentStateValue.text = player.rotation_statemachine.get_state_identifier(curr)
			)

func _process(delta: float) -> void:
	if player is PlayerController:
		$HBoxContainer2/VBoxContainer4/VelocityValue.text = \
			"x: {x}, y: {y}, z: {z} ".format({"x":player.velocity.x, "y": player.velocity.y, "z":player.velocity.z})
		$HBoxContainer2/VBoxContainer5/AccelerationValue.text = str(player.acceleration)

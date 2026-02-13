extends DebugUI
class_name PlayerDebug

var player : PlayerController

func connect_to_node(node):
	self.player = node
	if player is PlayerController:
		player.rotation_statemachine.stateChange.connect(func (prev, curr) :
			$HBoxContainer2/VBoxContainer/PrevStateValue.set_text(player.rotation_statemachine.get_state_identifier(prev))
			$HBoxContainer2/VBoxContainer2/CurrentStateValue.set_text(player.rotation_statemachine.get_state_identifier(curr))
			)
		
		player.rotation_statemachine.stateChange.connect(func(_prev, _curr) :
			$HBoxContainer2/VBoxContainer5/SpeedValue.set_text(str(sqrt(player.velocity.dot(player.velocity)))) 
			$HBoxContainer2/VBoxContainer4/VelocityValue.text = \
			"x: {x}, y: {y}, z: {z} ".format(
				{	"x": "%0.2f" % player.velocity.x ,
					"y": "%0.2f" % player.velocity.y, 
					"z": "%0.2f" % player.velocity.z})
			
		)

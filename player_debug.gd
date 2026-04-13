extends DebugUI
class_name PlayerDebug

var player : PlayerController

func _ready() -> void:
    self.player = get_tree().get_nodes_in_group("PlayerController")[0]
    
    if player is PlayerController:
        player.rotation_statemachine.stateChange.connect(func (prev, curr) :
            $HBoxContainer2/VBoxContainer/PrevStateValue.set_text(player.rotation_statemachine.get_state_identifier(prev))
            $HBoxContainer2/VBoxContainer2/CurrentStateValue.set_text(player.rotation_statemachine.get_state_identifier(curr))
            )
        
        player.movement_statemachine.stateChange.connect(func(_prev, _curr) :
            
            $HBoxContainer2/VBoxContainer7/MovementStateValue.set_text(player.movement_statemachine.get_state_identifier(_curr))
        )
    else:
        print_debug("Trying to connect the GUI Player pannel to a non-Player node.")

func _process(_delta: float) -> void:
    if player and player is PlayerController:
        $HBoxContainer2/VBoxContainer5/SpeedValue.set_text("%0.2f; %0.2f" % [player.speed, player.acceleration])
        $HBoxContainer2/VBoxContainer4/VelocityValue.text = \
                "(x: {x}, y: {y}, z: {z}) ".format(
                    {	"x": "%0.2f" % player.velocity.x ,
                        "y": "%0.2f" % player.velocity.y, 
                        "z": "%0.2f" % player.velocity.z})

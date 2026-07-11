extends MissionItem
class_name  CollectableItem

@export var item : Item
@export var throw_intensity : float = 50
@onready var physical_item : RigidBody3D = get_parent() 

var is_carried = false;
var has_been_carried = false;

func on_progress(player : PlayerController):
    if player.can_carry() and not self.is_carried:
        self.interactible.send_delete_on_play_interaction(Interaction.KEYS.E, "Carry",  get_carried.bind(player)) 
        
    else :
        add_content("Issue", "We can't carry ts")
        show_content()
    
func on_detected(player):
    if player.can_carry() and not self.is_carried:
        self.interactible.send_delete_on_play_interaction(Interaction.KEYS.E, "Carry",  get_carried.bind(player))
    else:
        self.disable_detection()

func mission_done():
    self.queue_free()

func get_carried(player: PlayerController):
    self.disable_detection()
    self.is_carried = true
    physical_item.linear_velocity = Vector3.ZERO
    physical_item.set_collision_layer_value(2, true)
    physical_item.set_collision_mask_value(2, true)
    physical_item.set_collision_layer_value(1, false)
    physical_item.set_collision_mask_value(1, false)

    
    self.has_been_carried = (not has_been_carried and self.is_carried and mission.statemachine.get_state() == Mission.MissionState.ACCEPTED_ONGOING)    
    player.carry(get_parent())
    if self.has_been_carried :
        taskDone.emit()

    self.interactible.send_delete_on_play_interaction(Interaction.KEYS.A, "Throw", throw.bind(player))


func throw(player):
    self.enable_detection()
    physical_item.set_collision_layer_value(2, false)
    physical_item.set_collision_mask_value(2, false)
    physical_item.set_collision_layer_value(1, true)
    physical_item.set_collision_mask_value(1, true)
    self.is_carried = false
    player.uncarry()
    physical_item.apply_impulse(throw_intensity*player.transform.basis.x)
        

func get_item_id():
    return self.item.item_id

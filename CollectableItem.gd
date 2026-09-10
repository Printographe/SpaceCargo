extends Detectable
class_name  CollectableItem

@export var item : Item

@onready var physical_item : RigidBody3D = get_parent() 


var is_carried = false;
var has_been_carried = false;

            
func on_detected(player):
    if player.can_carry() and not self.is_carried:
        self.interactible.send_delete_on_play_interaction(Interaction.KEYS.E, "Carry",  get_carried.bind(player))
    else:
        self.disable_detection()


func get_carried(player: PlayerController):
    self.disable_detection()
    self.is_carried = true
    self.has_been_carried=true
    physical_item.linear_velocity = Vector3.ZERO
    physical_item.set_collision_layer_value(2, true)
    physical_item.set_collision_mask_value(2, true)
    physical_item.set_collision_layer_value(1, false)
    physical_item.set_collision_mask_value(1, false)
    player.carry(physical_item)
    self.interactible.send_delete_on_play_interaction(Interaction.KEYS.A, "Throw", throw.bind(player))


func throw(player):
    self.enable_detection()
    physical_item.set_collision_layer_value(2, false)
    physical_item.set_collision_mask_value(2, false)
    physical_item.set_collision_layer_value(1, true)
    physical_item.set_collision_mask_value(1, true)
    self.is_carried = false
    player.uncarry()
    physical_item.apply_impulse(item.throw_intensity*player.transform.basis.x)
    self.interactible.lose_interaction()
        

func get_item_id():
    return self.item.item_id


func mission_done():
    self.queue_free()
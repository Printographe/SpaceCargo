extends MissionItem
class_name  CollectableItem

#Offset from the origin, depends on the models size
@export var offset_xy : Vector2 = Vector2.ZERO
@export var item : Item

var is_carried = false;
var has_been_carried = false;

func on_progress(player : PlayerController):
    if player.can_carry():
        self.get_carried(player)
        taskDone.emit()
    else :
        add_content("Issue", "We can't carry ts")
        show_content()
    
func on_detected(player):
    print('Detected !!')
    if player.can_carry():
        send_interaction(Interaction.KEYS.E, "Carry",  get_carried.bind(player)) 
    else :
        send_interaction(Interaction.KEYS.E, "Carry", func() : 
            add_content("", "Ayo, I can't carry this shit")
            show_content()
            )

func mission_done():
    self.queue_free()

func get_carried(player: PlayerController):
    self.has_been_carried = self.has_been_carried or (self.is_carried and mission.statemachine.get_state() == Mission.MissionState.ACCEPTED_ONGOING)
    self.is_carried = true
    player.carry(self)
    if not self.has_been_carried :
        taskDone.emit()
    self.send_delete_on_play_interaction(Interaction.KEYS.A, "Drop", func():
        player.uncarry()
        self.is_carried = false
    )

func get_item_id():
    return self.item.item_id

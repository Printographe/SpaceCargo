extends MissionItem
class_name  CollectableItem

#Offset from the origin, depends on the models size
@export var offset_xy : Vector2 = Vector2.ZERO
@export var item : Item


func on_progress(player : PlayerController):
    if player.can_carry():
        self.get_carried(player)
        taskDone.emit()
    else :
        show_content("Issue", "We can't carry ts")
    
func on_detected(player):
    print('Detected !!')
    if player.can_carry():
        sendInteraction.emit(Interaction.new(Interaction.KEYS.E, "Carry", self,  get_carried.bind(player)) )
    else :
        sendInteraction.emit(Interaction.new(Interaction.KEYS.E, "Carry", self, show_content.bind("object", "can't carry it you dumbass")))

func on_pending(_player): 
    print("Pretty pending !")

func mission_done():
    self.queue_free()

func get_carried(player: PlayerController):
    player.carry(self)

func get_item_id():
    return self.item.item_id

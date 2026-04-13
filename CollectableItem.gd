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
        add_content("Issue", "We can't carry ts")
        show_content()
    
func on_detected(player):
    print('Detected !!')
    if player.can_carry():
        sendInteraction.emit(Interaction.new(Interaction.KEYS.E, "Carry", self,  get_carried.bind(player)) )
    else :
        sendInteraction.emit(Interaction.new(Interaction.KEYS.E, "Carry", self, func() : 
            add_content("", "Ayo, I can't carry this shit")
            show_content()
            ))


func mission_done():
    self.queue_free()

func get_carried(player: PlayerController):
    player.carry(self)
    taskDone.emit()
    sendInteraction.emit(Interaction.new(Interaction.KEYS.A, "Throw", player, player.uncarry))
    print("I was in fact, carried")

func get_item_id():
    return self.item.item_id

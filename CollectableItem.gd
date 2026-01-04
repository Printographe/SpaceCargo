extends MissionItem
class_name  CollectableItem

var collected : bool = false

#Offset from the origin, depends on the models size
@export var offset_xy : Vector2 = Vector2.ZERO
@export var item_id : int = 0


func _ready() -> void:
	super._ready()
	
	if self.get_child_count() > 2:
		$MeshInstance3D.queue_free()
	

func on_progress(player):
	player.carry.remote_path = self.get_path()
	player.set_carrying_id(self.item_id)
	player.carrying = true
	collected = true
	taskDone.emit()
	

func on_pending(_player): 
	print("Pretty pending !")

func mission_done():
	self.queue_free()

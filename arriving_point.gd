
#Script that allows for customization of the receiving agent
extends MissionItem
class_name ArrivingPoint


@export var actor: PackedScene
@export var trigger_text : String = "Hold on"
@export var item_id : int


func _ready() -> void:
	super._ready()
	if actor and actor.can_instantiate():
		var actor_instance = actor.instantiate()
		self.add_child(actor_instance)
		$MeshInstance3D.queue_free()
	else :
		assert(error_string(ERR_UNCONFIGURED))


func on_progress(body):
	if body.carrying and body.get_carrying_id() == item_id:
		print(trigger_text)
		taskDone.emit()

func on_pending(player):
	print("hello")
	show_content("Chekov", "Hello I need my gun. Hello.", true)

func on_success(player):
	self.queue_free()

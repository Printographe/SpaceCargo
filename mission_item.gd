extends Area3D
class_name MissionItem


signal taskDone
signal showContent

var mission : Mission
var detected = false

@export var progress: int
@export var child_mesh_path : NodePath




@onready var highlight_shader = preload("res://simple contour shader.tres") 

@onready var StateFunction = {
	Mission.MissionState.PENDING : on_pending,
	Mission.MissionState.REFUSED : on_refusal,
	Mission.MissionState.FINISHED_SUCCESS : on_success,
	Mission.MissionState.ACCEPTED_ONGOING : on_progress,
	Mission.MissionState.FINISHED_FAILURE : on_failure
}


signal player_entered(body : PlayerController)

func on_success(player):
	print("Why doesn't it work ?")

func on_failure(player):
	pass
	

func on_progress(player):
	pass

func on_refusal(player):
	pass
	
func on_pending(player):
	print("body entered from mission itemds")

func mission_done():
	pass

func show_content(title, content, show_mission = false):
	self.showContent.emit(title, content, show_mission, self.mission)


func _player_entered_check(body):
	if body is PlayerController:
		player_entered.emit(body)

func _ready():
	self.body_entered.connect(_player_entered_check)
	
	mission = get_parent()
	if mission is Mission:
		#allowed, because it synchronises 
		player_entered.connect(StateFunction[mission.statemachine.get_state()])
		mission.statemachine.stateChange.connect(func (prev, current): 

			_on_mission_state_change(prev, current)
		)
	else :
		push_error(false, "MissionItem instance not child of Mission")
	
	self.add_to_group("mission_items")

	for player : PlayerController in get_tree().get_nodes_in_group("PlayerController"):
		player.mission_item_detected.connect(on_detected)
		player.mission_item_undetected.connect(on_undetect)


	


func _on_mission_state_change(prev, current):
	#These are sequential and work only on body entered
	if not prev == null:
		self.player_entered.disconnect(StateFunction[prev])
	self.player_entered.connect(StateFunction[current])
	
	#These work instantly
	if current == Mission.MissionState.FINISHED_SUCCESS:
		mission_done()

func on_detected(body):
	set_detect(body, true)

func on_undetect(body):
	set_detect(body, false)


func set_detect(body, enabled):
	if self != body: return
	var val = {true : highlight_shader, false : null}[enabled]
	var child_mesh = get_node_or_null(child_mesh_path)
	if !child_mesh:
		push_error("Child mesh not specified")
		return
	else:
		if not child_mesh is MeshInstance3D:
			for child in child_mesh.get_children():
				set_overlay(child, val)
		else : 
			set_overlay(child_mesh, val)

func set_overlay(object, val):
	if object is MeshInstance3D:
		object.set_material_overlay(val)

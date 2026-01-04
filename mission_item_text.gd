extends Control

signal showMission

func _ready() -> void:
	for mission_item : MissionItem in get_tree().get_nodes_in_group("mission_items"):
		mission_item.showContent.connect(show_content)
		
	$Panel/Button.pressed.connect(self.hide)

func show_content(title, content, show_mission, mission : Mission):
	self.show()
	$Panel/Title.text = title if title else ""
	$Panel/Content.text = content
	if show_mission:
		$Panel/Button.pressed.connect(func() : 
			self.showMission.emit(mission),CONNECT_ONE_SHOT)
		

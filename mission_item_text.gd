extends Control

signal showMission


@onready var title_label =  $VBoxContainer/MarginContainer3/Title
@onready var content_label = $VBoxContainer/MarginContainer2/Content
@onready var button = $VBoxContainer/MarginContainer/Button

func _ready() -> void:
    for mission_item : MissionItem in get_tree().get_nodes_in_group("mission_items"):
        mission_item.showContent.connect(show_content)
        
    button.pressed.connect(self.hide)

func show_content(title, content, show_mission, mission : Mission):
    self.show()
    title_label.set_text(title if title else "")
    content_label.set_text(content)
    if show_mission:
        button.pressed.connect(func() : 
            self.showMission.emit(mission),CONNECT_ONE_SHOT)
        

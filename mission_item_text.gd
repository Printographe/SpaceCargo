extends Control

signal showMission
signal showMissionThenComeBack


class Content:
    var title : String
    var text : String 
    #TODO implement and add a Builder
    #var options : Array[Content]

    func _init(title : String, text : String) -> void:
        self.title = title
        self.text = text
       # self.options = options

var queue : Array = []

@onready var title_label =  $VBoxContainer/MarginContainer3/Title
@onready var content_label = $VBoxContainer/MarginContainer2/Content
@onready var button = $VBoxContainer/MarginContainer/Button


func _ready() -> void:
    for mission_item : MissionItem in get_tree().get_nodes_in_group("mission_items"):
        mission_item.showContent.connect(show_content)
        mission_item.addContent.connect(add_content)
        
    button.pressed.connect(show_content)



func add_content(title : String, text : String, show_mission : bool, mission : Mission):
    self.queue.append(Content.new(title, text))
    if show_mission:
        queue.append(mission)


func show_content():
    print("called nth time")
    if !self.visible : self.show()
    var content = self.queue.pop_front()
    if content == null :
        self.hide();
        return
    elif content is Content:
        title_label.set_text(content.title if content.title else "")
        content_label.set_text(content.text)
    elif content is Mission:
        self.hide()
        self.showMission.emit(content)
        

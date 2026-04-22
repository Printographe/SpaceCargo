extends Control

class Content:
    var title : String
    var text : String 
    #TODO implement and add a Builder
    #var options : Array[Content]

    func _init(ti : String, txt : String) -> void:
        self.title = ti
        self.text = txt
       # self.options = options

signal resumeGame


@onready var interaction_system = get_tree().get_first_node_in_group("interaction_system")

@onready var content_display : ContentDisplay =  $MissionItemText
@onready var mission_panel = $mission_panel

var queue : Array = []




func _ready() -> void:

    for mission_item : MissionItem in get_tree().get_nodes_in_group("mission_items"):
        mission_item.showContent.connect(show_content)
        mission_item.addContent.connect(add_content)

    self.resumeGame.connect(interaction_system.resume_input_listner)
    content_display.nextItem.connect(show_content)
    mission_panel.nextItem.connect(show_content)


func add_content(title : String, text : String, show_mission : bool, mission : Mission):
    self.queue.append(Content.new(title, text))
    if show_mission:
        queue.append(mission)


func show_content(mission_answer = null):
    
    var content = self.queue.pop_front()
    if content == null :
        resumeGame.emit()

    elif content is Content:
        content_display.display(content)
        self.grab_click_focus()
    elif content is Mission:
        mission_panel.set_contract_info(content)
    
    






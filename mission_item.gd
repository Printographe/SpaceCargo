extends Interactible
class_name MissionItem


signal taskDone
signal showContent
signal addContent

@onready var mission : Mission = get_parent() 
var detected = false

@export var progress: int


@onready var state_function = {
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

func get_mission_progress():
    return get_parent().statemachine.get_state()



func add_content(title : String, content : String, show_mission = false):
    self.addContent.emit(title, content, show_mission, mission)

func show_content():
    self.showContent.emit()

func _player_entered_check(body):
    if body is PlayerController:
        player_entered.emit(body)

func _ready():
    super._ready()
    self.body_entered.connect(_player_entered_check)
    
    if mission is Mission:
        #allowed, because it synchronises 
        player_entered.connect(state_function[mission.statemachine.get_state()])
        mission.statemachine.stateChange.connect(func (prev, current): 

            _on_mission_state_change(prev, current)
        )
    else :
        push_error(false, "MissionItem instance not child of Mission")
    
    self.add_to_group("mission_items")

   

    


func _on_mission_state_change(prev, current):
    #These are sequential and work only on body entered
    if not prev == null:
        self.player_entered.disconnect(state_function[prev])
    self.player_entered.connect(state_function[current])
    
    #These work instantly
    if current == Mission.MissionState.FINISHED_SUCCESS:
        mission_done()

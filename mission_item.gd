extends Detectable
class_name MissionItem


signal taskDone
signal showContent
signal addContent
signal addCallback



var done : bool = false


enum TASK_PROCESSING_MODE {SEQUENTIAL, CONCURRENT};

@export var task_processing_mode := TASK_PROCESSING_MODE.SEQUENTIAL

@onready var mission : Mission 
var detected = false


@export var progress_level = 0

@export var pre_requisite : int:
    set(value):
        if value > progress_level:
            push_error("cannot pre requisite a higher value than the current progress")
            return null
        return value

@onready var state_function = {
    Mission.MissionState.PENDING : on_pending,
    Mission.MissionState.REFUSED : on_refusal,
    Mission.MissionState.FINISHED_SUCCESS : on_success,
    Mission.MissionState.ACCEPTED_ONGOING : on_progress,
    Mission.MissionState.FINISHED_FAILURE : on_failure
}


func set_up_task_processing_mode():
    match self.task_processing_mode : 
        TASK_PROCESSING_MODE.SEQUENTIAL: 
            self.pre_requisite = self.progress_level - 1
        TASK_PROCESSING_MODE.CONCURRENT:
            print("Task #", self.progress_level, "is concurrent to tasks : ", Array(range(self.pre_requisite, self.progress)) )


func _ready() -> void:
    super._ready()
    set_up_task_processing_mode()



signal player_entered(body : PlayerController)

func on_success(player):
    pass

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


func add_callback(callback : Callable):
    self.addCallback.emit(callback)


func task_done():
    # idempotence 
    if not done and mission.progress > self.pre_requisite:
            taskDone.emit()
            done = true
    else: 
        push_warning("Task done on already done task. ")


func show_content():
    self.showContent.emit()
    self.interactible.pauseInputProcessing.emit()

func _player_entered_check(body):
    if body is PlayerController:
        player_entered.emit(body)

func connect_to_mission(ex_mission):
    self.mission = ex_mission
    self.body_entered.connect(_player_entered_check)
    
    if mission is Mission:
        #allowed, because it synchronises 
        player_entered.connect(state_function[mission.statemachine.get_state()])
        mission.statemachine.stateChange.connect(func (prev, current): 

            _on_mission_state_change(prev, current)
        )
    self.add_to_group("mission_items")

   

    


func _on_mission_state_change(prev, current):
    #These are sequential and work only on body entered
    if not prev == null:
        self.player_entered.disconnect(state_function[prev])
    self.player_entered.connect(state_function[current])
    
    # this works instantly
    if current == Mission.MissionState.FINISHED_SUCCESS:
        mission_done()

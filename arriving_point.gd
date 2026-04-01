
#Script that allows for customization of the receiving agent
extends MissionItem
class_name ArrivingPoint


@export var trigger_text : String = "Hold on"
@export var item_id : int

var interaction_count = 0

var sentences = ["Ju-ju-jujujujujuuuuuuul", "bientôt je me casse d'ici tu verras...", "Mon gun c'est pour quand ?"]

func _ready() -> void:
    super._ready()


func on_progress(body : PlayerController):
    if body.carry_statemachine.get_state() == PlayerController.STATES.CARRYING \
    and  body.get_carrying_id() == item_id:
        print(trigger_text)
        show_content("Chekov", "Cimer mon reuf")
        taskDone.emit()
    else: 
        show_content("Chekov", sentences[interaction_count % len(sentences)])
        interaction_count += 1

func on_pending(player):
    show_content("Chekov", "Hello I need my gun. Hello.", true)
    

func on_detected(player):
    if get_mission_progress() == Mission.MissionState.PENDING:
        show_content("Chekov","Come nearer")
        

func on_success(player):
    show_content("Chekov", "Tié le tigre des montagnes")
    self.queue_free()

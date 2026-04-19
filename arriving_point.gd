
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
        add_content("Chekov", "Cimer mon reuf")
        show_content()
        taskDone.emit()
    else: 
        add_content("Chekov", sentences[interaction_count % len(sentences)])
        interaction_count += 1

func on_pending(player):
    add_content("Chekov", "Hello I need my gun. Hello.", true)
    show_content()
    

func on_detected(player):
    if get_mission_progress() == Mission.MissionState.PENDING:
        var special_interaction  = Interaction.new(Interaction.KEYS.A, "interact", self, ice_breaker, 2)
        _send_interaction_with_raw(special_interaction)
        

func on_success(player):
    add_content("Chekov", "Tié le tigre des montagnes")
    self.queue_free()

func ice_breaker():
    add_content("Chekov", "You'll never guess what will come next")
    add_content("Kendrick", "I hate when a rapper talk about guns, then somebody die \n They turn into nuns, then hop online, like \"Pray for my city\" \nHe fakin' for likes and digital hugs", true)
    show_content()

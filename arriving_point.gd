
#Script that allows for customization of the receiving agent
extends MissionItem
class_name ArrivingPoint


@export var trigger_text : String = "Hold on"
@export var item_id : int

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var focus_camera : Camera3D = $FocusCamera
@onready var end_position : Node3D = $EndPosition

@export var item : NodePath;

var interaction_count = 0

var sentences = ["Comment je respire dans l'espace ? Je fais de la photosynthèse", "Bon, tu te dépêche ?", "Mon livreur, Déli Vérrou, est à 500années lumières.."]

func _ready() -> void:
    super._ready()
    self.area_entered.connect(get_ball)
    self.animation_player.play("floating_spaceship")


func on_progress(body : PlayerController):
    if not body.can_carry() and body.get_carrying_id() == item_id:
        add_content("Chekov", "Trop ")
        show_content()
        taskDone.emit()
    else: 
        add_content("Chekov", sentences[interaction_count])
        show_content()
        interaction_count = (interaction_count +1) % len(sentences)

func on_pending(player_body : PlayerController):
    focus_camera.set_current(true)
    player_body.lose_focus()
    player_body.set_position(end_position.get_global_position())
    player_body.set_rotation(end_position.get_global_rotation())

    add_content("Chekov", "Je suis tombé en panne... Mon moteur ne marche plus.")
    add_content("Chekov", "Mais j'ai crû voir un moteur qlqpart dans ce vide. \n A pied c'est trop épuisant..")
    add_content("Chekov", "Peux-tu te déplacer pour aller chercher le moteur ? \n Je te donne 5 balles comme remerciement.", true)
    add_callback(func () :
        focus_camera.set_current(false)
        player_body.regain_focus()
    )
    show_content()
    

func on_detected(player):
    if get_mission_progress() == Mission.MissionState.PENDING:
        var special_interaction  = Interaction.new(Interaction.KEYS.A, "interact", self, ice_breaker, 2)
        self.interactible._send_interaction_with_raw(special_interaction)


func on_success(player_body):
    focus_camera.set_current(true)
    player_body.lose_focus()
    animation_player.animation_finished.connect(func (animation_name) :
        if not animation_name == "leaving" : return
        add_content("Chekov", "Tié le tigre des montagnes")
        add_callback(player_body.regain_focus)
        show_content()
        self.queue_free()
        
    )
    animation_player.play("leaving")

    
    

func ice_breaker():
    add_content("Chekov", "Eh toi, viens, j'ai quelque chose à te dire..")
    show_content()

func get_ball(body):
    if  body is CollectableItem and self.mission.get_state() == Mission.MissionState.ACCEPTED_ONGOING and body.get_item_id() == self.item_id:
        taskDone.emit()
        body.get_parent().queue_free()
            

extends Control

@onready var mission_show = preload("res://mission_show.tscn")
@onready var mission_button_prefab = preload("res://MissionButton.tscn")


@onready var mission_panel = $MissionContentSystem/mission_panel
@onready var mission_button = $Dashboard_panel/mission_button
@onready var mission_item_text = $MissionContentSystem/MissionItemText
@onready var mission_buttons_container = $Dashboard_panel/mission_container;
@onready var mission_view_container = $MissionViewContainer;


var free_mission_show = []

var show_mission_container = false

var available_mission_button : Dictionary[Mission, Button] = {}

var interactible_instance : Interactible

@export var debug_hidden = false



func handle_mission_states(mission, _last, current):
    if current == Mission.MissionState.FINISHED_SUCCESS:
        $MissionSuccessMessage.show()				
        $time.set_wait_time(2)
        $time.start()
        $time.timeout.connect(func () : 
            $MissionSuccessMessage.hide(), CONNECT_ONE_SHOT)
        print("Mission rcv from Dashboard")
        if available_mission_button.has(mission):
            available_mission_button[mission].queue_free()
            available_mission_button.erase(mission)



    elif current == Mission.MissionState.REFUSED :
        if available_mission_button.has(mission):
            available_mission_button[mission].queue_free()
            available_mission_button.erase(mission)
            
            
    elif current == Mission.MissionState.ACCEPTED_ONGOING:
        self.free_mission_show.pop_back().connect_to_mission(mission)

        

func connect_mission() :
    var missions = get_tree().get_nodes_in_group("missions")
    for mission: Mission in missions:
        mission.statemachine.stateChange.connect(func(prev, curr) : handle_mission_states(mission, prev, curr))

func setup_player_debug():
    $ShowDebug.pressed.connect(func ():
        for node in get_tree().get_nodes_in_group("Debug"):
            node.visible = debug_hidden
            debug_hidden = !debug_hidden)
    

func _ready():
    mission_button.connect("pressed", on_mission_button_pressed)
    setup_player_debug()
    connect_mission()

    for n in range(3):
        var mshow = mission_show.instantiate()
        mshow.hide()
        mshow.freeMS.connect(func(ui) : 
            self.free_mission_show.append(ui)
            ui.hide() )
        self.free_mission_show.append(mshow)
        mission_view_container.add_child(mshow)



func on_mission_button_pressed():
    self.show_mission_container = !self.show_mission_container
    mission_buttons_container.visible = self.show_mission_container
    update_mission_container()
    
func update_mission_container():
    var missions = get_tree().get_nodes_in_group("missions") 
    
    var pending_missions = []
    for mission : Mission in missions:
        if mission.statemachine.get_state() == Mission.MissionState.PENDING:
            pending_missions.append(mission)
    #for mission in missions:
        #print("mission {id} : {state}"\
            #.format({"id" : mission.id, "state" :  mission.statemachine.get_state_identifier(mission.statemachine.current_state) }))
    print("Pending Missions :", pending_missions)
    for mission in pending_missions: 
        if available_mission_button.has(mission) : continue
        else:
            var new_mission_button = mission_button_prefab.instantiate()
            new_mission_button.set_name("Mission " + str(mission.id))
            new_mission_button.set_text(mission.contractor)
            new_mission_button.pressed.connect(func () : mission_panel.set_contract_info(mission) )
            
            available_mission_button[mission] = new_mission_button
            
            mission_buttons_container.add_child(new_mission_button)

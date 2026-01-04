class_name PlayerController

extends CharacterBody3D


## Object carrying logic : 
@onready var carry = $"Space Cargo/Carry";
var carrying : bool = false
var _carrying_id


enum ROT_STATES {
	MOVING_RIGHT,
	MOVING_LEFT,
	MOVING_UP,
	MOVING_DOWN,
	MOVING_DIAG_UP_RIGHT,
	MOVING_DIAG_UP_LEFT,
	MOVING_DIAG_DOWN_RIGHT,
	MOVING_DIAG_DOWN_LEFT,
	SLOWING_DOWN,
	IDLE,
	BASE,
	NULL,
}

#utility function
static func sorted(list : Array) -> Array:
	list.sort()
	return list


var accelerating = false;

var rotation_statemachine : StateMachine
var position_statemachine : StateMachine
var carry_statemachine : StateMachine


var input_map : Dictionary[String, bool] = {
	"action_up" : false,
	"action_right" : false,
	"action_left" : false,
	"action_down" : false,
}


var banned_inputs_states = \
[sorted(["action_right", "action_left"]), sorted(["action_up", "action_down"])]


var input_to_state = {
	"action_left" : ROT_STATES.MOVING_LEFT,
	"action_right": ROT_STATES.MOVING_RIGHT,
	"action_up": ROT_STATES.MOVING_UP,
	"action_down": ROT_STATES.MOVING_DOWN,
	
	#
	sorted(["action_left","action_up"]) : ROT_STATES.MOVING_DIAG_UP_LEFT,
	sorted(["action_left", "action_down"]) : ROT_STATES.MOVING_DIAG_DOWN_LEFT,
	sorted(["action_right", "action_up"]) : ROT_STATES.MOVING_DIAG_UP_RIGHT,
	sorted(["action_right", "action_down"]) : ROT_STATES.MOVING_DIAG_DOWN_RIGHT
}

var state_to_animation = {
	ROT_STATES.MOVING_RIGHT : "right",
	ROT_STATES.MOVING_LEFT : "left",
	ROT_STATES.MOVING_DOWN : "down",
	ROT_STATES.MOVING_UP : "up",
	ROT_STATES.MOVING_DIAG_UP_RIGHT: "diag_up_right",
	ROT_STATES.MOVING_DIAG_UP_LEFT : "diag_up_left",
	ROT_STATES.MOVING_DIAG_DOWN_RIGHT : "diag_down_right",
	ROT_STATES.MOVING_DIAG_DOWN_LEFT : "diag_down_left",
}

var state_to_rotation = {
	ROT_STATES.MOVING_RIGHT : custom_rotate.bind(0, -1),
	ROT_STATES.MOVING_LEFT : custom_rotate.bind(0, 1),
	ROT_STATES.MOVING_UP : custom_rotate.bind(-1, 0),
	ROT_STATES.MOVING_DOWN : custom_rotate.bind(1, 0),
	#Diag
	ROT_STATES.MOVING_DIAG_UP_RIGHT : custom_rotate.bind(-1, -1),
	ROT_STATES.MOVING_DIAG_UP_LEFT : custom_rotate.bind(-1, 1),
	ROT_STATES.MOVING_DIAG_DOWN_RIGHT: custom_rotate.bind(1, -1),
	ROT_STATES.MOVING_DIAG_DOWN_LEFT :  custom_rotate.bind(1, 1),
}

func custom_rotate(up, right):
	self.basis = self.basis * Basis(Vector3.FORWARD, up*angle).orthonormalized()
	#self.basis = Basis.IDENTITY.rotated(Vector3(0, 1, 0), pos*angle).orthonormalized()
	self.basis = self.basis * Basis(Vector3.UP, right*angle).orthonormalized()
	

var speed = 0;

@export var MAX_SPEED = 200;
@export var angle = TAU/100 ;
@export var MAX_ANGLE = TAU/12;

@export_category("The physics of it")
@export var acceleration : float = 50
@export var decel_rate : float = 1.01
@export var decel_coef : float = 1

@export var fuel_per_acceleration = 10

func _ready() -> void:

	self.rotation_statemachine = StateMachine.new(
		ROT_STATES.IDLE, 
		[
		ROT_STATES.MOVING_RIGHT,
		ROT_STATES.MOVING_LEFT,
		ROT_STATES.MOVING_UP,
		ROT_STATES.MOVING_DOWN,
		ROT_STATES.IDLE,
		ROT_STATES.MOVING_DIAG_UP_RIGHT,
		ROT_STATES.MOVING_DIAG_UP_LEFT,
		ROT_STATES.MOVING_DIAG_DOWN_RIGHT,
		ROT_STATES.MOVING_DIAG_DOWN_LEFT,
		],
		{
			ROT_STATES.MOVING_RIGHT : "rot right",
			ROT_STATES.MOVING_LEFT : "rot left",
			ROT_STATES.MOVING_UP : "rot up",
			ROT_STATES.MOVING_DOWN : "rot down",
			ROT_STATES.IDLE : "idle",
			ROT_STATES.MOVING_DIAG_UP_RIGHT: "diag up right",
			ROT_STATES.MOVING_DIAG_UP_LEFT : "diag up left",
			ROT_STATES.MOVING_DIAG_DOWN_RIGHT : "diag down right",
			ROT_STATES.MOVING_DIAG_DOWN_LEFT : "diag down left",
			
		})\
		.ignore_self_transitions() \
		.add_st_transition(ROT_STATES.MOVING_RIGHT, play_rot) \
		.add_st_transition(ROT_STATES.MOVING_LEFT, play_rot) \
		.add_st_transition(ROT_STATES.MOVING_UP, play_rot) \
		.add_st_transition(ROT_STATES.MOVING_DOWN, play_rot)\
		.add_st_transition_arr([ROT_STATES.MOVING_DIAG_UP_RIGHT,
		ROT_STATES.MOVING_DIAG_UP_LEFT,
		ROT_STATES.MOVING_DIAG_DOWN_RIGHT,
		ROT_STATES.MOVING_DIAG_DOWN_LEFT,], play_rot)\
		.add_st_transition(ROT_STATES.IDLE,
			func (last, _current) : 
				if state_to_animation.has(last):
					#print("playing backwards : ")
					$AnimationPlayer.play_backwards(state_to_animation[last])\
			)\
		.set_st_process_function(update_rotation)
	
	for node in get_tree().get_nodes_in_group("Debug"):
		if node is PlayerDebug:
			node.connect_to_node(self)

func play_rot(last, current):
	$AnimationPlayer.play(state_to_animation[current])

func set_carrying_id(id):
	self._carrying_id = id
func get_carrying_id():
	return self._carrying_id 


func _physics_process(delta: float) -> void:
	if self.rotation_statemachine:
		self.rotation_statemachine.use_process(delta)
	move()
	if carrying:
		#carry.update_position()
		pass


func update_rotation(_delta):
	
	for inp in input_map.keys():
		input_map[inp] = Input.is_action_pressed(inp)
	#I wrote cum it's funny haha xD*
	var inp = input_map.keys().filter(func (x) : return input_map[x] == true)
	
	var input_count = input_map.values().reduce(func (cum, x) : return int(x) + int(cum))
	if input_count == 1: 
		inp = inp[0]
		self.rotation_statemachine.switch_to(input_to_state[inp])
		self.state_to_rotation[self.rotation_statemachine.get_state()].call()
	#For diagonal input
	elif input_count == 2:
		inp.sort()
		if not inp in banned_inputs_states:
			self.rotation_statemachine.switch_to(input_to_state[inp])
			self.state_to_rotation[self.rotation_statemachine.get_state()].call()
	
	#looking for releases
	for k in input_map.keys():
		input_map[k] = Input.is_action_just_released(k)
		
		
	var any_button_released = input_map.values() \
		.any(func (x) : return x == true)
		
	if any_button_released:
		self.rotation_statemachine.switch_to(ROT_STATES.IDLE)



func move() -> void:
	self.velocity = Vector3.ZERO
	if speed < 1:
		speed = 0;
	else:
		self.speed = speed* pow(decel_rate,decel_coef);
		
	accelerating = false;
	
	self.velocity += self.basis.x * speed
	#self.rot_axis = Vector3(1, 0, 0)

	
	if Input.is_action_just_pressed("ui_accept"):
		accelerating = self.speed < self.MAX_SPEED;
		if accelerating:
			self.speed += self.acceleration
			$AnimationPlayer.play("Speeding")
		else:
			self.speed = MAX_SPEED
	
	move_and_slide()

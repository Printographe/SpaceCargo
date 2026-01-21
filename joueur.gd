class_name PlayerController

extends CharacterBody3D


## Object carrying logic : 
@onready var carry = $"Space Cargo/Carry";
var carrying : bool = false
var _carrying_id


enum STATES {
	MOVING_RIGHT,
	MOVING_LEFT,
	MOVING_UP,
	MOVING_DOWN,
	MOVING_DIAG_UP_RIGHT,
	MOVING_DIAG_UP_LEFT,
	MOVING_DIAG_DOWN_RIGHT,
	MOVING_DIAG_DOWN_LEFT,
	ACCELERATING,
	DECELERATING,
	HYPERSPEED,
	IDLE,
	BASE,
	NULL,
}

#utility function
static func sorted(list : Array) -> Array:
	list.sort()
	return list



var rotation_statemachine : StateMachine
var movement_statemachine : StateMachine
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
	"action_left" : STATES.MOVING_LEFT,
	"action_right": STATES.MOVING_RIGHT,
	"action_up": STATES.MOVING_UP,
	"action_down": STATES.MOVING_DOWN,
	
	#crazy trick
	sorted(["action_left","action_up"]) : STATES.MOVING_DIAG_UP_LEFT,
	sorted(["action_left", "action_down"]) : STATES.MOVING_DIAG_DOWN_LEFT,
	sorted(["action_right", "action_up"]) : STATES.MOVING_DIAG_UP_RIGHT,
	sorted(["action_right", "action_down"]) : STATES.MOVING_DIAG_DOWN_RIGHT
}

var state_to_animation = {
	STATES.MOVING_RIGHT : "right",
	STATES.MOVING_LEFT : "left",
	STATES.MOVING_DOWN : "down",
	STATES.MOVING_UP : "up",
	STATES.MOVING_DIAG_UP_RIGHT: "diag_up_right",
	STATES.MOVING_DIAG_UP_LEFT : "diag_up_left",
	STATES.MOVING_DIAG_DOWN_RIGHT : "diag_down_right",
	STATES.MOVING_DIAG_DOWN_LEFT : "diag_down_left",
}

var state_to_rotation = {
	STATES.MOVING_RIGHT : custom_rotate.bind(0, -1),
	STATES.MOVING_LEFT : custom_rotate.bind(0, 1),
	STATES.MOVING_UP : custom_rotate.bind(-1, 0),
	STATES.MOVING_DOWN : custom_rotate.bind(1, 0),
	#Diag
	STATES.MOVING_DIAG_UP_RIGHT : custom_rotate.bind(-1, -1),
	STATES.MOVING_DIAG_UP_LEFT : custom_rotate.bind(-1, 1),
	STATES.MOVING_DIAG_DOWN_RIGHT: custom_rotate.bind(1, -1),
	STATES.MOVING_DIAG_DOWN_LEFT :  custom_rotate.bind(1, 1),
}

func custom_rotate(up, right):
	self.basis = self.basis * Basis(Vector3.FORWARD, up*angle).orthonormalized()
	#self.basis = Basis.IDENTITY.rotated(Vector3(0, 1, 0), pos*angle).orthonormalized()
	self.basis = self.basis * Basis(Vector3.UP, right*angle).orthonormalized()
	

var speed = 0;

@export var BASE_SPEED = 2;
@export var MAX_SPEED = 200;
@export var angle = TAU/100 ;
@export var MAX_ANGLE = TAU/12;

@export_category("The physics of it")
@export var acceleration : float = 50
@export var decel_rate : float = 0.5

@export var fuel_per_acceleration = 10


func setup_rotation_statemachine():
	self.rotation_statemachine = StateMachine.new(
		STATES.IDLE, 
		[
		STATES.MOVING_RIGHT,
		STATES.MOVING_LEFT,
		STATES.MOVING_UP,
		STATES.MOVING_DOWN,
		STATES.IDLE,
		STATES.MOVING_DIAG_UP_RIGHT,
		STATES.MOVING_DIAG_UP_LEFT,
		STATES.MOVING_DIAG_DOWN_RIGHT,
		STATES.MOVING_DIAG_DOWN_LEFT,
		],
		{
			STATES.MOVING_RIGHT : "rot right",
			STATES.MOVING_LEFT : "rot left",
			STATES.MOVING_UP : "rot up",
			STATES.MOVING_DOWN : "rot down",
			STATES.IDLE : "idle",
			STATES.MOVING_DIAG_UP_RIGHT: "diag up right",
			STATES.MOVING_DIAG_UP_LEFT : "diag up left",
			STATES.MOVING_DIAG_DOWN_RIGHT : "diag down right",
			STATES.MOVING_DIAG_DOWN_LEFT : "diag down left",
			
		})\
		.ignore_self_transitions() \
		.add_st_transition(STATES.MOVING_RIGHT, play_rot) \
		.add_st_transition(STATES.MOVING_LEFT, play_rot) \
		.add_st_transition(STATES.MOVING_UP, play_rot) \
		.add_st_transition(STATES.MOVING_DOWN, play_rot)\
		.add_st_transition_arr([STATES.MOVING_DIAG_UP_RIGHT,
		STATES.MOVING_DIAG_UP_LEFT,
		STATES.MOVING_DIAG_DOWN_RIGHT,
		STATES.MOVING_DIAG_DOWN_LEFT,], play_rot)\
		.add_st_transition(STATES.IDLE,
			func (last, _current) : 
				if state_to_animation.has(last):
					#print("playing backwards : ")
					$AnimationPlayer.play_backwards(state_to_animation[last])\
			)\
		.set_st_process_function(update_rotation)
	

func setup_movement_statemachine():
	self.movement_statemachine = StateMachine.new(STATES.IDLE, 
		[STATES.IDLE, STATES.ACCELERATING, STATES.DECELERATING, STATES.HYPERSPEED], {
			STATES.IDLE : "Idle",
			STATES.ACCELERATING : "Accelerating",
			STATES.DECELERATING : "Decelerating",
			STATES.HYPERSPEED : "Hyperspeed"
		}) \
		.set_process_function_for([STATES.IDLE, STATES.ACCELERATING,STATES.DECELERATING], update_movement) \
		#.add_st_transition(STATES.ACCELERATING, print.bind("Accel")) \
		#.add_st_transition(STATES.DECELERATING, print.bind("Decel")) \
		#When in hyperspeed start a timer ? 
		.add_st_transition(STATES.HYPERSPEED, func (_prev, _next) : movement_statemachine.switch_to(STATES.IDLE)) \
		.add_st_transition(STATES.IDLE, func (_prev, _next) : return ) \
		.add_st_transition(STATES.ACCELERATING, on_acceleration) \
		.add_st_transition(STATES.DECELERATING, on_deceleration) 
		#.show_debug()

	print(self.movement_statemachine.generate_transition_map())
	return




func on_acceleration(prev, _nxt):
	if prev == STATES.DECELERATING:
		speed = BASE_SPEED
	
	print("accellerating")
	if self.speed >= MAX_SPEED:
		self.movement_statemachine.switch_to(STATES.HYPERSPEED)
		print("hyperspeed")
		self.speed = BASE_SPEED
	self.speed += self.acceleration

func on_deceleration(_prev, _nxt):
	print("decellerating")
	if self.velocity.is_zero_approx():
		self.velocity = Vector3.ZERO
	self.speed = pow(self.speed, decel_rate)

	print(velocity.distance_to(Vector3.ZERO))





func update_movement(_delta):
	self.velocity = self.basis.x * speed

	if Input.is_action_just_pressed("acceleration"):
		self.movement_statemachine.switch_to(STATES.ACCELERATING)

	elif Input.is_action_pressed("deceleration"):
		self.movement_statemachine.switch_to(STATES.DECELERATING)
	
	self.move_and_slide()


func _ready() -> void:
	setup_rotation_statemachine()
	setup_movement_statemachine()

	for node in get_tree().get_nodes_in_group("Debug"):
		if node is PlayerDebug:
			node.connect_to_node(self)
	
	



func play_rot(_last, current):
	$AnimationPlayer.play(state_to_animation[current])

func set_carrying_id(id):
	self._carrying_id = id
func get_carrying_id():
	return self._carrying_id 


func _physics_process(delta: float) -> void:
	if self.rotation_statemachine:
		self.rotation_statemachine.use_process(delta)
	if self.movement_statemachine:
		self.movement_statemachine.use_process(delta)

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
		self.rotation_statemachine.switch_to(STATES.IDLE)



func move() -> void:
		
	self.velocity += self.basis.x * speed
	#self.rot_axis = Vector3(1, 0, 0)

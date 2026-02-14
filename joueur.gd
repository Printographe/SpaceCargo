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

	FIRST_GEAR,
	SECOND_GEAR,
	THIRD_GEAR,

}

#helper functions
static func sorted(list : Array) -> Array:
	list.sort()
	return list

func custom_rotate(up, right):
	self.basis = self.basis * Basis(Vector3.FORWARD, up*angle).orthonormalized()
	#self.basis = Basis.IDENTITY.rotated(Vector3(0, 1, 0), pos*angle).orthonormalized()
	self.basis = self.basis * Basis(Vector3.UP, right*angle).orthonormalized()
	

static func in_percent_range(value: float, test_value: float, percentage: float) -> bool :
	return   value >= test_value * (1-percentage) and value <= test_value * (1+percentage)



var rotation_statemachine : StateMachine
var movement_statemachine : StateMachine
var carry_statemachine : StateMachine


#maps
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



var gear_to_number : Dictionary =  {
	STATES.IDLE : 0,
	STATES.FIRST_GEAR : 1,
	STATES.SECOND_GEAR : 2,
	STATES.THIRD_GEAR : 3
}

var number_to_gear_map = {
	 0: STATES.IDLE        ,
	 1: STATES.FIRST_GEAR  ,
	 2: STATES.SECOND_GEAR ,
	 3: STATES.THIRD_GEAR  
}



func number_to_gear(n):
	if n > 3 or n < 0:
		return  null
	else:
		return  number_to_gear_map[n]




#Exports 
@export var BASE_ACCELERATION = 2;
@export var angle = TAU/100 ;
@export var MAX_ANGLE = TAU/12;


@export_category("The physics of it")
var speed : float = 0;
var current_max_speed : float = 0;
@export var acceleration : float = 5
@export var decel_rate : float = 5



@export var gear_to_max_speed = {
	0 : 0,
	1 : 50,
	2 : 100,
	3 : 150,
}

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
		[STATES.IDLE, STATES.HYPERSPEED, STATES.FIRST_GEAR, STATES.SECOND_GEAR, STATES.THIRD_GEAR], {
			STATES.IDLE : "Idle",
			STATES.HYPERSPEED : "Hyperspeed",
			STATES.FIRST_GEAR : "Gear I",
			STATES.SECOND_GEAR : "Gear II",
			STATES.THIRD_GEAR : "Gear III",
		}) \
		.add_transition(STATES.IDLE, STATES.FIRST_GEAR, set_acceleration)\
		.add_transition(STATES.FIRST_GEAR, STATES.SECOND_GEAR, set_acceleration)\
		.add_transition(STATES.SECOND_GEAR, STATES.THIRD_GEAR, set_acceleration)\
		## 
		.add_transition(STATES.THIRD_GEAR, STATES.SECOND_GEAR, set_deceleration)\
		.add_transition(STATES.SECOND_GEAR, STATES.FIRST_GEAR, set_deceleration)\
		.add_transition(STATES.FIRST_GEAR, STATES.IDLE, set_deceleration)\

		.set_process_function_for([STATES.IDLE, STATES.FIRST_GEAR, STATES.SECOND_GEAR, STATES.THIRD_GEAR], update_movement) \
		.show_debug()


	print(self.movement_statemachine.generate_transition_map())
	print(self.movement_statemachine.generate_process_map())
	return

func set_acceleration(_c, n):
	self.acceleration = BASE_ACCELERATION
	self.current_max_speed = gear_to_max_speed[gear_to_number[n]]

func set_deceleration(_c, n):
	self.acceleration = self.decel_rate
	self.current_max_speed = gear_to_max_speed[gear_to_number[n]]

func update_movement(delta):
	if self.speed < self.current_max_speed and acceleration > 0:
		self.speed += self.acceleration
	elif self.speed> self.current_max_speed and acceleration <0:
		self.speed += self.acceleration
	
	self.velocity = self.basis.x * speed * delta


	if Input.is_action_just_pressed("acceleration"):
		var current_gear_number = gear_to_number[self.movement_statemachine.get_state()]
		print("current gear : ",  current_gear_number)
		# condition 1 : If you've roughly reached the maximum speed for the current gear
		# condition 2 : Check whether you can go faster
		# condition 3 : Check that you're not decelerating
		print(in_percent_range(self.speed, self.current_max_speed, 0.05))
		print(current_gear_number < 3)
		print(self.acceleration >= 0)
		if in_percent_range(self.speed, self.current_max_speed, 0.05) and current_gear_number < 3 and self.acceleration >= 0 :
			self.movement_statemachine.switch_to(number_to_gear(current_gear_number+1))

	elif Input.is_action_pressed("deceleration"):
		var current_gear_number = gear_to_number[self.movement_statemachine.get_state()]
		if is_zero_approx(self.speed): return
		else : self.movement_statemachine.switch_to(number_to_gear(current_gear_number-1))


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

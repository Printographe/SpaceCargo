class_name FuelSystem
extends Node


signal RanOutOfFuel
signal currentFuel (float)

var player : PlayerController = null
var fuel_exhausted = false



@export var max_reserve : int = 100_000_000.00
@export var reserve : float = 100_000_000.00

@export var fuel_consumption_rate_per_speed = {
    PlayerController.STATES.NULL : 0,
    PlayerController.STATES.IDLE : 0,
    PlayerController.STATES.FIRST_GEAR : 1.5,
    PlayerController.STATES.SECOND_GEAR : 2.5,
    PlayerController.STATES.THIRD_GEAR : 4,
}

@export var on_accel_fuel_consumption = {
    PlayerController.STATES.NULL : 0,
    PlayerController.STATES.IDLE : 0,
    PlayerController.STATES.FIRST_GEAR : 1.5,
    PlayerController.STATES.SECOND_GEAR : 2.5,
    PlayerController.STATES.THIRD_GEAR : 4,
}

func _ready() -> void:
    player = get_parent()
    self.add_to_group("fuel_system")


var current_state = 0


func setState(_past, current):
    current_state = current
    reserve -= fuel_consumption_rate_per_speed[current_state]

func _process(dt):
    
    self.reserve = clampf(self.reserve-fuel_consumption_rate_per_speed[current_state]*dt, 0, max_reserve)

    self.currentFuel.emit(self.reserve)
    if reserve == 0 and not fuel_exhausted:
        RanOutOfFuel.emit()
        fuel_exhausted = true
    

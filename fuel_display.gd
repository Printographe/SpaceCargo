extends Control

#todo refactor everything else to have this syntax (it's way easier)
@onready var fuel_system : FuelSystem = get_tree().get_first_node_in_group("fuel_system")
@onready var progress_bar : ProgressBar = $"VBoxContainer/MarginContainer2/ProgressBar"
var max_amount  = null 

func _ready():
    if not fuel_system:
        push_error("Fuel display : fuel system not found")
        return
    max_amount = fuel_system.max_reserve
    fuel_system.currentFuel.connect(calculate_fuel_percent)
    progress_bar.set_value(1)
    progress_bar.set_max(1)
    progress_bar.set_min(0)

func calculate_fuel_percent(amount):
    var p = amount/max_amount
    progress_bar.set_value(p)

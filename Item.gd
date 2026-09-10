extends Resource
class_name Item


@export_category("intrinsics")
@export var item_id : int

@export_category("Behavior")
@export var timed : bool = false
@export var explodes_on_impact : bool = false

@export_category("Idle Behavior")
@export var pickable_on_pending : bool = false
@export var throw_intensity : float = 50

@export_category("Carry Behavior")
@export var drops_speed_when_carried : bool
@export var speed_drop : float
@export var prevents_gear : bool
@export var max_gear : bool
extends Mission

@onready var entry_area : Area3D = $Entry
@onready var animation_player : AnimationPlayer = $GarageScene/AnimationPlayer

@onready var red : MissionItem = $Red
@onready var blue : MissionItem = $Blue
@onready var camera : Camera3D = $GarageScene/Camera3D

func on_player_enters(body):
    if body is PlayerController : 
        body.lose_focus()
        camera.make_current()
        animation_player.play("GarageScene 1")

        animation_player.animation_finished.connect(func (_x) : 
            body.regain_focus() 
            entry_area.queue_free()
        )

        
        



func _ready() -> void:
    super._ready()
    entry_area.body_entered.connect(on_player_enters)
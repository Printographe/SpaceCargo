extends MeshInstance3D


@export var rotation_rate : float = 0.2
@export var rotation_direction : Vector3 = Vector3.UP


func _ready() -> void:
    self.rotation_direction = self.rotation_direction.normalized()

func _process(dt):
    self.rotate(rotation_direction, rotation_rate * dt)
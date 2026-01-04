extends ColorRect

@export_category("ProgressBar")
@export_range(0, 100, 1) var progress = 100


@export_category("Aesthetics or whatever")
@export var background_color: Color
@export var foreground_color1: Color
@export var foreground_color2: Color

@onready var hundred : float = $TextureRect.get_size().y

const INTERPOLATION_RATE = 1;


func _ready() -> void:
		
	self.color = background_color
	var new_texture = $TextureRect.texture.duplicate()
	
	var gradient : Gradient = new_texture.get_gradient().duplicate()
	
	
	var cnew = PackedColorArray()
	cnew.append(foreground_color1)
	cnew.append(foreground_color2)
	gradient.set_colors(cnew)
	
	new_texture.set_gradient(gradient)
	$TextureRect.set_texture(new_texture)
	
func set_progress(r):
	var px = $TextureRect.size.x;
	var py = $TextureRect.size.y;
	var tween = get_tree().create_tween()
	tween.tween_property($TextureRect,  "size",
	 Vector2(px, r*hundred),  abs(py/hundred-r)*INTERPOLATION_RATE )

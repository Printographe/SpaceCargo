extends CanvasLayer


func _ready() -> void:
	$MainMenue/DemoButton.pressed.connect(func () : 
		get_tree().change_scene_to_file("res://test.tscn"))
	$MainMenue/SettingsButton.pressed.connect(func() :
		$Settings.show()
		$MainMenue.hide()
		)
	$AnimationPlayer.play("main_menu")

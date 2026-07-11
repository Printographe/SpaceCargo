extends CanvasLayer


var loaded_scene = preload("res://test.tscn")


func _ready() -> void:
    $MainMenue/DemoButton.pressed.connect(load_test_scene_data.bind(loaded_scene))
    $MainMenue/SettingsButton.pressed.connect(func() :
        $Settings.show()
        $MainMenue.hide()
        )
    $AnimationPlayer.play("main_menu")


func load_test_scene_data(scene):
    get_tree().change_scene_to_packed(scene)

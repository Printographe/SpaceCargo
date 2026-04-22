extends Control
class_name ContentDisplay




signal nextItem

@onready var title_label =  $VBoxContainer/MarginContainer3/Title
@onready var content_label = $VBoxContainer/MarginContainer2/Content
@onready var button = $VBoxContainer/MarginContainer/Button


func display(content)  :
    self.show()
    self.title_label.set_text(content.title)
    self.content_label.set_text(content.text)
    button.grab_focus()


func _ready() -> void:
    button.pressed.connect(func() : 
        self.hide()
        nextItem.emit()
        )
    self.hide()
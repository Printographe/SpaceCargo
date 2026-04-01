class_name Interaction

enum KEYS {
    A,
    E, 
    X,
    C
}
var key : int
var label : String
var emitor : Variant
var callback : Callable
var priority : int 

func _init(key : int, label : String, emitor : Variant, fn : Callable, prio = 1) -> void:
    self.key = key
    self.label = label
    self.emitor = emitor
    self.callback = fn
    self.priority = 1


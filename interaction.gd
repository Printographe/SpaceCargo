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
var _callback : Callable
var priority : int 

func _init(key : int, label : String, emitor : Variant, fn : Callable, prio = 1) -> void:
    self.key = key
    self.label = label
    self.emitor = emitor
    self._callback = fn
    self.priority = 1

func play():
    self._callback.call()

func is_valid():
    #Can't outlive the emitor
    return is_instance_valid(self.emitor)

func clean():
    if !self.is_valid():
        self.free()

func force_clean():
    self.clean()

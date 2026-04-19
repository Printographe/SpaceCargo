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
var persistent : bool = false
var delete_on_play : bool = false


func _init(interaction_key : int, display_label : String, emitor_entity : Variant, callback : Callable, prio = 1) -> void:
    self.key = interaction_key
    self.label = display_label
    self.emitor = emitor_entity
    self._callback = callback
    self.priority = prio
    self.persistent = false;

func set_priority(p : int) -> Interaction:
    self.priority = p
    return self


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

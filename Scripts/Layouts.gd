extends Node3D

@onready var options = $Options

func _ready():
    var randomLayout = options.get_child(randi_range(0, options.get_child_count() - 1))
    randomLayout.reparent(self)
    randomLayout.show()

    for option in options.get_children():
        option.queue_free()

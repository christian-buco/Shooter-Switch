extends Node2D

var active: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		visible = true
		global_position = get_global_mouse_position()
	else:
		visible = false

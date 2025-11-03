extends Node2D

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#position = get_global_mouse_position()
func _process(delta: float) -> void:
	position = get_global_mouse_position()

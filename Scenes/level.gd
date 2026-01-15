class_name Level extends Node2D

var layers:Dictionary[int,LevelLayer]
func _ready() -> void:
	for i in get_children():
		if i is LevelLayer:
			layers[i.index] = i 
	print(layers)

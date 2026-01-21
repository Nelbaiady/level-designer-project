class_name PropertiesHandler extends Node

var isBeingEdited:bool = false
var parent: Level
@export var properties: Array[ObjectProperty] = [
	preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]

func _ready() -> void:
	parent = get_parent()
	parent.propertiesHandler = self
func setNotEditing():
	isBeingEdited = false
	

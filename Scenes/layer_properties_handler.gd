class_name LayerPropertiesHandler extends Node

var isBeingEdited:bool = false
var rootNode: Level
@export var properties: Array[ObjectProperty] = [
	preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]

func _ready() -> void:
	rootNode = get_parent()
	rootNode.layerPropertiesHandler = self
func setNotEditing():
	isBeingEdited = false
	

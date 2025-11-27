extends Node2D
@export var objectResource: objectItem
var objectReference: PackedScene
var categories = objectResource.categories
var category: objectItem.categories
var rootNode:Node 
var properties:Dictionary = {}
func _ready() -> void:

	objectReference= objectResource.objectReference
	categories = objectResource.categories
	category = objectResource.category 
	
	rootNode= get_parent()
	properties["position"] = rootNode.get("position")
	
func _physics_process(_delta: float) -> void:
	#rootNode
	rootNode.set("modulate",Color(18.892, 18.892, 18.892, 1.0))
	
	#properties.set("position")
	pass

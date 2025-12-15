extends Node
var isBeingEdited:bool = false
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]
@onready var clickCollision: Area2D = $"../Area2D"
@onready var rootNode: CharacterBody2D = $".."

func _ready() -> void:
	clickCollision.input_event.connect(clickedOn)

func clickedOn(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickRight"):
		summonPropertiesUI()
		signalBus.editingObject.emit("Player",0)

func getProperty(property:String):
	return rootNode.get(property)

func setProperty(property:String, value):
	rootNode.set(property, value )
	globalEditor.playerProperties[property] = value
	print(globalEditor.playerProperties)
	#objectsHash[ instanceID ]["properties"][property] = value

func summonPropertiesUI():
	populatePropertiesUI()

func populatePropertiesUI():
	pass
	globalEditor.showPropertiesSidebar.emit()
#	Empty the UI first
	for i in globalEditor.propertiesUI.get_children():
		i.queue_free()
#	tell the editor to focus on this object
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = self
	isBeingEdited = true
#	populate the properties editor
	for i in properties:
		var newNode = i.uiNode.instantiate()
		globalEditor.propertiesUI.add_child(newNode)
		newNode.label.text = i.displayName
		newNode.propertyName = i.codeName
		newNode.value = getProperty(i.codeName)
		newNode.updateValue()
	signalBus.updateProperty.connect(setProperty)
